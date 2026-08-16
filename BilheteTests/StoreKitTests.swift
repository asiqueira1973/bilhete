import Foundation
import StoreKit
import StoreKitTest
import Testing
@testable import BilheteCore

/// A compra do Bilhete Pro (épico 8.9, spec 13.4).
///
/// Usa `SKTestSession` com o `Bilhete.storekit` — a loja local do StoreKit
/// Testing. É o que o spec 22 pede: compra bem-sucedida, cancelada, restaurada
/// e **revogada**, que é a que costuma faltar e é a que a regra 11.11 governa.
///
/// O `StoreKitTest` só existe em alvo de teste. Ele **não** é linkado ao app —
/// tentar isso é o caminho mais curto para um binário que a loja rejeita.
@MainActor
@Suite("StoreKit (épico 8.9)", .serialized)
struct StoreKitTests {

    /// Abre a loja local e devolve o `EntitlementStore` apontando para ela.
    ///
    /// A sessão é **do simulador**, não do objeto: qualquer instância viva
    /// afeta o mesmo ambiente. Por isso a limpeza acontece no começo de cada
    /// caso, e não no fim — limpar no fim de um caso apagava a compra do caso
    /// seguinte.
    /// A loja local, criada **uma vez** e mantida viva.
    ///
    /// Quando o objeto da sessão é liberado, a loja local do simulador cai
    /// junto — e o caso seguinte encontrava zero produtos. Uma sessão por suíte
    /// resolve, e o estado é zerado no começo de cada caso.
    private static let sharedSession: SKTestSession? = {
        let session = try? SKTestSession(configurationFileNamed: "Bilhete")
        session?.disableDialogs = true
        return session
    }()

    private func makeSession() throws -> (SKTestSession, EntitlementStore, Preferences) {
        let session = try #require(Self.sharedSession, "Loja local do StoreKit não abriu")
        // Sem diálogo do sistema a compra completa sozinha, que é o que permite
        // testar o fluxo inteiro sem UI.
        session.disableDialogs = true
        session.askToBuyEnabled = false
        session.failTransactionsEnabled = false

        let suite = UserDefaults(suiteName: "bilhete.tests.\(UUID().uuidString)")!
        let preferences = Preferences(defaults: suite)
        return (session, EntitlementStore(preferences: preferences), preferences)
    }

    /// Carrega o produto com nova tentativa.
    ///
    /// A loja local do simulador recusa consultas em rajada logo depois de um
    /// `clearTransactions`, e devolve erro em vez de lista vazia. Isso é
    /// flakiness do ambiente de teste, não do app: o estado "sem produto" real
    /// é o da copy 15.12, e tem caso próprio.
    private func loadProduct(_ entitlement: EntitlementStore) async {
        for _ in 0..<8 {
            await entitlement.carregar()
            if entitlement.product != nil { return }
            try? await Task.sleep(for: .milliseconds(250))
        }
    }

