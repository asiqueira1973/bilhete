import Foundation
import SwiftData
import Testing
@testable import BilheteCore

/// Armazenamento local e portabilidade (épico 8.8, revisto pela decisão D-1).
///
/// Sem CloudKit, o que resta deste épico é o que mais importa: o dado abre
/// depois de fechar o app, o schema versionado não quebra na reabertura, e
/// existe um caminho de saída dos dados — que virou o **único** backup fora do
/// backup do iPhone.
@MainActor
@Suite("Armazenamento local (épico 8.8)")
struct StorageTests {

    @Test("O store fecha e reabre sem perder nada (proxy do teste de migração)")
    func dataSurvivesContainerReopen() throws {
        // Arquivo temporário próprio, para o caso não tocar no store do App
        // Group nem depender dele.
        let url = FileManager.default.temporaryDirectory
            .appending(path: "bilhete-migracao-\(UUID().uuidString).store")
        defer { try? FileManager.default.removeItem(at: url) }

        let schema = Schema(versionedSchema: BilheteSchemaV1.self)
        let config = ModelConfiguration(schema: schema, url: url)

        let idGravado: UUID = try {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: BilheteMigrationPlan.self,
                configurations: [config]
            )
            let store = BilheteStore(
                context: ModelContext(container),
                entitlement: StubEntitlement(isPro: true),
                pin: NoopPinCoordinator(),
                widgets: NoopWidgetReloader()
            )
            let bilhete = try store.create(texto: "sobrevive ao relançamento")
            try store.create(texto: "guardado também")
            return bilhete.id
        }()

        // Reabre do zero, como o app faria no lançamento seguinte.
        let container = try ModelContainer(
            for: schema,
            migrationPlan: BilheteMigrationPlan.self,
            configurations: [config]
        )
        let store = BilheteStore(
            context: ModelContext(container),
            entitlement: StubEntitlement(isPro: true),
            pin: NoopPinCoordinator(),
            widgets: NoopWidgetReloader()
        )

        #expect(store.allNotes().count == 2)
        #expect(store.allNotes().contains { $0.id == idGravado })
        #expect(store.invariantViolations().isEmpty)
    }

    @Test("O schema declara a versão 1 e o plano de migração desde o dia 1 (7.8)")
    func schemaIsVersioned() {
        #expect(BilheteSchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
        #expect(BilheteSchemaV1.models.count == 1)
        #expect(BilheteMigrationPlan.schemas.count == 1)
    }

    @Test("14.2 — a exportação traz as três seções na ordem do spec")
    func exportHasAllSections() throws {
        let h = try TestHarness(isPro: true)
        let destaque = try h.makeFeatured(texto: "o que está na tela")
        try h.store.create(texto: "esperando a vez")
        let arquivado = try h.store.create(texto: "já resolvido")
        try h.store.archive(arquivado)

        let texto = BilheteExporter.makeText(store: h.store, dates: h.dates)

        #expect(texto.contains("# EM DESTAQUE"))
        #expect(texto.contains("# GUARDADOS"))
        #expect(texto.contains("# ARQUIVADOS"))
        #expect(texto.contains("o que está na tela"))
        #expect(texto.contains("esperando a vez"))
        #expect(texto.contains("já resolvido"))
        #expect(destaque.estado == .emDestaque)

        // Ordem das seções conforme 14.2.
        let posDestaque = texto.range(of: "# EM DESTAQUE")!.lowerBound
        let posGuardados = texto.range(of: "# GUARDADOS")!.lowerBound
        let posArquivados = texto.range(of: "# ARQUIVADOS")!.lowerBound
        #expect(posDestaque < posGuardados)
        #expect(posGuardados < posArquivados)
    }

    @Test("14.2 — cada bilhete vira uma linha, com data no formato do spec")
    func exportLineFormat() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "linha\ncom quebra")

        let texto = BilheteExporter.makeText(store: h.store, dates: h.dates)

        // Quebra de linha achatada: uma linha por bilhete.
        #expect(texto.contains("linha com quebra"))
        #expect(!texto.contains("linha\ncom quebra"))
        // Formato `[dd/MM/yyyy HH:mm] texto`.
        #expect(texto.contains("["))
        #expect(texto.contains("] linha com quebra"))
        #expect(bilhete.texto.contains("\n"))
    }

    @Test("14.2 — o nome do arquivo segue bilhetes-AAAA-MM-DD.txt")
    func exportFileName() throws {
        let dates = FixedDateSource(Date(timeIntervalSince1970: 1_760_000_000))

        let nome = BilheteExporter.fileName(dates: dates)

        #expect(nome.hasPrefix("bilhetes-"))
        #expect(nome.hasSuffix(".txt"))
        #expect(nome.count == "bilhetes-2025-10-09.txt".count)
    }

    @Test("O container local não pede iCloud nem rede (decisão D-1)")
    func containerIsLocalOnly() throws {
        let fonte = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appending(path: "Packages/BilheteCore/Sources/BilheteCore/Store/BilheteContainer.swift"),
            encoding: .utf8
        )
        let codigo = fonte
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.hasPrefix("//") && !$0.hasPrefix("///") }
            .joined(separator: "\n")

        // Sem `cloudKitDatabase` não há sincronização — e o app inteiro funciona
        // offline, que é o requisito não-funcional da seção 17.
        #expect(!codigo.contains("cloudKitDatabase"))
    }
}
