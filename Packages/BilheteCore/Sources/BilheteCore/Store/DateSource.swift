import Foundation

/// Fonte de "agora" injetável (spec 22, "Como testar o que depende de tempo").
///
/// `fixadoAte`, o agendamento do aviso e todos os carimbos de data passam por
/// aqui. O spec proíbe `Date()` direto em código testável — sem isso não dá
/// para testar a regra 11.8 (fixação de 8h) nem a 11.7 (aviso 30 min antes) sem
/// esperar oito horas.
public protocol DateSource: Sendable {
    /// O instante atual, conforme a fonte.
    var now: Date { get }
}

/// Implementação de produção: o relógio do sistema.
///
/// Este é o **único** lugar do app onde `Date()` pode ser chamado.
public struct SystemDateSource: DateSource {
    public init() {}

    public var now: Date { Date() }
}
