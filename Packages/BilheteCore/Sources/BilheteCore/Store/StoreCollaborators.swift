import Foundation
import WidgetKit

/// O que o store precisa saber sobre o direito de compra (spec 5 e 7.4).
///
/// O store não fala com o StoreKit: ele pergunta. Assim a regra 11.3 (limite de
/// ativos) e a 11.4 (tamanho do arquivo) ficam testáveis sem StoreKit, e a
/// widget extension pode injetar o cache de `preferencias.pro_desbloqueado`
/// enquanto o app injeta o `EntitlementStore` de verdade.
public protocol EntitlementProviding: AnyObject {
    /// `true` quando o Bilhete Pro está ativo.
    var isPro: Bool { get }
}

/// Direito lido do cache das preferências (spec 7.4).
///
/// É o que a widget extension usa, porque ela não pode acessar o StoreKit. O
/// app **não** decide direito por aqui: ele injeta o `EntitlementStore`, que
/// relê o StoreKit ao abrir.
public final class CachedEntitlementProvider: EntitlementProviding {
    private let preferences: Preferences

    /// Cria o provedor lendo o cache do App Group.
    /// - Parameter preferences: as preferências compartilhadas.
    public init(preferences: Preferences = .shared) {
        self.preferences = preferences
    }

    public var isPro: Bool { preferences.proDesbloqueado }
}

/// O que o store precisa poder fazer com a Live Activity (spec 13.2).
///
/// O store é quem sabe **quando** a atividade tem que morrer — ao guardar, ao
/// promover outro, ao arquivar e ao excluir (regras 11.6 e 11.7) — mas não é
/// quem sabe **como**. O `PinService` do épico 8.4 implementa isto; até lá o
/// `NoopPinCoordinator` mantém o store completo e testável.
public protocol PinCoordinating: AnyObject {
    /// Encerra a Live Activity do bilhete, zera `fixadoAte` e `idAtividade` e
    /// cancela o aviso de expiração agendado (regras 11.6 e 11.7).
    /// - Parameter bilhete: o bilhete que está deixando de estar fixado.
    func soltar(_ bilhete: Bilhete)

    /// Atualiza o conteúdo da Live Activity em curso **sem recriá-la**, para o
    /// `idAtividade` não mudar (critério de aceite 8.4.3).
    /// - Parameter bilhete: o bilhete em destaque que acabou de mudar de texto.
    func atualizar(_ bilhete: Bilhete)
}

/// Implementação neutra, usada enquanto o épico 8.4 não existe e nos testes que
/// não são sobre Live Activity.
public final class NoopPinCoordinator: PinCoordinating {
    public init() {}

    /// Não faz nada além de limpar os campos locais de fixação, que é o efeito
    /// observável pelo modelo (invariante 2 da seção 22).
    public func soltar(_ bilhete: Bilhete) {
        bilhete.fixadoAte = nil
        bilhete.idAtividade = nil
    }

    public func atualizar(_ bilhete: Bilhete) {}
}

/// Quem recarrega as timelines dos widgets (regra 11.18).
public protocol WidgetReloading: AnyObject {
    /// Recarrega todas as timelines.
    func reloadAll()
}

/// Recarga de verdade, via `WidgetCenter` (spec 4.5, item 5).
///
/// O iOS limita a frequência de recarga — por isso o app chama explicitamente a
/// cada gravação em vez de confiar em atualização automática.
public final class WidgetCenterReloader: WidgetReloading {
    public init() {}

    public func reloadAll() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

/// Recarga silenciosa, para os testes contarem chamadas sem tocar no
/// `WidgetCenter`.
public final class NoopWidgetReloader: WidgetReloading {
    /// Quantas vezes a recarga foi pedida. Usado pelos testes da regra 11.18.
    public private(set) var reloadCount = 0

    public init() {}

    public func reloadAll() { reloadCount += 1 }
}
