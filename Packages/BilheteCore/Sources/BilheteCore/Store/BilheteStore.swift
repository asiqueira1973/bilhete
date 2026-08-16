import Foundation
import SwiftData

/// Ponto único de escrita do Bilhete (spec 13.1).
///
/// **Nenhuma view escreve no `ModelContext` diretamente.** As invariantes das
/// regras 11.1, 11.3, 11.4 e 11.6 são transacionais e precisam de um só dono:
/// se duas telas puderem mudar `estado`, mais cedo ou mais tarde existem dois
/// bilhetes em destaque, ou uma Live Activity órfã apontando para um bilhete
/// arquivado.
///
/// Convenção de idioma (spec 18.1): a API é em inglês, o que ela grava é em
/// português. `archive(_:)` grava `bilhete.arquivadoEm`.
///
/// É `@Observable` só para poder ser injetado no ambiente da SwiftUI; o estado
/// observável de verdade é o do SwiftData, que as views leem por `@Query`.
@MainActor
@Observable
public final class BilheteStore {

    // MARK: - Números da seção 11
    //
    // Nenhum destes valores é inferido: todos vêm da tabela de regras de
    // negócio do spec, e é aqui que eles moram.

    /// Bilhetes ativos no plano grátis — destaque + guardados (regra 11.3).
    /// Arquivados não contam (assunção A-3).
    public static let activeLimitFree = 3

    /// Tamanho do arquivo no plano grátis (regra 11.4).
    public static let archiveLimitFree = 10

    /// Tamanho máximo do texto de um bilhete (regra 11.2).
    public static let textLimit = 280

    /// A partir daqui o contador de caracteres aparece na tela (regra 11.2).
    public static let counterThreshold = 240

    /// Duração da fixação: `fixadoAte = agora + 8h` (regra 11.8). Não é
    /// configurável — é o limite ativo do sistema (L1), não escolha de produto.
    public static let pinDuration: TimeInterval = 8 * 60 * 60

    /// Antecedência do aviso de expiração (regra 11.7).
    public static let expiryWarningLead: TimeInterval = 30 * 60

    /// Debounce de gravação do editor (regra 11.17).
    public static let saveDebounce: TimeInterval = 1

    // MARK: - Dependências

    private let context: ModelContext
    private let dates: DateSource
    private let entitlement: EntitlementProviding
    private let pin: PinCoordinating
    private let widgets: WidgetReloading

    /// Monta o store.
    ///
    /// - Parameters:
    ///   - context: o `ModelContext` do container compartilhado (spec 4.5).
    ///   - dates: fonte de "agora"; injetável porque a seção 22 proíbe `Date()`
    ///     em código testável.
    ///   - entitlement: quem responde se o Pro está ativo (matriz da seção 5).
    ///   - pin: quem sabe encerrar e atualizar a Live Activity (spec 13.2).
    ///   - widgets: quem recarrega as timelines (regra 11.18).
    public init(
        context: ModelContext,
        dates: DateSource = SystemDateSource(),
        entitlement: EntitlementProviding = CachedEntitlementProvider(),
        pin: PinCoordinating = NoopPinCoordinator(),
        widgets: WidgetReloading = WidgetCenterReloader()
    ) {
        self.context = context
        self.dates = dates
        self.entitlement = entitlement
        self.pin = pin
        self.widgets = widgets
    }

    // MARK: - Leitura
    //
    // As consultas filtram em memória em vez de usar `#Predicate` com enum. O
    // spec desenha o app para até 500 bilhetes (seção 17), então o custo é
    // irrelevante, e assim o comportamento não depende de como o SwiftData
    // resolve comparação de enum dentro de predicado.

    /// Todos os bilhetes do store, sem ordem garantida.
    /// - Returns: a lista completa; `[]` se o fetch falhar, porque leitura
    ///   quebrada nunca pode derrubar a tela.
    public func allNotes() -> [Bilhete] {
        (try? context.fetch(FetchDescriptor<Bilhete>())) ?? []
    }

