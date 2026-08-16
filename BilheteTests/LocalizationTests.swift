import Foundation
import Testing

/// Localização PT-BR e EN (épico 8.11).
///
/// PT-BR é a versão canônica (spec 15); o EN é tradução dela. Estes testes
/// existem para impedir os dois jeitos de quebrar isso sem perceber: deixar uma
/// string fixa no código e esquecer de traduzir uma chave nova.
@Suite("Localização (épico 8.11)")
struct LocalizationTests {

    private var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    /// Os três catálogos do projeto: app, widget extension e package.
    private var catalogs: [String] {
        [
            "App/Resources/Localizable.xcstrings",
            "Widgets/Localizable.xcstrings",
            "Packages/BilheteCore/Sources/BilheteCore/Resources/Localizable.xcstrings"
        ]
    }

    /// Lê um catálogo de strings.
    private func loadCatalog(_ caminho: String) throws -> [String: Any] {
        let dados = try Data(contentsOf: root.appending(path: caminho))
        let json = try JSONSerialization.jsonObject(with: dados) as? [String: Any]
        return try #require(json?["strings"] as? [String: Any], "Catálogo vazio: \(caminho)")
    }

    /// Percorre os arquivos Swift de um diretório.
    private func swiftFiles(in pasta: String) throws -> [(nome: String, conteudo: String)] {
        let base = root.appending(path: pasta)
        let urls = FileManager.default.enumerator(at: base, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" } ?? []
        return try urls.map { ($0.lastPathComponent, try String(contentsOf: $0, encoding: .utf8)) }
    }

    @Test("8.11.2 — toda chave tem PT-BR e EN, nos três catálogos")
    func everyKeyHasBothLanguages() throws {
        for caminho in catalogs {
            let strings = try loadCatalog(caminho)
            #expect(!strings.isEmpty, "\(caminho) sem chaves")

            for (chave, valor) in strings {
                let entrada = try #require(valor as? [String: Any])
                let idiomas = try #require(
                    entrada["localizations"] as? [String: Any],
                    "\(caminho) → \(chave) sem localizações"
                )
                #expect(idiomas["pt-BR"] != nil, "\(caminho) → \(chave) sem PT-BR")
                #expect(idiomas["en"] != nil, "\(caminho) → \(chave) sem EN")
            }
        }
    }

    @Test("8.11.2 — nenhuma tradução ficou vazia")
    func noEmptyTranslations() throws {
        for caminho in catalogs {
            let strings = try loadCatalog(caminho)
            for (chave, valor) in strings {
                let entrada = valor as? [String: Any]
                let idiomas = entrada?["localizations"] as? [String: Any] ?? [:]
                for (idioma, conteudo) in idiomas {
                    let entradaIdioma = conteudo as? [String: Any]

                    // Chave com plural guarda o texto dentro de `variations`, e
                    // não em `stringUnit` — é o caso do contador da pilha
                    // ("1 bilhete" / "3 bilhetes").
                    if let variacoes = entradaIdioma?["variations"] as? [String: Any],
                       let plural = variacoes["plural"] as? [String: Any] {
                        #expect(!plural.isEmpty, "\(caminho) → \(chave) [\(idioma)] sem formas de plural")
                        for (forma, valor) in plural {
                            let unidade = (valor as? [String: Any])?["stringUnit"] as? [String: Any]
                            let texto = unidade?["value"] as? String ?? ""
                            #expect(!texto.isEmpty, "\(caminho) → \(chave) [\(idioma)/\(forma)] está vazia")
                        }
                        continue
                    }

                    let unidade = entradaIdioma?["stringUnit"] as? [String: Any]
                    let texto = unidade?["value"] as? String ?? ""
                    #expect(!texto.isEmpty, "\(caminho) → \(chave) [\(idioma)] está vazia")
                }
            }
        }
    }

    @Test("8.11.1 — nenhuma string visível fixa no código")
    func noHardcodedUserFacingStrings() throws {
        // `Text("...")` com literal é o jeito mais comum de vazar texto para o
        // código. O que é permitido é `Text(verbatim:)`, para conteúdo que não
        // se traduz — número do contador da pilha, por exemplo.
        for pasta in ["App", "Widgets"] {
            for arquivo in try swiftFiles(in: pasta) {
                let linhas = arquivo.conteudo.split(separator: "\n").map(String.init)
                for (indice, linha) in linhas.enumerated() {
                    let limpa = linha.trimmingCharacters(in: .whitespaces)
                    guard !limpa.hasPrefix("//") else { continue }
                    #expect(
                        !limpa.contains("Text(\""),
                        "\(arquivo.nome):\(indice + 1) tem texto fixo no código (critério 8.11.1): \(limpa)"
                    )
                    #expect(
                        !limpa.contains("Label(\""),
                        "\(arquivo.nome):\(indice + 1) tem rótulo fixo no código: \(limpa)"
                    )
                }
            }
        }
    }

    @Test("8.11.2 — a copy da seção 15 do spec está no catálogo, literal")
    func specCopyIsVerbatim() throws {
        let app = try loadCatalog("App/Resources/Localizable.xcstrings")

        /// Confere que a chave tem exatamente o texto do spec.
        func esperar(_ chave: String, ptBR: String) throws {
            let entrada = try #require(app[chave] as? [String: Any], "Falta a chave \(chave)")
            let idiomas = try #require(entrada["localizations"] as? [String: Any])
            let unidade = (idiomas["pt-BR"] as? [String: Any])?["stringUnit"] as? [String: Any]
            #expect(unidade?["value"] as? String == ptBR, "\(chave) divergiu da copy do spec")
        }

        // Amostra das copies que o spec marca como texto final, não placeholder.
        try esperar("editor.placeholder", ptBR: "Escreva o que você não quer esquecer")   // 15.1
        try esperar("stack.empty.title", ptBR: "Nada guardado.")                          // 15.2
        // 15.3 foi adaptada pela decisão D-10, que renomeou "Arquivo" para
        // "Concluídos": manter "arquivado" na copy contradiria o nome da tela.
        // O teste segue a copy **vigente**, e a divergência está registrada.
        try esperar("archive.empty.title", ptBR: "Nada concluído ainda.")                  // 15.3 + D-10
        try esperar("error.save.title", ptBR: "Não consegui salvar agora")                // 15.5
        try esperar("pin.unavailable.title", ptBR: "Não dá pra fixar agora")              // 15.6
        try esperar("pro.notice.title", ptBR: "Isso é do Bilhete Pro")                    // 15.8
        try esperar("notif.permission.body",
                    ptBR: "Pra deixar o bilhete na sua tela de bloqueio, o iPhone precisa da sua permissão. É só uma vez.") // 15.10
        try esperar("paywall.offline.title", ptBR: "Sem conexão")                         // 15.12
        try esperar("welcome.subtitle", ptBR: "Um recado por vez, na sua tela de bloqueio.") // 15.13
        try esperar("paywall.subtitle", ptBR: "Uma compra. Pra sempre.")                  // 15.17
        try esperar("delete.confirm.title", ptBR: "Excluir este bilhete?")                // 15.19
    }

    @Test("O idioma de origem dos catálogos é PT-BR, a versão canônica")
    func sourceLanguageIsBrazilianPortuguese() throws {
        for caminho in catalogs {
            let dados = try Data(contentsOf: root.appending(path: caminho))
            let json = try JSONSerialization.jsonObject(with: dados) as? [String: Any]
            #expect(json?["sourceLanguage"] as? String == "pt-BR", "\(caminho) não é canônico em PT-BR")
        }
    }
}
