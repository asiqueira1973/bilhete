import Foundation

/// Aparência do app (spec 7.3, chave `aparencia`).
///
/// Nomeado em português por ser valor persistido, como o resto da camada de
/// dados (spec 18.1).
public enum Aparencia: String, CaseIterable, Sendable {
    case sistema = "sistema"
    case claro = "claro"
    case escuro = "escuro"
}

/// Fonte do corpo do bilhete (spec 7.3, chave `fonte`, e spec 16.3).
///
/// Só `padrao` está disponível sem Pro — matriz de direitos da seção 5.
public enum FonteBilhete: String, CaseIterable, Sendable {
    case padrao = "padrao"
    case mono = "mono"
    case serifada = "serifada"

    /// Diz se a fonte exige Bilhete Pro.
    ///
    /// - Returns: `false` só para `padrao`.
    ///
    /// Implementa a linha "Escolha de fonte" da matriz da seção 5 e o critério
    /// de aceite 8.10.2.
    public var exigePro: Bool { self != .padrao }
}

/// Preferências do aparelho (spec 7.3).
///
/// **Não são persistidas em SwiftData**, de propósito e por dois motivos: são
/// valores por aparelho, e a widget extension precisa lê-las de forma síncrona
/// no momento do render, sem abrir um `ModelContainer` (spec 4.5, item 3).
/// Nenhum dado de bilhete entra aqui — só estado pequeno.
///
/// As propriedades são armazenadas (para o `@Observable` avisar a SwiftUI, o
/// que cumpre o critério 8.10.1) e escrevem no `UserDefaults` do App Group a
/// cada mudança, para o widget enxergar o valor novo no render seguinte.
@Observable
public final class Preferences {

    /// Instância compartilhada, apontando para o suite do App Group.
    public static let shared = Preferences()

    @ObservationIgnored private let defaults: UserDefaults

    /// Chaves persistidas, em `snake_case` como na tabela 7.3 do spec.
    private enum Key {
        static let aparencia = "aparencia"
        static let fonte = "fonte"
        static let textoPequeno = "texto_pequeno"
        static let avisarExpiracao = "avisar_expiracao"
        static let boasvindasConcluida = "boasvindas_concluida"
        static let dicaWidgetVista = "dica_widget_vista"
        static let proDesbloqueado = "pro_desbloqueado"
        static let insistenciasWidget = "insistencias_widget"
        static let jaFixouAlgumaVez = "ja_fixou_alguma_vez"
        static let permissaoNotificacaoPedida = "permissao_notificacao_pedida"
        static let idioma = "idioma"
    }

    /// Aparência escolhida (7.3). Default: `sistema`.
    public var aparencia: Aparencia {
        didSet { defaults.set(aparencia.rawValue, forKey: Key.aparencia) }
    }

    /// Idioma do app. Default: `sistema`, que segue o iPhone (critério 8.11.3).
    ///
    /// Existe porque no teste em aparelho apareceu o caso óbvio que o spec não
    /// previu: iPhone em inglês, pessoa brasileira querendo o app em português.
    public var idioma: AppLanguage {
        didSet {
            defaults.set(idioma.rawValue, forKey: Key.idioma)
            LanguageSwitcher.apply(idioma)
        }
    }

    /// Fonte escolhida pela pessoa (7.3). Default: `padrao`.
    ///
    /// Guarda a **escolha**, não o efeito. Quem desenha usa `fonteEfetiva`, que
    /// aplica o gating do Pro sem apagar a preferência (regra 11.11).
    public var fonte: FonteBilhete {
        didSet { defaults.set(fonte.rawValue, forKey: Key.fonte) }
    }

    /// Reduz o corpo do texto em todas as superfícies (7.3, spec 16.3).
    public var textoPequeno: Bool {
        didSet { defaults.set(textoPequeno, forKey: Key.textoPequeno) }
    }

    /// Liga o aviso de expiração da regra 11.7. Default: ligado (assunção A-9,
    /// porque a persona P-C não vai procurar isso nos Ajustes).
    public var avisarExpiracao: Bool {
        didSet { defaults.set(avisarExpiracao, forKey: Key.avisarExpiracao) }
    }

