import Foundation
import Testing

/// As restrições de plataforma das superfícies do sistema (épico 8.5).
///
/// Estes testes leem o **código-fonte** dos widgets, e isso é de propósito: as
/// regras L8, L9 e 4.5 item 4 não têm como ser verificadas em tempo de execução
/// dentro do alvo de testes — um widget roda em outro processo, desenhado pelo
/// sistema. O que dá para garantir automaticamente é que ninguém reintroduza o
/// padrão proibido sem o teste acusar.
@Suite("Restrições dos widgets (L8, L9, 4.5)")
struct WidgetRulesTests {

    /// Raiz do repositório, a partir deste arquivo de teste.
    private var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    /// Lê um arquivo da pasta `Widgets`.
    /// - Parameter nome: nome do arquivo.
    /// - Returns: o conteúdo em texto.
    private func widgetSource(_ nome: String) throws -> String {
        try String(contentsOf: root.appending(path: "Widgets/\(nome)"), encoding: .utf8)
    }

    @Test("8.5.6 / L9 — nenhum widget de tela de bloqueio tem botão")
    func noButtonsOnLockScreenWidgets() throws {
        let fonte = try widgetSource("LockScreenWidgets.swift")

        // Com o aparelho bloqueado o intent só executa depois do desbloqueio, e
        // não há API pública para reverter o estado visual se a pessoa cancelar
        // (L9, thread 766780). Por isso a ação interativa vive no Controle e nos
        // widgets de tela de início — regra 11.9.
        #expect(!fonte.contains("Button("))
        #expect(!fonte.contains("intent:"))
        #expect(!fonte.contains("Toggle("))
    }

    @Test("8.5.7 / 16.4 — os widgets de tela de bloqueio marcam o texto como sensível")
    func lockScreenWidgetsArePrivacySensitive() throws {
        let fonte = try widgetSource("LockScreenWidgets.swift")

        // O conteúdo é ocultado conforme a preferência do sistema para tela
        // bloqueada (critério 8.5.7).
        #expect(fonte.contains(".privacySensitive()"))
    }

    @Test("L8 — a tela de bloqueio não decide nada por cor")
    func lockScreenWidgetsDoNotUseColor() throws {
        let fonte = try widgetSource("LockScreenWidgets.swift")

        // O sistema força modo `vibrant` e dessatura tudo para escala de cinza;
        // não há como exibir cor nem desativar. Hierarquia por peso e opacidade.
        #expect(!fonte.contains("BilheteColors."))
        #expect(!fonte.contains("Color("))
        #expect(fonte.contains("AccessoryWidgetBackground()"))
    }

    @Test("4.5 item 4 — as views de widget leem por @Query, nunca por estado à mão")
    func widgetsReadThroughQuery() throws {
        let leitor = try widgetSource("FeaturedNoteEntry.swift")

        // App e widget são processos separados com containers distintos: mudança
        // feita pelo widget é *remote change* para o app e a observação direta
        // não reage (risco R-6). `@Query` é a única defesa, e é o que o critério
        // 8.5.5 valida.
        #expect(leitor.contains("@Query"))
        // A entrada de timeline não pode carregar o conteúdo — se carregar,
        // volta o bug.
        #expect(!leitor.contains("let texto"))
        #expect(!leitor.contains("var texto"))
    }

    @Test("8.5.1 — as quatro famílias estão declaradas com nome e descrição")
    func galleryEntriesAreDeclared() throws {
        let lock = try widgetSource("LockScreenWidgets.swift")
        let home = try widgetSource("HomeScreenWidget.swift")

        #expect(lock.contains(".accessoryRectangular"))
        #expect(lock.contains(".accessoryInline"))
        #expect(home.contains(".systemSmall"))
        #expect(home.contains(".systemMedium"))

        for fonte in [lock, home] {
            #expect(fonte.contains(".configurationDisplayName"))
            #expect(fonte.contains(".description("))
        }
    }

    @Test("A copy da galeria está nos dois idiomas (8.5.1 e 8.11.2)")
    func galleryStringsAreLocalized() throws {
        let url = root.appending(path: "Widgets/Localizable.xcstrings")
        let catalogo = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        let strings = try #require(catalogo?["strings"] as? [String: Any])

        let chavesDaGaleria = strings.keys.filter { $0.hasPrefix("widget.gallery.") }
        #expect(chavesDaGaleria.count == 6)

        for chave in chavesDaGaleria {
            let entrada = try #require(strings[chave] as? [String: Any])
            let idiomas = try #require(entrada["localizations"] as? [String: Any])
            #expect(idiomas["pt-BR"] != nil, "\(chave) sem PT-BR")
            #expect(idiomas["en"] != nil, "\(chave) sem EN")
        }
    }
}