    /// Espera o direito aparecer em `Transaction.currentEntitlements`.
    ///
    /// A loja local registra a compra de forma assíncrona: ler os direitos no
    /// instante seguinte ao `buyProduct` ainda devolve vazio.
    private func awaitPro(_ entitlement: EntitlementStore) async {
        for _ in 0..<15 {
            await entitlement.carregar()
            if entitlement.isPro { return }
            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    /// Zera as compras e espera a loja local assentar.
    ///
    /// Consultar produto imediatamente depois de limpar transações devolve
    /// erro; a pausa é do ambiente de teste, não do app.
    private func reset(_ session: SKTestSession) async {
        session.clearTransactions()
        try? await Task.sleep(for: .milliseconds(250))
    }

    @Test("8.9.2 — o preço vem do StoreKit localizado, nunca de string fixa")
    func priceComesFromStoreKit() async throws {
        let (session, entitlement, _) = try makeSession()

        await entitlement.carregar()

        let produto = try #require(entitlement.product)
        #expect(produto.id == AppConfig.proProductID)
        // `displayPrice` já vem formatado na moeda e na região do aparelho
        // (critério 8.11.4).
        #expect(entitlement.displayPrice?.isEmpty == false)
        #expect(entitlement.state == .ready)
    }

    @Test("8.9.3 — concluída a compra, o Pro fica ativo e o cache é atualizado")
    func purchaseUnlocksPro() async throws {
        let (session, entitlement, preferences) = try makeSession()
        await reset(session)

        await loadProduct(entitlement)
        #expect(entitlement.isPro == false)

        // A compra é feita pela loja local, não pelo `product.purchase()`: o
        // fluxo de compra do StoreKit precisa da folha do sistema na tela, e um
        // alvo de teste unitário não tem cena para apresentá-la. O que este caso
        // prova é o que o app é dono: ler o direito e espelhar no cache. O toque
        // no botão de compra está na validação manual da seção 22.
        try await session.buyProduct(identifier: AppConfig.proProductID)
        await awaitPro(entitlement)

        #expect(entitlement.isPro)
        // O espelho existe para a widget extension aplicar o gating sem
        // acessar o StoreKit (spec 7.4).
        #expect(preferences.proDesbloqueado)
        #expect(entitlement.state == .owned)
    }

    @Test("8.9.6 — compra interrompida volta ao estado anterior, sem liberar nada")
    func interruptedPurchaseChangesNothing() async throws {
        let (session, entitlement, preferences) = try makeSession()
        await reset(session)
        await loadProduct(entitlement)
        #expect(entitlement.state == .ready)

        // A loja local recusa a transação — é o mais perto que dá de simular,
        // sem UI, uma compra que não se completa. O cancelamento pelo próprio
        // usuário só se reproduz com o diálogo do sistema na tela, e está na
        // lista de validação manual da seção 22.
        session.failTransactionsEnabled = true
        let comprou = await entitlement.comprar()

        #expect(comprou == false)
        #expect(entitlement.isPro == false)
        // Nenhuma capacidade é liberada por engano (spec 12, tratamento de
        // falha do StoreKit).
        #expect(preferences.proDesbloqueado == false)
        session.failTransactionsEnabled = false
    }

    @Test("8.9.4 — restaurar relê os direitos e devolve o Pro")
    func restoreBringsProBack() async throws {
        let (session, entitlement, _) = try makeSession()
        await reset(session)

        await loadProduct(entitlement)
        try await session.buyProduct(identifier: AppConfig.proProductID)
        await awaitPro(entitlement)
        #expect(entitlement.isPro)

        // Simula aparelho novo com o mesmo Apple ID: o direito continua no
        // StoreKit, o app relê e libera sem cobrar de novo.
        await entitlement.restaurar()

        #expect(entitlement.isPro)
        #expect(entitlement.state == .owned)
    }

    @Test("11.11 — revogar o direito não apaga nada e volta a barrar novos ativos")
    func revocationKeepsDataAndBlocksCreation() async throws {
        let (session, entitlement, preferences) = try makeSession()
        await reset(session)

        await loadProduct(entitlement)
        try await session.buyProduct(identifier: AppConfig.proProductID)
        await awaitPro(entitlement)
        #expect(entitlement.isPro)

        // Monta um store com dados acima dos limites do plano grátis.
        let h = try TestHarness(isPro: true)
        try h.makeFeatured(texto: "um")
        for indice in 2...5 { try h.store.create(texto: "bilhete \(indice)") }
        let ativosAntes = h.store.activeCount()

        // Reembolso / chargeback: o StoreKit deixa de listar a transação como
        // direito ativo. `clearTransactions` é o equivalente da loja local.
        await reset(session)
        await entitlement.carregar()

        #expect(entitlement.isPro == false)
        #expect(preferences.proDesbloqueado == false)
        // Nenhum dado é apagado (regra 11.11): os 5 ativos continuam legíveis.
        #expect(h.store.activeCount() == ativosAntes)
        // E criar novo ativo volta a ser bloqueado até voltar a 3.
        h.entitlement.isPro = false
        #expect(throws: BilheteStoreError.limitReached(limit: 3)) {
            try h.store.create(texto: "não deveria entrar")
        }
        h.expectInvariantsHold()
    }
}
