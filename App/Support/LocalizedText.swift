import BilheteCore
import Foundation
import SwiftUI

/// Resolve as strings no idioma escolhido nos Ajustes.
///
/// Trocar o `Bundle.main` sozinho não bastava: `String(localized:)` resolve no
/// instante da chamada e não observa a troca, então os rótulos continuavam no
/// idioma do iPhone — foi o que apareceu no teste em aparelho. Aqui o idioma é
/// aplicado **em cada resolução**, marcando o `locale` do próprio recurso.
extension LocalizedStringResource {

    /// O mesmo recurso, resolvido no idioma escolhido.
    ///
    /// - Returns: cópia com o `locale` da preferência; inalterado quando a
    ///   escolha é "sistema", que é o comportamento do critério 8.11.3.
    var no: LocalizedStringResource {
        guard let identifier = Preferences.shared.idioma.localeIdentifier else { return self }
        var copia = self
        copia.locale = Locale(identifier: identifier)
        return copia
    }
}

extension String {
    /// Texto já resolvido no idioma escolhido.
    ///
    /// - Parameter resource: a chave do String Catalog.
    /// - Returns: a string pronta para um rótulo de botão.
    static func loc(_ resource: LocalizedStringResource) -> String {
        String(localized: resource.no)
    }
}

extension Text {
    /// `Text` resolvido no idioma escolhido.
    ///
    /// - Parameter resource: a chave do String Catalog.
    ///
    /// Resolve para `String` **antes** de construir o `Text`: passar o recurso
    /// direto faz a SwiftUI ignorar o `locale` marcado nele e usar o idioma do
    /// sistema — foi por isso que só metade da tela traduzia no teste.
    init(loc resource: LocalizedStringResource) {
        self.init(verbatim: String.loc(resource))
    }
}
