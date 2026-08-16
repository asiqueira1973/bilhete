import BilheteCore
import SwiftData
import SwiftUI

/// Tela 10.1 — o bilhete em destaque (épico 8.1).
///
/// Abre direto no editor, com o cursor ativo, sem nenhum passo intermediário:
/// é o cumprimento do princípio P2 ("escrever custa um toque"). Não há botão de
/// salvar — a gravação é por debounce de 1 segundo (regra 11.17).
///
/// A consulta é `@Query` para a tela reagir a mudança feita em qualquer outro
/// processo, inclusive pelo widget (spec 4.5, item 4).
struct FeaturedNoteView: View {
    /// Seleciona o texto inteiro ao aparecer.
    ///
    /// Só é verdadeiro logo depois do seed da primeira execução (spec 7.7),
    /// para o exemplo de 15.1 vir selecionado e digitar substituir.
    var selectsAllOnAppear = false

    /// Todos os bilhetes.
    ///
    /// A filtragem por estado é feita em memória, e não por `#Predicate`, porque
    /// o app é desenhado para até 500 bilhetes (spec 17) e assim o
    /// comportamento não depende de como o SwiftData resolve comparação de enum
    /// dentro de predicado. O que **não** pode mudar é o `@Query`: app e widget
    /// são processos separados, e a observação direta de modelo não reage à
    /// mudança feita pelo outro processo (spec 4.5, item 4).
    @Query private var notes: [Bilhete]

    @Environment(\.scenePhase) private var scenePhase
    @Environment(Preferences.self) private var preferences
    @Environment(BilheteStore.self) private var store
    @Environment(ProGate.self) private var proGate
    @Environment(PinService.self) private var pinService
    @Environment(ExpiryWarningScheduler.self) private var expiryScheduler

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var model: FeaturedNoteViewModel?
    @State private var showingDeleteConfirmation = false
    @State private var showingStack = false
    @State private var showingArchive = false
    /// Texto do bilhete que a poda apagaria; não-nulo enquanto o aviso 15.4
    /// está na tela (regra 11.4).
    @State private var pruneVictimText: String?
    /// Liga a animação de encerramento (16.7) enquanto o papel sai da tela.
    @State private var archiving = false
    /// Mostra a copy 15.6 quando as Atividades ao Vivo estão desligadas.
    @State private var showingPinUnavailable = false
    /// Mostra a copy 15.10 antes do pedido de permissão do sistema.
    @State private var showingNotificationRationale = false
    /// Mostra o cartão da tela 10.7 no rodapé do destaque (spec 9.4).
    @State private var showingGuideCard = false
    /// Abre a tela 10.7 inteira.
    @State private var showingGuide = false
    /// Abre a tela 10.4.
    @State private var showingSettings = false
    @FocusState private var editorFocused: Bool
    /// Se o teclado está de fato na tela.
    ///
    /// **Foco não é teclado.** Com teclado físico conectado, ou logo depois de
    /// o teclado descer, o campo continua focado e a tela ficava sem barra
    /// nenhuma. Quem decide o layout aqui é o teclado, não o foco.
    @State private var keyboardVisible = false

    /// O bilhete em destaque. É sempre zero ou um (regra 11.1).
    private var featured: Bilhete? { notes.first { $0.estado == .emDestaque } }

    /// Quantos bilhetes estão guardados, para o contador do acesso à pilha.
    private var stashedCount: Int { notes.count { $0.estado == .guardado } }

    /// Se o papel precisa ceder altura.
    ///
    /// Verdadeiro com o teclado na tela **ou** com o campo focado. São coisas
    /// diferentes — teclado físico dá foco sem teclado, e voltar de outra tela
    /// dá teclado antes de a notificação chegar — e qualquer uma das duas
    /// exige espaço para a barra de ações.
    private var needsRoomForKeyboard: Bool { keyboardVisible || editorFocused }

