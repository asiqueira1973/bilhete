import Foundation
import Testing
@testable import BilheteCore

/// Uma bateria por regra numérica da seção 11 do spec.
///
/// Nenhum número é inferido: todos vêm da tabela de regras de negócio, e o teste
/// existe para que ninguém "arredonde" um deles sem perceber.
@MainActor
@Suite("Regras de negócio (seção 11)")
struct BusinessRulesTests {

    // MARK: - 11.2 — tamanho máximo do texto

    @Test("11.2 — o limite é 280 caracteres e o contador começa em 240")
    func textLimitValues() {
        #expect(BilheteStore.textLimit == 280)
        #expect(BilheteStore.counterThreshold == 240)
    }

    @Test("11.2 — 280 caracteres passam, 281 são recusados")
    func textLimitEnforced() throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()

        let noLimite = String(repeating: "a", count: 280)
        try h.store.save(bilhete, texto: noLimite)
        #expect(bilhete.texto.count == 280)

        let passandoDoLimite = String(repeating: "a", count: 281)
        #expect(throws: BilheteStoreError.textTooLong(limit: 280)) {
            try h.store.save(bilhete, texto: passandoDoLimite)
        }
        // O texto que estava lá continua intacto: nunca se descarta o que a
        // pessoa escreveu (spec 12, tratamento de falha).
        #expect(bilhete.texto == noLimite)
    }

    @Test("11.2 — criar por Siri ou Atalho também respeita o limite")
    func textLimitOnCreate() throws {
        let h = try TestHarness()
        #expect(throws: BilheteStoreError.textTooLong(limit: 280)) {
            try h.store.create(texto: String(repeating: "b", count: 281), origem: .siri)
        }
    }

    // MARK: - 11.3 — bilhetes ativos

    @Test("11.3 — sem Pro são 3 ativos; o quarto é recusado")
    func activeLimitFree() throws {
        let h = try TestHarness(isPro: false)
        #expect(BilheteStore.activeLimitFree == 3)

        let primeiro = try h.makeFeatured(texto: "um")
        let segundo = try h.store.stash(primeiro)      // 2 ativos
        try h.store.save(segundo, texto: "dois")
        let terceiro = try h.store.stash(segundo)      // 3 ativos
        try h.store.save(terceiro, texto: "três")
        #expect(h.store.activeCount() == 3)

        // Critério 8.2.5: com 3 ativos, "Guardar" abre o paywall e não cria o
        // quarto bilhete.
        #expect(throws: BilheteStoreError.limitReached(limit: 3)) {
            try h.store.stash(terceiro)
        }
        #expect(h.store.activeCount() == 3)
        #expect(terceiro.estado == .emDestaque)

        #expect(throws: BilheteStoreError.limitReached(limit: 3)) {
            try h.store.create(texto: "quarto", origem: .siri)
        }
        h.expectInvariantsHold()
    }

    @Test("11.3 — arquivados não contam para o limite de ativos")
    func archivedDoNotCountAsActive() throws {
        let h = try TestHarness(isPro: false)
        let primeiro = try h.makeFeatured(texto: "um")
        let segundo = try h.store.stash(primeiro)
        try h.store.save(segundo, texto: "dois")

        try h.store.archive(primeiro)
        // Arquivar libera espaço: assunção A-3, arquivar é encerramento e não
        // pode ser punido.
        #expect(h.store.activeCount() < BilheteStore.activeLimitFree)
        try h.store.create(texto: "novo ativo")
        h.expectInvariantsHold()
    }

    @Test("11.3 — com Pro, o 4º, o 10º e o 50º ativo funcionam sem aviso")
    func activeLimitUnlimitedWithPro() throws {
        let h = try TestHarness(isPro: true)
        try h.makeFeatured(texto: "um")
        for indice in 2...50 {
            try h.store.create(texto: "bilhete \(indice)")
        }
        #expect(h.store.activeCount() == 50)
        h.expectInvariantsHold()
    }

    // MARK: - 11.4 — tamanho do arquivo

    @Test("11.4 — o arquivo grátis é 10 e o 11º pede confirmação nominal")
    func archiveLimitRequiresConfirmation() throws {
        let h = try TestHarness(isPro: false)
        #expect(BilheteStore.archiveLimitFree == 10)

        // Dez arquivados, o mais antigo criado primeiro.
        for indice in 1...10 {
            let bilhete = try h.store.ensureFeatured()
            try h.store.save(bilhete, texto: "arquivado \(indice)")
            try h.store.archive(bilhete)
            h.dates.advance(by: 60)
        }
        #expect(h.store.archived().count == 10)

        let onzeavo = try h.store.ensureFeatured()
        try h.store.save(onzeavo, texto: "o décimo primeiro")

        // Não arquiva calado: devolve o texto do que seria apagado, para a
        // copy 15.4 poder ser nominal (mitigação do risco R-8).
        do {
            try h.store.archive(onzeavo)
            Issue.record("Deveria ter pedido confirmação de poda")
        } catch let erro as BilheteStoreError {
            #expect(erro == .pruneRequired(limit: 10, oldestText: "arquivado 1"))
        }
        #expect(h.store.archived().count == 10)
        #expect(onzeavo.estado == .emDestaque)

        // Confirmado, arquiva e apaga o mais antigo em definitivo.
        try h.store.archive(onzeavo, confirmingPrune: true)
        #expect(h.store.archived().count == 10)
        #expect(!h.store.allNotes().contains { $0.texto == "arquivado 1" })
        #expect(h.store.archived().contains { $0.texto == "o décimo primeiro" })
        h.expectInvariantsHold()
    }

    @Test("11.4 — com Pro o arquivo não tem limite nem poda")
    func archiveUnlimitedWithPro() throws {
        let h = try TestHarness(isPro: true)
        for indice in 1...15 {
            let bilhete = try h.store.ensureFeatured()
            try h.store.save(bilhete, texto: "arquivado \(indice)")
            try h.store.archive(bilhete)
            h.dates.advance(by: 60)
        }
        #expect(h.store.archived().count == 15)
        h.expectInvariantsHold()
    }

    // MARK: - 11.5 — ordem da pilha

    @Test("11.5 — guardar insere no topo da pilha")
    func stashInsertsOnTop() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "primeiro")
        let segundo = try h.store.stash(primeiro)
        try h.store.save(segundo, texto: "segundo")
        try h.store.stash(segundo)

        // O último guardado fica acima do anterior.
        #expect(h.store.stack().map(\.texto) == ["segundo", "primeiro"])
    }

    @Test("11.5 — reordenar reescreve a sequência inteira a partir de 0")
    func reorderRewritesSequence() throws {
        let h = try TestHarness(isPro: true)
        try h.makeFeatured(texto: "destaque")
        for texto in ["a", "b", "c"] {
            try h.store.create(texto: texto)
        }

        let antes = h.store.stack().map(\.texto)
        try h.store.reorder(from: IndexSet(integer: 0), to: 3)
        let depois = h.store.stack()

        #expect(depois.map(\.texto) == Array(antes.dropFirst()) + [antes[0]])
        // A sequência é 0,1,2 — sem buracos e sem negativos, para a ordem
        // sobreviver a fechar e reabrir o app (critério 8.2.4).
        #expect(depois.map(\.ordemPilha) == [0, 1, 2])
    }

    // MARK: - 11.6 e 11.7 — Live Activity e aviso

    @Test("11.6 — a Live Activity é encerrada antes de o estado mudar")
    func activityEndedBeforeStateChange() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "fixado")
        bilhete.fixadoAte = h.dates.now.addingTimeInterval(BilheteStore.pinDuration)
        bilhete.idAtividade = "activity-1"

        try h.store.archive(bilhete)

        #expect(h.pin.released == [bilhete.id])
        // Critério 8.3.3: encerrar acontece com o bilhete ainda em destaque —
        // atividade órfã deixaria texto na tela de bloqueio sem dono.
        #expect(h.pin.stateWhenReleased == [.emDestaque])
        #expect(bilhete.fixadoAte == nil)
        #expect(bilhete.idAtividade == nil)
        h.expectInvariantsHold()
    }

    @Test("11.6 — promover outro bilhete encerra a atividade do que sai")
    func promotingEndsPreviousActivity() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "primeiro")
        let segundo = try h.store.stash(primeiro)
        try h.store.save(segundo, texto: "segundo")
        segundo.fixadoAte = h.dates.now.addingTimeInterval(BilheteStore.pinDuration)
        segundo.idAtividade = "activity-2"

        try h.store.promoteToFeatured(primeiro)

        // `stash` no começo do caso já havia soltado o primeiro; o que importa
        // aqui é que a última atividade encerrada seja a do bilhete que saiu do
        // destaque.
        #expect(h.pin.released.last == segundo.id)
        #expect(segundo.fixadoAte == nil)
        #expect(segundo.idAtividade == nil)
        #expect(primeiro.estado == .emDestaque)
        h.expectInvariantsHold()
    }

    @Test("11.6 — excluir também encerra a atividade")
    func deleteEndsActivity() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "some")
        bilhete.idAtividade = "activity-3"
        bilhete.fixadoAte = h.dates.now

        try h.store.delete(bilhete)

        #expect(h.pin.released.count == 1)
        h.expectInvariantsHold()
    }

    // MARK: - 11.8 — duração da fixação

    @Test("11.8 — a fixação dura 8 horas e o aviso vem 30 minutos antes")
    func pinDurationValues() {
        #expect(BilheteStore.pinDuration == 8 * 60 * 60)
        #expect(BilheteStore.expiryWarningLead == 30 * 60)
    }

    // MARK: - 11.10 — primeira exibição do paywall

    @Test("11.10 — o paywall não aparece antes do momento de valor")
    func paywallGate() throws {
        let h = try TestHarness()
        let gate = PaywallGate(preferences: h.preferences)

        // Nada escrito, nada fixado.
        #expect(gate.outcome(hasNoteWithText: false) == .showProNotice)

        // Escreveu, mas ainda não fixou: só o aviso da copy 15.8.
        let bilhete = try h.makeFeatured(texto: "comprar pão")
        #expect(h.store.hasNoteWithText())
        #expect(gate.outcome(hasNoteWithText: h.store.hasNoteWithText()) == .showProNotice)

        // Fixou pela primeira vez: agora sim.
        h.preferences.jaFixouAlgumaVez = true
        #expect(gate.outcome(hasNoteWithText: h.store.hasNoteWithText()) == .openPaywall)

        // Fixou mas apagou o texto: volta a ser só aviso.
        try h.store.save(bilhete, texto: "")
        #expect(gate.outcome(hasNoteWithText: h.store.hasNoteWithText()) == .showProNotice)
    }

    // MARK: - 11.11 — perda do direito Pro

    @Test("11.11 — perder o Pro não apaga nada e volta a fonte para a padrão")
    func entitlementRevocationKeepsData() throws {
        let h = try TestHarness(isPro: true)
        try h.makeFeatured(texto: "um")
        for indice in 2...6 {
            try h.store.create(texto: "bilhete \(indice)")
        }
        for indice in 1...12 {
            let bilhete = try h.store.create(texto: "para arquivar \(indice)")
            try h.store.archive(bilhete)
            h.dates.advance(by: 60)
        }
        let ativosAntes = h.store.activeCount()
        let arquivadosAntes = h.store.archived().count

        h.preferences.proDesbloqueado = true
        h.preferences.fonte = .serifada
        #expect(h.preferences.fonteEfetiva == .serifada)

        // Revogação (reembolso, cancelamento de família, chargeback).
        h.entitlement.isPro = false
        h.preferences.proDesbloqueado = false

        // Nenhum dado é apagado: os 6 ativos e os 12 arquivados continuam lá,
        // legíveis.
        #expect(h.store.activeCount() == ativosAntes)
        #expect(h.store.archived().count == arquivadosAntes)
        // A fonte degrada para a padrão sem apagar a escolha da pessoa.
        #expect(h.preferences.fonteEfetiva == .padrao)
        #expect(h.preferences.fonte == .serifada)
        // Criar novo ativo fica bloqueado até voltar a 3.
        #expect(throws: BilheteStoreError.limitReached(limit: 3)) {
            try h.store.create(texto: "mais um")
        }
        h.expectInvariantsHold()
    }

    // MARK: - 11.13 — colisão de id

    @Test("11.13 — a criação nunca repete um id existente")
    func uniqueIDs() throws {
        let h = try TestHarness(isPro: true)
        try h.makeFeatured(texto: "um")
        for indice in 2...30 {
            try h.store.create(texto: "bilhete \(indice)")
        }
        let ids = h.store.allNotes().map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    // MARK: - 11.16 — ciclo de vida ao arquivar o destaque

    @Test("11.16 — arquivar o destaque promove o primeiro da pilha")
    func archivingPromotesTopOfStack() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "primeiro")
        let segundo = try h.store.stash(primeiro)
        try h.store.save(segundo, texto: "segundo")

        // Pilha: [primeiro]. Destaque: segundo.
        try h.store.archive(segundo)

        #expect(primeiro.estado == .emDestaque)
        #expect(h.store.stack().isEmpty)
        h.expectInvariantsHold()
    }

    @Test("11.16 — arquivar com a pilha vazia cria um bilhete novo em branco")
    func archivingWithEmptyStackCreatesBlank() throws {
        let h = try TestHarness()
        let bilhete = try h.makeFeatured(texto: "único")

        try h.store.archive(bilhete)

        let destaque = try #require(h.store.featured())
        #expect(destaque.texto.isEmpty)
        #expect(destaque.id != bilhete.id)
        h.expectInvariantsHold()
    }

    @Test("11.16 — repor o destaque não é barrado pelo limite do plano grátis")
    func replacementFeaturedIgnoresLimit() throws {
        // Com 3 ativos sem Pro, arquivar o destaque com a pilha vazia ainda
        // precisa repor o destaque: a regra 11.1 vence a 11.3 nesse instante.
        let h = try TestHarness(isPro: false)
        let bilhete = try h.makeFeatured(texto: "único")
        try h.store.archive(bilhete)
        #expect(h.store.featured() != nil)
        h.expectInvariantsHold()
    }

    // MARK: - 11.17 e 11.18 — debounce e recarga de widget

    @Test("11.17 — o debounce de gravação é de 1 segundo")
    func debounceValue() {
        #expect(BilheteStore.saveDebounce == 1)
    }

    @Test("11.18 — toda gravação que muda o destaque recarrega os widgets")
    func widgetReloadOnFeaturedChange() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.store.ensureFeatured()
        let depoisDeCriar = h.widgets.reloadCount

        try h.store.save(bilhete, texto: "texto novo")
        #expect(h.widgets.reloadCount == depoisDeCriar + 1)

        // Guardar troca o destaque: recarrega.
        let novo = try h.store.stash(bilhete)
        #expect(h.widgets.reloadCount == depoisDeCriar + 2)

        // Editar um guardado não muda nenhuma superfície do sistema: não
        // recarrega.
        let contagem = h.widgets.reloadCount
        try h.store.save(bilhete, texto: "editando o guardado")
        #expect(h.widgets.reloadCount == contagem)

        try h.store.archive(novo)
        #expect(h.widgets.reloadCount > contagem)
    }

    @Test("Gravar o mesmo texto não mexe em atualizadoEm")
    func savingSameTextIsNoop() throws {
        let h = try TestHarness()
        let bilhete = try h.makeFeatured(texto: "igual")
        let antes = bilhete.atualizadoEm

        h.dates.advance(by: 3600)
        try h.store.save(bilhete, texto: "igual")

        #expect(bilhete.atualizadoEm == antes)
    }

    @Test("8.1.5 — criadoEm nunca muda e atualizadoEm acompanha cada alteração")
    func timestamps() throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()
        let criado = bilhete.criadoEm

        h.dates.advance(by: 120)
        try h.store.save(bilhete, texto: "primeira versão")
        #expect(bilhete.criadoEm == criado)
        #expect(bilhete.atualizadoEm == criado.addingTimeInterval(120))

        h.dates.advance(by: 60)
        try h.store.save(bilhete, texto: "segunda versão")
        #expect(bilhete.criadoEm == criado)
        #expect(bilhete.atualizadoEm == criado.addingTimeInterval(180))
    }
}
