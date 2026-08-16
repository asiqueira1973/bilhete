import BilheteCore
import Foundation
import UserNotifications

/// Trata o toque na notificação de expiração (critério de aceite 8.7.6).
///
/// A ação "Refixar" **abre o app** por imposição da plataforma: iniciar Live
/// Activity exige foreground (L4). É a única ação do produto que abre o app sem
/// a pessoa pedir, e a copy 15.9 já avisa disso.
@MainActor
final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {

    private let store: BilheteStore
    private let pin: PinService

    /// Cria o tratador.
    /// - Parameters:
    ///   - store: para achar o bilhete em destaque (regra 11.1).
    ///   - pin: para refixar de fato (regras 11.6 e 11.8).
    init(store: BilheteStore, pin: PinService) {
        self.store = store
        self.pin = pin
        super.init()
    }

    /// Responde ao toque na notificação.
    ///
    /// - Parameters:
    ///   - center: o centro de notificações.
    ///   - response: a resposta da pessoa, com o identificador da ação.
    ///
    /// Só a ação "Refixar" faz algo: tocar no corpo apenas abre o app, que já
    /// abre no bilhete em destaque (regra 11.1 garante que só existe um).
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard response.actionIdentifier == ExpiryWarningScheduler.repinActionID,
              let bilhete = store.featured()
        else { return }

        // Refixa automaticamente: a pessoa já disse o que queria ao tocar na
        // ação, pedir confirmação de novo seria um toque a mais contra o P2.
        try? pin.fixar(bilhete)
    }

    /// Mostra a notificação mesmo com o app aberto.
    ///
    /// Se o destaque vai expirar em 30 minutos, isso importa igual com o app na
    /// frente — e é a única notificação que o produto tem.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
