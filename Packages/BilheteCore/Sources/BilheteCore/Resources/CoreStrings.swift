import Foundation

/// Strings que os intents e as notificações precisam, dentro e fora do app.
///
/// Ficam no package porque quem as usa roda em vários processos — o app, a
/// widget extension, a Siri e os Atalhos. O catálogo é o
/// `Localizable.xcstrings` do próprio `BilheteCore`, lido por `Bundle.module`.
public enum CoreStrings {

    /// Aviso 15.8, mostrado quando um Controle ou a Siri é acionado sem Pro
    /// (critério de aceite 8.6.9).
    public static let proNoticeTitle = resource("core.pro.notice.title")
    public static let proNoticeBody = resource("core.pro.notice.body")

    /// Copy 15.15 — o Controle falhou. Ele não tem UI para erro (L10, L13),
    /// então falha em silêncio e avisa por notificação local (spec 12).
    public static let controlFailureTitle = resource("core.control.failure.title")
    public static let controlFailureBody = resource("core.control.failure.body")

    /// Aviso de expiração do destaque (copy 15.9a e 15.9b, regra 11.7).
    ///
    /// O corpo tem duas variantes: com o widget já na tela de bloqueio, mostra o
    /// próprio bilhete; sem o widget, ensina a colocar (spec 9.4, item 2).
    public static let expiryTitle = resource("core.expiry.title")
    public static let expiryBodyNoWidget = resource("core.expiry.body.noWidget")
    public static let expiryActionRepin = resource("core.expiry.action.repin")

    /// Confirmações por voz da Siri (critério 8.6.6).
    public static let siriCreated = resource("core.siri.created")
    public static let siriPinned = resource("core.siri.pinned")

    /// Monta a referência apontando para o catálogo do package.
    /// - Parameter key: a chave no `Localizable.xcstrings` do `BilheteCore`.
    /// - Returns: o recurso localizado.
    private static func resource(_ key: String.LocalizationValue) -> LocalizedStringResource {
        LocalizedStringResource(key, bundle: .atURL(Bundle.module.bundleURL))
    }
}
