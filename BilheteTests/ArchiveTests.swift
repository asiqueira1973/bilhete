import Foundation
import Testing
@testable import BilheteCore

/// Arquivar, restaurar, excluir e compartilhar (épico 8.3).
///
/// O que este épico promete é o princípio P4: encerrar é deliberado, é
/// reversível e não é sinônimo de excluir.
@MainActor
@Suite("Arquivo (épico 8.3)")
struct ArchiveTests {

    @Test("8.3.2 — arquivar grava o estado e o instante da ação")
    func archiveStampsTime() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "resolvido")

        h.dates.advance(by: 3_600)
        try h.store.archive(bilhete)

        #expect(bilhete.estado == .arquivado)
        #expect(bilhete.arquivadoEm == h.dates.now)
        h.expectInvariantsHold()
    }

    @Test("8.3.4 — restaurar devolve como guardado no topo, sem data de arquivo")
    func restorePutsOnTopOfStack() throws {
        let h = try TestHarness(isPro: true)
        let arquivado = try h.makeFeatured(texto: "volta pra pilha")
        try h.store.archive(arquivado)
        try h.store.create(texto: "já estava guardado")

        try h.store.restore(arquivado)

        #expect(arquivado.estado == .guardado)
        #expect(arquivado.arquivadoEm == nil)
        #expect(h.store.stack().first?.id == arquivado.id)
        h.expectInvariantsHold()
    }

    @Test("11.4 — a sondagem da poda não altera nada")
    func pruneProbeHasNoSideEffect() throws {
        let h = try TestHarness(isPro: false)
        for indice in 1...10 {
            let bilhete = try h.store.ensureFeatured()
            try h.store.save(bilhete, texto: "arquivado \(indice)")
            try h.store.archive(bilhete)
            h.dates.advance(by: 60)
        }
        let destaque = try h.store.ensureFeatured()
        try h.store.save(destaque, texto: "o próximo")

        // A tela pergunta antes de animar. Perguntar não pode arquivar nada.
        let vitima = h.store.pruneVictimText()

        #expect(vitima == "arquivado 1")
        #expect(h.store.archived().count == 10)
        #expect(destaque.estado == .emDestaque)
        #expect(h.store.allNotes().contains { $0.texto == "arquivado 1" })
        h.expectInvariantsHold()
    }

    @Test("11.4 — com Pro não há vítima de poda")
    func noPruneVictimWithPro() throws {
        let h = try TestHarness(isPro: true)
        for indice in 1...12 {
            let bilhete = try h.store.ensureFeatured()
            try h.store.save(bilhete, texto: "arquivado \(indice)")
            try h.store.archive(bilhete)
            h.dates.advance(by: 60)
        }

        #expect(h.store.pruneVictimText() == nil)
    }

    @Test("11.4 — com o arquivo ainda com espaço não há vítima")
    func noPruneVictimBelowLimit() throws {
        let h = try TestHarness(isPro: false)
        for indice in 1...9 {
            let bilhete = try h.store.ensureFeatured()
            try h.store.save(bilhete, texto: "arquivado \(indice)")
            try h.store.archive(bilhete)
            h.dates.advance(by: 60)
        }

        #expect(h.store.pruneVictimText() == nil)
    }

    @Test("8.3.6 — apagar tudo esvazia o arquivo e não toca nos ativos")
    func deleteAllOnlyTouchesArchive() throws {
        let h = try TestHarness(isPro: true)
        let destaque = try h.makeFeatured(texto: "em destaque")
        let guardado = try h.store.create(texto: "guardado")
        for indice in 1...4 {
            let bilhete = try h.store.create(texto: "arquivado \(indice)")
            try h.store.archive(bilhete)
        }

        try h.store.deleteAllArchived()

        #expect(h.store.archived().isEmpty)
        #expect(h.store.allNotes().count == 2)
        #expect(destaque.estado == .emDestaque)
        #expect(guardado.estado == .guardado)
        h.expectInvariantsHold()
    }

    @Test("A ordem do arquivo é do mais recente para o mais antigo")
    func archiveIsSortedByArchivedDate() throws {
        let h = try TestHarness(isPro: true)
        for indice in 1...3 {
            let bilhete = try h.store.ensureFeatured()
            try h.store.save(bilhete, texto: "bilhete \(indice)")
            try h.store.archive(bilhete)
            h.dates.advance(by: 3_600)
        }

        #expect(h.store.archived().map(\.texto) == ["bilhete 3", "bilhete 2", "bilhete 1"])
    }

    @Test("Excluir um arquivado não mexe no destaque")
    func deletingArchivedKeepsFeatured() throws {
        let h = try TestHarness(isPro: true)
        let arquivado = try h.makeFeatured(texto: "some")
        try h.store.archive(arquivado)
        let destaque = try #require(h.store.featured())

        try h.store.delete(arquivado)

        #expect(h.store.featured()?.id == destaque.id)
        #expect(h.store.archived().isEmpty)
        h.expectInvariantsHold()
    }
}
