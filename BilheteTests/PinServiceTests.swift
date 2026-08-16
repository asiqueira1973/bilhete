import Foundation
import Testing
@testable import BilheteCore

/// O `PinService` (spec 13.2, épico 8.4).
///
/// O que dá para testar aqui é a parte que é **do modelo**: quando os campos de
/// fixação são gravados, quando são limpos, e o que acontece no lançamento com
/// uma atividade que já morreu. O `Activity.request` em si exige o app em
/// foreground (L4) e não roda dentro do alvo de testes — isso fica na
/// validação manual em aparelho, listada na seção 22.
@MainActor
@Suite("PinService (épico 8.4)")
struct PinServiceTests {

    /// Monta o serviço sobre o mesmo store em memória do harness.
    private func makeService(_ h: TestHarness) -> PinService {
        PinService(
            context: h.context,
            dates: h.dates,
            scheduler: NoopExpiryWarningScheduler(),
            preferences: h.preferences
        )
    }

    @Test("8.4.5 — soltar limpa os dois campos e não arquiva")
    func unpinDoesNotArchive() throws {
        let h = try TestHarness()
        let service = makeService(h)
        let bilhete = try h.makeFeatured(texto: "na tela")
        bilhete.fixadoAte = h.dates.now.addingTimeInterval(BilheteStore.pinDuration)
        bilhete.idAtividade = "activity-1"

        service.soltar(bilhete)

        #expect(bilhete.fixadoAte == nil)
        #expect(bilhete.idAtividade == nil)
        // Soltar não é concluir: o bilhete continua em destaque (critério 8.4.5).
        #expect(bilhete.estado == .emDestaque)
        h.expectInvariantsHold()
    }

    @Test("11.8 — a fixação expira 8 horas depois, e o aviso é 30 min antes")
    func pinWindow() throws {
        let h = try TestHarness()
        let inicio = h.dates.now
        let expira = inicio.addingTimeInterval(BilheteStore.pinDuration)

        #expect(expira.timeIntervalSince(inicio) == 8 * 3_600)
        #expect(expira.addingTimeInterval(-BilheteStore.expiryWarningLead)
            .timeIntervalSince(inicio) == 7.5 * 3_600)
    }

    @Test("No lançamento, fixação expirada é limpa do modelo")
    func reconcileClearsExpiredPin() throws {
        let h = try TestHarness()
        let service = makeService(h)
        let bilhete = try h.makeFeatured(texto: "fixado de manhã")
        bilhete.fixadoAte = h.dates.now.addingTimeInterval(BilheteStore.pinDuration)
        bilhete.idAtividade = "activity-manha"

        // Oito horas depois o sistema já encerrou a atividade (L1). Sem esta
        // limpeza o botão continuaria dizendo "Soltar" para algo que não existe.
        h.dates.advance(by: BilheteStore.pinDuration + 60)
        service.reconciliar(destaque: bilhete)

        #expect(bilhete.fixadoAte == nil)
        #expect(bilhete.idAtividade == nil)
        h.expectInvariantsHold()
    }

    @Test("No lançamento, fixação sem atividade viva também é limpa")
    func reconcileClearsOrphanPin() throws {
        let h = try TestHarness()
        let service = makeService(h)
        let bilhete = try h.makeFeatured(texto: "atividade órfã")
        // Dentro da janela de 8h, mas sem nenhuma atividade viva com este id —
        // é o caso de o app ter sido encerrado sem encerrar a atividade.
        bilhete.fixadoAte = h.dates.now.addingTimeInterval(3_600)
        bilhete.idAtividade = "activity-que-nao-existe"

        service.reconciliar(destaque: bilhete)

        #expect(bilhete.fixadoAte == nil)
        #expect(bilhete.idAtividade == nil)
        h.expectInvariantsHold()
    }

    @Test("O deep link da Live Activity aponta para o bilhete")
    func deepLinkCarriesNoteID() throws {
        let id = UUID()
        let url = BilheteAttributes.deepLink(for: id)

        #expect(url.scheme == "bilhete")
        #expect(url.absoluteString.contains(id.uuidString))
    }

    @Test("O payload da Live Activity cabe folgado nos 4 KB do sistema (L11)")
    func payloadFitsSystemLimit() throws {
        let estado = BilheteAttributes.ContentState(
            texto: String(repeating: "a", count: BilheteStore.textLimit),
            fixadoAte: Date(timeIntervalSince1970: 1_760_000_000)
        )
        let dados = try JSONEncoder().encode(estado)

        #expect(dados.count < 4_096)
    }
}