    /// O bilhete em destaque, se existir (regra 11.1).
    /// - Returns: o único `emDestaque`, ou `nil` no instante entre transições.
    public func featured() -> Bilhete? {
        allNotes().first { $0.estado == .emDestaque }
    }

    /// A pilha de guardados, de cima para baixo (regra 11.5).
    /// - Returns: os `guardado` ordenados por `ordemPilha` crescente.
    public func stack() -> [Bilhete] {
        allNotes()
            .filter { $0.estado == .guardado }
            .sorted { $0.ordemPilha < $1.ordemPilha }
    }

    /// O arquivo, do mais recente para o mais antigo (tela 10.3).
    /// - Returns: os `arquivado` ordenados por `arquivadoEm` decrescente.
    public func archived() -> [Bilhete] {
        allNotes()
            .filter { $0.estado == .arquivado }
            .sorted { ($0.arquivadoEm ?? .distantPast) > ($1.arquivadoEm ?? .distantPast) }
    }

    /// Quantos bilhetes contam para o limite do plano grátis (regra 11.3).
    /// - Returns: destaque + guardados. Arquivados não entram.
    public func activeCount() -> Int {
        allNotes().count { $0.estado.contaComoAtivo }
    }

    /// Diz qual bilhete seria apagado se mais um fosse arquivado agora.
    ///
    /// - Returns: o texto do bilhete mais antigo do arquivo quando arquivar
    ///   mais um exigiria poda; `nil` quando há espaço ou quando o Pro está
    ///   ativo.
    ///
    /// É consulta pura, sem efeito colateral: existe para a UI montar o aviso
    /// nominal de 15.4 **antes** de tocar a animação de encerramento, sem
    /// precisar saber o número 10 nem como se escolhe o mais antigo — isso é da
    /// regra 11.4 e mora aqui.
    public func pruneVictimText() -> String? {
        guard !entitlement.isPro else { return nil }
        let arquivo = archived()
        guard arquivo.count >= Self.archiveLimitFree else { return nil }
        return arquivo.last?.texto
    }

