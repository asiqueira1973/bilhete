import Foundation

/// Por onde o bilhete foi criado (spec 7.6).
///
/// Existe para contagem local (spec 21) e para medir se Siri e Controle valem o
/// custo de manutenção. **Nunca sai do aparelho**: não há SDK de analytics
/// (assunção A-8) e a ficha da App Store declara "Dados não coletados"
/// (spec 20).
///
/// Nomeado em português por fazer parte do schema persistido (spec 18.1).
public enum OrigemBilhete: String, Codable, CaseIterable, Sendable {
    /// Criado dentro do app.
    case app = "app"

    /// Criado por comando de voz.
    case siri = "siri"

    /// Criado por um Atalho.
    case atalho = "atalho"

    /// Criado pelo Controle da Central de Controle ou pelo Botão de Ação.
    case controle = "controle"

    /// Criado pela ação de um widget de tela de início.
    case widget = "widget"
}
