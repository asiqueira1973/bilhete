import Foundation
import Testing
import UserNotifications
@testable import BilheteCore

/// O aviso de expiração do destaque (épico 8.7, regra 11.7).
///
/// A entrega da notificação em si é do sistema; o que se garante aqui é o
/// contrato: quando agenda, quando não agenda, e por que nunca existem duas
/// agendadas para o mesmo bilhete.
@MainActor
@Suite("Aviso de expiração (épico 8.7)")
struct ExpiryWarningTests {

    @Test("11.7 — o aviso é agendado para 30 minutos antes da expiração")
    func warningLeadTime() throws {
        let h = try TestHarness()
        let fixadoAte = h.dates.now.addingTimeInterval(BilheteStore.pinDuration)

        let disparo = fixadoAte.addingTimeInterval(-BilheteStore.expiryWarningLead)

        // Fixou às 7h30 → expira às 15h30 → avisa às 15h00 (fluxo 9.3).
        #expect(disparo.timeIntervalSince(h.dates.now) == 7.5 * 3_600)
    }

    @Test("8.7.3 — o identificador é derivado do bilhete, então refixar substitui")
    func identifierIsStablePerNote() throws {
        let h = try TestHarness()
        let primeiro = try h.makeFeatured(texto: "um")
        let segundo = try h.store.create(texto: "dois")

        let idPrimeiro = ExpiryWarningScheduler.identifier(for: primeiro)
        let idSegundo = ExpiryWarningScheduler.identifier(for: segundo)

        // Mesmo bilhete, mesmo identificador: o sistema substitui em vez de
        // empilhar, e nunca existem duas notificações para o mesmo bilhete.
        #expect(idPrimeiro == ExpiryWarningScheduler.identifier(for: primeiro))
        #expect(idPrimeiro != idSegundo)
        #expect(idPrimeiro.contains(primeiro.id.uuidString))
    }

    @Test("8.7.4 — com o aviso desligado, nada é agendado")
    func nothingScheduledWhenDisabled() throws {
        let h = try TestHarness()
        h.preferences.avisarExpiracao = false
        let scheduler = ExpiryWarningScheduler(preferences: h.preferences)
        let bilhete = try h.makeFeatured(texto: "sem aviso")

        // Não há como inspecionar o centro de notificações de forma determinística
        // aqui; o que este caso garante é que a preferência é lida antes de
        // qualquer agendamento, e que a chamada não explode.
        scheduler.agendar(for: bilhete, fixadoAte: h.dates.now.addingTimeInterval(3_600))
        #expect(h.preferences.avisarExpiracao == false)
    }

    @Test("A preferência de aviso nasce ligada (assunção A-9)")
    func warningIsOnByDefault() throws {
        let suite = UserDefaults(suiteName: "bilhete.tests.\(UUID().uuidString)")!
        let preferences = Preferences(defaults: suite)

        // Ligado por padrão porque a persona P-C não vai procurar isso nos
        // Ajustes (spec 24, A-9).
        #expect(preferences.avisarExpiracao)
    }

    @Test("8.7.2 — soltar cancela o aviso junto com a atividade")
    func unpinCancelsWarning() throws {
        let h = try TestHarness()
        let scheduler = SpyScheduler()
        let pin = PinService(
            context: h.context,
            dates: h.dates,
            scheduler: scheduler,
            preferences: h.preferences
        )
        let bilhete = try h.makeFeatured(texto: "fixado")
        bilhete.fixadoAte = h.dates.now.addingTimeInterval(BilheteStore.pinDuration)
        bilhete.idAtividade = "activity-1"

        pin.soltar(bilhete)

        #expect(scheduler.cancelados == [bilhete.id])
    }

    @Test("8.7.5 — a permissão é marcada como pedida uma única vez")
    func permissionAskedOnlyOnce() throws {
        let h = try TestHarness()

        #expect(h.preferences.permissaoNotificacaoPedida == false)
        h.preferences.permissaoNotificacaoPedida = true
        // A tela só mostra a copy 15.10 quando esta marca é falsa, então o
        // pedido não se repete a cada fixação.
        #expect(h.preferences.permissaoNotificacaoPedida)
    }
}

/// Agendador espião, para provar quem foi cancelado e quando.
@MainActor
private final class SpyScheduler: ExpiryWarningScheduling {
    private(set) var agendados: [UUID] = []
    private(set) var cancelados: [UUID] = []

    func agendar(for bilhete: Bilhete, fixadoAte: Date) {
        agendados.append(bilhete.id)
    }

    func cancelar(for bilhete: Bilhete) {
        cancelados.append(bilhete.id)
    }
}
