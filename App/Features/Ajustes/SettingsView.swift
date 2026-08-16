import BilheteCore
import StoreKit
import SwiftUI
import WidgetKit

/// Tela 10.4 — Ajustes (épico 8.10).
///
/// Preferências por aparelho (spec 7.3), o caminho para a tela 10.7, o Bilhete
/// Pro, a exportação e o "sobre".
///
/// **Não há linha de estado da sincronização.** A decisão D-1 tirou o CloudKit:
/// mostrar "sincronização desligada" seria descrever uma função que o app não
/// tem. No lugar dela, a exportação ganhou destaque — sem sync, ela é o único
/// backup fora do backup do iPhone.
struct SettingsView: View {
    @Environment(Preferences.self) private var preferences
    @Environment(BilheteStore.self) private var store
    @Environment(EntitlementStore.self) private var entitlement
    @Environment(ProGate.self) private var proGate
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    @State private var exportURL: URL?
    @State private var showingGuide = false
    @State private var showingConcepts = false

    var body: some View {
        @Bindable var preferences = preferences

        Form {
            // MARK: Aparência e leitura
            Section {
                Picker(selection: $preferences.aparencia) {
                    Text(loc: AppStrings.settingsAppearanceSystem).tag(Aparencia.sistema)
                    Text(loc: AppStrings.settingsAppearanceLight).tag(Aparencia.claro)
                    Text(loc: AppStrings.settingsAppearanceDark).tag(Aparencia.escuro)
                } label: {
                    Text(loc: AppStrings.settingsAppearance)
                }

                // Idioma dentro do app: quem tem o iPhone em inglês e quer o
                // Bilhete em português não tinha saída antes disso.
                Picker(selection: $preferences.idioma) {
                    Text(loc: AppStrings.settingsLanguageSystem).tag(AppLanguage.sistema)
                    Text(loc: AppStrings.settingsLanguagePT).tag(AppLanguage.portugues)
                    Text(loc: AppStrings.settingsLanguageEN).tag(AppLanguage.ingles)
                } label: {
                    Text(loc: AppStrings.settingsLanguage)
                }

                fontPicker

                Toggle(isOn: $preferences.textoPequeno) {
                    Text(loc: AppStrings.settingsSmallText)
                }

                Toggle(isOn: $preferences.avisarExpiracao) {
                    Text(loc: AppStrings.settingsWarn)
                }
            }

            // MARK: A tela de bloqueio (10.7)
            //
            // **Decisão D-7:** a entrada para o guia do widget saiu dos Ajustes.
            // O widget resolve o problema das 12 horas, mas adicioná-lo é
            // trabalhoso demais para a maioria das pessoas — o próprio Alexandre
            // avaliou assim testando no aparelho. A tela 10.7 continua no código
            // e pode voltar; o app é que deixou de sugerir.

            // MARK: Bilhete Pro
            Section {
                if entitlement.isPro {
                    Label(String.loc(AppStrings.settingsProActive), systemImage: "checkmark.seal.fill")
                        .foregroundStyle(Theme.sucesso)
                        .frame(minHeight: 44)
                } else {
                    Button { proGate.showingPaywall = true } label: {
                        Label(String.loc(AppStrings.settingsPro), systemImage: "sparkles")
                    }
                    .frame(minHeight: 44)
                }

                Button {
                    Task { await entitlement.restaurar() }
                } label: {
                    Text(loc: AppStrings.settingsRestore)
                }
                .frame(minHeight: 44)
            }

            // MARK: Exportar (14.2)
            Section {
                Button { exportURL = BilheteExporter.writeFile(store: store) } label: {
                    Label(String.loc(AppStrings.settingsExport), systemImage: "square.and.arrow.up")
                }
                .frame(minHeight: 44)
            } footer: {
                Text(loc: AppStrings.settingsExportNote)
            }

            // MARK: Sobre
            Section {
                Button { showingConcepts = true } label: {
                    Label(String.loc(AppStrings.settingsHowItWorks), systemImage: "questionmark.circle")
                }
                .frame(minHeight: 44)

                Button { requestReview() } label: {
                    Text(loc: AppStrings.settingsRate)
                }
                .frame(minHeight: 44)

                Button { openURL(AppLinks.support) } label: {
                    Text(loc: AppStrings.settingsSupport)
                }
                .frame(minHeight: 44)

                Button {
                    openURL(URL(string: "mailto:\(AppLinks.feedbackEmail)")!)
                } label: {
                    Text(loc: AppStrings.settingsFeedback)
                }
                .frame(minHeight: 44)

                Button { openURL(AppLinks.privacy) } label: {
                    Text(loc: AppStrings.settingsPrivacy)
                }
                .frame(minHeight: 44)
            } header: {
                Text(loc: AppStrings.settingsAbout)
            } footer: {
                Text(loc: AppStrings.settingsVersion(appVersion))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.fundoApp)
        .navigationTitle(Text(loc: AppStrings.settingsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingGuide) { LockScreenGuideView() }
        .navigationDestination(isPresented: $showingConcepts) { ConceptsView() }
        .proGate(proGate)
        .sheet(isPresented: .init(get: { exportURL != nil }, set: { if !$0 { exportURL = nil } })) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
        // Preferência visual mudou: os widgets precisam saber (regra 11.18 e
        // critério 8.10.1).
        .onChange(of: preferences.aparencia) { WidgetCenter.shared.reloadAllTimelines() }
        .onChange(of: preferences.textoPequeno) { WidgetCenter.shared.reloadAllTimelines() }
        .onChange(of: preferences.fonte) { WidgetCenter.shared.reloadAllTimelines() }
    }

    /// Seletor de fonte, com o gating da matriz da seção 5.
    ///
    /// Escolher fonte diferente da padrão sem Pro **não aplica a mudança** e
    /// abre o caminho da compra (critério 8.10.2).
    private var fontPicker: some View {
        @Bindable var preferences = preferences

        return Picker(selection: Binding(
            get: { preferences.fonteEfetiva },
            set: { nova in
                guard !nova.exigePro || preferences.proDesbloqueado else {
                    proGate.requestPro()
                    return
                }
                preferences.fonte = nova
            }
        )) {
            Text(loc: AppStrings.settingsFontDefault).tag(FonteBilhete.padrao)
            Text(loc: AppStrings.settingsFontMono).tag(FonteBilhete.mono)
            Text(loc: AppStrings.settingsFontSerif).tag(FonteBilhete.serifada)
        } label: {
            HStack {
                Text(loc: AppStrings.settingsFont)
                if !preferences.proDesbloqueado {
                    Text(loc: AppStrings.badgePro)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.marca)
                }
            }
        }
    }

    /// A versão de marketing do app, lida do bundle (critério 8.10.3).
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }
}

/// Share sheet do sistema, para entregar o arquivo de exportação (spec 14.2).
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
