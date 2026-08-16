import Foundation
import SwiftData
import Testing
@testable import BilheteCore

/// A máquina de estados da seção 12 do spec.
///
/// Toda transição permitida executa e produz os efeitos colaterais listados na
/// tabela; toda transição proibida falha. As proibidas importam tanto quanto as
/// permitidas: `arquivado → emDestaque` direto quebraria o princípio P4, e dois
/// `emDestaque` simultâneos quebrariam o app inteiro.
@MainActor
@Suite("Máquina de estados (seção 12)")
struct StateMachineTests {

    // MARK: - Transições permitidas

    @Test("— → emDestaque: criar com a pilha vazia")
    func createIntoFeatured() throws {
        let h = try TestHarness()
        let bilhete = try h.store.create(texto: "primeiro")

        #expect(bilhete.estado == .emDestaque)
        h.expectInvariantsHold()
    }

    @Test("— → guardado: criar com o destaque ocupado entra no topo da pilha")
    func createIntoStack() throws {
        let h = try TestHarness(isPro: true)
        try h.makeFeatured(texto: "destaque")

        let guardado = try h.store.create(texto: "vindo da Siri", origem: .siri)

        #expect(guardado.estado == .guardado)
        #expect(guardado.origem == .siri)
        // Efeito colateral obrigatório da tabela: ordemPilha = min − 1.
        #expect(h.store.stack().first?.id == guardado.id)
        h.expectInvariantsHold()
    }

