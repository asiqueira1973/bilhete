import Foundation

/// Idioma escolhido dentro do app.
///
/// O spec (critério 8.11.3) manda o app seguir o idioma do aparelho. Na prática,
/// quem tem o iPhone em inglês e quer o app em português não tinha saída — foi o
/// que apareceu no teste em aparelho. Esta preferência resolve **sem** contrariar
/// o critério: `sistema` continua sendo o padrão e o comportamento de origem.
nonisolated public enum AppLanguage: String, CaseIterable, Sendable {
    /// Segue o idioma do iPhone (padrão, e o que o critério 8.11.3 descreve).
    case sistema = "sistema"
    case portugues = "pt-BR"
    case ingles = "en"

    /// O código de idioma a aplicar, ou `nil` para seguir o sistema.
    public var localeIdentifier: String? {
        self == .sistema ? nil : rawValue
    }
}

/// Troca o idioma do app em tempo de execução.
///
/// Funciona substituindo a classe do `Bundle.main` por uma que procura as
/// strings no `.lproj` do idioma escolhido. É a técnica padrão para seletor de
/// idioma dentro do app: sem ela, só trocando o idioma do iPhone inteiro.
///
/// **A widget extension não é afetada** — ela é outro processo e continua
/// seguindo o idioma do sistema. Está registrado nas divergências.
/// `nonisolated` porque mexe em `Bundle`, que é global e não pertence à main
/// actor — e porque precisa rodar no `init` do app, antes de qualquer tela.
public enum LanguageSwitcher {

    /// Aplica o idioma escolhido ao bundle principal.
    ///
    /// - Parameter language: a escolha da pessoa nos Ajustes.
    ///
    /// Chamado no lançamento e a cada troca. Com `sistema`, devolve o bundle ao
    /// comportamento normal.
    nonisolated public static func apply(_ language: AppLanguage) {
        guard let identifier = language.localeIdentifier,
              let caminho = Bundle.main.path(forResource: identifier, ofType: "lproj"),
              let bundle = Bundle(path: caminho)
        else {
            object_setClass(Bundle.main, Bundle.self)
            return
        }

        object_setClass(Bundle.main, LocalizedBundle.self)
        LocalizedBundle.override = bundle
    }
}

/// Bundle que resolve as strings no idioma escolhido.
nonisolated private final class LocalizedBundle: Bundle, @unchecked Sendable {
    /// O bundle do idioma escolhido; `nil` volta ao comportamento do sistema.
    nonisolated(unsafe) static var override: Bundle?

    override func localizedString(
        forKey key: String,
        value: String?,
        table tableName: String?
    ) -> String {
        guard let bundle = Self.override else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
