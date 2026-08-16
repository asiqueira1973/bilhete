import AppIntents
import BilheteCore

/// Frases de Siri e Atalhos (spec 13.3 e copy 15.16).
///
/// Fica no **target principal**, não na extension: é onde a restrição L14 exige
/// que o código dos intents esteja para as frases serem registradas.
///
/// **Toda frase contém `\(.applicationName)`.** Sem isso a frase simplesmente
/// não é registrada pelo sistema — é o erro mais comum desta API e o que o
/// critério de aceite 8.6.7 verifica.
struct BilheteShortcuts: AppShortcutsProvider {

    /// O terracota da marca no cartão do app Atalhos (spec 16.2).
    static var shortcutTileColor: ShortcutTileColor { .orange }

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CriarBilheteIntent(),
            phrases: [
                "Criar bilhete no \(.applicationName)",
                "Create a note in \(.applicationName)"
            ],
            shortTitle: "Criar bilhete",
            systemImageName: "square.and.pencil"
        )

        AppShortcut(
            intent: NovoBilheteIntent(),
            phrases: [
                "Novo bilhete no \(.applicationName)",
                "New note in \(.applicationName)"
            ],
            shortTitle: "Novo bilhete",
            systemImageName: "plus.square"
        )

        AppShortcut(
            intent: RefixarBilheteIntent(),
            phrases: [
                "Refixar meu bilhete no \(.applicationName)",
                "Pin my note again in \(.applicationName)"
            ],
            shortTitle: "Refixar bilhete",
            systemImageName: "pin.fill"
        )

        AppShortcut(
            intent: ArquivarBilheteIntent(),
            phrases: [
                "Arquivar meu bilhete no \(.applicationName)",
                "Archive my note in \(.applicationName)"
            ],
            shortTitle: "Arquivar bilhete",
            systemImageName: "archivebox"
        )
    }
}
