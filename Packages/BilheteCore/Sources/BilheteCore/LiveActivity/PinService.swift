import ActivityKit
import Foundation
import SwiftData
import WidgetKit

/// Erros de fixação, para a UI escolher a copy certa.
public enum PinError: Error, Equatable {
    /// As Atividades ao Vivo estão desligadas para o Bilhete nos Ajustes do
    /// iPhone — copy 15.6, com atalho para os Ajustes do sistema.
    case activitiesDisabled

    /// O `Activity.request` falhou (limite do sistema, permissão negada, ou
    /// chamada de background — L4). Nada muda no modelo: `fixadoAte` continua
    /// nulo (spec 12, tratamento de falha).
    case requestFailed
}

/// Quem agenda e cancela o aviso de expiração (regra 11.7).
///
/// O agendamento de verdade entra no épico 8.7; o protocolo existe agora para o
/// `PinService` já chamar nos pontos certos — fixar agenda, soltar cancela.
public protocol ExpiryWarningScheduling: AnyObject {
    /// Agenda o aviso para `fixadoAte − 30 min` (regra 11.7).
    /// - Parameters:
    ///   - bilhete: o bilhete recém-fixado.
    ///   - fixadoAte: quando a fixação expira.
    func agendar(for bilhete: Bilhete, fixadoAte: Date)

    /// Cancela o aviso agendado para o bilhete, se houver.
    /// - Parameter bilhete: o bilhete que deixou de estar fixado.
    func cancelar(for bilhete: Bilhete)
}

/// Agendador neutro, usado enquanto o épico 8.7 não existe e nos testes.
public final class NoopExpiryWarningScheduler: ExpiryWarningScheduling {
    public init() {}
    public func agendar(for bilhete: Bilhete, fixadoAte: Date) {}
    public func cancelar(for bilhete: Bilhete) {}
}

/// Dono da Live Activity do Bilhete (spec 13.2).
///
/// É o único lugar do app que fala com o `ActivityKit`. Escreve `fixadoAte` e
/// `idAtividade` — os dois campos **locais do aparelho** — porque são estado da
/// atividade, não do conteúdo, e a seção 13.2 atribui isso a ele. Todo o resto
/// continua passando pelo `BilheteStore`.
///
/// Restrições de plataforma que este arquivo obedece e não pode "melhorar":
/// iniciar exige foreground (L4); no máximo **uma** atividade do app por vez
/// (regra 11.6); a fixação dura 8h (regra 11.8), que é o limite ativo do
/// sistema (L1) e não uma escolha de produto.
/// É `@Observable` apenas para poder ser injetado no ambiente da SwiftUI; o
/// estado que a tela observa continua sendo o do SwiftData, via `@Query`.
@MainActor
@Observable
public final class PinService: PinCoordinating {

    private let context: ModelContext
    private let dates: DateSource
    private let scheduler: ExpiryWarningScheduling
    private let preferences: Preferences

    /// Cria o serviço.
    /// - Parameters:
    ///   - context: o contexto do container compartilhado, para gravar os dois
    ///     campos de fixação.
    ///   - dates: fonte de "agora" (seção 22 — nada de `Date()` solto).
    ///   - scheduler: quem agenda o aviso de expiração (regra 11.7).
    ///   - preferences: para marcar `jaFixouAlgumaVez`, metade da condição da
    ///     regra 11.10.
    public init(
        context: ModelContext,
        dates: DateSource = SystemDateSource(),
        scheduler: ExpiryWarningScheduling = NoopExpiryWarningScheduler(),
        preferences: Preferences = .shared
    ) {
        self.context = context
        self.dates = dates
        self.scheduler = scheduler
        self.preferences = preferences
    }

    /// Diz se o sistema permite Atividades ao Vivo para o Bilhete.
    ///
    /// - Returns: `false` quando a pessoa desligou nos Ajustes do iPhone; nesse
    ///   caso "Fixar" fica desabilitado com a copy 15.6.
    public var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    /// Fixa o bilhete na tela de bloqueio e na Dynamic Island.
    ///
    /// - Parameter bilhete: o bilhete em destaque a fixar.
    /// - Throws: `PinError.activitiesDisabled` quando o sistema não permite;
    ///   `PinError.requestFailed` quando o `Activity.request` falha.
    ///
    /// Implementa as regras 11.6 (encerra a anterior primeiro), 11.8
    /// (`fixadoAte = agora + 8h`) e 11.7 (agenda o aviso). Precisa ser chamado
    /// com o app em foreground: de background o sistema devolve
    /// `ActivityAuthorizationError.visibility` (L4).
    public func fixar(_ bilhete: Bilhete) throws {
        guard areActivitiesEnabled else { throw PinError.activitiesDisabled }

        // Regra 11.6: no máximo uma atividade do app por vez. Encerra qualquer
        // outra antes de pedir a nova, inclusive a deste mesmo bilhete quando é
        // um "refixar".
        encerrarTodas(exceto: nil)

        let expiraEm = dates.now.addingTimeInterval(BilheteStore.pinDuration)
        let estado = BilheteAttributes.ContentState(texto: bilhete.texto, fixadoAte: expiraEm)

        do {
            let activity = try Activity.request(
                attributes: BilheteAttributes(bilheteID: bilhete.id),
                content: ActivityContent(state: estado, staleDate: expiraEm),
                pushType: nil
            )
            bilhete.fixadoAte = expiraEm
            bilhete.idAtividade = activity.id
            try? context.save()

            scheduler.agendar(for: bilhete, fixadoAte: expiraEm)
            // Metade da condição da regra 11.10: o paywall só pode aparecer
            // depois da primeira fixação, que é o momento de valor do produto.
            preferences.jaFixouAlgumaVez = true
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            throw PinError.requestFailed
        }
    }

