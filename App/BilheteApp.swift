import BilheteCore
import UserNotifications
import SwiftData
import SwiftUI

/// Ponto de entrada do app.
///
/// Abre o `ModelContainer` compartilhado com a widget extension (spec 4.5) e
/// injeta as duas dependências que toda tela usa: o `BilheteStore`, que é o
/// ponto único de escrita (spec 13.1), e as `Preferences` do App Group (7.3).
///
/// Não há tela de carregamento: os dados são locais e o primeiro render é
/// síncrono, como o épico 8.1 exige (abertura em menos de 1 segundo, spec 17).
@main
struct BilheteApp: App {
    @Environment(\.scenePhase) private var scenePhase

    private let container: ModelContainer
    private let store: BilheteStore
    private let preferences: Preferences
    private let proGate: ProGate
    private let pinService: PinService
    private let expiryScheduler: ExpiryWarningScheduler
    private let notificationHandler: NotificationHandler
    private let entitlement: EntitlementStore

    init() {
        let container = BilheteContainer.shared
        let preferences = Preferences.shared
        // O PinService é criado antes do store porque o store precisa dele para
        // encerrar a Live Activity ao guardar, arquivar, promover e excluir
        // (regras 11.6 e 11.7).
        // Aplica o idioma escolhido antes de qualquer tela desenhar.
        LanguageSwitcher.apply(preferences.idioma)
        let entitlement = EntitlementStore(preferences: preferences)
        let expiryScheduler = ExpiryWarningScheduler(preferences: preferences)
        let pinService = PinService(
            context: container.mainContext,
            scheduler: expiryScheduler,
            preferences: preferences
        )
        // O direito vem do StoreKit, não do cache: o store pergunta ao
        // EntitlementStore a cada decisão de limite (regras 11.3 e 11.4).
        let store = BilheteStore(
            context: container.mainContext,
            entitlement: entitlement,
            pin: pinService
        )
        self.container = container
        self.preferences = preferences
        self.store = store
        self.pinService = pinService
        self.expiryScheduler = expiryScheduler
        self.entitlement = entitlement
        self.proGate = ProGate(store: store, preferences: preferences)
        self.notificationHandler = NotificationHandler(store: store, pin: pinService)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(preferences)
                .environment(proGate)
                .environment(pinService)
                .environment(expiryScheduler)
                .environment(entitlement)
                .task {
                    // A ação "Refixar" da notificação precisa de categoria
                    // registrada, senão o aviso chega sem botão (critério
                    // 8.7.6).
                    // Listener de Transaction.updates desde o lançamento
                    // (critério 8.9.5): captura compra em outro aparelho, Ask
                    // to Buy, código promocional e revogação (regra 11.11).
                    entitlement.observar()
                    await entitlement.carregar()
                    expiryScheduler.registrarCategoria()
                    UNUserNotificationCenter.current().delegate = notificationHandler
                    // Defesa contra atividade órfã no lançamento (spec 13.2):
                    // o app pode ter sido encerrado antes de encerrar a
                    // atividade, ou o bilhete pode ter sido arquivado por um
                    // widget de outro processo.
                    pinService.reconciliar(destaque: store.featured())
                }
                .onChange(of: scenePhase) { _, fase in
                    // Voltando para o primeiro plano, descarta o cache do
                    // contexto e relê o arquivo: o que o botão da Live Activity
                    // gravou rodou em outro processo, e a observação de modelo
                    // não reage a isso sozinha (spec 4.5 item 4, risco R-6).
                    guard fase == .active else { return }
                    container.mainContext.rollback()
                    pinService.reconciliar(destaque: store.featured())
                }
                .onOpenURL { url in
                    // Toque no corpo da Live Activity: abre o app **no bilhete
                    // correspondente** (critério 8.4.6). Não bastava abrir o
                    // app — se o destaque tiver trocado enquanto a atividade
                    // estava na tela, a pessoa cairia em outro bilhete, que foi
                    // exatamente o que aconteceu no teste em aparelho.
                    guard url.scheme == "bilhete",
                          let id = UUID(uuidString: url.lastPathComponent)
                    else { return }
                    store.focus(noteWithID: id)
                }
        }
        .modelContainer(container)
    }
}
