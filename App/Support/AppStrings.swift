import Foundation

/// Todas as strings visíveis do app, resolvidas pelo String Catalog.
///
/// Existe para cumprir o critério 8.11.1: nenhuma string fixa no código. As
/// views referenciam constantes daqui, e o texto de verdade vive no
/// `Localizable.xcstrings`, em PT-BR (canônico) e EN.
///
/// A copy é a da seção 15 do spec — texto final, não placeholder.
enum AppStrings {

    // MARK: - 10.6 Boas-vindas (copy 15.13)

    static let welcomeTitle = LocalizedStringResource("welcome.title")
    static let welcomeSubtitle = LocalizedStringResource("welcome.subtitle")
    static let welcomeButton = LocalizedStringResource("welcome.button")

    // MARK: - 10.1 Destaque

    /// Placeholder do editor e texto do seed da primeira execução (15.1, 7.7).
    static let editorPlaceholder = LocalizedStringResource("editor.placeholder")
    static let editorAccessibility = LocalizedStringResource("editor.accessibility")

    /// Contador de caracteres, que aparece a partir de 240 (regra 11.2).
    /// - Parameters:
    ///   - count: quantos caracteres já foram digitados.
    ///   - limit: o teto de 280.
    /// - Returns: o texto localizado do contador.
    static func editorCounter(count: Int, limit: Int) -> LocalizedStringResource {
        LocalizedStringResource("editor.counter", defaultValue: "\(count) / \(limit)")
    }

    // MARK: - Ações

    static let actionStash = LocalizedStringResource("action.stash")
    static let actionPin = LocalizedStringResource("action.pin")
    static let actionRepin = LocalizedStringResource("action.repin")
    static let actionUnpin = LocalizedStringResource("action.unpin")
    static let actionArchive = LocalizedStringResource("action.archive")
    static let actionDelete = LocalizedStringResource("action.delete")
    static let actionShare = LocalizedStringResource("action.share")
    static let actionCopy = LocalizedStringResource("action.copy")
    static let actionCancel = LocalizedStringResource("action.cancel")
    static let actionMore = LocalizedStringResource("action.more")

    /// Botão da barra do teclado, que o fecha para a pessoa ver o bilhete
    /// inteiro (tela 10.1).
    static let actionDoneTyping = LocalizedStringResource("action.doneTyping")

    /// Explicação do fluxo, no rodapé do destaque (tela 10.1).
    ///
    /// Some assim que a pessoa guarda ou conclui o primeiro bilhete: dica que
    /// fica para sempre vira ruído, e o princípio P2 pede tela limpa.
    static let hintFlow = LocalizedStringResource("hint.flow")

    // MARK: - Navegação

    static let navStack = LocalizedStringResource("nav.stack")
    static let navDone = LocalizedStringResource("nav.done")

    /// Contador do acesso à pilha, com plural ("1 bilhete" / "3 bilhetes").
    /// - Parameter count: quantos bilhetes estão guardados.
    static func navStackCountLabel(_ count: Int) -> LocalizedStringResource {
        LocalizedStringResource("nav.stack.count", defaultValue: "\(count)")
    }
    static let navSettings = LocalizedStringResource("nav.settings")

    /// Rótulo de VoiceOver do acesso à pilha, com a contagem.
    /// - Parameter count: quantos bilhetes estão guardados.
    static func navStackCount(_ count: Int) -> LocalizedStringResource {
        LocalizedStringResource("nav.stack.count", defaultValue: "\(count)")
    }

    // MARK: - 10.2 Pilha (copy 15.2)

    static let stackTitle = LocalizedStringResource("stack.title")
    static let stackEmptyTitle = LocalizedStringResource("stack.empty.title")
    static let stackEmptyBody = LocalizedStringResource("stack.empty.body")
    static let stackEmptyButton = LocalizedStringResource("stack.empty.button")
    static let stackPromoteHint = LocalizedStringResource("stack.promote.hint")

    /// Selo do bilhete em destaque quando ele aparece no topo da pilha (D-11).
    static let stackFeaturedBadge = LocalizedStringResource("stack.featured.badge")
    static let badgePro = LocalizedStringResource("badge.pro")

    /// Contador "3 de 3" da pilha, que só aparece no limite do plano grátis
    /// (tela 10.2, regra 11.3).
    /// - Parameters:
    ///   - count: quantos ativos existem.
    ///   - limit: o limite do plano grátis.
    static func stackCounter(count: Int, limit: Int) -> LocalizedStringResource {
        LocalizedStringResource("stack.counter", defaultValue: "\(count) / \(limit)")
    }

