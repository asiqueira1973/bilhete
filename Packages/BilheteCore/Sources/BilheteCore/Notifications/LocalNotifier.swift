import Foundation
import UserNotifications

/// Notificações locais do Bilhete.
///
/// O app tem **uma única** notificação de produto — o aviso de expiração do
/// destaque (regra 11.7, épico 8.7). As outras duas existem porque as
/// superfícies que as disparam **não têm tela para mostrar erro**: o Controle da
/// Central de Controle não tem UI (L10, L13), então avisa por aqui.
///
/// Nenhuma delas carrega texto do bilhete além do necessário, e nenhuma sai do
/// aparelho (spec 20).
@MainActor
public enum LocalNotifier {

    /// Identificadores fixos, para uma notificação substituir a anterior em vez
    /// de empilhar.
    private enum ID {
        static let proNotice = "bilhete.pro-notice"
        static let controlFailure = "bilhete.control-failure"
    }

    /// Avisa que a capacidade acionada é do Pro (copy 15.8).
    ///
    /// Implementa o critério 8.6.9 no caso do Controle e do Botão de Ação, que
    /// não têm como abrir um alerta: a notificação leva ao app, e é lá que o
    /// paywall aparece — respeitando a regra 11.10.
    public static func avisarCapacidadePro() {
        entregar(
            id: ID.proNotice,
            titulo: String(localized: CoreStrings.proNoticeTitle),
            corpo: String(localized: CoreStrings.proNoticeBody)
        )
    }

    /// Avisa que a fixação pelo Controle falhou (copy 15.15).
    ///
    /// É o tratamento de falha da seção 12 para `Activity.request` dentro de um
    /// Controle: falha em silêncio na superfície e explica por notificação.
    public static func avisarFalhaDoControle() {
        entregar(
            id: ID.controlFailure,
            titulo: String(localized: CoreStrings.controlFailureTitle),
            corpo: String(localized: CoreStrings.controlFailureBody)
        )
    }

    /// Entrega uma notificação imediata, se houver permissão.
    ///
    /// - Parameters:
    ///   - id: identificador; repetido de propósito para substituir a anterior.
    ///   - titulo: título da notificação.
    ///   - corpo: corpo da notificação.
    ///
    /// **Não pede permissão aqui.** A permissão é pedida uma única vez, na
    /// primeira fixação (critério 8.7.5): pedir a partir de um Controle seria
    /// pedir do nada, com o app fechado.
    private static func entregar(id: String, titulo: String, corpo: String) {
        let centro = UNUserNotificationCenter.current()
        let conteudo = UNMutableNotificationContent()
        conteudo.title = titulo
        conteudo.body = corpo
        conteudo.sound = .default

        let pedido = UNNotificationRequest(identifier: id, content: conteudo, trigger: nil)
        centro.add(pedido)
    }
}
