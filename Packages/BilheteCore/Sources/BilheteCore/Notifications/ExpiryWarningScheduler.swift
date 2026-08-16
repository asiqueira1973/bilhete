import Foundation
import UserNotifications
import WidgetKit

/// O aviso de expiração do destaque (regra 11.7, épico 8.7).
///
/// É **a única notificação de produto do Bilhete**. Existe por causa da persona
/// P-C: se o bilhete sumir da tela sem explicação, ela conclui que o app não
/// funciona e desinstala (spec 2). O aviso chega 30 minutos antes, com uma ação
/// de refixar.
///
/// A ação precisa abrir o app porque iniciar Live Activity exige foreground
/// (L4) — é a única ação do produto que abre o app por imposição da
/// plataforma, e a copy 15.9 reflete isso.
/// É `@Observable` para poder ser injetado no ambiente da SwiftUI.
@MainActor
@Observable
public final class ExpiryWarningScheduler: ExpiryWarningScheduling {

    /// Categoria da notificação, com a ação "Refixar".
    public static let categoryID = "bilhete.expiry"

    /// Identificador da ação "Refixar" (critério 8.7.6).
    public static let repinActionID = "bilhete.expiry.repin"

    private let preferences: Preferences
    private let center: UNUserNotificationCenter

    /// Cria o agendador.
    /// - Parameters:
    ///   - preferences: onde mora `avisarExpiracao` (7.3) e o controle de
    ///     permissão já pedida.
    ///   - center: o centro de notificações; injetável para teste.
    public init(
        preferences: Preferences = .shared,
        center: UNUserNotificationCenter = .current()
    ) {
        self.preferences = preferences
        self.center = center
    }

    /// Registra a categoria com a ação "Refixar".
    ///
    /// Chamado no lançamento do app. Sem a categoria registrada, a notificação
    /// chega sem botão.
    public func registrarCategoria() {
        let refixar = UNNotificationAction(
            identifier: Self.repinActionID,
            title: String(localized: CoreStrings.expiryActionRepin),
            // Abre o app de propósito: iniciar Live Activity exige foreground
            // (L4). Não dá para refixar de dentro da notificação.
            options: [.foreground]
        )
        let categoria = UNNotificationCategory(
            identifier: Self.categoryID,
            actions: [refixar],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([categoria])
    }

    /// Pede permissão de notificação **uma única vez**, na primeira fixação.
    ///
    /// - Returns: `true` se a permissão foi concedida ou já existia.
    ///
    /// Critério de aceite 8.7.5: o app não pede de novo a cada fixação. A copy
    /// 15.10 aparece **antes** deste pedido, na tela, explicando por que o
    /// sistema vai perguntar.
    @discardableResult
    public func pedirPermissaoSeNecessario() async -> Bool {
        let estado = await center.notificationSettings().authorizationStatus
        guard estado == .notDetermined else {
            preferences.permissaoNotificacaoPedida = true
            return estado == .authorized
        }

        preferences.permissaoNotificacaoPedida = true
        return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Agenda o aviso para `fixadoAte − 30 min` (regra 11.7).
    ///
    /// - Parameters:
    ///   - bilhete: o bilhete recém-fixado.
    ///   - fixadoAte: quando a fixação expira.
    ///
    /// Não agenda nada quando `avisarExpiracao` está desligado (critério 8.7.4)
    /// nem quando os 30 minutos já passaram. O identificador é derivado do id do
    /// bilhete, então refixar **substitui** o aviso anterior em vez de empilhar
    /// (critério 8.7.3).
    public func agendar(for bilhete: Bilhete, fixadoAte: Date) {
        cancelar(for: bilhete)
        guard preferences.avisarExpiracao else { return }

        let disparo = fixadoAte.addingTimeInterval(-BilheteStore.expiryWarningLead)
        let segundos = disparo.timeIntervalSinceNow
        guard segundos > 0 else { return }

        let texto = bilhete.texto
        let id = Self.identifier(for: bilhete)

        // A escolha da copy depende de a pessoa ter ou não o widget na tela de
        // bloqueio (spec 9.4, item 2): sem widget, o aviso ensina em vez de só
        // avisar.
        Task { [center] in
            let temWidget = await Self.temWidgetDeTelaDeBloqueio()
            let conteudo = UNMutableNotificationContent()
            conteudo.title = String(localized: CoreStrings.expiryTitle)
            conteudo.body = temWidget
                ? texto
                : String(localized: CoreStrings.expiryBodyNoWidget)
            conteudo.categoryIdentifier = Self.categoryID
            conteudo.sound = .default

            let gatilho = UNTimeIntervalNotificationTrigger(timeInterval: segundos, repeats: false)
            let pedido = UNNotificationRequest(identifier: id, content: conteudo, trigger: gatilho)
            try? await center.add(pedido)
        }
    }

    /// Cancela o aviso agendado do bilhete.
    ///
    /// - Parameter bilhete: o bilhete que deixou de estar fixado.
    ///
    /// Critério de aceite 8.7.2: soltar, arquivar, excluir ou trocar o destaque
    /// cancelam o aviso. Quem chama é o `PinService`, no `soltar`.
    public func cancelar(for bilhete: Bilhete) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: bilhete)])
    }

    /// Identificador estável do aviso de um bilhete.
    ///
    /// - Parameter bilhete: o bilhete.
    /// - Returns: `bilhete.expiry.<uuid>` — derivado do id, e é isso que impede
    ///   duas notificações agendadas para o mesmo bilhete (critério 8.7.3).
    public static func identifier(for bilhete: Bilhete) -> String {
        "\(categoryID).\(bilhete.id.uuidString)"
    }

    /// Diz se a pessoa tem algum widget do Bilhete na tela de bloqueio.
    ///
    /// - Returns: `true` quando existe widget `accessoryRectangular` ou
    ///   `accessoryInline` instalado.
    ///
    /// Serve para escolher entre a copy 15.9a e a 15.9b: quem já tem o widget
    /// não precisa de aula, quem não tem precisa (spec 9.4).
    private static func temWidgetDeTelaDeBloqueio() async -> Bool {
        let configs = try? await WidgetCenter.shared.currentConfigurations()
        return configs?.contains { $0.family == .accessoryRectangular || $0.family == .accessoryInline } ?? false
    }
}