    /// Diz se já existe algum bilhete com texto.
    ///
    /// - Returns: `true` se qualquer bilhete tem texto não vazio.
    ///
    /// É metade da condição da regra 11.10: o paywall nunca aparece antes de a
    /// pessoa ter criado um bilhete com texto **e** fixado ao menos uma vez.
    public func hasNoteWithText() -> Bool {
        allNotes().contains { !$0.texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    // MARK: - Escrita

    /// Garante que existe exatamente um bilhete em destaque.
    ///
    /// - Parameter origem: a superfície que provocou a criação, quando for
    ///   preciso criar (spec 7.6).
    /// - Returns: o bilhete em destaque — o que já existia, o promovido da
    ///   pilha, ou um novo em branco.
    /// - Throws: erro de gravação do SwiftData.
    ///
    /// Implementa a regra 11.1 e o critério de aceite 8.1.6: abrir o app com a
    /// pilha vazia e sem destaque cria um bilhete novo, sem pedir confirmação.
    @discardableResult
    public func ensureFeatured(origem: OrigemBilhete = .app) throws -> Bilhete {
        if let atual = featured() { return atual }

        // Sem destaque mas com pilha: o primeiro da pilha assume, em vez de
        // criar um bilhete em branco que empurraria o resto para baixo (11.16).
        if let proximo = stack().first {
            proximo.estado = .emDestaque
            proximo.atualizadoEm = dates.now
            try context.save()
            widgets.reloadAll()
            return proximo
        }

        let novo = try makeBlankFeatured(origem: origem)
        try context.save()
        widgets.reloadAll()
        return novo
    }

    /// Traz para o destaque o bilhete que a pessoa tocou na tela de bloqueio.
    ///
    /// - Parameter id: o identificador vindo do deep link da Live Activity.
    ///
    /// Implementa o critério de aceite 8.4.6. Três casos, e os três importam:
    /// se já é o destaque, não faz nada; se está guardado, promove; se foi
    /// arquivado, **não ressuscita** — encerrar é deliberado (P4), e trazer de
    /// volta sozinho desfaria uma decisão da pessoa.
    public func focus(noteWithID id: UUID) {
        guard let bilhete = allNotes().first(where: { $0.id == id }) else { return }
        if bilhete.estado == .guardado {
            try? promoteToFeatured(bilhete)
        }
    }

    /// Cria um bilhete.
    ///
    /// - Parameters:
    ///   - texto: o conteúdo; no máximo 280 caracteres (regra 11.2).
    ///   - origem: por onde veio (spec 7.6) — alimenta a contagem local da
    ///     seção 21 e nunca sai do aparelho.
    /// - Returns: o bilhete criado, em destaque se não havia nenhum, guardado no
    ///   topo da pilha caso contrário (transições da seção 12).
    /// - Throws: `limitReached` quando o plano grátis já tem 3 ativos
    ///   (regra 11.3); `textTooLong` acima de 280 caracteres.
    ///
    /// Aplica também a regra 11.13: confere se o `id` sorteado já existe e
    /// sorteia outro se existir, porque `@Attribute(.unique)` não é usado.
    @discardableResult
    public func create(texto: String, origem: OrigemBilhete = .app) throws -> Bilhete {
        try validate(texto: texto)
        try enforceActiveLimit()

        let temDestaque = featured() != nil
        let bilhete = Bilhete(
            id: uniqueID(),
            texto: texto,
            estado: temDestaque ? .guardado : .emDestaque,
            ordemPilha: temDestaque ? topOfStackOrder() : 0,
            criadoEm: dates.now,
            atualizadoEm: dates.now,
            origem: origem
        )
        context.insert(bilhete)
        try context.save()

        // Só recarrega quando o que apareceu nas superfícies mudou (regra 11.18).
        if bilhete.estado == .emDestaque { widgets.reloadAll() }
        return bilhete
    }

    /// Grava o texto de um bilhete.
    ///
    /// - Parameters:
    ///   - bilhete: o bilhete a alterar.
    ///   - texto: o novo conteúdo, no máximo 280 caracteres (regra 11.2).
    /// - Throws: `textTooLong` acima do limite; erro de gravação do SwiftData —
    ///   quem chama mostra a copy 15.5 e **nunca** descarta o que foi escrito.
    ///
    /// O debounce de 1 segundo (regra 11.17) é do editor, não daqui: este método
    /// grava na hora em que é chamado. Atualiza a Live Activity em curso sem
    /// recriá-la (critério 8.4.3) e recarrega os widgets (regra 11.18).
    public func save(_ bilhete: Bilhete, texto: String) throws {
        try validate(texto: texto)
        // Digitar e apagar de volta não deve mexer em `atualizadoEm`, que é o
        // que ordena o arquivo.
        guard bilhete.texto != texto else { return }

        bilhete.texto = texto
        bilhete.atualizadoEm = dates.now
        try context.save()

        if bilhete.estado == .emDestaque {
            pin.atualizar(bilhete)
            widgets.reloadAll()
        }
    }

    /// Guarda o bilhete em destaque e abre um novo em branco no lugar dele.
    ///
    /// - Parameter bilhete: o bilhete em destaque.
    /// - Returns: o novo bilhete em destaque, vazio (critério de aceite 8.2.1).
    /// - Throws: `forbiddenTransition` se o bilhete não estiver em destaque;
    ///   `limitReached` quando o plano grátis já tem 3 ativos e o novo destaque
    ///   seria o quarto (regra 11.3, critério 8.2.5).
    ///
    /// Encerra a Live Activity antes de mudar o estado (regra 11.6) e insere no
    /// topo da pilha, `min − 1` (regra 11.5).
    @discardableResult
    public func stash(_ bilhete: Bilhete) throws -> Bilhete {
        guard bilhete.estado == .emDestaque else {
            throw BilheteStoreError.forbiddenTransition(from: bilhete.estado, to: .guardado)
        }
        // O bilhete guardado continua ativo, então guardar sempre soma um ao
        // total. Com 3 ativos sem Pro, isso é o quarto: o paywall abre e nada
        // muda (critério 8.2.5).
        try enforceActiveLimit()

        pin.soltar(bilhete)
        bilhete.estado = .guardado
        bilhete.ordemPilha = topOfStackOrder()
        bilhete.atualizadoEm = dates.now

        let novo = try makeBlankFeatured(origem: .app)
        try context.save()
        widgets.reloadAll()
        return novo
    }

    /// Promove um guardado a destaque, rebaixando o atual.
    ///
    /// - Parameter bilhete: um bilhete `guardado`.
    /// - Throws: `forbiddenTransition` para qualquer outro estado — em especial
    ///   `arquivado → emDestaque`, que a seção 12 proíbe: restaurar sempre passa
    ///   por `guardado`, e promover é um segundo ato deliberado (P4).
    ///
    /// Troca os dois estados numa gravação só, de modo que em nenhum instante
    /// persistido existem dois `emDestaque` (regra 11.1, critério 8.2.2), e
    /// encerra a Live Activity do que está saindo (regra 11.6, critério 8.2.3).
    public func promoteToFeatured(_ bilhete: Bilhete) throws {
        guard bilhete.estado == .guardado else {
            throw BilheteStoreError.forbiddenTransition(from: bilhete.estado, to: .emDestaque)
        }

        if let atual = featured() {
            pin.soltar(atual)
            atual.estado = .guardado
            atual.ordemPilha = topOfStackOrder()
            atual.atualizadoEm = dates.now
        }

        bilhete.estado = .emDestaque
        bilhete.atualizadoEm = dates.now
        try context.save()
        widgets.reloadAll()
    }

    /// Reordena a pilha de guardados.
    ///
    /// - Parameters:
    ///   - source: os índices arrastados, na ordem exibida.
    ///   - destination: o índice de destino, na convenção do `onMove` da
    ///     SwiftUI.
    /// - Throws: erro de gravação do SwiftData.
    ///
    /// Implementa a regra 11.5: reordenar reescreve a sequência inteira a partir
    /// de 0, em vez de tentar encaixar valores no meio — assim a ordem sobrevive
    /// a fechar e reabrir o app (critério 8.2.4).
    public func reorder(from source: IndexSet, to destination: Int) throws {
        var pilha = stack()
        pilha.move(fromOffsets: source, toOffset: destination)
        for (indice, bilhete) in pilha.enumerated() {
            bilhete.ordemPilha = indice
        }
        try context.save()
    }

    /// Arquiva um bilhete.
    ///
    /// - Parameters:
    ///   - bilhete: o bilhete a arquivar; precisa estar em destaque ou guardado.
    ///   - confirmingPrune: `true` quando a pessoa já viu o aviso 15.4 e
    ///     confirmou que o mais antigo pode ser apagado.
    /// - Throws: `forbiddenTransition` se já estiver arquivado;
    ///   `pruneRequired` quando o arquivo do plano grátis está cheio e falta a
    ///   confirmação (regra 11.4).
    ///
    /// Encerra a Live Activity e cancela o aviso **antes** de gravar o novo
    /// estado (regras 11.6 e 11.7, critério 8.3.3) — uma atividade órfã deixaria
    /// o texto na tela de bloqueio sem dono. Depois promove o próximo da pilha,
    /// ou cria um bilhete em branco se a pilha estiver vazia (regra 11.16).
    public func archive(_ bilhete: Bilhete, confirmingPrune: Bool = false) throws {
        guard bilhete.estado != .arquivado else {
            throw BilheteStoreError.forbiddenTransition(from: .arquivado, to: .arquivado)
        }

        let arquivo = archived()
        let precisaPodar = !entitlement.isPro && arquivo.count >= Self.archiveLimitFree
        if precisaPodar && !confirmingPrune {
            // Não é falha: é o pedido de confirmação da copy 15.4, com o texto
            // do bilhete que seria apagado, para o aviso ser nominal (risco R-8).
            let maisAntigo = arquivo.last
            throw BilheteStoreError.pruneRequired(
                limit: Self.archiveLimitFree,
                oldestText: maisAntigo?.texto ?? ""
            )
        }

        pin.soltar(bilhete)

        let eraDestaque = bilhete.estado == .emDestaque
        bilhete.estado = .arquivado
        bilhete.arquivadoEm = dates.now
        bilhete.atualizadoEm = dates.now

        if precisaPodar, let maisAntigo = arquivo.last {
            // Poda do plano grátis: hard delete do mais antigo por
            // `arquivadoEm` (regra 11.4). A pessoa já confirmou.
            context.delete(maisAntigo)
        }

        if eraDestaque { try succeedFeatured() }

        try context.save()
        widgets.reloadAll()
    }

    /// Restaura um bilhete arquivado.
    ///
    /// - Parameter bilhete: um bilhete `arquivado`.
    /// - Throws: `forbiddenTransition` se não estiver arquivado; `limitReached`
    ///   quando devolvê-lo passaria de 3 ativos sem Pro (regra 11.3,
    ///   critério 8.3.4) — e nesse caso **nada** muda.
    ///
    /// Volta como `guardado` no topo da pilha, com `arquivadoEm = nil`. Nunca
    /// volta direto a destaque: essa transição é proibida na seção 12.
    public func restore(_ bilhete: Bilhete) throws {
        guard bilhete.estado == .arquivado else {
            throw BilheteStoreError.forbiddenTransition(from: bilhete.estado, to: .guardado)
        }
        try enforceActiveLimit()

        bilhete.estado = .guardado
        bilhete.arquivadoEm = nil
        bilhete.ordemPilha = topOfStackOrder()
        bilhete.atualizadoEm = dates.now
        try context.save()
    }

    /// Exclui um bilhete em definitivo (hard delete).
    ///
    /// - Parameter bilhete: qualquer bilhete, em qualquer estado.
    /// - Throws: erro de gravação do SwiftData.
    ///
    /// Encerra a Live Activity e cancela o aviso antes de apagar (regras 11.6 e
    /// 11.7). Se o excluído era o destaque, promove o próximo da pilha ou cria
    /// um em branco, porque a regra 11.1 exige que sempre exista um destaque.
    /// É irreversível e a UI confirma antes (copy 15.19).
    public func delete(_ bilhete: Bilhete) throws {
        pin.soltar(bilhete)
        let eraDestaque = bilhete.estado == .emDestaque

        context.delete(bilhete)
        if eraDestaque { try succeedFeatured() }

        try context.save()
        if eraDestaque { widgets.reloadAll() }
    }

    /// Apaga todo o arquivo em definitivo.
    ///
    /// - Throws: erro de gravação do SwiftData.
    ///
    /// É o "Apagar tudo" da tela 10.3, irreversível e com confirmação
    /// destrutiva na UI (critério 8.3.6). Serve também ao direito de exclusão
    /// da LGPD (spec 20).
    public func deleteAllArchived() throws {
        for bilhete in archived() {
            context.delete(bilhete)
        }
        try context.save()
    }

    // MARK: - Invariantes

    /// Confere as invariantes do modelo (spec 22).
    ///
    /// - Returns: a lista de violações encontradas, vazia quando está tudo certo.
    ///
    /// Existe para os testes rodarem esta conferência depois de **toda**
    /// operação, em vez de cada teste reescrever as mesmas quatro perguntas.
    /// A quarta invariante (nenhum `Array`/`Set` em `@Model`) não cabe aqui:
    /// ela é conferida por reflexão em `ModelInvariantsTests` e pela build phase
    /// `check-no-model-collections.sh`, que derruba o build.
    public func invariantViolations() -> [String] {
        var problemas: [String] = []
        let todos = allNotes()

        let destaques = todos.count { $0.estado == .emDestaque }
        if destaques > 1 {
            problemas.append("Invariante 22.1: \(destaques) bilhetes em destaque ao mesmo tempo (regra 11.1).")
        }

        for bilhete in todos where bilhete.estado != .emDestaque {
            if bilhete.fixadoAte != nil {
                problemas.append("Invariante 22.2: fixadoAte não-nulo com estado \(bilhete.estado.rawValue).")
            }
            if bilhete.idAtividade != nil {
                problemas.append("Invariante 22.2: idAtividade não-nulo com estado \(bilhete.estado.rawValue).")
            }
        }

        for bilhete in todos {
            let arquivado = bilhete.estado == .arquivado
            let temData = bilhete.arquivadoEm != nil
            if arquivado != temData {
                problemas.append("Invariante 22.3: arquivadoEm=\(temData ? "preenchido" : "nulo") com estado \(bilhete.estado.rawValue).")
            }
        }

        return problemas
    }

    // MARK: - Apoio interno

    /// Valida o tamanho do texto (regra 11.2).
    /// - Parameter texto: o conteúdo proposto.
    /// - Throws: `textTooLong` acima de 280 caracteres.
    private func validate(texto: String) throws {
        guard texto.count <= Self.textLimit else {
            throw BilheteStoreError.textTooLong(limit: Self.textLimit)
        }
    }

    /// Barra a criação de mais um ativo no plano grátis (regra 11.3).
    /// - Throws: `limitReached` quando já há 3 ativos e o Pro não está ativo.
    private func enforceActiveLimit() throws {
        guard !entitlement.isPro else { return }
        guard activeCount() < Self.activeLimitFree else {
            throw BilheteStoreError.limitReached(limit: Self.activeLimitFree)
        }
    }

    /// Calcula a posição do topo da pilha (regra 11.5).
    /// - Returns: `min − 1` entre os guardados, ou 0 se a pilha estiver vazia.
    private func topOfStackOrder() -> Int {
        (stack().map(\.ordemPilha).min() ?? 1) - 1
    }

    /// Sorteia um `id` que ainda não existe no store (regra 11.13).
    ///
    /// - Returns: um `UUID` livre.
    ///
    /// Colisão de UUID v4 é praticamente impossível, mas como
    /// `@Attribute(.unique)` não é usado, a conferência é feita aqui — é barata
    /// e é o que a regra pede.
    private func uniqueID() -> UUID {
        let existentes = Set(allNotes().map(\.id))
        var novo = UUID()
        while existentes.contains(novo) { novo = UUID() }
        return novo
    }

    /// Cria um bilhete em branco já em destaque, **sem** conferir o limite.
    ///
    /// - Parameter origem: por onde veio a criação (spec 7.6).
    /// - Returns: o bilhete novo, já inserido no contexto.
    ///
    /// O limite não vale aqui de propósito: este caminho só é usado quando o
    /// app precisa repor o destaque depois de guardar, arquivar ou excluir. A
    /// regra 11.1 ("sempre exatamente um em destaque") vence a 11.3 nesse
    /// instante — deixar a pessoa sem destaque nenhum quebraria o app inteiro,
    /// inclusive os widgets.
    private func makeBlankFeatured(origem: OrigemBilhete) throws -> Bilhete {
        let bilhete = Bilhete(
            id: uniqueID(),
            texto: "",
            estado: .emDestaque,
            ordemPilha: 0,
            criadoEm: dates.now,
            atualizadoEm: dates.now,
            origem: origem
        )
        context.insert(bilhete)
        return bilhete
    }

    /// Repõe o destaque depois de o anterior sair de cena (regra 11.16).
    ///
    /// Promove o primeiro da pilha — o de `ordemPilha` menor — e, se a pilha
    /// estiver vazia, cria um bilhete em branco. Não grava: quem chama é que
    /// fecha a transação, para arquivar e promover acontecerem juntos.
    private func succeedFeatured() throws {
        if let proximo = stack().first {
            proximo.estado = .emDestaque
            proximo.atualizadoEm = dates.now
        } else {
            _ = try makeBlankFeatured(origem: .app)
        }
    }
}
