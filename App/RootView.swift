import BilheteCore
import SwiftData
import SwiftUI

/// Raiz do app: decide entre a tela de boas-vindas (10.6) e o destaque (10.1).
///
/// Na primeira execução, semeia **um** bilhete em destaque com o texto de
/// exemplo de 15.1 (spec 7.7) e mostra as boas-vindas. Depois disso, o app abre
/// sempre direto no destaque, sem tela intermediária (princípio P2).
struct RootView: View {
    @Environment(Preferences.self) private var preferences
    @Environment(BilheteStore.self) private var store

    /// Verdadeiro no instante em que as boas-vindas terminam, para o bilhete
    /// semeado abrir com o texto selecionado.
    @State private var justSeeded = false

    /// Abre direto no paywall quando o app é lançado para a captura de tela da
    /// loja. **Só em DEBUG**: em Release este caminho não existe.
    private var capturingPaywall: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("-BilheteCapturePaywall")
        #else
        false
        #endif
    }

    /// Abre direto nos Ajustes quando o app é lançado para captura de tela.
    /// **Só em DEBUG** — serve para comparar paletas sem depender de toque.
    private var capturingSettings: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("-BilheteCaptureSettings")
        #else
        false
        #endif
    }

    var body: some View {
        Group {
            if preferences.boasvindasConcluida {
                // A pilha (10.2) e o arquivo (10.3) são empilhados sobre o
                // destaque; a tela inicial continua sendo o bilhete, sem barra
                // de navegação, para parecer uma folha e não um formulário
                // (16.1).
                NavigationStack {
                    FeaturedNoteView(selectsAllOnAppear: justSeeded)
                        .toolbar(.hidden, for: .navigationBar)
                }
            } else {
                WelcomeView(onStart: start)
            }
        }
        .preferredColorScheme(Theme.colorScheme(preferences.aparencia))
        .tint(Theme.marca)
        .task {
            #if DEBUG
            // Cenário fixo para as imagens da App Store (só em DEBUG).
            if DemoData.isRequested {
                DemoData.seed(into: store)
                preferences.boasvindasConcluida = true
            }
            #endif
        }
        .sheet(isPresented: .constant(capturingPaywall)) { PaywallView() }
        .sheet(isPresented: .constant(capturingSettings)) {
            // A folha não herda o tint da raiz; sem isto a captura sairia com
            // as cores do sistema em vez das do app.
            NavigationStack { SettingsView() }
                .tint(Theme.marca)
                .preferredColorScheme(Theme.colorScheme(preferences.aparencia))
        }
    }

    /// Conclui as boas-vindas e prepara o primeiro bilhete.
    ///
    /// Implementa o seed da seção 7.7: um bilhete em destaque com o texto de
    /// exemplo de 15.1, que é um bilhete normal — editável, arquivável,
    /// excluível. Não existe nenhum outro seed.
    private func start() {
        // **Decisão D-9:** o primeiro bilhete nasce **vazio**, e não com o texto
        // de exemplo que a seção 7.7 do spec mandava gravar. Dois motivos, os
        // dois vindos do teste em aparelho: texto semeado é *conteúdo*, então
        // ficava congelado no idioma da primeira abertura mesmo depois de a
        // pessoa trocar o idioma nos Ajustes; e obrigava a apagar um exemplo
        // antes de escrever. O placeholder faz o mesmo papel, é interface, e
        // acompanha o idioma.
        _ = try? store.ensureFeatured()
        preferences.boasvindasConcluida = true
    }
}
