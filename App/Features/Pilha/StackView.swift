import BilheteCore
import SwiftData
import SwiftUI

/// Tela 10.2 — a pilha de guardados (épico 8.2).
///
/// Mostra os bilhetes `guardado` na ordem que a pessoa definiu (regra 11.5).
/// Tocar promove a destaque, arrastar reordena, o swipe arquiva ou exclui.
/// Não existe ordenação automática por data nem por relevância: a ordem é a que
/// a pessoa definiu (spec 11, "o que explicitamente não é automático").
struct StackView: View {
    @Query private var notes: [Bilhete]

    @Environment(BilheteStore.self) private var store
    @Environment(Preferences.self) private var preferences
    @Environment(ProGate.self) private var proGate
    @Environment(\.dismiss) private var dismiss

    @State private var noteToDelete: Bilhete?

    /// Os guardados, de cima para baixo (regra 11.5).
    private var stack: [Bilhete] {
        notes.filter { $0.estado == .guardado }.sorted { $0.ordemPilha < $1.ordemPilha }
    }

    /// O bilhete em destaque, listado no topo (decisão D-11).
    ///
    /// Ele **não** é da pilha — o estado dele continua sendo `emDestaque`, e a
    /// regra 11.1 continua valendo. Ele aparece aqui porque, sem isto, não havia
    /// nenhuma lista onde o bilhete ativo aparecesse: quando a fixação expirava,
    /// ele parecia ter sumido do app.
    private var featured: Bilhete? {
        notes.first { $0.estado == .emDestaque && !$0.texto.isEmpty }
    }

    /// Quantos bilhetes contam para o limite do plano grátis (regra 11.3).
    private var activeCount: Int { notes.count { $0.estado.contaComoAtivo } }

    /// Se o contador "3 de 3" deve aparecer.
    ///
    /// Só aparece no limite e só sem Pro: com Pro não há limite, e mostrar
    /// contagem sem limite seria transformar o app num painel de estatística,
    /// que o anti-escopo da seção 1 proíbe.
    private var showsCounter: Bool {
        !preferences.proDesbloqueado && activeCount >= BilheteStore.activeLimitFree
    }

