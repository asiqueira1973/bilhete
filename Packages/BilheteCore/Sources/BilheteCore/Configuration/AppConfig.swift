import Foundation

/// Identificadores fixos do app (spec 18.5).
///
/// Nada aqui é segredo: o Bilhete não tem servidor, chave de API nem token. Os
/// mesmos valores vivem no `Bilhete.xcconfig` para o build; aqui eles existem
/// porque o package precisa deles em tempo de execução e não lê `.xcconfig`.
///
/// `CLOUDKIT_CONTAINER` não aparece: a decisão D-1 tirou o CloudKit e a
/// sincronização do escopo da v1.
public enum AppConfig {

    /// App Group compartilhado entre o app e a widget extension (spec 4.5,
    /// item 1). É onde o store do SwiftData vive, para os dois processos
    /// enxergarem o mesmo arquivo.
    public static let appGroup = "group.com.dablab.bilhete"

    /// Produto não-consumível do Bilhete Pro (spec 7.4). O preço **nunca** vem
    /// daqui — sempre do StoreKit localizado (critério 8.9.2).
    public static let proProductID = "com.dablab.bilhete.pro"

    /// Nome do arquivo do store dentro do container do App Group.
    public static let storeFileName = "Bilhete.store"
}

/// Links externos do app (perguntas Q-3 da seção 25, respondidas em D-5).
///
/// Centralizados em um lugar só para trocar em um lugar só.
public enum AppLinks {

    /// Página de suporte padrão da Dab Lab, já aceita pela Apple em revisões
    /// anteriores. Aparece nos Ajustes (tela 10.4).
    public static let support = URL(string: "https://suportedablab.carrd.co/")!

    /// Política de privacidade compartilhada dos aplicativos da Dab Lab.
    /// Aparece no rodapé do paywall (tela 10.5) e nos Ajustes.
    public static let privacy = URL(
        string: "https://app.notion.com/p/POL-TICA-DE-PRIVACIDADE-APLICATIVOS-DA-DAB-LAB-2bd4305f24e180c395cdda41879cf567"
    )!

    /// Endereço de contato para "Enviar feedback" (tela 10.4).
    public static let feedbackEmail = "alexandre@dablab.com.br"
}
