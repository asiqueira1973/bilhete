import AppIntents
import Foundation
import Testing
@testable import Bilhete
@testable import BilheteCore

/// Controles, Botão de Ação, Siri e Atalhos (épico 8.6).
///
/// As restrições desta parte são de plataforma, não de gosto: L5, L6, L10, L13 e
/// L14. Quase todas só se manifestam em aparelho, com o app fechado — o que dá
/// para garantir aqui é que o código continua obedecendo a elas.
@MainActor
@Suite("Controles, Siri e Atalhos (épico 8.6)")
struct IntentsAndControlsTests {

    private var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(_ caminho: String) throws -> String {
        try String(contentsOf: root.appending(path: caminho), encoding: .utf8)
    }

    // MARK: - L14 — frases de Siri

    @Test("8.6.7 — toda frase de AppShortcut contém a variável do nome do app")
    func everyPhraseHasApplicationName() throws {
        let fonte = try source("App/BilheteShortcuts.swift")

        // Sem `\(.applicationName)` a frase não é registrada pelo sistema. É o
        // erro mais comum desta API (L14).
        let linhasDeFrase = fonte
            .split(separator: "\n")
            .map(String.init)
            .filter { $0.contains("\" ) ") == false && $0.trimmingCharacters(in: .whitespaces).hasPrefix("\"") }

        #expect(!linhasDeFrase.isEmpty)
        for linha in linhasDeFrase {
            #expect(
                linha.contains("\\(.applicationName)"),
                "Frase sem \\(.applicationName), não será registrada (L14): \(linha)"
            )
        }
    }

    @Test("15.16 — as quatro frases previstas no spec existem")
    func allSpecPhrasesExist() throws {
        let fonte = try source("App/BilheteShortcuts.swift")

        for frase in ["Criar bilhete no", "Novo bilhete no", "Refixar meu bilhete no", "Arquivar meu bilhete no"] {
            #expect(fonte.contains(frase), "Falta a frase da copy 15.16: \(frase)")
        }
    }

    @Test("8.6.8 — o provedor de atalhos está no target principal, não na extension")
    func shortcutsProviderLivesInTheApp() throws {
        // L14: o código dos intents precisa estar no binário do app. O provedor
        // fica em App/, e os intents vêm do package, que é linkado aos dois
        // targets — nunca duplicado (spec 18.3).
        let existeNoApp = FileManager.default.fileExists(
            atPath: root.appending(path: "App/BilheteShortcuts.swift").path
        )
        #expect(existeNoApp)

        let extensionFiles = try FileManager.default.contentsOfDirectory(
            atPath: root.appending(path: "Widgets").path
        )
        #expect(!extensionFiles.contains { $0.contains("Shortcuts") })
    }

    // MARK: - L13 — o Controle completa de forma síncrona

    @Test("8.6.4 — nenhum intent de Controle conforma ForegroundContinuableIntent")
    func noForegroundContinuableIntent() throws {
        // `ForegroundContinuableIntent` não é suportado em Controle (L13): o
        // `perform()` precisa completar sozinho. A conferência ignora
        // comentários — a própria explicação da regra cita o tipo.
        for caminho in [
            "Packages/BilheteCore/Sources/BilheteCore/Intents/ProIntents.swift",
            "Packages/BilheteCore/Sources/BilheteCore/Intents/BilheteIntents.swift",
            "Widgets/BilheteControls.swift"
        ] {
            let codigo = try source(caminho)
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.hasPrefix("//") && !$0.hasPrefix("///") }
                .joined(separator: "\n")

            #expect(
                !codigo.contains("ForegroundContinuableIntent"),
                "\(caminho) conforma ForegroundContinuableIntent, proibido em Controle (L13)"
            )
        }
    }

    @Test("L5/L6 — o intent de refixar é LiveActivityIntent e não abre o app")
    func repinIntentRunsWithoutOpeningApp() throws {
        let fonte = try source("Packages/BilheteCore/Sources/BilheteCore/Intents/ProIntents.swift")

        #expect(fonte.contains("RefixarBilheteIntent: AppIntent, LiveActivityIntent"))
        #expect(RefixarBilheteIntent.openAppWhenRun == false)
        // "Novo bilhete" é o oposto de propósito: escrever exige teclado, e a
        // Live Activity não tem campo de texto (L12).
        #expect(NovoBilheteIntent.openAppWhenRun == true)
        #expect(ConcluirBilheteIntent.openAppWhenRun == false)
        #expect(SoltarBilheteIntent.openAppWhenRun == false)
    }

    // MARK: - L10 — compreensível só pelo símbolo

    @Test("8.6.5 — os dois Controles usam os símbolos definidos no spec 16.6")
    func controlsUseSpecSymbols() throws {
        let fonte = try source("Widgets/BilheteControls.swift")

        // O texto do Controle fica oculto na tela de bloqueio (L10), então o
        // símbolo é a única informação.
        #expect(fonte.contains("\"pin.fill\""))
        #expect(fonte.contains("\"square.and.pencil\""))
    }

    // MARK: - Matriz da seção 5 — gating

    @Test("D-12 — refixar é grátis: o intent não confere direito Pro")
    func repinIsFree() throws {
        let fonte = try source("Packages/BilheteCore/Sources/BilheteCore/Intents/ProIntents.swift")

        // Sem o widget sugerido (D-7), refixar virou o único caminho de volta em
        // um toque. Cobrar por ele deixaria o plano grátis sem rede de segurança
        // quando a fixação expira, contra o princípio P5.
        let bloco = fonte
            .components(separatedBy: "public struct RefixarBilheteIntent")[1]
            .components(separatedBy: "public struct NovoBilheteIntent")[0]
        let codigo = bloco
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.hasPrefix("//") && !$0.hasPrefix("///") }
            .joined(separator: "\n")

        #expect(!codigo.contains("temPro()"))
    }

    @Test("8.6.9 — criar bilhete pela Siri continua sendo Pro")
    func createBySiriIsGated() throws {
        let fonte = try source("Packages/BilheteCore/Sources/BilheteCore/Intents/ProIntents.swift")
        let bloco = fonte.components(separatedBy: "public struct CriarBilheteIntent")[1]

        #expect(bloco.contains("temPro()"))
    }

    @Test("Arquivar por voz é grátis: a matriz da seção 5 põe arquivar na coluna de todos")
    func archiveIntentIsFree() throws {
        let fonte = try source("Packages/BilheteCore/Sources/BilheteCore/Intents/ProIntents.swift")

        // O bloco do ArquivarBilheteIntent não pode conferir `temPro()`.
        let bloco = fonte.components(separatedBy: "struct ArquivarBilheteIntent").last ?? ""
        #expect(!bloco.contains("temPro()"))
    }

    @Test("Os nomes e descrições dos Controles estão nos dois idiomas")
    func controlStringsAreLocalized() throws {
        let url = root.appending(path: "Widgets/Localizable.xcstrings")
        let catalogo = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        let strings = try #require(catalogo?["strings"] as? [String: Any])

        for chave in ["control.repin.name", "control.repin.description",
                      "control.new.name", "control.new.description"] {
            let entrada = try #require(strings[chave] as? [String: Any], "Falta \(chave)")
            let idiomas = try #require(entrada["localizations"] as? [String: Any])
            #expect(idiomas["pt-BR"] != nil)
            #expect(idiomas["en"] != nil)
        }
    }
}
