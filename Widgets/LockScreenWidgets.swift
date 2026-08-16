import BilheteCore
import SwiftUI
import WidgetKit

/// S1 — widget `accessoryRectangular` da tela de bloqueio (épico 8.5).
///
/// **É a camada permanente do Bilhete** (L2 e princípio P3): a Live Activity
/// expira em 12h, este widget não expira nunca. É ele que faz "perder o
/// destaque" não significar "perder o bilhete".
///
/// Duas restrições duras governam o desenho e não podem ser "melhoradas":
/// - **L8:** o sistema força modo `vibrant`, dessatura tudo para escala de cinza
///   e recolore para o fundo. **Não há como exibir cor.** Toda hierarquia aqui é
///   feita com peso e opacidade, nunca com matiz.
/// - **L9 / regra 11.9:** **proibido botão.** Com o aparelho bloqueado o intent
///   só executa depois do desbloqueio e não há API pública para reverter o
///   estado visual se a pessoa cancelar o desbloqueio. Ação interativa vive no
///   Controle (S9/S10) e nos widgets de tela de início (S3/S4).
struct LockScreenRectangularWidget: Widget {
    private let kind = "BilheteRectangular"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FeaturedNoteProvider()) { _ in
            FeaturedNoteReader { bilhete in
                if let bilhete {
                    Text(bilhete.texto)
                        // Peso **semibold**, não medium: em teste no aparelho,
                        // sobre papel de parede claro, o medium sumia. Em
                        // `vibrant` não há contraste de cor para compensar (L8),
                        // então o peso é a única alavanca que sobra.
                        .font(.caption.weight(.semibold))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // Deixa o texto participar do realce do sistema, o que
                        // melhora a leitura sobre fundo claro.
                        .widgetAccentable()
                        // Respeita a preferência do sistema para conteúdo com o
                        // aparelho bloqueado (critério 8.5.7).
                        .privacySensitive()
                } else {
                    WidgetEmptyLabel()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 4)
            .bilheteStore()
            // Fundo padrão do sistema para acessórios (spec 16.4). Sem ele o
            // texto fica direto sobre o papel de parede e some — foi o que
            // aconteceu no teste em aparelho.
            .containerBackground(for: .widget) { AccessoryWidgetBackground() }
        }
        .configurationDisplayName(Text(WidgetStrings.galleryRectangularName))
        .description(Text(WidgetStrings.galleryRectangularDescription))
        .supportedFamilies([.accessoryRectangular])
    }
}

/// S2 — widget `accessoryInline`, a linha acima do relógio (épico 8.5).
///
/// Uma linha só, truncada (critério 8.5.4). Mesmas restrições da S1: escala de
/// cinza forçada (L8) e **sem botão** (L9).
struct LockScreenInlineWidget: Widget {
    private let kind = "BilheteInline"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FeaturedNoteProvider()) { _ in
            FeaturedNoteReader { bilhete in
                if let bilhete {
                    // A apresentação inline aceita só uma linha de texto: o
                    // sistema já trunca, e o layout não é nosso.
                    Text(bilhete.texto.firstLine)
                        .privacySensitive()
                } else {
                    Text(WidgetStrings.empty)
                }
            }
            .bilheteStore()
        }
        .configurationDisplayName(Text(WidgetStrings.galleryInlineName))
        .description(Text(WidgetStrings.galleryInlineDescription))
        .supportedFamilies([.accessoryInline])
    }
}

extension String {
    /// A primeira linha do texto, para a apresentação inline (S2).
    ///
    /// - Returns: o trecho até a primeira quebra de linha; o texto inteiro se
    ///   não houver quebra.
    var firstLine: String {
        split(separator: "\n", maxSplits: 1).first.map(String.init) ?? self
    }
}