    @Test("emDestaque → guardado: Guardar encerra a atividade e cria novo destaque em branco")
    func featuredToStashed() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "guardar este")
        bilhete.idAtividade = "activity-x"
        bilhete.fixadoAte = h.dates.now

        let novo = try h.store.stash(bilhete)

        #expect(bilhete.estado == .guardado)
        #expect(h.pin.released == [bilhete.id])
        #expect(novo.estado == .emDestaque)
        #expect(novo.texto.isEmpty)
        h.expectInvariantsHold()
    }

    @Test("guardado → emDestaque: promover rebaixa o destaque atual")
    func stashedToFeatured() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "primeiro")
        let segundo = try h.store.stash(primeiro)
        try h.store.save(segundo, texto: "segundo")

        try h.store.promoteToFeatured(primeiro)

        #expect(primeiro.estado == .emDestaque)
        #expect(segundo.estado == .guardado)
        h.expectInvariantsHold()
    }

    @Test("emDestaque → arquivado: arquiva, promove o próximo e grava arquivadoEm")
    func featuredToArchived() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "primeiro")
        let segundo = try h.store.stash(primeiro)
        try h.store.save(segundo, texto: "segundo")

        try h.store.archive(segundo)

        #expect(segundo.estado == .arquivado)
        #expect(segundo.arquivadoEm == h.dates.now)
        #expect(primeiro.estado == .emDestaque)
        h.expectInvariantsHold()
    }

    @Test("guardado → arquivado: swipe na pilha não mexe no destaque")
    func stashedToArchived() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "primeiro")
        let destaque = try h.store.stash(primeiro)
        try h.store.save(destaque, texto: "continua em destaque")

        try h.store.archive(primeiro)

        #expect(primeiro.estado == .arquivado)
        #expect(destaque.estado == .emDestaque)
        h.expectInvariantsHold()
    }

    @Test("arquivado → guardado: restaurar limpa arquivadoEm e entra no topo")
    func archivedToStashed() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "vai e volta")
        try h.store.archive(primeiro)
        try h.store.create(texto: "outro guardado")

        try h.store.restore(primeiro)

        #expect(primeiro.estado == .guardado)
        #expect(primeiro.arquivadoEm == nil)
        #expect(h.store.stack().first?.id == primeiro.id)
        h.expectInvariantsHold()
    }

    @Test("qualquer → removido: excluir apaga de vez e repõe o destaque")
    func deleteRemoves() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "some de vez")
        let id = bilhete.id

        try h.store.delete(bilhete)

        #expect(!h.store.allNotes().contains { $0.id == id })
        #expect(h.store.featured() != nil)
        h.expectInvariantsHold()
    }

    @Test("Apagar tudo esvazia o arquivo e preserva ativos")
    func deleteAllArchived() throws {
        let h = try TestHarness(isPro: true)
        let destaque = try h.makeFeatured(texto: "fica")
        for indice in 1...3 {
            let bilhete = try h.store.create(texto: "arquivado \(indice)")
            try h.store.archive(bilhete)
        }

        try h.store.deleteAllArchived()

        #expect(h.store.archived().isEmpty)
        #expect(h.store.allNotes().contains { $0.id == destaque.id })
        h.expectInvariantsHold()
    }

    // MARK: - Transições proibidas

    @Test("Proibida: arquivado → emDestaque direto")
    func archivedCannotBecomeFeatured() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "arquivado")
        try h.store.archive(bilhete)

        // Restaurar sempre passa por guardado; promover é um segundo ato
        // deliberado, porque o encerramento tem peso (P4).
        #expect(throws: BilheteStoreError.forbiddenTransition(from: .arquivado, to: .emDestaque)) {
            try h.store.promoteToFeatured(bilhete)
        }
        #expect(bilhete.estado == .arquivado)
        h.expectInvariantsHold()
    }

    @Test("Proibida: guardar um bilhete que não está em destaque")
    func onlyFeaturedCanBeStashed() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "primeiro")
        try h.store.stash(primeiro)

        #expect(throws: BilheteStoreError.forbiddenTransition(from: .guardado, to: .guardado)) {
            try h.store.stash(primeiro)
        }
        h.expectInvariantsHold()
    }

    @Test("Proibida: arquivar duas vezes o mesmo bilhete")
    func cannotArchiveTwice() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "uma vez só")
        try h.store.archive(bilhete)

        #expect(throws: BilheteStoreError.forbiddenTransition(from: .arquivado, to: .arquivado)) {
            try h.store.archive(bilhete)
        }
        h.expectInvariantsHold()
    }

    @Test("Proibida: restaurar quem não está arquivado")
    func cannotRestoreNonArchived() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured(texto: "em destaque")

        #expect(throws: BilheteStoreError.forbiddenTransition(from: .emDestaque, to: .guardado)) {
            try h.store.restore(bilhete)
        }
        h.expectInvariantsHold()
    }

    @Test("Proibida: restaurar quando isso passaria de 3 ativos sem Pro")
    func restoreBlockedByActiveLimit() throws {
        let h = try TestHarness(isPro: false)
        let arquivado = try h.makeFeatured(texto: "arquivado")
        try h.store.archive(arquivado)

        // Enche os 3 ativos.
        let destaque = try #require(h.store.featured())
        try h.store.save(destaque, texto: "um")
        let segundo = try h.store.stash(destaque)
        try h.store.save(segundo, texto: "dois")
        let terceiro = try h.store.stash(segundo)
        try h.store.save(terceiro, texto: "três")
        #expect(h.store.activeCount() == 3)

        // Critério 8.3.4: o paywall abre e a restauração não acontece.
        #expect(throws: BilheteStoreError.limitReached(limit: 3)) {
            try h.store.restore(arquivado)
        }
        #expect(arquivado.estado == .arquivado)
        #expect(arquivado.arquivadoEm != nil)
        h.expectInvariantsHold()
    }

    // MARK: - Reposição do destaque

    @Test("8.1.6 — abrir sem destaque e sem pilha cria um bilhete em branco")
    func ensureFeaturedCreatesWhenEmpty() throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()

        #expect(bilhete.estado == .emDestaque)
        #expect(bilhete.texto.isEmpty)
        #expect(h.store.allNotes().count == 1)
        h.expectInvariantsHold()
    }

    @Test("Abrir sem destaque mas com pilha promove o primeiro, sem criar em branco")
    func ensureFeaturedPromotesFromStack() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.makeFeatured(texto: "primeiro")
        try h.store.stash(primeiro)

        // Simula o estado em que o app poderia acordar se o destaque tivesse
        // sido excluído fora do fluxo normal.
        let destaqueAtual = try #require(h.store.featured())
        h.context.delete(destaqueAtual)
        try h.context.save()

        let reposto = try h.store.ensureFeatured()

        #expect(reposto.id == primeiro.id)
        #expect(h.store.stack().isEmpty)
        h.expectInvariantsHold()
    }

    @Test("ensureFeatured é idempotente")
    func ensureFeaturedIsIdempotent() throws {
        let h = try TestHarness()
        let primeiro = try h.store.ensureFeatured()
        let segundo = try h.store.ensureFeatured()

        #expect(primeiro.id == segundo.id)
        #expect(h.store.allNotes().count == 1)
    }
}
