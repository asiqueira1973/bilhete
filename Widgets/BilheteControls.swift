import AppIntents
import BilheteCore
import SwiftUI
import WidgetKit

/// S9 — Controle "Refixar bilhete" (épico 8.6).
///
/// Vai para a Central de Controle, para a tela de bloqueio (no lugar da lanterna
/// ou da câmera) e para o Botão de Ação. Dispara um `LiveActivityIntent` que
/// chama `Activity.request` dentro do `perform()`, **sem abrir o app** — o
/// caminho que a Apple demonstrou na sessão 10157 do WWDC24 (L5, L6).
///
/// **O texto de título e valor fica oculto na tela de bloqueio e nos tamanhos
/// pequenos** (L10): o Controle precisa ser compreensível só pelo símbolo. Por
/// isso `pin.fill`, e por isso nenhum outro Controle do app pode usar símbolo
/// próximo (spec 16.6).
struct RefixarBilheteControl: ControlWidget {
    static let kind = "com.dablab.bilhete.control.refixar"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: RefixarBilheteIntent()) {
                Label {
                    Text(ControlStrings.repinTitle)
                } icon: {
                    Image(systemName: "pin.fill")
                }
            }
        }
        .displayName(LocalizedStringResource("control.repin.name"))
        .description(LocalizedStringResource("control.repin.description"))
    }
}

/// S10 — Controle "Novo bilhete" (épico 8.6).
///
/// Abre o app direto no editor. Escrever exige teclado e a Live Activity não tem
/// campo de texto (L12), então abrir é a única saída — e é a que cumpre o
/// princípio P2: do Controle ao cursor, um toque.
///
/// Símbolo `square.and.pencil`, inequívoco sem texto (L10, spec 16.6).
struct NovoBilheteControl: ControlWidget {
    static let kind = "com.dablab.bilhete.control.novo"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: NovoBilheteIntent()) {
                Label {
                    Text(ControlStrings.newNoteTitle)
                } icon: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .displayName(LocalizedStringResource("control.new.name"))
        .description(LocalizedStringResource("control.new.description"))
    }
}

/// Rótulos dos Controles (spec 15, nomes das superfícies do sistema).
enum ControlStrings {
    static let repinTitle = LocalizedStringResource("control.repin.name")
    static let newNoteTitle = LocalizedStringResource("control.new.name")
}
