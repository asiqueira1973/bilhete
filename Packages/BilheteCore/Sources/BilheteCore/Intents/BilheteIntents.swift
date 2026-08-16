import AppIntents
import Foundation
import SwiftData

/// Monta um `BilheteStore` fora do app.
///
/// Os intents rodam em processos que não são o app — a widget extension, a
/// Siri, os Atalhos — e mesmo assim **não podem** escrever no `ModelContext`
/// direto: as invariantes são transacionais e têm um dono só (spec 13.1).
/// Este ajudante abre o container do App Group e devolve o store de sempre.
@MainActor
enum IntentEnvironment {
    /// Cria store e serviço de fixação apontando para o container compartilhado.
    /// - Returns: o store e o `PinService`, ou `nil` se o container não abrir.
    static func make() -> (store: BilheteStore, pin: PinService)? {
        // **Container compartilhado, nunca um novo.** `LiveActivityIntent` roda
        // dentro do processo do app: criar um `ModelContainer` próprio deixava
        // dois containers sobre o mesmo arquivo, e o que o botão da tela de
        // bloqueio gravava a tela do app não enxergava — o bilhete parecia ter
        // sumido. Foi o bug encontrado no teste em aparelho.
        guard let container = BilheteContainer.optional else { return nil }
        let context = container.mainContext
        let preferences = Preferences.shared
        let pin = PinService(context: context, preferences: preferences)
        let store = BilheteStore(
            context: context,
            entitlement: CachedEntitlementProvider(preferences: preferences),
            pin: pin
        )
        return (store, pin)
    }

    /// Acha o bilhete em destaque (regra 11.1).
    /// - Parameter store: o store aberto pelo intent.
    /// - Returns: o bilhete `emDestaque`, se existir.
    static func featured(in store: BilheteStore) -> Bilhete? {
        store.featured()
    }
}

/// Conclui o bilhete: arquiva sem abrir o app (spec 13.3).
///
/// Monta no botão dos widgets de tela de início (S3/S4) e nos botões da Live
/// Activity (S5/S8). É capacidade **grátis** — a matriz da seção 5 põe arquivar
/// na coluna de todo mundo, e o princípio P5 diz que o ciclo completo funciona
/// sem pagar.
/// Conforma `LiveActivityIntent` **por necessidade da plataforma**: botão dentro
/// de Live Activity só executa se o intent for desse tipo. Sem isso o toque na
/// tela de bloqueio não faz nada — foi o que aconteceu no teste em aparelho.
/// A conformidade não atrapalha o uso nos widgets de tela de início.
public struct ConcluirBilheteIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource { "Concluir bilhete" }
    public static var description: IntentDescription {
        IntentDescription("Arquiva o bilhete em destaque.")
    }
    /// Não abre o app: concluir é o gesto de encerramento e acontece onde a
    /// pessoa está (critério de aceite 8.4.4).
    public static var openAppWhenRun: Bool { false }

    public init() {}

    /// Arquiva o bilhete em destaque.
    ///
    /// - Returns: resultado vazio; a mudança aparece no app por `@Query`, sem
    ///   exigir reinício (critério 8.5.5 e risco R-6).
    ///
    /// Aplica as regras 11.4 (poda), 11.6 (encerra a Live Activity), 11.7
    /// (cancela o aviso) e 11.16 (promove o próximo da pilha) — todas dentro do
    /// `BilheteStore`, porque este intent não tem tela para pedir confirmação.
    @MainActor
    public func perform() async throws -> some IntentResult {
        guard let env = IntentEnvironment.make(),
              let bilhete = IntentEnvironment.featured(in: env.store)
        else { return .result() }

        // Sem tela não há como mostrar o aviso nominal de poda (15.4), então
        // aqui a poda vai confirmada: a alternativa seria o botão não fazer
        // nada, o que é pior — a pessoa tocou em "Concluir" e espera concluir.
        try? env.store.archive(bilhete, confirmingPrune: true)
        return .result()
    }
}

/// Solta o bilhete: encerra a Live Activity sem arquivar (spec 13.3).
///
/// Monta no segundo botão da Live Activity (S5/S8). Conforma
/// `LiveActivityIntent` para executar sem abrir o app (L5). É capacidade grátis.
public struct SoltarBilheteIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource { "Soltar bilhete" }
    public static var description: IntentDescription {
        IntentDescription("Tira o bilhete da tela sem arquivar.")
    }
    public static var openAppWhenRun: Bool { false }

    public init() {}

    /// Encerra a atividade em curso e limpa os campos de fixação.
    ///
    /// - Returns: resultado vazio.
    ///
    /// Critério de aceite 8.4.5: encerra com `.immediate`, zera `fixadoAte` e
    /// `idAtividade` e **não** arquiva. Soltar não é concluir — o bilhete
    /// continua em destaque e o widget permanente continua mostrando ele (P3).
    @MainActor
    public func perform() async throws -> some IntentResult {
        guard let env = IntentEnvironment.make(),
              let bilhete = IntentEnvironment.featured(in: env.store)
        else { return .result() }

        env.pin.soltar(bilhete)
        return .result()
    }
}
