import ActivityKit
import AppIntents
import Foundation

/// Os intents das superfícies do sistema (spec 13.3 e matriz da seção 5).
///
/// **Refixar é grátis** desde a decisão D-12: sem o widget sugerido (D-7), ele é
/// o único caminho de volta em um toque quando a fixação expira, e o princípio
/// P5 diz que o ciclo básico é grátis para sempre. Criar bilhete pela Siri, por
/// Atalho ou pelo Controle continua sendo Pro (assunção A-5), e nesses casos o
/// aviso 15.8 aparece sem executar (critério 8.6.9).

/// Confere o direito Pro antes de executar (matriz da seção 5).
///
/// - Returns: `true` quando o Pro está ativo.
///
/// Lê o cache das preferências do App Group, porque a widget extension e a Siri
/// não têm como falar com o StoreKit (spec 7.4). O app corrige o cache toda vez
/// que abre.
@MainActor
private func temPro() -> Bool {
    Preferences.shared.proDesbloqueado
}

/// Refixa o bilhete em destaque **sem abrir o app** (S9, spec 13.3).
///
/// Este é o caminho central da v1: é ele que responde ao momento mais difícil da
/// seção 2 — a Live Activity morreu às 15h e a pessoa refixa em um toque, da
/// própria tela de bloqueio.
///
/// Conforma `LiveActivityIntent` porque só assim o `Activity.request` pode
/// acontecer fora do app (L5, L6). O `perform()` **completa de forma síncrona** e
/// não conforma `ForegroundContinuableIntent`, que não é suportado em Controle
/// (L13, critério 8.6.4).
///
/// **É capacidade grátis desde a decisão D-12.** A assunção A-5 do spec amarrava
/// o Controle ao preço, mas depois que o app deixou de sugerir o widget (D-7),
/// refixar virou o único caminho de volta em um toque — e o princípio P5 diz que
/// o ciclo básico é grátis para sempre. Cobrar por ele deixaria quem não paga
/// sem rede de segurança nenhuma quando a fixação expira.
public struct RefixarBilheteIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource { "Refixar bilhete" }
    public static var description: IntentDescription {
        IntentDescription("Coloca seu bilhete de volta na tela de bloqueio.")
    }
    public static var openAppWhenRun: Bool { false }

    public init() {}

    /// Recria a Live Activity do bilhete em destaque.
    ///
    /// - Returns: resultado vazio; o Controle não tem UI para resposta (L10).
    ///
    /// Se o `Activity.request` falhar, avisa com a copy 15.15 — falha em
    /// silêncio na superfície, porque o Controle não tem onde mostrar erro
    /// (spec 12). Não confere direito Pro: refixar é grátis (D-12).
    @MainActor
    public func perform() async throws -> some IntentResult {
        guard let env = IntentEnvironment.make(),
              let bilhete = IntentEnvironment.featured(in: env.store),
              !bilhete.texto.isEmpty
        else { return .result() }

        do {
            try env.pin.fixar(bilhete)
        } catch {
            LocalNotifier.avisarFalhaDoControle()
        }
        return .result()
    }
}

/// Abre o app já no editor (S10, spec 13.3).
///
/// Diferente do "Refixar", este **abre o app** de propósito: escrever exige
/// teclado, e a Live Activity não tem campo de texto (L12). É o único jeito de
/// cumprir o princípio P2 a partir de um Controle.
public struct NovoBilheteIntent: AppIntent {
    public static var title: LocalizedStringResource { "Novo bilhete" }
    public static var description: IntentDescription {
        IntentDescription("Abre o Bilhete direto no editor.")
    }
    /// Abre o app: é a razão de existir deste intent.
    public static var openAppWhenRun: Bool { true }

    public init() {}

    /// Garante que existe um bilhete em destaque para a pessoa escrever.
    ///
    /// - Returns: resultado vazio; quem mostra a tela é o app, que já abre no
    ///   editor com o cursor ativo (critério 8.1.1).
    @MainActor
    public func perform() async throws -> some IntentResult {
        guard temPro() else {
            LocalNotifier.avisarCapacidadePro()
            return .result()
        }
        if let env = IntentEnvironment.make() {
            // Regra 11.1: o app nunca fica sem destaque. Se a pessoa apagou
            // tudo, este é o momento de repor.
            try? env.store.ensureFeatured(origem: .controle)
        }
        return .result()
    }
}

/// Cria um bilhete por voz ou por Atalho (spec 13.3).
///
/// É o caso de uso principal da persona P-A: lembrar de algo no meio de uma
/// ligação e registrar em três segundos, sem sair do que está fazendo. Por isso
/// não abre o app e confirma por voz (critério 8.6.6).
public struct CriarBilheteIntent: AppIntent {
    public static var title: LocalizedStringResource { "Criar bilhete" }
    public static var description: IntentDescription {
        IntentDescription("Cria um bilhete com o texto que você ditar.")
    }
    public static var openAppWhenRun: Bool { false }

    /// O texto ditado. Pedido à pessoa quando o Atalho não fornece.
    @Parameter(title: "Texto", requestValueDialog: "O que você quer anotar?")
    public var texto: String

    public init() {}

    public init(texto: String) {
        self.texto = texto
    }

    /// Cria o bilhete com origem `siri`.
    ///
    /// - Returns: diálogo de confirmação por voz.
    ///
    /// Aplica a regra 11.2 cortando em 280 caracteres em vez de recusar: quem
    /// falou uma frase longa perderia tudo se o intent simplesmente falhasse. E
    /// aplica a 11.3 — no limite do plano grátis, avisa em vez de criar.
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        guard temPro() else {
            return .result(dialog: IntentDialog(CoreStrings.proNoticeTitle))
        }
        guard let env = IntentEnvironment.make() else {
            return .result(dialog: IntentDialog(CoreStrings.controlFailureTitle))
        }

        let cortado = String(texto.prefix(BilheteStore.textLimit))
        do {
            try env.store.create(texto: cortado, origem: .siri)
            return .result(dialog: IntentDialog(CoreStrings.siriCreated))
        } catch {
            // Limite de ativos do plano grátis (regra 11.3): a Siri diz que é
            // do Pro, sem abrir compra — a compra é ato deliberado na tela.
            return .result(dialog: IntentDialog(CoreStrings.proNoticeTitle))
        }
    }
}

/// Arquiva o bilhete em destaque por voz ou por Atalho.
///
/// Existe porque a frase "Arquivar meu bilhete no Bilhete" está na lista da copy
/// 15.16. Arquivar é capacidade **grátis** (matriz da seção 5), então este intent
/// não confere o direito Pro — a Siri é Pro como superfície, mas o produto não
/// cobra para encerrar um bilhete.
public struct ArquivarBilheteIntent: AppIntent {
    public static var title: LocalizedStringResource { "Arquivar bilhete" }
    public static var description: IntentDescription {
        IntentDescription("Arquiva o bilhete em destaque.")
    }
    public static var openAppWhenRun: Bool { false }

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        guard let env = IntentEnvironment.make(),
              let bilhete = IntentEnvironment.featured(in: env.store)
        else { return .result() }

        try? env.store.archive(bilhete, confirmingPrune: true)
        return .result()
    }
}
