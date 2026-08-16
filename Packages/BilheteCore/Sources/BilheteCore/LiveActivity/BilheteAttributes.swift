import ActivityKit
import Foundation

/// O contrato de dados da Live Activity (spec 13.2 e superfícies S5–S8).
///
/// A Live Activity **não compartilha o store** com o app: o canal de dados é o
/// `ContentState` (spec 4.5, item 6). O App Group serve só para a UI da
/// atividade ler preferências.
///
/// O payload inteiro — atributos mais estado — precisa caber em **4 KB** (L11).
/// Com 280 caracteres de texto (regra 11.2) sobra folga; o gargalo real é a
/// área de tela, não o tamanho (L12).
public struct BilheteAttributes: ActivityAttributes {

    /// O que muda ao longo da vida da atividade.
    public struct ContentState: Codable, Hashable {
        /// O texto do bilhete, como aparece na tela de bloqueio.
        public var texto: String

        /// Quando a fixação expira: `agora + 8h` no momento de fixar
        /// (regra 11.8). Dá começo e fim reais ao evento, que é o que alinha a
        /// Live Activity com a HIG por desenho e não por argumento (risco R-3).
        public var fixadoAte: Date

        public init(texto: String, fixadoAte: Date) {
            self.texto = texto
            self.fixadoAte = fixadoAte
        }
    }

    /// Identificador do bilhete, para o toque no corpo abrir o app nele
    /// (critério de aceite 8.4.6) e para os botões saberem em quem agir.
    public var bilheteID: UUID

    public init(bilheteID: UUID) {
        self.bilheteID = bilheteID
    }
}

public extension BilheteAttributes {
    /// Monta a URL de abertura do app no bilhete da atividade.
    ///
    /// - Parameter id: o identificador do bilhete.
    /// - Returns: `bilhete://destaque/<uuid>`.
    ///
    /// É o deep link do critério 8.4.6. O app trata em `onOpenURL`.
    static func deepLink(for id: UUID) -> URL {
        URL(string: "bilhete://destaque/\(id.uuidString)")!
    }
}
