import Foundation

/// Erros do `BilheteStore` (spec 13.1).
///
/// O spec nomeia dois deles em português (`LimiteAtingido`, `PodaNecessaria`)
/// na tabela 13.1. Aqui eles saem em inglês porque estão **fora** da fronteira
/// do store: pela regra 18.1, do `BilheteStore` para dentro é português, da API
/// dele para fora é inglês. O mapeamento está registrado na documentação
/// técnica:
/// `LimiteAtingido` → `limitReached`, `PodaNecessaria` → `pruneRequired`.
public enum BilheteStoreError: Error, Equatable {

    /// O limite de bilhetes ativos do plano grátis foi atingido (regra 11.3).
    ///
    /// Quem trata abre o paywall (tela 10.5) e **não** completa a ação. Vale
    /// para criar, guardar e restaurar.
    /// - Parameter limit: o limite vigente, para a UI não repetir o número.
    case limitReached(limit: Int)

    /// O arquivo do plano grátis está cheio e arquivar mais um vai apagar o
    /// bilhete mais antigo em definitivo (regra 11.4).
    ///
    /// Não é falha: é pedido de confirmação. Quem trata mostra a copy 15.4 com o
    /// texto do bilhete que será apagado e, se a pessoa confirmar, chama
    /// `archive(_:confirmingPrune: true)`.
    /// - Parameters:
    ///   - limit: o tamanho do arquivo no plano grátis.
    ///   - oldestText: o texto do bilhete que será apagado, para a copy 15.4.
    case pruneRequired(limit: Int, oldestText: String)

    /// O texto passou de 280 caracteres (regra 11.2).
    ///
    /// O editor bloqueia a entrada antes disso; este erro protege as entradas
    /// que não passam pelo editor, como Siri e Atalhos.
    case textTooLong(limit: Int)

    /// A transição pedida não existe na máquina de estados da seção 12.
    ///
    /// Exemplo: promover um arquivado direto a destaque, sem passar por
    /// guardado — proibido de propósito, porque o encerramento tem peso (P4).
    case forbiddenTransition(from: EstadoBilhete, to: EstadoBilhete)
}
