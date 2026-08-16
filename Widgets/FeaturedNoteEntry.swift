import BilheteCore
import SwiftData
import SwiftUI
import WidgetKit

/// Entrada de timeline dos widgets do Bilhete (épico 8.5).
///
/// É deliberadamente vazia: **o conteúdo não vem da timeline, vem do
/// `@Query`**. App e widget são processos separados com `ModelContainer`
/// distintos, e mudança feita por um é *remote change* para o outro — a
/// observação direta de modelo não reage a ela (spec 4.5, item 4, e risco R-6).
/// Popular a entrada à mão traria de volta exatamente o bug que o critério
/// 8.5.5 existe para impedir.
struct FeaturedNoteEntry: TimelineEntry {
    let date: Date
}

/// Provider de timeline dos widgets (épico 8.5).
///
/// Devolve uma única entrada e política `.never`: quem manda recarregar é o
/// app, com `reloadAllTimelines()` a cada gravação (regra 11.18). O iOS limita a
/// frequência de recarga, então não se confia em atualização automática
/// (spec 4.5, item 5).
struct FeaturedNoteProvider: TimelineProvider {
    /// Placeholder da galeria de widgets.
    /// - Parameter context: contexto do WidgetKit.
    /// - Returns: uma entrada com a data atual.
    func placeholder(in context: Context) -> FeaturedNoteEntry {
        FeaturedNoteEntry(date: .now)
    }

    /// Instantâneo para a galeria e para transições do sistema.
    func getSnapshot(in context: Context, completion: @escaping (FeaturedNoteEntry) -> Void) {
        completion(FeaturedNoteEntry(date: .now))
    }

    /// Timeline com uma entrada só.
    func getTimeline(in context: Context, completion: @escaping (Timeline<FeaturedNoteEntry>) -> Void) {
        completion(Timeline(entries: [FeaturedNoteEntry(date: .now)], policy: .never))
    }
}

/// Lê o bilhete em destaque direto do store compartilhado, por `@Query`.
///
/// Este é o ponto do app onde a regra 4.5, item 4 é cumprida — e é o que o
/// critério de aceite 8.5.5 valida: concluir pelo widget aparece no app **sem
/// exigir reinício**.
struct FeaturedNoteReader<Content: View>: View {
    /// Todos os bilhetes; a filtragem por estado é feita em memória, como no
    /// app, para não depender de como o SwiftData resolve enum em predicado.
    @Query private var notes: [Bilhete]

    /// O que desenhar com o bilhete em destaque (ou `nil`, estado vazio 15.7).
    private let content: (Bilhete?) -> Content

    /// Cria o leitor.
    /// - Parameter content: o desenho, que recebe o bilhete em destaque ou
    ///   `nil` quando não há nenhum com texto.
    init(@ViewBuilder content: @escaping (Bilhete?) -> Content) {
        self.content = content
    }

    var body: some View {
        let destaque = notes.first { $0.estado == .emDestaque }
        // Bilhete em branco conta como "sem bilhete" na tela de bloqueio: papel
        // vazio na tela de bloqueio não informa nada (copy 15.7).
        content(destaque?.texto.isEmpty == false ? destaque : nil)
    }
}

extension View {
    /// Liga a view do widget ao store compartilhado do App Group.
    ///
    /// - Returns: a view com o `ModelContainer` do App Group, ou o estado vazio
    ///   quando o store não abre — widget nunca pode travar.
    @ViewBuilder
    func bilheteStore() -> some View {
        if let container = BilheteContainer.optional {
            self.modelContainer(container)
        } else {
            WidgetEmptyLabel()
        }
    }
}

/// Estado vazio das superfícies do sistema (copy 15.7).
struct WidgetEmptyLabel: View {
    var body: some View {
        Text(WidgetStrings.empty)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)
    }
}
