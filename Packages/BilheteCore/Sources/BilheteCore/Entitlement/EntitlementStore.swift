import Foundation
import StoreKit
import WidgetKit

/// Estado da compra, para a tela 10.5 saber o que mostrar.
public enum PurchaseState: Equatable, Sendable {
    /// Buscando o produto no StoreKit.
    case loading
    /// Produto carregado e pronto para comprar.
    case ready
    /// Compra em andamento.
    case purchasing
    /// Sem rede ou produto indisponível — copy 15.12, botão desabilitado.
    case unavailable
    /// Já é Pro.
    case owned
}

/// O direito de compra do Bilhete Pro (spec 13.4 e 7.4).
///
/// A **fonte de verdade é o StoreKit**: `Transaction.currentEntitlements`, lido
/// no lançamento e observado por `Transaction.updates`. O valor é espelhado em
/// `preferencias.pro_desbloqueado` **exclusivamente** para a widget extension
/// poder aplicar o gating sem acessar o StoreKit — o app nunca decide direito
/// pelo cache.
///
/// Produto único, não-consumível: sem servidor, verificação criptográfica JWS no
/// próprio aparelho (spec 4.1).
@MainActor
@Observable
public final class EntitlementStore: EntitlementProviding {

    /// `true` quando o Bilhete Pro está ativo.
    public private(set) var isPro: Bool

    /// Estado da tela de compra (10.5).
    public private(set) var state: PurchaseState = .loading

    /// O produto do StoreKit, de onde sai o preço localizado.
    ///
    /// O preço **nunca** vem de string fixa no código (critério 8.9.2): vem
    /// daqui, já formatado na moeda e na região do aparelho.
    public private(set) var product: Product?

    @ObservationIgnored private let preferences: Preferences
    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    /// Cria o store de direito.
    /// - Parameter preferences: onde o direito é espelhado para a extension.
    public init(preferences: Preferences = .shared) {
        self.preferences = preferences
        // Começa pelo cache só para não piscar a UI; `carregar()` corrige em
        // seguida com o que o StoreKit disser.
        self.isPro = preferences.proDesbloqueado
    }

    /// Preço já formatado para exibir (critério 8.9.2).
    ///
    /// - Returns: o preço localizado do StoreKit, ou `nil` enquanto o produto
    ///   não carregou.
    public var displayPrice: String? { product?.displayPrice }

    /// Lê o direito atual e o produto.
    ///
    /// Chamado no lançamento e ao abrir o paywall. Relê o StoreKit sempre — o
    /// cache das preferências existe para a extension, não para o app (7.4).
    public func carregar() async {
        await atualizarDireito()

        do {
            let produtos = try await Product.products(for: [AppConfig.proProductID])
            product = produtos.first
            if state != .purchasing {
                // Sem produto não há o que comprar: a tela mostra a copy 15.12 e
                // desabilita o botão (critério 8.9.7).
                state = isPro ? .owned : (product == nil ? .unavailable : .ready)
            }
        } catch {
            state = isPro ? .owned : .unavailable
        }
    }

    /// Observa as mudanças de transação enquanto o app viver.
    ///
    /// Iniciada no `App.init` (critério 8.9.5). Captura compra feita em outro
    /// aparelho, Ask to Buy, código promocional e **revogação** — que é tratada
    /// pela regra 11.11: nenhum dado é apagado.
    public func observar() {
        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            for await resultado in Transaction.updates {
                guard let self else { return }
                if case .verified(let transacao) = resultado {
                    await transacao.finish()
                }
                await self.atualizarDireito()
            }
        }
    }

    /// Compra o Bilhete Pro.
    ///
    /// - Returns: `true` quando a compra foi concluída e verificada.
    ///
    /// Cancelar no meio volta ao estado anterior sem erro e sem alterar nada
    /// (critério 8.9.6). A transação é finalizada com `finish()`, obrigatório —
    /// sem isso o StoreKit reapresenta a compra para sempre.
    @discardableResult
    public func comprar() async -> Bool {
        guard let product else { return false }
        state = .purchasing

        do {
            let resultado = try await product.purchase()
            switch resultado {
            case .success(let verificacao):
                guard case .verified(let transacao) = verificacao else {
                    // Assinatura JWS inválida: não libera nada. Melhor não
                    // vender do que liberar por engano.
                    state = .ready
                    return false
                }
                await transacao.finish()
                await atualizarDireito()
                return true

            case .userCancelled:
                state = isPro ? .owned : .ready
                return false

            case .pending:
                // Ask to Buy: quem resolve é o listener de `Transaction.updates`.
                state = .ready
                return false

            @unknown default:
                state = .ready
                return false
            }
        } catch {
            state = .unavailable
            return false
        }
    }

    /// Restaura compras (critério 8.9.4).
    ///
    /// `AppStore.sync()` seguido de releitura de `currentEntitlements`. O botão
    /// existe por exigência de App Review, não por necessidade técnica (spec 6).
    public func restaurar() async {
        try? await AppStore.sync()
        await carregar()
    }

    /// Relê `Transaction.currentEntitlements` e espelha no cache.
    ///
    /// Aplica a regra 11.11 na prática: ao perder o direito, o app **não apaga
    /// nada** — só volta a barrar a criação de novos ativos e devolve a fonte
    /// padrão. Quem faz isso é o `BilheteStore` e as `Preferences`, lendo este
    /// valor.
    private func atualizarDireito() async {
        var ativo = false
        for await resultado in Transaction.currentEntitlements {
            if case .verified(let transacao) = resultado,
               transacao.productID == AppConfig.proProductID,
               transacao.revocationDate == nil {
                ativo = true
            }
        }

        isPro = ativo
        preferences.proDesbloqueado = ativo
        state = ativo ? .owned : (product == nil ? .unavailable : .ready)
        // A extension precisa saber na hora: o gating dela sai do cache.
        WidgetCenter.shared.reloadAllTimelines()
    }
}
