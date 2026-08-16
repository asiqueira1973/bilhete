import Foundation

/// Estado do bilhete no ciclo de vida (spec 7.5).
///
/// Os casos são nomeados em português porque fazem parte do schema persistido —
/// a camada de dados fica do lado português da fronteira (spec 18.1). Os valores
/// crus são `snake_case` para bater com o `modelo-bilhete.dbml` e com a seção 7.
///
/// A máquina de estados, com as transições permitidas e as proibidas, está na
/// seção 12 e é aplicada pelo `BilheteStore`.
public enum EstadoBilhete: String, Codable, CaseIterable, Sendable {
    /// O bilhete da vez. Exatamente um por vez, ou zero no instante entre
    /// transições (regra 11.1). É o que aparece nos widgets e na Live Activity.
    case emDestaque = "em_destaque"

    /// Na pilha, esperando a vez. Não aparece em nenhuma superfície do sistema.
    case guardado = "guardado"

    /// Encerrado. Sai da pilha, é restaurável, e não conta para o limite de
    /// ativos da regra 11.3.
    case arquivado = "arquivado"
}

public extension EstadoBilhete {
    /// Diz se o estado conta para o limite de bilhetes ativos.
    ///
    /// - Returns: `true` para `emDestaque` e `guardado`; `false` para
    ///   `arquivado`.
    ///
    /// Implementa a regra 11.3 do spec: ativos são destaque + guardados, e
    /// arquivados **não** contam (assunção A-3 — arquivar é encerramento, não
    /// pode ser punido).
    var contaComoAtivo: Bool {
        switch self {
        case .emDestaque, .guardado: true
        case .arquivado: false
        }
    }
}
