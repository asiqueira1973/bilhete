import StoreKitTest
import XCTest

/// Captura o print do paywall para o App Store Connect (tela 10.5).
///
/// O App Store Connect exige uma imagem da tela de compra na revisão do
/// in-app purchase `com.dablab.bilhete.pro`. O print precisa mostrar o preço
/// **vindo do StoreKit** (critério de aceite 8.9.2), e o preço só existe com a
/// loja local ligada — que é o que o `SKTestSession` faz.
///
/// Este alvo existe só para isso; não é suíte de regressão.
@MainActor
final class PaywallScreenshotTests: XCTestCase {

    /// Abre o app direto no paywall e salva a captura em disco.
    ///
    /// O arquivo sai no tamanho nativo do simulador; o redimensionamento para
    /// os 1242 × 2688 exigidos pela loja é feito fora, no script de captura.
    func testCapturePaywall() async throws {
        let session = try SKTestSession(configurationFileNamed: "Bilhete")
        session.disableDialogs = true
        session.clearTransactions()

        let app = XCUIApplication()
        // Afordância só de DEBUG: abre a tela 10.5 direto, sem precisar
        // percorrer o momento de valor da regra 11.10 a cada captura.
        // PT-BR é a versão canônica da copy (spec 15), e é o idioma da ficha
        // brasileira da loja.
        app.launchArguments = [
            "-BilheteCapturePaywall",
            "-AppleLanguages", "(pt-BR)",
            "-AppleLocale", "pt_BR"
        ]
        app.launch()

        // Espera o preço chegar do StoreKit antes de fotografar.
        let botaoDeCompra = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "R$")).firstMatch
        XCTAssertTrue(botaoDeCompra.waitForExistence(timeout: 15), "O preço do StoreKit não chegou ao paywall")

        let captura = XCUIScreen.main.screenshot()
        let destino = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(path: "bilhete-paywall-appstore.png")
        try captura.pngRepresentation.write(to: destino)

        // O caminho vai para o log, para o script de captura achar o arquivo.
        print("PAYWALL_SCREENSHOT_PATH=\(destino.path)")
    }
}
