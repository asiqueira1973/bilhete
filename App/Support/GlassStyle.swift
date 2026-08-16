import SwiftUI

/// Aplica o material Liquid Glass nativo quando o sistema tem (spec 16.8).
///
/// O deployment target é iOS 18.0 (spec 4.2), e o Liquid Glass só existe do
/// iOS 26 em diante. Em iOS 18 e 19 o app usa o estilo `bordered` do próprio
/// sistema. O spec é explícito em não replicar o material à mão nem usar blur
/// custom — então o degrade é para o padrão do sistema, não para uma imitação.
extension View {
    /// Estilo dos botões de barra.
    /// - Returns: a view com `.glass` no iOS 26+, `.bordered` antes disso.
    @ViewBuilder
    func barButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
    }

    /// Garante a área de toque mínima de 44×44pt exigida pela seção 17.
    ///
    /// Ícone de barra desenha uns 20pt; sem isto o alvo real fica menos da
    /// metade do mínimo, o que reprova em acessibilidade e erra o toque de quem
    /// tem pouca precisão — a persona P-C do spec.
    func tappableArea() -> some View {
        frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
    }
}
