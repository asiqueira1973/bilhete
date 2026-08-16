import Foundation

/// O que fazer quando a pessoa toca numa capacidade Pro.
public enum ProActionOutcome: Equatable, Sendable {
    /// Abre o paywall (tela 10.5) com a compra disponível.
    case openPaywall

    /// Mostra apenas o aviso da copy 15.8 ("Isso é do Bilhete Pro / Uma compra
    /// só, pra sempre."), **sem** abrir a compra.
    case showProNotice
}

/// Decide se o paywall pode aparecer (regra 11.10).
///
/// A regra é dura: o paywall **nunca** aparece antes de a pessoa ter (a) criado
/// um bilhete com texto **e** (b) fixado ao menos uma vez. Antes disso, tocar
/// numa capacidade Pro só mostra o aviso 15.8.
///
/// Isso existe porque o momento de valor do produto é ver o próprio bilhete na
/// tela de bloqueio (fluxo 9.1, passo 6). Cobrar antes disso é cobrar por uma
/// promessa que a pessoa ainda não viu cumprida, e o princípio P5 diz que grátis
/// é útil de verdade.
@MainActor
public struct PaywallGate {

    private let preferences: Preferences

    /// Cria o portão.
    /// - Parameter preferences: onde mora `jaFixouAlgumaVez`, metade da
    ///   condição da regra 11.10.
    public init(preferences: Preferences = .shared) {
        self.preferences = preferences
    }

    /// Diz se o momento de valor já aconteceu.
    ///
    /// - Parameter hasNoteWithText: se já existe algum bilhete com texto —
    ///   vem de `BilheteStore.hasNoteWithText()`.
    /// - Returns: `true` quando as duas condições da regra 11.10 foram
    ///   cumpridas.
    public func hasReachedValueMoment(hasNoteWithText: Bool) -> Bool {
        hasNoteWithText && preferences.jaFixouAlgumaVez
    }

    /// Decide o que mostrar quando uma capacidade Pro é tocada.
    ///
    /// - Parameter hasNoteWithText: se já existe algum bilhete com texto.
    /// - Returns: `.openPaywall` depois do momento de valor; `.showProNotice`
    ///   antes dele (regra 11.10).
    public func outcome(hasNoteWithText: Bool) -> ProActionOutcome {
        hasReachedValueMoment(hasNoteWithText: hasNoteWithText) ? .openPaywall : .showProNotice
    }
}
