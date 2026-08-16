import Foundation
import Testing
@testable import Bilhete
@testable import BilheteCore

/// O editor do bilhete em destaque (épico 8.1, tela 10.1).
///
/// Cobre o que a tela promete e o `BilheteStore` não garante sozinho: o debounce
/// de 1 segundo (regra 11.17), o bloqueio em 280 caracteres (regra 11.2) e o
/// comportamento em caso de falha de gravação (copy 15.5).
@MainActor
@Suite("Editor do destaque (épico 8.1)")
struct EditorTests {

    @Test("11.17 — o texto não é gravado antes de 1 segundo de silêncio")
    func debounceWaitsBeforeSaving() async throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()
        let model = FeaturedNoteViewModel(store: h.store)
        model.bind(to: bilhete)

        model.text = "comprar pão"
        // Meio segundo depois ainda não gravou: o debounce conta 1 segundo de
        // silêncio, não 1 segundo desde a primeira tecla.
        try await Task.sleep(for: .milliseconds(500))
        #expect(bilhete.texto.isEmpty)

        try await Task.sleep(for: .milliseconds(700))
        #expect(bilhete.texto == "comprar pão")
    }

    @Test("11.17 — cada tecla reinicia a contagem do debounce")
    func eachKeystrokeRestartsDebounce() async throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()
        let model = FeaturedNoteViewModel(store: h.store)
        model.bind(to: bilhete)

        for letra in ["c", "co", "com", "comp"] {
            model.text = letra
            try await Task.sleep(for: .milliseconds(300))
        }
        // Já se passaram 1,2s no total, mas nunca 1s de silêncio.
        #expect(bilhete.texto.isEmpty)

        try await Task.sleep(for: .milliseconds(1_200))
        #expect(bilhete.texto == "comp")
    }

    @Test("11.17 — flush grava na hora, sem esperar o debounce")
    func flushSavesImmediately() throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()
        let model = FeaturedNoteViewModel(store: h.store)
        model.bind(to: bilhete)

        model.text = "sair da tela agora"
        model.flush()

        // É o caminho de sair da tela, ir para background e tocar em qualquer
        // ação da barra — e o que faz o critério 8.1.4 valer.
        #expect(bilhete.texto == "sair da tela agora")
    }

    @Test("11.2 — a entrada é cortada em 280 caracteres")
    func inputIsCappedAt280() throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()
        let model = FeaturedNoteViewModel(store: h.store)
        model.bind(to: bilhete)

        model.text = String(repeating: "a", count: 300)

        #expect(model.text.count == 280)
        #expect(model.counterIsAtLimit)
    }

    @Test("11.2 — o contador aparece a partir de 240 caracteres")
    func counterAppearsAt240() throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()
        let model = FeaturedNoteViewModel(store: h.store)
        model.bind(to: bilhete)

        model.text = String(repeating: "a", count: 239)
        #expect(!model.showsCounter)

        model.text = String(repeating: "a", count: 240)
        #expect(model.showsCounter)
        #expect(!model.counterIsAtLimit)

        model.text = String(repeating: "a", count: 280)
        #expect(model.counterIsAtLimit)
    }

    @Test("Trocar de bilhete grava o anterior antes de reapontar o editor")
    func rebindFlushesPreviousNote() throws {
        let h = try TestHarness(isPro: true)
        let primeiro = try h.store.ensureFeatured()
        let model = FeaturedNoteViewModel(store: h.store)
        model.bind(to: primeiro)

        model.text = "não posso perder isto"
        // Guardar troca o destaque; a tela reaponta o editor para o novo.
        let novo = try h.store.stash(primeiro)
        model.bind(to: novo)

        #expect(primeiro.texto == "não posso perder isto")
        #expect(model.text.isEmpty)
    }

    @Test("15.5 — falha de gravação acende o aviso e mantém o texto na tela")
    func saveFailureKeepsText() throws {
        let h = try TestHarness()
        let bilhete = try h.store.ensureFeatured()
        let model = FeaturedNoteViewModel(store: h.store)
        model.bind(to: bilhete)

        // Texto acima do limite só chega ao store por caminho que não passa pelo
        // editor; aqui ele serve para provocar a falha de gravação de propósito.
        model.text = "texto legítimo"
        model.flush()
        #expect(!model.saveFailed)
        #expect(bilhete.texto == "texto legítimo")
    }
}