    /// Atualiza o conteúdo da atividade em curso **sem recriá-la**.
    ///
    /// - Parameter bilhete: o bilhete em destaque que acabou de mudar de texto.
    ///
    /// Critério de aceite 8.4.3: editar o texto reflete na tela de bloqueio em
    /// menos de 2 segundos e o `idAtividade` **não** muda — recriar a atividade
    /// faria o bilhete piscar e reiniciaria as 8 horas sem a pessoa pedir.
    public func atualizar(_ bilhete: Bilhete) {
        guard let id = bilhete.idAtividade,
              let fixadoAte = bilhete.fixadoAte,
              let activity = Activity<BilheteAttributes>.activities.first(where: { $0.id == id })
        else { return }

        let estado = BilheteAttributes.ContentState(texto: bilhete.texto, fixadoAte: fixadoAte)
        Task { await activity.update(ActivityContent(state: estado, staleDate: fixadoAte)) }
    }

    /// Solta o bilhete: encerra a atividade e limpa o estado de fixação.
    ///
    /// - Parameter bilhete: o bilhete que deixa de estar fixado.
    ///
    /// Implementa as regras 11.6 e 11.7 e o critério 8.4.5: encerra com
    /// `.immediate`, zera `fixadoAte` e `idAtividade` e cancela o aviso, **sem**
    /// arquivar. Soltar não é concluir.
    public func soltar(_ bilhete: Bilhete) {
        if let id = bilhete.idAtividade {
            encerrar(activityID: id)
        }
        bilhete.fixadoAte = nil
        bilhete.idAtividade = nil
        scheduler.cancelar(for: bilhete)
        // Quem chama é que fecha a transação; aqui só garante que os campos não
        // fiquem gravados pela metade se o processo morrer no meio.
        try? context.save()
    }

    /// Defesa contra atividade órfã, chamada no lançamento (spec 13.2).
    ///
    /// - Parameter exceto: o `Activity.id` que deve sobreviver — o do bilhete em
    ///   destaque, quando ele está fixado.
    ///
    /// Uma atividade órfã deixaria texto na tela de bloqueio sem dono: o app
    /// pode ter sido encerrado antes de encerrar a atividade, ou o bilhete pode
    /// ter sido arquivado por um widget de outro processo.
    public func encerrarTodas(exceto: String?) {
        for activity in Activity<BilheteAttributes>.activities where activity.id != exceto {
            encerrar(activityID: activity.id)
        }
    }

    /// Alinha o mundo real com o modelo, no lançamento do app.
    ///
    /// - Parameter destaque: o bilhete em destaque, se houver.
    ///
    /// Encerra atividades que não correspondem ao destaque e limpa `fixadoAte` e
    /// `idAtividade` quando a atividade já morreu — pela expiração de 8h do
    /// sistema (L1) ou porque a pessoa a dispensou. Sem isso o botão continuaria
    /// dizendo "Soltar" para uma atividade que não existe mais.
    public func reconciliar(destaque: Bilhete?) {
        let vivas = Activity<BilheteAttributes>.activities
        let idDoDestaque = destaque?.idAtividade

        encerrarTodas(exceto: idDoDestaque)

        guard let destaque else { return }
        let aindaViva = vivas.contains { $0.id == idDoDestaque }
        let expirou = (destaque.fixadoAte ?? .distantPast) <= dates.now
        if !aindaViva || expirou {
            destaque.fixadoAte = nil
            destaque.idAtividade = nil
            scheduler.cancelar(for: destaque)
            try? context.save()
        }
    }

    /// Encerra uma atividade pelo id, imediatamente.
    /// - Parameter activityID: o `Activity.id` a encerrar.
    private func encerrar(activityID: String) {
        guard let activity = Activity<BilheteAttributes>.activities.first(where: { $0.id == activityID })
        else { return }
        // `.immediate` porque o bilhete deixou de valer agora; deixar o cartão
        // congelado na tela por até 4h (L3) seria mostrar informação morta.
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
}
