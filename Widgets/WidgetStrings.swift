import Foundation

/// Strings das superfícies do sistema (widgets, Live Activity e Controles).
///
/// A widget extension é um bundle separado, então ela tem o próprio String
/// Catalog — o do app não é visível daqui. As chaves seguem a mesma convenção e
/// a copy é a da seção 15 do spec.
enum WidgetStrings {

    /// Botão "Concluir" da Live Activity (S5/S8) e dos widgets de tela de início
    /// (S3/S4).
    static let actionDone = LocalizedStringResource("widget.action.done")

    /// Botão "Soltar" da Live Activity (S5/S8).
    static let actionUnpin = LocalizedStringResource("widget.action.unpin")

    /// Estado sem bilhete em destaque com texto (copy 15.7).
    static let empty = LocalizedStringResource("widget.empty")
}

extension WidgetStrings {
    /// Botão "Fixar" do `systemMedium` (S4).
    static let actionPin = LocalizedStringResource("widget.action.pin")

    // MARK: - Nomes e descrições de galeria (spec 15)
    //
    // Aparecem na galeria de widgets do sistema, em PT-BR e EN
    // (critério de aceite 8.5.1).

    static let galleryRectangularName = LocalizedStringResource("widget.gallery.rectangular.name")
    static let galleryRectangularDescription = LocalizedStringResource("widget.gallery.rectangular.description")
    static let galleryInlineName = LocalizedStringResource("widget.gallery.inline.name")
    static let galleryInlineDescription = LocalizedStringResource("widget.gallery.inline.description")
    static let galleryHomeName = LocalizedStringResource("widget.gallery.home.name")
    static let galleryHomeDescription = LocalizedStringResource("widget.gallery.home.description")
}