    /// Marca que a tela de boas-vindas (10.6) já foi vista.
    public var boasvindasConcluida: Bool {
        didSet { defaults.set(boasvindasConcluida, forKey: Key.boasvindasConcluida) }
    }

    /// Marca que a dica de widget (10.7) já foi vista.
    public var dicaWidgetVista: Bool {
        didSet { defaults.set(dicaWidgetVista, forKey: Key.dicaWidgetVista) }
    }

    /// **Cache** do direito Pro, para a widget extension aplicar o gating sem
    /// acessar o StoreKit (spec 7.4).
    ///
    /// O app **nunca** decide direito por aqui: sempre relê o StoreKit ao abrir.
    public var proDesbloqueado: Bool {
        didSet { defaults.set(proDesbloqueado, forKey: Key.proDesbloqueado) }
    }

    /// Quantas vezes o app já falou de widget para a pessoa.
    ///
    /// Existe para cumprir o teto do spec 9.4: o app **nunca** insiste mais de
    /// duas vezes no total.
    public var insistenciasWidget: Int {
        didSet { defaults.set(insistenciasWidget, forKey: Key.insistenciasWidget) }
    }

    /// Marca que a pessoa já fixou pelo menos uma vez.
    ///
    /// É metade da condição da regra 11.10 — o paywall não pode aparecer antes
    /// de a pessoa ter criado um bilhete com texto **e** fixado ao menos uma
    /// vez. A outra metade é conferida no `PaywallGate`.
    public var jaFixouAlgumaVez: Bool {
        didSet { defaults.set(jaFixouAlgumaVez, forKey: Key.jaFixouAlgumaVez) }
    }

    /// Marca que a permissão de notificação já foi pedida uma vez.
    ///
    /// Critério de aceite 8.7.5: o app pede uma única vez, no primeiro "Fixar",
    /// e nunca de novo a cada fixação.
    public var permissaoNotificacaoPedida: Bool {
        didSet { defaults.set(permissaoNotificacaoPedida, forKey: Key.permissaoNotificacaoPedida) }
    }

    /// A fonte que deve ser efetivamente desenhada.
    ///
    /// - Returns: a escolha da pessoa, ou `padrao` quando ela escolheu uma fonte
    ///   Pro e o direito não está ativo.
    ///
    /// Implementa a regra 11.11: perder o Pro devolve a fonte padrão **sem
    /// apagar** a escolha, que volta a valer se o direito voltar.
    public var fonteEfetiva: FonteBilhete {
        (fonte.exigePro && !proDesbloqueado) ? .padrao : fonte
    }

    /// Lê as preferências do suite informado.
    ///
    /// - Parameter defaults: o `UserDefaults` a usar. O padrão é o suite do App
    ///   Group, que é o que o app e o widget compartilham (spec 4.5, item 3).
    ///   Os testes injetam um suite próprio para não sujar o do aparelho.
    public init(defaults: UserDefaults? = nil) {
        let store = defaults ?? UserDefaults(suiteName: AppConfig.appGroup) ?? .standard
        // `avisar_expiracao` é o único que nasce ligado (7.3). Registrar o
        // default antes de ler evita que a primeira leitura devolva `false`.
        store.register(defaults: [Key.avisarExpiracao: true])
        self.defaults = store

        self.aparencia = Aparencia(rawValue: store.string(forKey: Key.aparencia) ?? "") ?? .sistema
        self.idioma = AppLanguage(rawValue: store.string(forKey: Key.idioma) ?? "") ?? .sistema
        self.fonte = FonteBilhete(rawValue: store.string(forKey: Key.fonte) ?? "") ?? .padrao
        self.textoPequeno = store.bool(forKey: Key.textoPequeno)
        self.avisarExpiracao = store.bool(forKey: Key.avisarExpiracao)
        self.boasvindasConcluida = store.bool(forKey: Key.boasvindasConcluida)
        self.dicaWidgetVista = store.bool(forKey: Key.dicaWidgetVista)
        self.proDesbloqueado = store.bool(forKey: Key.proDesbloqueado)
        self.insistenciasWidget = store.integer(forKey: Key.insistenciasWidget)
        self.jaFixouAlgumaVez = store.bool(forKey: Key.jaFixouAlgumaVez)
        self.permissaoNotificacaoPedida = store.bool(forKey: Key.permissaoNotificacaoPedida)
    }
}
