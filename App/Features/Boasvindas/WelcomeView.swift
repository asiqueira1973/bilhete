import BilheteCore
import SwiftUI

/// Tela 10.6 — boas-vindas, uma tela só, na primeira execução.
///
/// Uma frase e um botão. Nada de carrossel de cinco telas: o princípio P2 diz
/// que do ícone ao cursor não pode haver tela intermediária, e esta é a única
/// exceção tolerada porque acontece **uma vez** e explica o que o app é
/// (fluxo 9.1, passo 1).
struct WelcomeView: View {
    /// Chamado quando a pessoa toca em "Escrever o primeiro".
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Theme.fundoApp.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Text(loc: AppStrings.welcomeTitle)
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(Theme.tinta)
                    Text(loc: AppStrings.welcomeSubtitle)
                        .font(.title3)
                        .foregroundStyle(Theme.tintaSecundaria)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Theme.margin)

                Spacer()

                Button(action: onStart) {
                    Text(loc: AppStrings.welcomeButton)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                // O terracota aparece pouco e este é um dos lugares: ação
                // principal da única tela de entrada (16.2).
                .tint(Theme.marca)
                .padding(.horizontal, Theme.margin)
                .padding(.bottom, 32)
            }
        }
    }
}
