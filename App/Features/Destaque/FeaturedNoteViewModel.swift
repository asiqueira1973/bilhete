import BilheteCore
import Foundation
import Observation
import SwiftUI

/// View model do bilhete em destaque (tela 10.1, épico 8.1).
///
/// Cuida de três coisas que a view não deve saber fazer: o debounce de gravação
/// de 1 segundo (regra 11.17), o limite de 280 caracteres com contador a partir
/// de 240 (regra 11.2) e o estado de erro de gravação (copy 15.5).
///
/// Não escreve no `ModelContext`: tudo passa pelo `BilheteStore` (spec 13.1).
@MainActor
@Observable
final class FeaturedNoteViewModel {

    /// O texto que está na tela. A view escreve aqui a cada tecla.
    var text: String = "" {
        didSet {
            guard text != oldValue else { return }
            enforceLimit()
            scheduleSave()
        }
    }

    /// Seleção corrente do editor.
    ///
    /// Existe para o fluxo 9.1, passo 2: na primeira execução o bilhete já vem
    /// com o exemplo de 15.1 preenchido **e selecionado**, de modo que digitar
    /// substitui em vez de exigir apagar antes.
    var selection: TextSelection?

    /// Verdadeiro quando a última gravação falhou (copy 15.5 na tela).
    private(set) var saveFailed = false

    /// O bilhete que está sendo editado.
    private(set) var bilhete: Bilhete?

    @ObservationIgnored private let store: BilheteStore
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    /// Guarda o texto já gravado, para não gravar duas vezes a mesma coisa.
    @ObservationIgnored private var lastSavedText = ""

    /// Cria o view model.
    /// - Parameter store: o ponto único de escrita (spec 13.1).
    init(store: BilheteStore) {
        self.store = store
    }

    // MARK: - Contador (regra 11.2)

    /// Quantos caracteres o texto tem agora.
    var characterCount: Int { text.count }

    /// Se o contador deve aparecer.
    ///
    /// - Returns: `true` a partir de 240 caracteres (regra 11.2). Antes disso o
    ///   contador não existe na tela — o app é uma folha de papel, não um
    ///   formulário (16.1).
    var showsCounter: Bool { characterCount >= BilheteStore.counterThreshold }

    /// Se o contador deve aparecer em vermelho.
    ///
    /// - Returns: `true` quando o texto chegou a 280, ponto em que a entrada é
    ///   bloqueada (critério de aceite 8.1.3).
    var counterIsAtLimit: Bool { characterCount >= BilheteStore.textLimit }

    // MARK: - Ciclo de vida da tela

    /// Prepara a tela com o bilhete em destaque.
    ///
    /// - Parameter bilhete: o bilhete `emDestaque` vindo da consulta da view.
    ///
    /// Chamado no primeiro render e sempre que o destaque troca (guardar,
    /// arquivar, promover). Descarta gravação pendente do bilhete anterior
    /// depois de aplicá-la, para nunca perder tecla digitada.
    func bind(to bilhete: Bilhete) {
        guard self.bilhete?.id != bilhete.id else { return }
        flush()
        self.bilhete = bilhete
        self.text = bilhete.texto
        self.lastSavedText = bilhete.texto
        self.saveFailed = false
    }

    /// Seleciona o texto inteiro.
    ///
    /// Chamado quando a tela abre logo depois do seed da primeira execução
    /// (spec 7.7 e fluxo 9.1, passo 2). Em bilhete vazio não faz nada.
    func selectAll() {
        guard !text.isEmpty else { return }
        selection = TextSelection(range: text.startIndex..<text.endIndex)
    }

    /// Agenda a gravação para 1 segundo depois da última tecla (regra 11.17).
    ///
    /// Cada tecla cancela o agendamento anterior: o que interessa é 1 segundo de
    /// silêncio, não 1 segundo desde a primeira tecla.
    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(BilheteStore.saveDebounce))
            guard !Task.isCancelled else { return }
            self?.persist()
        }
    }

    /// Grava agora, sem esperar o debounce.
    ///
    /// Usado ao sair da tela, ao app ir para background e antes de qualquer ação
    /// da barra inferior — as três situações que a regra 11.17 lista como
    /// gravação imediata, e que também cobrem o critério 8.1.4 (encerrar pelo
    /// multitarefa e reabrir preserva o texto).
    func flush() {
        saveTask?.cancel()
        saveTask = nil
        persist()
    }

    /// Corta o texto no limite de 280 caracteres (regra 11.2).
    ///
    /// Bloquear a entrada é preferível a recusar a gravação depois: a pessoa vê
    /// na hora que chegou ao fim, e nada do que ela escreveu é descartado sem
    /// aviso.
    private func enforceLimit() {
        if text.count > BilheteStore.textLimit {
            text = String(text.prefix(BilheteStore.textLimit))
        }
    }

    /// Manda o texto para o store.
    ///
    /// Em caso de falha, liga `saveFailed` para a view mostrar a copy 15.5 e
    /// **mantém o texto na tela** — nunca se descarta o que a pessoa escreveu
    /// (spec 12, tratamento de falha).
    private func persist() {
        guard let bilhete, text != lastSavedText else { return }
        do {
            try store.save(bilhete, texto: text)
            lastSavedText = text
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }

    /// Nova tentativa de gravação depois de um erro (copy 15.5: "Vou tentar de
    /// novo em instantes").
    func retrySave() {
        persist()
    }
}
