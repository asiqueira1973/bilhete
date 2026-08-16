import BilheteCore
import SwiftUI

/// A direção visual da seção 16 do spec, em um lugar só.
///
/// A metáfora é papel (16.1): fundo levemente quente, cantos arredondados
/// generosos, sombra mínima e difusa, sem borda dura. O terracota da marca
/// aparece **pouco** — estado fixado, botão primário do paywall e seletor ativo
/// dos Ajustes — e nunca em erro ou confirmação destrutiva (16.2).
enum Theme {

    // MARK: - Cores (paleta exata da seção 16.2, via Asset Catalog)

    // A paleta vive no package, compartilhada com a widget extension (18.3).
    static let fundoApp = BilheteColors.fundoApp
    static let papel = BilheteColors.papel
    static let tinta = BilheteColors.tinta
    static let tintaSecundaria = BilheteColors.tintaSecundaria
    static let hairline = BilheteColors.hairline
    static let marca = BilheteColors.marca
    static let destrutivo = BilheteColors.destrutivo
    static let sucesso = BilheteColors.sucesso

    // MARK: - Métrica

    /// Margem lateral padrão (16.9): 20pt, sobre um grid de 4pt.
    static let margin: CGFloat = 20

    /// Raio dos cantos do papel (16.1): arredondamento generoso.
    static let paperCornerRadius: CGFloat = 24

    /// Entrelinha do corpo do bilhete (16.3).
    static let bodyLineSpacing: CGFloat = 4

    // MARK: - Tipografia (16.3)

    /// A fonte do corpo do bilhete.
    ///
    /// - Parameter preferences: de onde saem a fonte escolhida e o "texto
    ///   pequeno".
    /// - Returns: `.title2` regular por padrão; `.body` quando "texto pequeno"
    ///   está ligado, em todas as superfícies.
    ///
    /// O corpo do bilhete é o texto mais importante do app e precisa parecer
    /// escrito, não catalogado (16.3). A família segue a escolha da pessoa, já
    /// degradada para a padrão quando o Pro não está ativo (regra 11.11).
    static func noteFont(_ preferences: Preferences) -> Font {
        // Usa estilo de texto, e não tamanho fixo, para o Dynamic Type continuar
        // valendo até `.accessibility3` (spec 17).
        let style: Font.TextStyle = preferences.textoPequeno ? .body : .title2
        let design: Font.Design = switch preferences.fonteEfetiva {
        case .padrao: .default
        case .mono: .monospaced
        case .serifada: .serif
        }
        return .system(style, design: design)
    }

    /// Traduz a preferência de aparência para o esquema de cor da SwiftUI.
    ///
    /// - Parameter aparencia: a escolha da pessoa nos Ajustes (7.3).
    /// - Returns: `nil` para "sistema", que deixa o iOS decidir.
    static func colorScheme(_ aparencia: Aparencia) -> ColorScheme? {
        switch aparencia {
        case .sistema: nil
        case .claro: .light
        case .escuro: .dark
        }
    }
}