    // MARK: - Aviso de capacidade Pro (copy 15.8)

    static let proNoticeTitle = LocalizedStringResource("pro.notice.title")
    static let proNoticeBody = LocalizedStringResource("pro.notice.body")
    static let proNoticeSee = LocalizedStringResource("pro.notice.see")

    // MARK: - 10.3 Arquivo (copy 15.3)

    static let archiveTitle = LocalizedStringResource("archive.title")
    static let archiveEmptyTitle = LocalizedStringResource("archive.empty.title")
    static let archiveEmptyBody = LocalizedStringResource("archive.empty.body")
    static let archiveSearch = LocalizedStringResource("archive.search")
    static let archiveSearchEmpty = LocalizedStringResource("archive.search.empty")
    static let archiveRestore = LocalizedStringResource("archive.restore")
    static let archiveDeleteAll = LocalizedStringResource("archive.deleteAll")
    static let archiveDeleteAllTitle = LocalizedStringResource("archive.deleteAll.title")

    /// Confirmação de "Apagar tudo", com a contagem para a pessoa saber o
    /// tamanho do que está apagando (critério 8.3.6).
    /// - Parameter count: quantos bilhetes serão apagados.
    static func archiveDeleteAllBody(count: Int) -> LocalizedStringResource {
        LocalizedStringResource("archive.deleteAll.body", defaultValue: "\(count)")
    }

    // MARK: - Poda do arquivo grátis (copy 15.4)

    static let pruneTitle = LocalizedStringResource("prune.title")
    static let pruneConfirm = LocalizedStringResource("prune.confirm")

    /// Aviso nominal de poda: diz **qual** bilhete será apagado (regra 11.4).
    ///
    /// O aviso é nominal de propósito — é a mitigação do risco R-8, perda de
    /// dado percebida virando avaliação de uma estrela.
    /// - Parameter oldestText: o texto do bilhete mais antigo do arquivo.
    static func pruneBody(oldestText: String) -> LocalizedStringResource {
        LocalizedStringResource("prune.body", defaultValue: "\(oldestText)")
    }

    // MARK: - Fixação (copy 15.6)

    static let pinUnavailableTitle = LocalizedStringResource("pin.unavailable.title")
    static let pinUnavailableBody = LocalizedStringResource("pin.unavailable.body")
    static let pinUnavailableSettings = LocalizedStringResource("pin.unavailable.settings")

    /// Selo do estado fixado (tela 10.1): mostra até quando o bilhete fica na
    /// tela. A seção 15 não define esta copy; é tradução minha, registrada nas
    /// divergências.
    /// - Parameter time: o horário de expiração já formatado pela região.
    static func pinBadge(_ time: String) -> LocalizedStringResource {
        LocalizedStringResource("pin.badge", defaultValue: "\(time)")
    }

    // MARK: - 8.7 Permissão de notificação (copy 15.10)

    static let notifPermissionBody = LocalizedStringResource("notif.permission.body")
    static let notifPermissionOK = LocalizedStringResource("notif.permission.ok")

    // MARK: - 10.7 Como colocar na tela de bloqueio

    static let guideTitle = LocalizedStringResource("guide.title")
    static let guideCardTitle = LocalizedStringResource("guide.card.title")
    static let guideCardBody = LocalizedStringResource("guide.card.body")
    static let guideStep1Title = LocalizedStringResource("guide.step1.title")
    static let guideStep1Body = LocalizedStringResource("guide.step1.body")
    static let guideStep2Title = LocalizedStringResource("guide.step2.title")
    static let guideStep2Body = LocalizedStringResource("guide.step2.body")
    static let guideStep3Title = LocalizedStringResource("guide.step3.title")
    static let guideStep3Body = LocalizedStringResource("guide.step3.body")
    static let guideDone = LocalizedStringResource("guide.done")

    // MARK: - 10.5 Paywall (copy 15.17, 15.18 e 15.12)

    static let paywallTitle = LocalizedStringResource("paywall.title")
    static let paywallSubtitle = LocalizedStringResource("paywall.subtitle")
    static let paywallRestore = LocalizedStringResource("paywall.restore")
    static let paywallOwned = LocalizedStringResource("paywall.owned")
    static let paywallOfflineTitle = LocalizedStringResource("paywall.offline.title")
    static let paywallOfflineBody = LocalizedStringResource("paywall.offline.body")
    static let paywallTerms = LocalizedStringResource("paywall.terms")
    static let paywallClose = LocalizedStringResource("paywall.close")

