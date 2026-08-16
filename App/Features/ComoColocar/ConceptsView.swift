import BilheteCore
import SwiftUI

/// "Como o Bilhete funciona" — a tela que explica os conceitos (decisão D-10).
///
/// Nasceu de um problema real de uso: a dica de rodapé some depois do primeiro
/// uso, e as ações continuavam parecendo iguais entre si. Aqui elas são
/// explicadas **por significado**, não por destino — inclusive a equivalência
/// que faltava: o botão "Concluir" da tela de bloqueio é a mesma ação de
/// Concluir do app.
///
/// Fica nos Ajustes, alcançável a qualquer momento, e nunca interrompe: nada
/// aqui é modal, e o princípio P2 continua valendo na tela principal.
struct ConceptsView: View {

    var body: some View {
        ZStack {
            Theme.fundoApp.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(loc: AppStrings.conceptsIntro)
                        .font(.callout)
                        .foregroundStyle(Theme.tintaSecundaria)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)

                    concept(
                        symbol: "pin",
                        title: AppStrings.conceptsPinTitle,
                        body: AppStrings.conceptsPinBody
                    )
                    concept(
                        symbol: "tray.and.arrow.down",
                        title: AppStrings.conceptsStashTitle,
                        body: AppStrings.conceptsStashBody
                    )
                    concept(
                        symbol: "archivebox",
                        title: AppStrings.conceptsDoneTitle,
                        body: AppStrings.conceptsDoneBody
                    )
                    concept(
                        symbol: "pin.slash",
                        title: AppStrings.conceptsUnpinTitle,
                        body: AppStrings.conceptsUnpinBody
                    )
                    concept(
                        symbol: "rectangle.stack",
                        title: AppStrings.conceptsLimitsTitle,
                        body: AppStrings.conceptsLimitsBody
                    )
                }
                .padding(Theme.margin)
            }
        }
        .navigationTitle(Text(loc: AppStrings.conceptsTitle))
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Um conceito: símbolo, nome da ação e o que ela significa.
    ///
    /// - Parameters:
    ///   - symbol: o mesmo símbolo que a ação usa na barra, para a pessoa ligar
    ///     o texto ao botão que ela vê.
    ///   - title: o nome da ação, idêntico ao do botão.
    ///   - body: o que ela faz, em uma frase.
    private func concept(
        symbol: String,
        title: LocalizedStringResource,
        body: LocalizedStringResource
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.marca)
                .frame(width: 38, height: 38)
                .background(Theme.marca.opacity(0.12), in: .circle)

            VStack(alignment: .leading, spacing: 4) {
                Text(loc: title)
                    .font(.headline)
                    .foregroundStyle(Theme.tinta)
                Text(loc: body)
                    .font(.callout)
                    .foregroundStyle(Theme.tintaSecundaria)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.papel, in: .rect(cornerRadius: 18, style: .continuous))
    }
}
