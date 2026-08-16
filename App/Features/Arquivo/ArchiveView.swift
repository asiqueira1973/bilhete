import BilheteCore
import SwiftData
import SwiftUI

/// Tela 10.3 — o arquivo (épico 8.3).
///
/// Lista os arquivados do mais recente para o mais antigo, com restaurar e
/// excluir por item, busca (capacidade Pro, matriz da seção 5) e "Apagar tudo".
///
/// Arquivar não é excluir (princípio P4): o que está aqui continua inteiro e
/// pode voltar. Excluir, sim, é definitivo — e sempre com confirmação.
struct ArchiveView: View {
    @Query private var notes: [Bilhete]

    @Environment(BilheteStore.self) private var store
    @Environment(Preferences.self) private var preferences
    @Environment(ProGate.self) private var proGate

    @State private var searchText = ""
    @State private var noteToDelete: Bilhete?
    @State private var showingDeleteAll = false

    /// Os arquivados, do mais recente para o mais antigo (tela 10.3).
    private var archived: [Bilhete] {
        notes
            .filter { $0.estado == .arquivado }
            .sorted { ($0.arquivadoEm ?? .distantPast) > ($1.arquivadoEm ?? .distantPast) }
    }

    /// O que a lista mostra depois da busca.
    ///
    /// A busca só filtra com Pro. Sem Pro o campo aparece desabilitado com o
    /// selo, porque esconder a capacidade seria esconder o que o Pro vende
    /// (matriz da seção 5).
    private var visible: [Bilhete] {
        guard preferences.proDesbloqueado, !searchText.isEmpty else { return archived }
        return archived.filter { $0.texto.localizedStandardContains(searchText) }
    }

    var body: some View {
        ZStack {
            Theme.fundoApp.ignoresSafeArea()

            if archived.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    searchField
                    if visible.isEmpty {
                        emptySearch
                    } else {
                        list
                    }
                    deleteAllButton
                }
            }
        }
        .navigationTitle(Text(loc: AppStrings.archiveTitle))
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
        .confirmationDialog(
            Text(loc: AppStrings.archiveDeleteAllTitle),
            isPresented: $showingDeleteAll,
            titleVisibility: .visible
        ) {
            Button(String.loc(AppStrings.actionDelete), role: .destructive) {
                try? store.deleteAllArchived()
            }
            Button(String.loc(AppStrings.actionCancel), role: .cancel) {}
        } message: {
            Text(loc: AppStrings.archiveDeleteAllBody(count: archived.count))
        }
        .proGate(proGate)
    }

    /// Se o contador "10 de 10" deve aparecer (tela 10.3, regra 11.4).
    private var showsCounter: Bool {
        !preferences.proDesbloqueado && archived.count >= BilheteStore.archiveLimitFree
    }

    // MARK: - Partes da tela

    /// Estado vazio, com a copy 15.3.
    private var emptyState: some View {
        VStack(spacing: 12) {
            Text(loc: AppStrings.archiveEmptyTitle)
                .font(.title3.weight(.medium))
                .foregroundStyle(Theme.tinta)
            Text(loc: AppStrings.archiveEmptyBody)
                .font(.callout)
                .foregroundStyle(Theme.tintaSecundaria)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, Theme.margin * 2)
    }

    /// Busca sem resultado (tela 10.3, estados).
    private var emptySearch: some View {
        VStack {
            Spacer()
            Text(loc: AppStrings.archiveSearchEmpty)
                .font(.callout)
                .foregroundStyle(Theme.tintaSecundaria)
            Spacer()
        }
    }

    /// Campo de busca — capacidade Pro (matriz da seção 5).
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.tintaSecundaria)

            if preferences.proDesbloqueado {
                TextField(String.loc(AppStrings.archiveSearch), text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(Theme.tinta)
            } else {
                // Sem Pro o campo não digita: toca e explica. Esconder o campo
                // esconderia o que o Pro vende.
                Button { proGate.requestPro() } label: {
                    HStack {
                        Text(loc: AppStrings.archiveSearch)
                            .foregroundStyle(Theme.tintaSecundaria)
                        Spacer()
                        Text(loc: AppStrings.badgePro)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.marca)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .background(Theme.tinta.opacity(0.05), in: .rect(cornerRadius: 12))
        .padding(.horizontal, Theme.margin)
        .padding(.bottom, 8)
    }

    /// A lista de arquivados, por `arquivadoEm` decrescente.
    private var list: some View {
        List {
            ForEach(visible) { bilhete in
                VStack(alignment: .leading, spacing: 4) {
                    Text(bilhete.texto)
                        .font(.body)
                        .foregroundStyle(Theme.tinta)
                        .lineLimit(3)
                    if let arquivadoEm = bilhete.arquivadoEm {
                        // Data na formatação da região do aparelho (8.11.4).
                        Text(arquivadoEm, format: .dateTime.day().month(.abbreviated))
                            .font(.caption)
                            .foregroundStyle(Theme.tintaSecundaria)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .listRowBackground(Theme.papel)
                .listRowSeparatorTint(Theme.hairline)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        noteToDelete = bilhete
                    } label: {
                        Label(String.loc(AppStrings.actionDelete), systemImage: "trash")
                    }

                    Button {
                        restore(bilhete)
                    } label: {
                        Label(String.loc(AppStrings.archiveRestore), systemImage: "arrow.uturn.backward")
                    }
                    .tint(Theme.sucesso)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    /// "Apagar tudo" no rodapé (tela 10.3).
    private var deleteAllButton: some View {
        Button(role: .destructive) {
            showingDeleteAll = true
        } label: {
            Text(loc: AppStrings.archiveDeleteAll)
                .font(.callout)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Theme.destrutivo)
        .padding(.bottom, 8)
    }

    /// Selo "10 de 10" com a marca de Pro (tela 10.3).
    private var counterBadge: some View {
        Button { proGate.requestPro() } label: {
            HStack(spacing: 6) {
                Text(loc: AppStrings.stackCounter(count: archived.count, limit: BilheteStore.archiveLimitFree))
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

    /// Restaura um arquivado como guardado no topo da pilha (critério 8.3.4).
    ///
    /// Se isso passar de 3 ativos sem Pro, **nada acontece** com o bilhete e o
    /// caminho do Pro abre (regra 11.3).
    private func restore(_ bilhete: Bilhete) {
        do {
            try store.restore(bilhete)
        } catch BilheteStoreError.limitReached {
            proGate.requestPro()
        } catch {
            // Operação local: não há outro erro possível além de gravação.
        }
    }
}