    /// As cinco capacidades da matriz da seção 5, na copy 15.18.
    static let paywallItems: [LocalizedStringResource] = [
        LocalizedStringResource("paywall.item1"),
        LocalizedStringResource("paywall.item2"),
        LocalizedStringResource("paywall.item3"),
        LocalizedStringResource("paywall.item4"),
        LocalizedStringResource("paywall.item5")
    ]

    /// Botão de compra com o preço **do StoreKit** (critério 8.9.2).
    /// - Parameter price: o `displayPrice` já localizado pelo StoreKit.
    static func paywallBuy(price: String) -> LocalizedStringResource {
        LocalizedStringResource("paywall.buy", defaultValue: "\(price)")
    }

    // MARK: - 10.4 Ajustes

    static let settingsTitle = LocalizedStringResource("settings.title")
    static let settingsAppearance = LocalizedStringResource("settings.appearance")
    static let settingsLanguage = LocalizedStringResource("settings.language")
    static let settingsLanguageSystem = LocalizedStringResource("settings.language.system")
    static let settingsLanguagePT = LocalizedStringResource("settings.language.pt")
    static let settingsLanguageEN = LocalizedStringResource("settings.language.en")
    static let settingsAppearanceSystem = LocalizedStringResource("settings.appearance.system")
    static let settingsAppearanceLight = LocalizedStringResource("settings.appearance.light")
    static let settingsAppearanceDark = LocalizedStringResource("settings.appearance.dark")
    static let settingsFont = LocalizedStringResource("settings.font")
    static let settingsFontDefault = LocalizedStringResource("settings.font.default")
    static let settingsFontMono = LocalizedStringResource("settings.font.mono")
    static let settingsFontSerif = LocalizedStringResource("settings.font.serif")
    static let settingsSmallText = LocalizedStringResource("settings.smallText")
    static let settingsWarn = LocalizedStringResource("settings.warn")
    static let settingsGuide = LocalizedStringResource("settings.guide")
    static let settingsPro = LocalizedStringResource("settings.pro")
    static let settingsProActive = LocalizedStringResource("settings.pro.active")
    static let settingsRestore = LocalizedStringResource("settings.restore")
    static let settingsRate = LocalizedStringResource("settings.rate")
    static let settingsFeedback = LocalizedStringResource("settings.feedback")
    static let settingsExport = LocalizedStringResource("settings.export")
    static let settingsExportNote = LocalizedStringResource("settings.export.note")
    static let settingsAbout = LocalizedStringResource("settings.about")
    static let settingsHowItWorks = LocalizedStringResource("settings.howItWorks")

    // MARK: - Tela de conceitos (D-10)

    static let conceptsTitle = LocalizedStringResource("concepts.title")
    static let conceptsIntro = LocalizedStringResource("concepts.intro")
    static let conceptsPinTitle = LocalizedStringResource("concepts.pin.title")
    static let conceptsPinBody = LocalizedStringResource("concepts.pin.body")
    static let conceptsStashTitle = LocalizedStringResource("concepts.stash.title")
    static let conceptsStashBody = LocalizedStringResource("concepts.stash.body")
    static let conceptsDoneTitle = LocalizedStringResource("concepts.done.title")
    static let conceptsDoneBody = LocalizedStringResource("concepts.done.body")
    static let conceptsUnpinTitle = LocalizedStringResource("concepts.unpin.title")
    static let conceptsUnpinBody = LocalizedStringResource("concepts.unpin.body")
    static let conceptsLimitsTitle = LocalizedStringResource("concepts.limits.title")
    static let conceptsLimitsBody = LocalizedStringResource("concepts.limits.body")
    static let settingsPrivacy = LocalizedStringResource("settings.privacy")
    static let settingsSupport = LocalizedStringResource("settings.support")

    /// Versão do app, lida do bundle (critério 8.10.3).
    /// - Parameter version: a versão de marketing.
    static func settingsVersion(_ version: String) -> LocalizedStringResource {
        LocalizedStringResource("settings.version", defaultValue: "\(version)")
    }

    // MARK: - Erros e confirmações

    static let errorSaveTitle = LocalizedStringResource("error.save.title")
    static let errorSaveBody = LocalizedStringResource("error.save.body")
    static let deleteConfirmTitle = LocalizedStringResource("delete.confirm.title")
    static let deleteConfirmBody = LocalizedStringResource("delete.confirm.body")
}