    /// Se a explicação do fluxo deve aparecer no rodapé.
    ///
    /// Aparece só enquanto a pessoa **ainda não guardou nem concluiu nada** — a
    /// dica se apaga sozinha quando deixa de ser necessária. Com o teclado
    /// aberto ela some, para não disputar espaço com a barra de ações.
    private var showsFlowHint: Bool {
        // Some com o teclado aberto, onde não há espaço, e some de vez quando a
        // pessoa guarda ou conclui o primeiro bilhete — dica que fica para
        // sempre vira ruído. A tela "Como o Bilhete funciona", nos Ajustes,
        // continua disponível para sempre.
        !needsRoomForKeyboard
            && stashedCount == 0
            && !notes.contains { $0.estado == .arquivado }
    }

    var body: some View {
        ZStack {
            // Tocar no fundo fecha o teclado. Sem isto, quem abre o teclado num
            // bilhete vazio fica preso: arrastar o texto não funciona (não há o
            // que rolar) e não havia botão nenhum de saída.
            Theme.fundoApp
                .ignoresSafeArea()
                .contentShape(.rect)
                .onTapGesture { leaveEditor() }

            // A barra de ações fica **dentro** da pilha, não num inset: com o
            // teclado aberto, a pilha inteira encolhe e a barra continua
            // visível. O `safeAreaInset` funcionava só às vezes — dependia de o
            // teclado já estar na tela quando a view aparecia, e voltando dos
            // Ajustes ele ficava atrás do teclado.
            VStack(spacing: 0) {
                topBar
                paper
                bottomBar
                    // Prioridade de layout: sem isto a SwiftUI espreme a barra
                    // quando o espaço aperta, e ela é a única parte que não
                    // pode sumir.
                    .layoutPriority(1)

                if showsFlowHint {
                    Text(loc: AppStrings.hintFlow)
                        .font(.footnote)
                        .foregroundStyle(Theme.tintaSecundaria)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.margin * 1.5)
                        .padding(.top, 12)
                        .transition(.opacity)
                }
                // Empurra tudo para o topo: sem isto o papel menor deixava a
                // pilha inteira boiando no meio da tela.
                Spacer(minLength: 0)
            }
        }
        .task { prepare() }
        .onReceive(NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillShowNotification
        )) { _ in
            withAnimation(.easeOut(duration: 0.2)) { keyboardVisible = true }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillHideNotification
        )) { _ in
            withAnimation(.easeOut(duration: 0.2)) { keyboardVisible = false }
        }
        // O destaque troca quando a pessoa guarda, arquiva ou promove outro:
        // a tela precisa reapontar o editor para o bilhete novo.
        .onChange(of: featured?.id) { prepare() }
        .onChange(of: scenePhase) { _, novo in
            // Gravação imediata ao ir para background (regra 11.17), o que
            // também cobre encerrar pelo multitarefa (critério 8.1.4).
            if novo != .active { model?.flush() }
        }
        // Navegar para outra tela solta o foco. Sem isto, o iOS devolve o
        // teclado ao voltar — e a pessoa cai numa tela com metade coberta sem
        // ter pedido para escrever.
        .onChange(of: showingStack) { _, abriu in if abriu { leaveEditor() } }
        .onChange(of: showingArchive) { _, abriu in if abriu { leaveEditor() } }
        .onChange(of: showingSettings) { _, abriu in if abriu { leaveEditor() } }
        .navigationDestination(isPresented: $showingStack) { StackView() }
        .navigationDestination(isPresented: $showingArchive) { ArchiveView() }
        .navigationDestination(isPresented: $showingGuide) { LockScreenGuideView() }
        .navigationDestination(isPresented: $showingSettings) { SettingsView() }
        .proGate(proGate)
        // Copy 15.10: explica por que o iPhone vai perguntar, antes de ele
        // perguntar. Uma única vez (critério 8.7.5).
        .alert(Text(loc: AppStrings.notifPermissionBody), isPresented: $showingNotificationRationale) {
            Button(String.loc(AppStrings.notifPermissionOK)) {
                Task {
                    await expiryScheduler.pedirPermissaoSeNecessario()
                    if let bilhete = model?.bilhete { performPin(bilhete) }
                }
            }
        }
        .confirmationDialog(
            Text(loc: AppStrings.deleteConfirmTitle),
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String.loc(AppStrings.actionDelete), role: .destructive) { delete() }
            Button(String.loc(AppStrings.actionCancel), role: .cancel) {}
        } message: {
            Text(loc: AppStrings.deleteConfirmBody)
        }
        // Live Activity indisponível (copy 15.6), com o atalho para os Ajustes
        // do iPhone — o app não tem como ligar isso sozinho.
        .alert(Text(loc: AppStrings.pinUnavailableTitle), isPresented: $showingPinUnavailable) {
            Button(String.loc(AppStrings.pinUnavailableSettings)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(String.loc(AppStrings.actionCancel), role: .cancel) {}
        } message: {
            Text(loc: AppStrings.pinUnavailableBody)
        }
        // Aviso de poda do arquivo grátis (copy 15.4). Aparece **antes** da
        // ação, é nominal e tem saída — mitigação do risco R-8.
        .confirmationDialog(
            Text(loc: AppStrings.pruneTitle),
            isPresented: .init(get: { pruneVictimText != nil }, set: { if !$0 { pruneVictimText = nil } }),
            titleVisibility: .visible
        ) {
            Button(String.loc(AppStrings.pruneConfirm), role: .destructive) {
                pruneVictimText = nil
                archive(confirmingPrune: true)
            }
            Button(String.loc(AppStrings.proNoticeSee)) {
                pruneVictimText = nil
                proGate.requestPro()
            }
            Button(String.loc(AppStrings.actionCancel), role: .cancel) { pruneVictimText = nil }
        } message: {
            Text(loc: AppStrings.pruneBody(oldestText: pruneVictimText ?? ""))
        }
    }

    // MARK: - Partes da tela

    /// Topo: Pilha, Concluídos, menu ••• e Ajustes (tela 10.1).
    ///
    /// Os dois destinos de um bilhete — a pilha e os concluídos — ficam à vista,
    /// não escondidos no menu. Em tela estreita os rótulos não cabem, e o
    /// `ViewThatFits` escolhe a versão que couber em vez de truncar palavra no
    /// meio: foi o que aconteceu no iPhone 13 mini ("0 bilh…", "Concluí…").
    private var topBar: some View {
        ViewThatFits(in: .horizontal) {
            topBarContent(showsLabels: true)
            topBarContent(showsLabels: false)
        }
        .font(.body)
        .foregroundStyle(Theme.tintaSecundaria)
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 8)
    }

    /// Monta a barra de topo com ou sem os rótulos de texto.
    /// - Parameter showsLabels: `true` para a versão com palavras.
    private func topBarContent(showsLabels: Bool) -> some View {
        HStack(spacing: 14) {
            Button { showingStack = true } label: {
                Label {
                    if showsLabels {
                        Text(loc: AppStrings.navStackCountLabel(stashedCount))
                            .font(.subheadline)
                            .lineLimit(1)
                            .fixedSize()
                    } else {
                        Text(verbatim: "\(stashedCount)")
                            .font(.subheadline)
                    }
                } icon: {
                    Image(systemName: "rectangle.stack")
                }
                .labelStyle(.titleAndIcon)
                .frame(minHeight: 44)
                .contentShape(.rect)
            }
            .accessibilityLabel(Text(loc: AppStrings.navStack))

            Button { showingArchive = true } label: {
                Label {
                    if showsLabels {
                        Text(loc: AppStrings.navDone)
                            .font(.subheadline)
                            .lineLimit(1)
                            .fixedSize()
                    }
                } icon: {
                    Image(systemName: "checkmark.circle")
                }
                .labelStyle(.titleAndIcon)
                .frame(minHeight: 44)
                .contentShape(.rect)
            }
            .accessibilityLabel(Text(loc: AppStrings.navDone))

            Spacer(minLength: 8)

            Menu {
                // Texto puro, sem assinatura, sem marca e sem link do app: um
                // bilhete compartilhado com marca é propaganda dentro do
                // conteúdo da pessoa (spec 14.1).
                ShareLink(item: model?.text ?? "") {
                    Label(String.loc(AppStrings.actionShare), systemImage: "square.and.arrow.up")
                }
                Button { copyText() } label: {
                    Label(String.loc(AppStrings.actionCopy), systemImage: "doc.on.doc")
                }
                Divider()
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label(String.loc(AppStrings.actionDelete), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .tappableArea()
                    .accessibilityLabel(Text(loc: AppStrings.actionMore))
            }

            Button { showingSettings = true } label: {
                Image(systemName: "gearshape")
                    .tappableArea()
                    .accessibilityLabel(Text(loc: AppStrings.navSettings))
            }
        }
    }

    /// O papel: o cartão com o texto do bilhete (16.1).
    private var paper: some View {
        VStack(alignment: .leading, spacing: 12) {
            editor
            HStack {
                if let model, model.saveFailed {
                    saveErrorLabel
                }
                Spacer()
                if let model, model.showsCounter {
                    counter(model)
                }
            }
        }
        .padding(Theme.margin)
        // O papel ocupa cerca de metade da tela, não a tela toda: um bilhete de
        // uma linha num cartão de tela inteira parece um formulário vazio, e a
        // metáfora da seção 16.1 é uma folha, não uma página.
        // Teto, não altura fixa: com espaço sobrando o papel para em 420pt (em
        // vez de ocupar a tela toda), e com o teclado aberto ele **encolhe**,
        // mantendo a barra visível. `containerRelativeFrame` não servia: media
        // o container, que não encolhe com o teclado.
        // Teto de 420pt e piso de 120pt: com espaço sobrando o papel para em
        // 420; com o teclado aberto ele encolhe até 120 e a barra continua na
        // tela.
        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 420, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Theme.paperCornerRadius, style: .continuous)
                .fill(Theme.papel)
                // Sombra mínima e difusa, sem borda dura (16.1).
                .shadow(color: .black.opacity(0.06), radius: 18, y: 6)
        )
        .padding(.horizontal, Theme.margin)
        // Animação de encerramento (16.7): o papel desliza para baixo e some
        // com leve rotação. Com redução de movimento ligada, vira só um fade
        // (spec 17, acessibilidade).
        .offset(y: archiving && !reduceMotion ? 900 : 0)
        .rotationEffect(.degrees(archiving && !reduceMotion ? 5 : 0), anchor: .topLeading)
        .opacity(archiving ? 0 : 1)
    }

    @ViewBuilder
    private var editor: some View {
        if let model {
            @Bindable var model = model
            ZStack(alignment: .topLeading) {
                if model.text.isEmpty {
                    Text(loc: AppStrings.editorPlaceholder)
                        .font(Theme.noteFont(preferences))
                        .foregroundStyle(Theme.tintaSecundaria)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $model.text, selection: $model.selection)
                    .font(Theme.noteFont(preferences))
                    .lineSpacing(Theme.bodyLineSpacing)
                    .foregroundStyle(Theme.tinta)
                    .scrollContentBackground(.hidden)
                    // Arrastar o texto para baixo fecha o teclado, sem precisar
                    // de botão "Pronto" ocupando espaço.
                    .scrollDismissesKeyboard(.interactively)
                    .focused($editorFocused)
                    .accessibilityLabel(Text(loc: AppStrings.editorAccessibility))
            }
        }
    }

    /// Contador de caracteres, visível a partir de 240 (regra 11.2).
    private func counter(_ model: FeaturedNoteViewModel) -> some View {
        Text(loc: AppStrings.editorCounter(count: model.characterCount, limit: BilheteStore.textLimit))
            .font(.footnote.monospacedDigit())
            .foregroundStyle(model.counterIsAtLimit ? Theme.destrutivo : Theme.tintaSecundaria)
            .accessibilityAddTraits(.updatesFrequently)
    }

    /// Aviso de falha de gravação (copy 15.5). O texto continua na tela.
    private var saveErrorLabel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(loc: AppStrings.errorSaveTitle)
                .font(.footnote.weight(.medium))
            Text(loc: AppStrings.errorSaveBody)
                .font(.caption)
        }
        .foregroundStyle(Theme.destrutivo)
    }

    /// Barra inferior: Guardar · Fixar/Soltar · Arquivar (tela 10.1).
    private var bottomBar: some View {
        VStack(spacing: 8) {
            if let fixadoAte = featured?.fixadoAte, fixadoAte > .now {
                pinnedBadge(until: fixadoAte)
            }

            // Nos tamanhos de acessibilidade os três botões lado a lado
            // espremem o rótulo até virar uma letra por linha. Empilhar mantém
            // o texto legível — exigência da seção 17 (Dynamic Type até
            // `.accessibility3` sem quebra de layout).
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 8) { barButtons }
            } else {
                HStack(spacing: 12) { barButtons }
            }
        }
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 16)
    }

    /// Os três botões da barra, na ordem da tela 10.1.
    ///
    /// Ficam separados do arranjo porque o arranjo muda com o tamanho de texto:
    /// lado a lado no tamanho normal, empilhados nos de acessibilidade.
    @ViewBuilder
    private var barButtons: some View {
        barButton(AppStrings.actionStash, systemImage: "tray.and.arrow.down") { stash() }

        // O botão vira "Soltar" enquanto o bilhete está na tela (tela 10.1,
        // estados). Expirado, volta a dizer "Fixar" (épico 8.4, estados).
        if isPinned {
            barButton(AppStrings.actionUnpin, systemImage: "pin.slash") { unpin() }
        } else {
            barButton(AppStrings.actionPin, systemImage: "pin") { pin() }
        }

        barButton(AppStrings.actionArchive, systemImage: "archivebox") { archive() }
            .disabled(archiving)
    }

    /// Selo do estado fixado: mostra até quando o bilhete fica na tela.
    ///
    /// - Parameter until: o instante de expiração, `agora + 8h` (regra 11.8).
    ///
    /// O terracota aparece aqui porque este é um dos poucos lugares onde a
    /// seção 16.2 autoriza a cor de marca: o estado fixado.
    private func pinnedBadge(until: Date) -> some View {
        Text(loc: AppStrings.pinBadge(until.formatted(date: .omitted, time: .shortened)))
            .font(.caption.weight(.medium))
            .foregroundStyle(Theme.marca)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    /// Diz se o bilhete em destaque está fixado agora.
    ///
    /// Confere a data além do id da atividade: a fixação expira sozinha em 8h
    /// (L1) e o botão não pode continuar dizendo "Soltar" para uma atividade que
    /// já morreu.
    private var isPinned: Bool {
        guard let bilhete = featured, bilhete.idAtividade != nil,
              let fixadoAte = bilhete.fixadoAte else { return false }
        return fixadoAte > .now
    }

    /// Botão da barra inferior, com área de toque de no mínimo 44pt (spec 17).
    private func barButton(
        _ title: LocalizedStringResource,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(String.loc(title), systemImage: systemImage)
                .font(.callout.weight(.medium))
                // Uma linha, encolhendo se precisar: "Arquivar" e "Guardar" não
                // cabem em três pílulas lado a lado sem isto, e quebravam no
                // meio da palavra.
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .barButtonStyle()
        .tint(Theme.tinta)
    }

    // MARK: - Ações

    /// Liga o view model ao bilhete em destaque e põe o cursor no campo.
    ///
    /// Implementa os critérios 8.1.1 e 8.1.6: com a pilha vazia, o app cria o
    /// destaque sozinho e o cursor já está ativo, sem toque adicional.
    private func prepare() {
        let model = model ?? FeaturedNoteViewModel(store: store)
        self.model = model

        let destaque: Bilhete? = featured ?? (try? store.ensureFeatured())
        guard let destaque else { return }
        let trocouDeBilhete = model.bilhete?.id != destaque.id
        model.bind(to: destaque)

        // O cursor só é pedido em bilhete **em branco**. Em bilhete que já tem
        // texto, abrir o teclado sozinho tira metade da tela sem a pessoa ter
        // pedido — foi o que aconteceu ao voltar dos Ajustes, no teste em
        // aparelho. O princípio P2 continua valendo onde importa: bilhete novo
        // abre pronto para escrever.
        guard trocouDeBilhete, destaque.texto.isEmpty || selectsAllOnAppear else { return }
        Task {
            // O foco só pega depois que o campo existe na árvore de views;
            // pedir no mesmo ciclo do primeiro render é ignorado em silêncio.
            await Task.yield()
            editorFocused = true
            // Vindo do seed da primeira execução, o texto de exemplo entra
            // selecionado para digitar substituir (fluxo 9.1, passo 2).
            if selectsAllOnAppear { model.selectAll() }
        }
    }

    /// Guarda o bilhete atual, abrindo um novo destaque em branco (épico 8.2).
    ///
    /// Grava antes de agir, como manda a regra 11.17. Com 3 ativos e sem Pro, o
    /// quarto bilhete não é criado e o caminho do Pro abre — critério 8.2.5 e
    /// regra 11.3.
    private func stash() {
        guard let bilhete = model?.bilhete else { return }
        model?.flush()
        do {
            try store.stash(bilhete)
        } catch BilheteStoreError.limitReached {
            proGate.requestPro()
        } catch {
            // Guardar é operação local: o único erro possível é de gravação, e
            // ele já aparece pela copy 15.5 do editor.
        }
    }

    /// Arquiva o bilhete em destaque (épico 8.3).
    ///
    /// - Parameter confirmingPrune: `true` quando a pessoa já viu o aviso 15.4
    ///   e autorizou apagar o bilhete mais antigo do arquivo (regra 11.4).
    ///
    /// Encerrar tem peso (princípio P4): toca a animação de 16.7 uma única vez,
    /// com háptico de sucesso, e só então grava. Antes de tudo, grava o texto
    /// pendente (regra 11.17) — arquivar não pode perder a última palavra
    /// digitada.
    private func archive(confirmingPrune: Bool = false) {
        guard let bilhete = model?.bilhete, !archiving else { return }
        model?.flush()

        // Confere a poda antes de animar: mostrar o papel saindo e trazer ele de
        // volta com um alerta seria mentir sobre o que aconteceu.
        if !confirmingPrune, let victim = store.pruneVictimText() {
            pruneVictimText = victim
            return
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.easeIn(duration: 0.4)) { archiving = true }

        Task {
            // 400 ms é a duração da animação de 16.7; o critério 8.3.1 pede que
            // o bilhete saia da tela em menos de 600 ms.
            try? await Task.sleep(for: .milliseconds(400))
            try? store.archive(bilhete, confirmingPrune: confirmingPrune)
            archiving = false
        }
    }

    /// Sai do editor antes de navegar para outra tela.
    ///
    /// Grava o que estiver pendente (regra 11.17) e solta o foco, para o teclado
    /// não voltar sozinho quando a pessoa retornar.
    private func leaveEditor() {
        model?.flush()
        editorFocused = false
    }

    /// Copia o texto puro do bilhete para a área de transferência (spec 14.1).
    private func copyText() {
        UIPasteboard.general.string = model?.text ?? ""
    }

    /// Fixa o bilhete na tela de bloqueio (épico 8.4).
    ///
    /// Grava o texto pendente antes (regra 11.17) — fixar tem que mostrar o que
    /// está na tela, não a versão de um segundo atrás. Se as Atividades ao Vivo
    /// estiverem desligadas, mostra a copy 15.6 com o atalho para os Ajustes do
    /// sistema, em vez de falhar em silêncio.
    private func pin() {
        guard let bilhete = model?.bilhete else { return }
        model?.flush()

        // Na primeira fixação, explica antes de o sistema perguntar (copy
        // 15.10). Uma única vez, nunca a cada fixação (critério 8.7.5).
        if !preferences.permissaoNotificacaoPedida {
            showingNotificationRationale = true
            return
        }
        performPin(bilhete)
    }

    /// Fixa de fato, depois de resolvida a permissão.
    ///
    /// - Parameter bilhete: o bilhete em destaque.
    ///
    /// Mostra a copy 15.6 se as Atividades ao Vivo estiverem desligadas, e
    /// oferece o cartão da tela 10.7 na primeira fixação (spec 9.4, item 1).
    private func performPin(_ bilhete: Bilhete) {
        do {
            // O cartão que sugeria o widget saiu na decisão D-7: fixar agora só
            // fixa, e o destaque de 12 horas é o caminho padrão do produto.
            try pinService.fixar(bilhete)
        } catch {
            showingPinUnavailable = true
        }
    }

    /// Solta o bilhete: tira da tela sem arquivar (critério 8.4.5).
    private func unpin() {
        guard let bilhete = model?.bilhete else { return }
        pinService.soltar(bilhete)
    }

    /// Exclui o bilhete atual, em definitivo (copy 15.19).
    private func delete() {
        guard let bilhete = model?.bilhete else { return }
        try? store.delete(bilhete)
    }
}
