import BilheteCore
import SwiftUI

/// Tela 10.7 — "Como colocar na tela de bloqueio" (épico 8.7).
///
/// Esta é a resposta do produto ao cenário mais provável de desinstalação
/// (spec 9.4): a pessoa não descobre sozinha que existe um widget, que ele
/// precisa ser adicionado à mão, nem que a Live Activity expira.
///
/// Três blocos, na ordem que importa: o widget (a camada permanente, L2), o
/// Controle (o refixar de um toque, L6) e a explicação de por que o destaque sai
/// da tela (L1). É a métrica M4 do spec 21 que mede se esta tela funcionou.
struct LockScreenGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Preferences.self) private var preferences

    var body: some View {
        ZStack {
            Theme.fundoApp.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    step(
                        number: 1,
                        symbol: "rectangle.on.rectangle.angled",
                        title: AppStrings.guideStep1Title,
                        body: AppStrings.guideStep1Body
                    )
                    step(
                        number: 2,
                        symbol: "pin.fill",
                        title: AppStrings.guideStep2Title,
                        body: AppStrings.guideStep2Body
                    )
                    step(
                        number: 3,
                        symbol: "clock.arrow.circlepath",
                        title: AppStrings.guideStep3Title,
                        body: AppStrings.guideStep3Body
                    )

                    Button { dismiss() } label: {
                        Text(loc: AppStrings.guideDone)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.marca)
                    .padding(.top, 8)
                }
                .padding(Theme.margin)
            }
        }
        .navigationTitle(Text(loc: AppStrings.guideTitle))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Marca como vista: o app nunca insiste mais de duas vezes no total
            // (spec 9.4, item 4).
            preferences.dicaWidgetVista = true
        }
    }

    /// Um bloco do passo a passo.
    ///
    /// - Parameters:
    ///   - number: a ordem do passo.
    ///   - symbol: o símbolo SF que ilustra o bloco.
    ///   - title: o título do bloco.
    ///   - body: a explicação.
    private func step(
        number: Int,
        symbol: String,
        title: LocalizedStringResource,
        body: LocalizedStringResource
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Theme.marca)
                .frame(width: 44, height: 44)
                .background(Theme.marca.opacity(0.12), in: .circle)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.tinta)
                Text(body)
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

/// O cartão dispensável do rodapé do destaque (spec 9.4, item 1).
///
/// Aparece **uma única vez**, e só depois de a pessoa já ter fixado pelo menos
/// uma vez — antes disso ela ainda não viu o problema que este cartão resolve.
/// Nunca é modal: interromper para ensinar contraria o princípio P2.
struct LockScreenGuideCard: View {
    /// Chamado quando a pessoa toca no cartão para abrir a tela 10.7.
    let onOpen: () -> Void
    /// Chamado quando a pessoa dispensa o cartão.
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lock.rectangle.on.rectangle")
                .font(.title3)
                .foregroundStyle(Theme.marca)

            VStack(alignment: .leading, spacing: 2) {
                Text(loc: AppStrings.guideCardTitle)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.tinta)
                Text(loc: AppStrings.guideCardBody)
                    .font(.caption)
                    .foregroundStyle(Theme.tintaSecundaria)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.tintaSecundaria)
                    .tappableArea()
            }
            .accessibilityLabel(Text(loc: AppStrings.actionCancel))
        }
        .padding(12)
        .background(Theme.papel, in: .rect(cornerRadius: 16, style: .continuous))
        .contentShape(.rect)
        .onTapGesture(perform: onOpen)
    }
}
