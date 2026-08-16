import BilheteCore
import SwiftUI

/// Estado compartilhado do gating de capacidades Pro (matriz da seção 5).
///
/// Existe para que qualquer tela peça "abrir o Pro" de um jeito só, e para que a
/// regra 11.10 seja aplicada em um lugar só: antes do momento de valor — bilhete
/// com texto **e** ao menos uma fixação — a pessoa vê apenas o aviso de 15.8, e
/// a compra não abre.
@MainActor
@Observable
final class ProGate {
    /// Verdadeiro quando o aviso de 15.8 está na tela.
    var showingNotice = false

    /// Verdadeiro quando o paywall (tela 10.5) está na tela.
    var showingPaywall = false

    @ObservationIgnored private let gate: PaywallGate
    @ObservationIgnored private let store: BilheteStore

    /// Cria o gating.
    /// - Parameters:
    ///   - store: usado para saber se já existe bilhete com texto (11.10).
    ///   - preferences: onde mora `jaFixouAlgumaVez` (11.10).
    init(store: BilheteStore, preferences: Preferences) {
        self.store = store
        self.gate = PaywallGate(preferences: preferences)
    }

    /// Reage a uma capacidade Pro que a pessoa tentou usar.
    ///
    /// Implementa a regra 11.10: depois do momento de valor abre o paywall;
    /// antes dele mostra só o aviso de 15.8, sem oferecer a compra.
    func requestPro() {
        switch gate.outcome(hasNoteWithText: store.hasNoteWithText()) {
        case .openPaywall: showingPaywall = true
        case .showProNotice: showingNotice = true
        }
    }

    /// Diz se o aviso deve oferecer o caminho para a compra.
    ///
    /// - Returns: `true` quando o momento de valor já passou. Serve para o
    ///   botão "Ver o Pro" não aparecer antes da hora (regra 11.10).
    var canOfferPurchase: Bool {
        gate.hasReachedValueMoment(hasNoteWithText: store.hasNoteWithText())
    }
}

/// Apresenta o aviso 15.8 e, depois do momento de valor, o paywall (10.5).
struct ProGateModifier: ViewModifier {
    @Bindable var gate: ProGate

    func body(content: Content) -> some View {
        content
            .alert(
                Text(loc: AppStrings.proNoticeTitle),
                isPresented: $gate.showingNotice
            ) {
                if gate.canOfferPurchase {
                    Button(String.loc(AppStrings.proNoticeSee)) { gate.showingPaywall = true }
                }
                Button(String.loc(AppStrings.actionCancel), role: .cancel) {}
            } message: {
                Text(loc: AppStrings.proNoticeBody)
            }
            .sheet(isPresented: $gate.showingPaywall) {
                PaywallView()
            }
    }
}

extension View {
    /// Liga a tela ao gating de Pro (seção 5 e regra 11.10).
    /// - Parameter gate: o estado compartilhado do gating.
    func proGate(_ gate: ProGate) -> some View {
        modifier(ProGateModifier(gate: gate))
    }
}
