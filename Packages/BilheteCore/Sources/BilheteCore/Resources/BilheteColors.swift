import SwiftUI

/// A paleta da seção 16.2 do spec, compartilhada entre o app e a widget
/// extension.
///
/// Mora no package, e não no catálogo do app, porque a extension é um bundle
/// separado e precisa das mesmas cores — e a regra 18.3 proíbe duplicar arquivo
/// entre targets. As cores vêm do `Colors.xcassets` do próprio package, lido por
/// `Bundle.module`.
///
/// Separação estrita entre cor de marca e cor semântica (16.2): o terracota
/// aparece pouco e **nunca** em erro ou confirmação destrutiva.
public enum BilheteColors {
    /// Fundo do app: areia no claro, quase preto no escuro.
    public static let fundoApp = Color("FundoApp", bundle: .module)

    /// O papel — o cartão do bilhete (metáfora da seção 16.1).
    public static let papel = Color("Papel", bundle: .module)

    /// Tinta: o texto principal.
    public static let tinta = Color("Tinta", bundle: .module)

    /// Tinta secundária: datas, contadores, rótulos.
    public static let tintaSecundaria = Color("TintaSecundaria", bundle: .module)

    /// Hairline e divisórias.
    public static let hairline = Color("Hairline", bundle: .module)

    /// Terracota da marca. Puxa da cerâmica e do barro, não do amarelo de
    /// post-it (16.2).
    public static let marca = Color("BrandTerracota", bundle: .module)

    /// Semântica — destrutivo. Nunca o terracota.
    public static let destrutivo = Color("Destrutivo", bundle: .module)

    /// Semântica — sucesso e estado fixado.
    public static let sucesso = Color("Sucesso", bundle: .module)
}
