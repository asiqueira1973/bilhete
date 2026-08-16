import SwiftUI
import WidgetKit

/// Bundle da widget extension.
///
/// Reúne, num único alvo, todas as superfícies do sistema (spec 10):
/// a Live Activity (S5–S8) no épico 8.4, os quatro widgets (S1–S4) no 8.5 e os
/// dois Controles (S9, S10) no 8.6.
///
/// Os `AppIntent` **não** moram aqui: vivem no package `BilheteCore`, que é
/// linkado ao app e a esta extension. Assim o código dos intents está no binário
/// do app, como L14 exige, e o botão do widget enxerga o tipo sem duplicar
/// arquivo entre targets (spec 18.3).
@main
struct BilheteWidgetBundle: WidgetBundle {
    var body: some Widget {
        BilheteLiveActivity()
        LockScreenRectangularWidget()
        LockScreenInlineWidget()
        HomeScreenNoteWidget()
        RefixarBilheteControl()
        NovoBilheteControl()
    }
}