    var body: some View {
        ZStack {
            Theme.fundoApp.ignoresSafeArea()
            if stack.isEmpty && featured == nil {
                emptyState
            } else {
                list
            }
        }
        .navigationTitle(Text(loc: AppStrings.stackTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showsCounter {
                ToolbarItem(placement: .topBarTrailing) { counterBadge }
            }
        }
        .confirmationDialog(
            Text(loc: AppStrings.deleteConfirmTitle),
            isPresented: .init(get: { noteToDelete != nil }, set: { if !$0 { noteToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button(String.loc(AppStrings.actionDelete), role: .destructive) {
                if let noteToDelete { try? store.delete(noteToDelete) }
                noteToDelete = nil
            }
            Button(String.loc(AppStrings.actionCancel), role: .cancel) { noteToDelete = nil }
        } message: {
            Text(loc: AppStrings.deleteConfirmBody)
        }
    }

    // MARK: - Partes da tela

    /// Estado vazio, com a copy 15.2 e o caminho de volta ao destaque.
    private var emptyState: some View {
        VStack(spacing: 12) {
            Text(loc: AppStrings.stackEmptyTitle)
                .font(.title3.weight(.medium))
                .foregroundStyle(Theme.tinta)
            Text(loc: AppStrings.stackEmptyBody)
                .font(.callout)
                .foregroundStyle(Theme.tintaSecundaria)
                .multilineTextAlignment(.center)

            Button { dismiss() } label: {
                Text(loc: AppStrings.stackEmptyButton)
                    .font(.callout.weight(.medium))
            }
            .buttonStyle(.borderless)
            .tint(Theme.marca)
            .padding(.top, 8)
            .frame(minHeight: 44)
        }
        .padding(.horizontal, Theme.margin * 2)
    }

    /// A lista de guardados, com reordenação e swipe.
    private var list: some View {
        List {
            // O destaque encabeça a lista, sem poder ser arrastado: ele não tem
            // posição na pilha (regra 11.5 vale só para os guardados).
            if let featured {
                featuredRow(featured)
                    .listRowBackground(Theme.papel)
                    .listRowSeparatorTint(Theme.hairline)
            }

            ForEach(stack) { bilhete in
                row(bilhete)
            }
            .onMove(perform: move)
            .listRowBackground(Theme.papel)
            .listRowSeparatorTint(Theme.hairline)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        // O arrasto reordena sem precisar entrar em modo de edição, que seria um
        // passo a mais contra o princípio P2.
        .environment(\.editMode, .constant(.active))
    }

    /// A linha do bilhete em destaque, no topo (D-11).
    ///
    /// - Parameter bilhete: o bilhete `emDestaque`.
    ///
    /// Não promove ao toque (já é o destaque) e não arquiva por swipe daqui —
    /// concluir é ato da tela principal, onde a animação de encerramento
    /// acontece (16.7).
    private func featuredRow(_ bilhete: Bilhete) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                Text(loc: AppStrings.stackFeaturedBadge)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(Theme.marca)

            Text(bilhete.texto)
                .font(.body)
                .foregroundStyle(Theme.tinta)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }

    /// Uma linha da pilha: trecho do texto e data relativa (tela 10.2).
    private func row(_ bilhete: Bilhete) -> some View {
        Button {
            promote(bilhete)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(bilhete.texto)
                    .font(.body)
                    .foregroundStyle(Theme.tinta)
                    .lineLimit(2)
                // A data segue a formatação da região do aparelho
                // (critério 8.11.4).
                Text(bilhete.atualizadoEm, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(Theme.tintaSecundaria)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text(loc: AppStrings.stackPromoteHint))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                noteToDelete = bilhete
            } label: {
                Label(String.loc(AppStrings.actionDelete), systemImage: "trash")
            }

            Button {
                archive(bilhete)
            } label: {
                Label(String.loc(AppStrings.actionArchive), systemImage: "archivebox")
            }
            .tint(Theme.sucesso)
        }
    }

    /// Selo "3 de 3" com a marca de Pro (tela 10.2, gating da seção 5).
    private var counterBadge: some View {
        Button {
            proGate.requestPro()
        } label: {
            HStack(spacing: 6) {
                Text(loc: AppStrings.stackCounter(count: activeCount, limit: BilheteStore.activeLimitFree))
                    .font(.caption.weight(.medium).monospacedDigit())
                Text(loc: AppStrings.badgePro)
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(Theme.marca)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.marca.opacity(0.12), in: .capsule)
        }
    }

    // MARK: - Ações

    /// Promove um guardado a destaque e volta para a tela do destaque.
    ///
    /// A troca dos dois estados é feita pelo store numa transação só
    /// (critério 8.2.2) e encerra a Live Activity do que sai (critério 8.2.3).
    private func promote(_ bilhete: Bilhete) {
        try? store.promoteToFeatured(bilhete)
        dismiss()
    }

    /// Arquiva um guardado pelo swipe (transição `guardado → arquivado`).
    ///
    /// O aviso de poda do arquivo grátis (copy 15.4) entra no épico 8.3; aqui a
    /// tentativa que precisa de confirmação simplesmente não arquiva, em vez de
    /// apagar o mais antigo sem perguntar.
    private func archive(_ bilhete: Bilhete) {
        try? store.archive(bilhete)
    }

    /// Reordena a pilha (regra 11.5).
    ///
    /// - Parameters:
    ///   - source: os índices arrastados.
    ///   - destination: o índice de destino.
    ///
    /// A sequência inteira é reescrita a partir de 0 pelo store, o que faz a
    /// ordem sobreviver a fechar e reabrir o app (critério 8.2.4).
    private func move(from source: IndexSet, to destination: Int) {
        try? store.reorder(from: source, to: destination)
    }
}
