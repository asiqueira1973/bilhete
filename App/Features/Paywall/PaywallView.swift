import BilheteCore
import StoreKit
import SwiftUI

/// Tela 10.5 — Bilhete Pro (épico 8.9).
///
/// Um produto, um preço, um botão. O paywall vende **capacidade e velocidade**,
/// nunca a função básica: escrever, fixar, ver na tela e arquivar continuam
/// inteiros na coluna grátis, para sempre (princípio P5 e matriz da seção 5).
///
/// Nunca aparece antes do momento de valor — a regra 11.10 é aplicada pelo
/// `ProGate`, antes desta tela existir na hierarquia.
struct PaywallView: View {
    @Environment(EntitlementStore.self) private var entitlement
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var restoring = false

    var body: some View {
        ZStack {
            Theme.fundoApp.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                capacidades
                Spacer(minLength: 12)
                if entitlement.state == .unavailable {
                    offlineNotice
                }
                comprarButton
                rodape
            }
            .padding(.horizontal, Theme.margin)
            .padding(.bottom, 16)
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.tintaSecundaria)
                    .tappableArea()
            }
            .accessibilityLabel(Text(loc: AppStrings.paywallClose))
            .padding(.trailing, 8)
        }
        .task {
            // Relê o StoreKit ao abrir: o app nunca decide direito pelo cache
            // (spec 7.4).
            await entitlement.carregar()
        }
    }

    // MARK: - Partes da tela

    /// Título e subtítulo (copy 15.17).
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "note.text")
                .font(.system(size: 44))
                .foregroundStyle(Theme.marca)
                .padding(.bottom, 4)

            Text(loc: AppStrings.paywallTitle)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(Theme.tinta)

            Text(loc: AppStrings.paywallSubtitle)
                .font(.title3)
                .foregroundStyle(Theme.tintaSecundaria)
        }
        .padding(.top, 48)
        .padding(.bottom, 32)
    }

    /// As cinco capacidades da matriz da seção 5, na copy 15.18.
    private var capacidades: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(AppStrings.paywallItems.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Theme.marca)
                        .frame(width: 24, height: 24)
                        .background(Theme.marca.opacity(0.12), in: .circle)

                    Text(item)
                        .font(.callout)
                        .foregroundStyle(Theme.tinta)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(20)
        .background(Theme.papel, in: .rect(cornerRadius: 20, style: .continuous))
    }

    /// Sem rede ou produto indisponível (copy 15.12).
    private var offlineNotice: some View {
        VStack(spacing: 4) {
            Text(loc: AppStrings.paywallOfflineTitle)
                .font(.footnote.weight(.semibold))
            Text(loc: AppStrings.paywallOfflineBody)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(Theme.tintaSecundaria)
        .padding(.bottom, 12)
    }

    /// O botão de compra, com o preço vindo do StoreKit (critério 8.9.2).
    @ViewBuilder
    private var comprarButton: some View {
        if entitlement.isPro {
            Text(loc: AppStrings.paywallOwned)
                .font(.headline)
                .foregroundStyle(Theme.sucesso)
                .frame(maxWidth: .infinity, minHeight: 50)
        } else {
            Button {
                Task {
                    if await entitlement.comprar() { dismiss() }
                }
            } label: {
                Group {
                    if entitlement.state == .purchasing {
                        ProgressView()
                    } else if let preco = entitlement.displayPrice {
                        Text(loc: AppStrings.paywallBuy(price: preco))
                    } else {
                        // Sem preço não há botão útil: a copy 15.12 já explica
                        // acima, e o botão fica desabilitado (critério 8.9.7).
                        Text(loc: AppStrings.paywallTitle)
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.marca)
            .disabled(entitlement.state == .unavailable || entitlement.state == .purchasing)
        }
    }

    /// Restaurar compras e o link de termos e privacidade (tela 10.5).
    private var rodape: some View {
        VStack(spacing: 10) {
            Button {
                restoring = true
                Task {
                    await entitlement.restaurar()
                    restoring = false
                }
            } label: {
                Text(loc: AppStrings.paywallRestore)
                    .font(.footnote)
                    .frame(minHeight: 44)
            }
            .disabled(restoring)

            Button {
                openURL(AppLinks.privacy)
            } label: {
                Text(loc: AppStrings.paywallTerms)
                    .font(.caption)
                    .frame(minHeight: 44)
            }
        }
        .tint(Theme.tintaSecundaria)
        .padding(.top, 8)
    }
}
