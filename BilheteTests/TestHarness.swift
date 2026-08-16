import Foundation
import SwiftData
import Testing
@testable import BilheteCore

/// Relógio fixo para os testes (spec 22, "Como testar o que depende de tempo").
///
/// Sem isto não dá para testar a regra 11.8 (fixação de 8h) nem a 11.7 (aviso
/// 30 minutos antes) sem esperar oito horas.
final class FixedDateSource: DateSource, @unchecked Sendable {
    private let lock = NSLock()
    private var current: Date

    init(_ start: Date = Date(timeIntervalSince1970: 1_760_000_000)) {
        self.current = start
    }

    var now: Date {
        lock.lock()
        defer { lock.unlock() }
        return current
    }

    /// Avança o relógio.
    /// - Parameter seconds: quantos segundos somar ao instante atual.
    func advance(by seconds: TimeInterval) {
        lock.lock()
        current = current.addingTimeInterval(seconds)
        lock.unlock()
    }
}

/// Direito de compra controlado pelo teste (matriz da seção 5).
final class StubEntitlement: EntitlementProviding, @unchecked Sendable {
    var isPro: Bool

    init(isPro: Bool = false) {
        self.isPro = isPro
    }
}

/// Espião da coordenação de fixação.
///
/// Guarda a ordem das chamadas para os testes provarem que a Live Activity é
/// encerrada **antes** de o estado mudar (regras 11.6 e 11.7, critério 8.3.3).
@MainActor
final class SpyPinCoordinator: PinCoordinating {
    /// Ids dos bilhetes que receberam `soltar`, na ordem.
    private(set) var released: [UUID] = []
    /// Ids dos bilhetes que receberam `atualizar`, na ordem.
    private(set) var updated: [UUID] = []
    /// Estado do bilhete no instante em que `soltar` foi chamado.
    private(set) var stateWhenReleased: [EstadoBilhete] = []

    func soltar(_ bilhete: Bilhete) {
        released.append(bilhete.id)
        stateWhenReleased.append(bilhete.estado)
        bilhete.fixadoAte = nil
        bilhete.idAtividade = nil
    }

    func atualizar(_ bilhete: Bilhete) {
        updated.append(bilhete.id)
    }
}

/// Monta um store limpo, em memória, com todas as dependências controláveis.
///
/// Cada teste recebe o seu, para não haver estado vazando entre casos.
@MainActor
struct TestHarness {
    let container: ModelContainer
    let context: ModelContext
    let store: BilheteStore
    let dates: FixedDateSource
    let entitlement: StubEntitlement
    let pin: SpyPinCoordinator
    let widgets: NoopWidgetReloader
    let preferences: Preferences

    /// Cria o ambiente de teste.
    /// - Parameter isPro: se o Bilhete Pro está ativo neste caso (seção 5).
    init(isPro: Bool = false) throws {
        container = try BilheteContainer.make(inMemory: true)
        context = ModelContext(container)
        dates = FixedDateSource()
        entitlement = StubEntitlement(isPro: isPro)
        pin = SpyPinCoordinator()
        widgets = NoopWidgetReloader()
        // Suite próprio por teste: as preferências do aparelho não podem ser
        // sujas por uma bateria de testes.
        let suiteName = "bilhete.tests.\(UUID().uuidString)"
        preferences = Preferences(defaults: UserDefaults(suiteName: suiteName)!)
        store = BilheteStore(
            context: context,
            dates: dates,
            entitlement: entitlement,
            pin: pin,
            widgets: widgets
        )
    }

    /// Confere as invariantes do modelo e falha o teste se alguma quebrou.
    ///
    /// Chamado ao fim de cada operação: as invariantes da seção 22 não podem
    /// valer só no caso feliz.
    func expectInvariantsHold(_ location: SourceLocation = #_sourceLocation) {
        let violations = store.invariantViolations()
        #expect(violations.isEmpty, "\(violations.joined(separator: " | "))", sourceLocation: location)
    }

    /// Cria um bilhete em destaque com texto, que é o ponto de partida da
    /// maioria dos casos.
    /// - Parameter texto: o conteúdo inicial.
    /// - Returns: o bilhete em destaque.
    @discardableResult
    func makeFeatured(texto: String = "primeiro") throws -> Bilhete {
        let bilhete = try store.ensureFeatured()
        try store.save(bilhete, texto: texto)
        return bilhete
    }
}
