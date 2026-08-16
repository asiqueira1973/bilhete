import AppIntents
import BilheteCore
import SwiftUI
import WidgetKit

/// S3 e S4 — widgets de tela de início, `systemSmall` e `systemMedium`
/// (épico 8.5).
///
/// Aqui botão **é** permitido: com o aparelho desbloqueado o intent executa na
/// hora, e a restrição L9 vale só para a tela de bloqueio. É por isso que a ação
/// interativa do produto vive aqui e no Controle (regra 11.9).
///
/// O `systemSmall` traz "Concluir"; o `systemMedium`, que tem espaço, traz
/// também "Fixar" (superfícies S3 e S4 da seção 10).
struct HomeScreenNoteWidget: Widget {
    private let kind = "BilheteHome"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FeaturedNoteProvider()) { _ in
            HomeScreenNoteView()
                .bilheteStore()
                .containerBackground(BilheteColors.papel, for: .widget)
        }
        .configurationDisplayName(Text(WidgetStrings.galleryHomeName))
        .description(Text(WidgetStrings.galleryHomeDescription))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// O conteúdo dos widgets de tela de início.
///
/// Lê o bilhete em destaque por `@Query` (spec 4.5, item 4): é o que faz a
/// conclusão pelo widget aparecer no app sem reinício, como o critério 8.5.5
/// exige.
struct HomeScreenNoteView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        FeaturedNoteReader { bilhete in
            VStack(alignment: .leading, spacing: 8) {
                if let bilhete {
                    Text(bilhete.texto)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(BilheteColors.tinta)
                        .lineLimit(family == .systemSmall ? 4 : 3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    actions(for: bilhete)
                } else {
                    WidgetEmptyLabel()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
    }

    /// Os botões do widget.
    ///
    /// - Parameter bilhete: o bilhete em destaque.
    /// - Returns: "Concluir" no pequeno; "Concluir" e "Fixar" no médio.
    ///
    /// "Concluir" é grátis (matriz da seção 5); "Fixar" também — fixar na tela
    /// de bloqueio está na coluna grátis para sempre, porque é o ciclo básico do
    /// produto (princípio P5).
    @ViewBuilder
    private func actions(for bilhete: Bilhete) -> some View {
        HStack(spacing: 8) {
            Button(intent: ConcluirBilheteIntent()) {
                Label(String(localized: WidgetStrings.actionDone), systemImage: "checkmark")
                    .font(.caption.weight(.medium))
                    .frame(maxWidth: .infinity, minHeight: 28)
            }

            if family == .systemMedium {
                // Fixar abre o app: iniciar Live Activity exige foreground (L4),
                // então este botão não pode executar sozinho no widget.
                Link(destination: BilheteAttributes.deepLink(for: bilhete.id)) {
                    Label(String(localized: WidgetStrings.actionPin), systemImage: "pin")
                        .font(.caption.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: 28)
                        .background(BilheteColors.marca.opacity(0.12), in: .rect(cornerRadius: 8))
                }
            }
        }
        .buttonStyle(.bordered)
        .tint(BilheteColors.marca)
    }
}
