import ActivityKit
import AppIntents
import BilheteCore
import SwiftUI
import WidgetKit

/// A Live Activity do Bilhete — superfícies S5 a S8 (épico 8.4).
///
/// É a camada **temporária**: o sistema encerra em 8h e o cartão some da tela de
/// bloqueio em até 12h (L1). Quem é permanente é o widget da tela de bloqueio
/// (L2), e é isso que cumpre o princípio P3 — perder o destaque nunca significa
/// perder o bilhete.
struct BilheteLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BilheteAttributes.self) { context in
            lockScreen(context)
                // Toque no corpo abre o app no bilhete (critério 8.4.6).
                .widgetURL(BilheteAttributes.deepLink(for: context.attributes.bilheteID))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expandida (S8): o texto inteiro e os dois botões.
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "note.text")
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.texto)
                        .font(.callout.weight(.medium))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        Button(intent: ConcluirBilheteIntent()) {
                            Label(String(localized: WidgetStrings.actionDone), systemImage: "checkmark")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        Button(intent: SoltarBilheteIntent()) {
                            Label(String(localized: WidgetStrings.actionUnpin), systemImage: "pin.slash")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                    }
                    .font(.footnote.weight(.medium))
                    .buttonStyle(.bordered)
                }
            } compactLeading: {
                // Compacta (S6): símbolo à esquerda…
                Image(systemName: "note.text")
            } compactTrailing: {
                // …e as primeiras palavras à direita (spec 16.5).
                Text(firstWords(context.state.texto))
                    .font(.caption2.weight(.medium))
                    .lineLimit(1)
            } minimal: {
                // Mínima (S7): só o símbolo.
                Image(systemName: "note.text")
            }
            // A Dynamic Island não aceita fundo personalizado — é preto opaco do
            // sistema (spec 16.5). O que dá para controlar é o tint do texto.
            .keylineTint(BilheteColors.marca)
        }
    }

    /// A apresentação da tela de bloqueio (S5).
    ///
    /// - Parameter context: o estado da atividade.
    /// - Returns: o cartão de ~120pt de altura, com o texto e os dois botões.
    ///
    /// Altura alvo de 120pt e teto de 160pt (L12 e spec 16.5). Peso de texto
    /// medium ou maior em tudo, exigência da HIG para legibilidade em
    /// Always-On.
    @ViewBuilder
    private func lockScreen(_ context: ActivityViewContext<BilheteAttributes>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(context.state.texto)
                    // Peso semibold e cor primária **do sistema**: sobre o
                    // material translúcido da tela de bloqueio, quem garante
                    // contraste é o iOS, não uma cor fixa nossa. Foi assim que
                    // o widget ficou legível no teste em aparelho.
                    .font(.title3.weight(.semibold))
                    .lineLimit(3)
                    // Trunca com reticências sem quebrar o layout, mesmo com os
                    // 280 caracteres da regra 11.2 (critério 8.4.8).
                    .truncationMode(.tail)
                    .foregroundStyle(.primary)

                Text(context.state.fixadoAte, style: .timer)
                    .font(.caption2.weight(.medium).monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Ícone **com rótulo**: no teste em aparelho, dois ícones sozinhos
            // não diziam o que faziam. O espaço da tela de bloqueio comporta o
            // texto pequeno, e a clareza vale mais que a economia de pixel.
            VStack(spacing: 6) {
                Button(intent: ConcluirBilheteIntent()) {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark")
                        Text(WidgetStrings.actionDone)
                            .font(.caption2.weight(.medium))
                    }
                    .frame(width: 64)
                }

                Button(intent: SoltarBilheteIntent()) {
                    VStack(spacing: 2) {
                        Image(systemName: "pin.slash")
                        Text(WidgetStrings.actionUnpin)
                            .font(.caption2.weight(.medium))
                    }
                    .frame(width: 64)
                }
            }
            .buttonStyle(.bordered)
            .tint(BilheteColors.marca)
        }
        .padding(16)
        .frame(minHeight: 96, idealHeight: 120, maxHeight: 160)
        // **Sem `activityBackgroundTint`.** Forçar o branco do papel deixava o
        // cartão claro sobre qualquer papel de parede, com o texto quase sumindo
        // — foi o que apareceu no teste em aparelho. Sem o tint, o sistema usa o
        // material translúcido dele, o mesmo do widget, que se adapta ao fundo.
        .activitySystemActionForegroundColor(BilheteColors.marca)
    }

    /// Pega as duas ou três primeiras palavras do bilhete.
    ///
    /// - Parameter texto: o texto completo.
    /// - Returns: um trecho curto que cabe nos ~62×37pt da apresentação
    ///   compacta (S6).
    private func firstWords(_ texto: String) -> String {
        texto.split(separator: " ").prefix(3).joined(separator: " ")
    }
}
