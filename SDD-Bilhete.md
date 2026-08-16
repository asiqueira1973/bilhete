# SDD — Bilhete

**Versão do documento:** 1.3
**Produto:** Bilhete — nota na tela de bloqueio
**Responsável de produto:** Alexandre Siqueira (Dab Lab)
**Status:** v1.0 (build 1) submetida à revisão da App Store em 16/08/2026, com o produto de compra junto; pendências de validação na seção 22
**Data:** 15/08/2026 (v1.0) · 15/08/2026 (v1.1) · 16/08/2026 (v1.2) · 16/08/2026 (v1.3)
**Plataforma:** iOS — **iPhone apenas**

---

## Registro de alterações

### v1.3 — 16/08/2026

Nenhuma decisão nova e nenhuma mudança de escopo — a v1.0 já estava em revisão na
App Store quando esta versão foi escrita. Registra duas coisas:

| O quê | Onde |
|---|---|
| **A prateleira**: guardar usado como estoque de lembretes reutilizáveis, e não como fila. Uso observado depois do app pronto, já suportado pela v1, com consequência comercial (é um uso de Pro) e de copy (o vocabulário do produto só descreve a fila). | 2 |
| Status do documento atualizado para "submetida à revisão". | cabeçalho |

### v1.2 — 16/08/2026

Cinco decisões nascidas do **teste em aparelho** (iPhone 13 mini), depois da v1
construída. Duas delas mexem no que o documento defendia e estão explicadas por
extenso nas seções afetadas.

| # | Decisão | Seções afetadas |
|---|---|---|
| **D-7** | **O app deixou de sugerir o widget de tela de bloqueio.** A tela 10.7 continua existindo, sem porta de entrada. | 0 (P3 reescrito), 3, 8.5, 8.7, 9.4, 10.4, 21 (M4), 23 |
| **D-8** | **Seletor de idioma dentro do app** (Ajustes → Idioma: Sistema / Português / Inglês). | 7.3, 8.11, 10.4 |
| **D-9** | **"Arquivar" virou "Concluir"** no app, mesmo nome do botão da Live Activity. O primeiro bilhete **nasce vazio**, sem o texto de exemplo. | 7.7, 8.1, 8.3, 10.1, 15 |
| **D-10** | **"Arquivo" virou "Concluídos"**, com acesso no topo ao lado da Pilha. Contador com palavra ("3 bilhetes"). Nova tela **"Como o Bilhete funciona"** (10.8). | 10.1, 10.3, 10.4, 10.8, 15.3 |
| **D-11** | **A Pilha lista o bilhete em destaque no topo**, com o selo "na tela". Tocar no fundo fecha o teclado. | 10.1, 10.2 |

**O que a decisão D-7 custou, dito por extenso.** O widget era a resposta do
documento ao "momento mais difícil" da seção 2 — o destaque que morre às 15h. Sem
sugerir o widget, **o bilhete sai da tela sozinho depois de 12h** e volta por ato
da pessoa: o Controle da Central de Controle, que refixa em um toque sem abrir o
app, mais o aviso 30 minutos antes. O princípio P3 foi reescrito para descrever o
produto como ele é, e a métrica M4 passou a medir o refixar em vez da adoção do
widget. A aposta, tomada com o app na mão, é que instalar widget é mais difícil
para a maioria das pessoas do que refixar.

### v1.1 — 15/08/2026

Seis decisões tomadas por Alexandre durante a implementação. Todas já estão
aplicadas nas seções abaixo; esta lista existe para quem comparar com a v1.0.

| # | Decisão | Seções afetadas |
|---|---|---|
| **D-1** | **Sem CloudKit e sem sincronização.** SwiftData 100% local no container do App Group. | 3, 4.1, 4.3, 4.5, 6, 8.8, 10.4, 11.12, 11.14, 11.15, 15.11, 15.14, 15.20, 23 (R-9), 26 |
| **D-2** | **iPhone apenas.** Sem iPad, sem Mac Catalyst. | Cabeçalho, 4.2, 17, 24 (A-10), 25 (Q-5) |
| **D-3** | **Preço de lançamento R$ 19,90** em vez de R$ 19,90. | 5, 7.4, 25 (Q-1) |
| **D-4** | **Só PT-BR e EN.** Espanhol fora da v1. | 25 (Q-2) |
| **D-5** | **Links definitivos:** suporte no Carrd e privacidade no Notion da Dab Lab. | 25 (Q-3) |
| **D-6** | **Paleta nova: padrão de app da Apple com azul do sistema.** | 16.2, 16.6, 25 (Q-4) |

**O que a decisão D-1 preserva de propósito:** o modelo da seção 7 ficou
**idêntico** ao da v1.0 — sem `Array`/`Set`, sem `@Attribute(.unique)`, tudo
opcional ou com default, `VersionedSchema` desde o dia 1. Manter o schema
compatível com sincronização é o que permite ligar o CloudKit depois, na v2, sem
migração pesada. As restrições da seção 4.3 continuam valendo como regra de
projeto.

**O que a decisão D-6 troca:** a v1.0 defendia o terracota porque ele
distinguia o app de tudo que está na categoria. Com o azul do sistema, a aposta
passa a ser **parecer nativo** em vez de **parecer diferente**. A metáfora de
papel da seção 16.1 sobrevive na forma — cartão, cantos, sombra —, não mais na
cor.

---

## Como usar este documento

Este é o documento de referência único do Bilhete v1. Ele foi escrito para ser colado inteiro num agente de código (Claude Code) e produzir o app sem que o agente precise inventar decisão.

Consome este documento: **Claude Code**, para implementação; **Claude Design**, para as telas (via o arquivo `prompt-design-bilhete.md`, gerado junto).

Antes de gerar qualquer código, **revise a seção 24 (Assunções declaradas)**. Assunção não revisada vira verdade no minuto em que o agente começa a codar. A seção 25 (Perguntas abertas) lista o que ainda não tem dono — o agente deve **perguntar em vez de assumir** ao cruzar com qualquer item dela.

A numeração das seções é estável. Conversas futuras e o prompt de implementação referenciam "seção 8.2", "regra 11.4". Não renumere.

---

## 0. Princípios não-negociáveis

Regras de desempate. Quando houver dúvida de UX, copy ou trade-off, resolva a favor destes.

| # | Princípio | O que ele exclui |
|---|---|---|
| **P1** | **Uma coisa por vez.** Existe sempre exatamente um bilhete em destaque, e é ele que aparece na tela. Tudo o mais está guardado. | Exclui lista de notas como tela principal, exclui múltiplas Live Activities, exclui qualquer visão "todos os bilhetes" como tela de abertura. |
| **P2** | **Escrever custa um toque.** Do ícone ao cursor piscando não pode haver tela intermediária, modal, dica ou pergunta. | Exclui onboarding bloqueante, exclui tela de lista antes do editor, exclui "escolha uma categoria". |
| **P3** | **O bilhete nunca se perde.** A Live Activity expira em 12h por imposição do sistema, e o bilhete **sai da tela** — mas continua no app, aparece no topo da Pilha e volta para a tela de bloqueio em um toque pelo Controle. Perder o destaque nunca significa perder o bilhete. *(Reescrito na v1.2 pela decisão D-7. Na v1.0 e v1.1 este princípio se apoiava no widget permanente, que o app deixou de sugerir.)* | Exclui apagar por inatividade, exclui limpar automaticamente, exclui qualquer caminho em que o texto escrito deixe de estar acessível. |
| **P4** | **Arquivar é o gesto de encerramento.** É deliberado, é satisfatório e é reversível. Não é sinônimo de excluir. | Exclui checkbox discreto, exclui swipe silencioso sem feedback, exclui arquivar sem poder restaurar. |
| **P5** | **Grátis é útil de verdade.** O ciclo completo — escrever, fixar na tela, arquivar — funciona sem pagar nada, para sempre. O paywall vende capacidade, nunca destrava o básico. | Exclui limite de tempo, exclui marca d'água, exclui anúncio, exclui bloquear a Live Activity. |

---

## 1. Visão e problema

**Bilhete é o bilhete de geladeira do seu iPhone.** Você escreve uma coisa que precisa lembrar, ela fica grande na tela de bloqueio, e você arquiva quando resolveu.

**O problema:** o lembrete que importa hoje não cabe em nenhuma ferramenta existente. App de tarefas exige projeto, prazo e categoria para guardar "comprar pão". Notas vira um cemitério de arquivos sem título. Lembrete com alarme dispara uma vez no horário errado e some. Mensagem pra si mesmo no WhatsApp se perde na conversa seguinte. O que falta é o equivalente digital do papel preso na geladeira: **uma coisa, visível o tempo todo, que some quando você resolve.**

**Para quem:** pessoa brasileira, usuária de iPhone, que tem de uma a três coisas por dia que precisa ter na frente dos olhos — não trinta. Estudante, autônomo, pai ou mãe de família, pessoa em tratamento de saúde, qualquer um que já mandou mensagem pra si mesmo pra não esquecer.

**A escolha de posicionamento:** o mercado tem 14+ apps de nota na tela de bloqueio, nenhum localizado em português e nenhum feito no Brasil. Todos tratam a nota como objeto pessoal e nenhum resolve bem a expiração de 12 horas da Live Activity. O Bilhete ataca exatamente esses dois pontos.

### Anti-escopo — o que o Bilhete explicitamente não é

- **Não é um app de tarefas.** Sem projeto, sem prazo, sem prioridade, sem subtarefa, sem etiqueta.
- **Não é um app de notas.** Sem pasta, sem título, sem formatação, sem anexo, sem markdown.
- **Não é um lembrete com alarme.** A única notificação que existe é o aviso de expiração do destaque (regra 11.7).
- **Não é um app de produtividade com gráfico.** Sem streak, sem estatística, sem gamificação.
- **Não é multiusuário na v1.** Compartilhamento entre pessoas está na seção 28 (roadmap v2), e a v1 é modelada para recebê-lo sem reescrita.

---

## 2. Personas e cenários de uso

### P-A — Camila, 34, autônoma, São Paulo
Trabalha em casa, tem o dia fragmentado. O momento de uso dela é **entre uma coisa e outra**: lembra de algo no meio de uma ligação e precisa registrar em 3 segundos, sem sair do que está fazendo. Se o app pedir mais de um toque, ela não usa — manda mensagem pra si mesma no WhatsApp e perde.
**Implicação de desenho:** a captura por Siri e pelo Botão de Ação não é conveniência, é o caso de uso principal dela.

### P-B — Rodrigo, 21, estudante, Recife
Usa o telefone dezenas de vezes por dia e a tela de bloqueio é a superfície que ele mais vê. Quer a informação **na cara**, sem abrir nada. Não vai pagar assinatura por isso, mas pagaria uma vez um valor de lanche.
**Implicação de desenho:** o widget permanente da tela de bloqueio importa mais que o app em si. E o modelo é compra única.

### P-C — Dona Eliane, 58, Belo Horizonte
Não é usuária avançada. Não vai descobrir sozinha que existe um widget, que ele precisa ser adicionado à mão na tela de bloqueio, nem que a Live Activity expira. Se o bilhete sumir sem explicação, ela conclui que o app "não funciona" e desinstala.
**Implicação de desenho:** este é o momento mais difícil de uso e é ele que define a arquitetura. O app precisa (a) ensinar a adicionar o widget de um jeito que não seja um texto de ajuda, (b) avisar antes do destaque expirar, e (c) nunca deixar o bilhete desaparecer de verdade.

### O momento mais difícil
São 15h. A pessoa fixou o bilhete às 7h. Às 15h a Live Activity morreu por imposição do sistema, sumiu da Dynamic Island e vai sumir da tela de bloqueio até as 19h. **Se o app não fizer nada, a pessoa acha que perdeu o bilhete.** A resposta do Bilhete a esse momento é a soma de três coisas: o widget permanente que continua lá, o aviso de expiração 30 minutos antes, e o Controle da Central de Controle que refixa em um toque sem abrir o app.

### A prateleira — um segundo uso, observado depois de pronto

Descoberto pelo Alexandre usando o app, em 16/08/2026, e registrado aqui porque
**não foi previsto no desenho**: guardar não serve só de fila, serve de
**prateleira de lembretes reutilizáveis**.

A pessoa deixa guardados bilhetes que se repetem — "pôr o computador na mochila",
"passar na padaria", "levar o guarda-chuva" — e vai fixando cada um quando o
contexto pede. O bilhete nunca é concluído: sai da tela pelo **Soltar**, volta
para a pilha pelo **Guardar**, e fica disponível para a próxima vez.

**A v1 já suporta isso, sem código novo.** Nada expira um bilhete guardado, e a
poda da regra 11.4 só alcança os concluídos. O caminho de volta também existe se
a pessoa concluir por engano: restaurar devolve o bilhete ao topo da pilha
(épico 8.3).

Três consequências que valem estar escritas:

1. **É um uso de Pro na prática.** Uma prateleira útil tem mais de três itens, e
   o limite de 3 ativos do plano grátis (regra 11.3) inclui os guardados. Este é
   o argumento de venda mais concreto que apareceu até agora, e **não está em
   lugar nenhum da ficha da loja** nem da copy da seção 15.
2. **O vocabulário do produto descreve só a fila.** "Guardar é o agora não"
   (seção 15) e "o que pode esperar fica atrás" descrevem algo temporário. A
   prateleira é o oposto: permanente e recorrente. Mesma mecânica, modelo mental
   diferente, e nenhum texto do app nomeia o segundo.
3. **Ela roça o item 28.2 sem precisar dele.** Prateleira parece pedir
   recorrência, mas não pede: um bilhete que nunca é concluído já é recorrente
   por omissão. Antes de construir prazo e recorrência, vale checar se o que as
   pessoas queriam era só isto.

Nada disso muda a v1. Fica como hipótese a observar nas avaliações e no uso —
se confirmar, a resposta provavelmente é copy, não feature.

---

## 3. Escopo do MVP

### Dentro da v1

| # | Item | Épico |
|---|---|---|
| 1 | Bilhete em destaque com edição inline, salvamento automático | 8.1 |
| 2 | Pilha de bilhetes guardados, com promoção a destaque e reordenação | 8.2 |
| 3 | Arquivar, restaurar e excluir | 8.3 |
| 4 | Live Activity na tela de bloqueio e Dynamic Island, com botões | 8.4 |
| 5 | Widgets de tela de bloqueio (`accessoryRectangular`, `accessoryInline`) | 8.5 |
| 6 | Widgets de tela de início (`systemSmall`, `systemMedium`), interativos | 8.5 |
| 7 | Controle da Central de Controle + Botão de Ação: refixar e criar bilhete | 8.6 |
| 8 | Siri e Atalhos: criar bilhete, refixar, arquivar | 8.6 |
| 9 | Aviso de expiração do destaque (notificação local, opcional) | 8.7 |
| 10 | Armazenamento local no App Group e exportação de tudo (decisão D-1) | 8.8 |
| 11 | Compra vitalícia "Bilhete Pro" — R$ 19,90, StoreKit 2 | 8.9 |
| 12 | Ajustes: aparência, fonte, tamanho de texto, aviso, restaurar compras | 8.10 |
| 13 | Localização PT-BR (canônica) e EN | 8.11 |
| 14 | Compartilhar e copiar o texto do bilhete (share sheet do sistema) | 8.3 |

### Fora da v1

| Item | Destino | Motivo / dependência |
|---|---|---|
| **Bilhete compartilhado entre pessoas** | **v2** — seção 28.1 | É o diferencial estratégico do produto, mas exige backend, identidade e sincronia entre contas iCloud distintas (CloudKit privado não compartilha entre contas). A v1 valida a demanda e é modelada para receber isso sem reescrever a seção 7. |
| **Prazo e recorrência do bilhete** | **v2** — seção 28.2 | Depende de decidir se o Bilhete vira lembrete com alarme, o que conflita com o anti-escopo atual. Precisa de validação de uso primeiro. |
| **Bilhete por contexto (chegou no mercado, saiu de casa)** | **v2** — seção 28.3 | Restrição técnica dura: geofence **não pode iniciar** Live Activity a partir de background (seção 4.4). Só viável via notificação acionável ou Atalho. Precisa de desenho próprio. |
| **Renovação automática da Live Activity via push** | **v2** — seção 28.4 | Exige backend e o payload de `start` da APNs **obriga um `alert`**, ou seja: notificação para o usuário a cada 8h. Só faz sentido depois que o backend da v2 existir por outro motivo. |
| **Temas e cores personalizadas** | **Descartado na v1** | Conflita com P2 e com a promessa de simplicidade, e o widget da tela de bloqueio é forçado a escala de cinza pelo sistema (seção 4.5) — ou seja, cor não aparece onde mais importa. Fontes ficam (item 12), cores não. |
| **Anúncios** | **Descartado permanentemente** | Viola P5. A guideline 2.5.18 da Apple proíbe anúncio em widget e extension, e a categoria já tem um caso com 2,73 estrelas por isso. |
| **Apple Watch com UI dedicada** | **Descartado na v1 — ganho automático** | A Live Activity do iPhone já aparece sozinha no Smart Stack do watchOS 11+, sem código. Vale citar no marketing; não vale código na v1. |
| **Conta de usuário / login** | **Descartado permanentemente na v1** | Não há identidade nenhuma: o app é local. Ver seção 6. |
| **Sincronização entre aparelhos (CloudKit privado)** | **v2** — decisão D-1 | Tirada da v1 em 15/08/2026 para simplificar o app: na prática a maioria das pessoas tem um telefone só. O modelo da seção 7 continua compatível com sync, então religar é adicionar a configuração do container, não reescrever. Sem sync, "Exportar tudo" (14.2) passa a ser o único backup fora do backup do iPhone. |
| **iPad e Mac Catalyst** | **Descartado na v1** — decisão D-2 | O app é de tela de bloqueio de iPhone. |

---

## 4. Arquitetura

### 4.1 Stack

| Camada | Escolha | Versão | Por quê | Alternativa descartada |
|---|---|---|---|---|
| Linguagem | Swift | 6.3 (Xcode 26.6) | Padrão atual da plataforma. | — |
| UI | SwiftUI | iOS 18+ | O app tem 7 telas e nenhuma view complexa; UIKit seria custo sem retorno. | UIKit |
| Persistência | **SwiftData** | iOS 18+ | Modelo minúsculo (2 entidades), integração nativa com `@Query` no app e nos widgets, e suporte a App Group e CloudKit em uma linha de configuração. | Core Data (mais seguro, muito mais boilerplate); GRDB/SQLiteData (não integra com widget via `@Query`). **Ver risco R-1 e a regra de mitigação 4.3.** |
| Sincronização | **Nenhuma na v1** (decisão D-1) | — | O dado vive no container do App Group e não sai do aparelho. Simplifica o app e elimina toda a superfície de conflito, merge e estado de sincronização. | CloudKit privado (era o plano da v1.0; foi para a v2 sem perda — o schema continua compatível). |
| Tela de bloqueio / Início | WidgetKit | iOS 18+ | — | — |
| Destaque temporário | ActivityKit | iOS 18+ | — | — |
| Ações do sistema | App Intents | iOS 18+ | Um único tipo de intent monta em widget, Controle, Live Activity, Siri, Atalhos, Spotlight e Botão de Ação. É a camada de ação canônica do app. | Intents separados por superfície (duplicação garantida). |
| Compra | StoreKit 2 | iOS 18+ | Verificação criptográfica JWS no próprio aparelho. **Não exige servidor** para não-consumível. | StoreKit 1 (obsoleto); RevenueCat (camada paga desnecessária para um único produto). |
| Notificação local | UserNotifications | — | Só o aviso de expiração. | — |

**Repositório:** Git, um único repositório, `main` protegida.
**Deploy:** App Store Connect, conta Apple Developer da Dab Lab.
**Bundle ID:** `com.dablab.bilhete` · App Group: `group.com.dablab.bilhete` · CloudKit container: `iCloud.com.dablab.bilhete`

### 4.2 Deployment target: iOS 18.0

Decisão e justificativa, com os números verificados em agosto/2026:

- **Controles da Central de Controle exigem iOS 18+.** É o requisito mais restritivo de toda a v1, e o Controle é o item 7 do escopo — o diferencial que resolve a expiração de 12h. Isso sozinho descarta iOS 17.
- **Cobertura:** dados oficiais da Apple de 07/06/2026 dão iOS 26 em 79% de todos os iPhones e iOS 18 em 14% — soma de **93%**. No lançamento previsto (out/nov 2026) o iOS 27 já estará distribuído e a cobertura de "iOS 18 ou superior" só cresce.
- **iOS 26 como mínimo** custaria ~21% da base sem ganhar nenhuma API que a v1 use.
- **Requisito obrigatório de submissão:** desde 28/04/2026 todo binário precisa ser compilado com **Xcode 26+ e SDK do iOS 26**. Isso é sobre o SDK de compilação, não sobre o deployment target — os dois convivem.
- APIs novas de SwiftData anunciadas no WWDC26 (`sectionBy:`, `@Attribute(.codable)`, `ResultsObserver`, `HistoryObserver`) só chegam no iOS 27. **A v1 não pode depender delas.** Se forem usadas, é atrás de `@available`.

### 4.3 Regra de mitigação obrigatória do SwiftData (leia antes de modelar)

Há uma regressão conhecida e **sem correção confirmada** introduzida no iOS 26.1: atributos de tipo `Array` e `Set` passaram a ser convertidos internamente de `Binary Data` para `Transformable`, causando falha de migração (`NSCocoaErrorDomain 134140`), travamento na abertura e **perda de dados de usuários com iCloud ligado**. Um engenheiro de Developer Relations da Apple classificou publicamente como bug sério e não resolvido.

**Regra:** o modelo de dados do Bilhete **não pode conter nenhuma propriedade de tipo `Array` ou `Set` de tipos primitivos em classes `@Model`.** A seção 7 já está desenhada assim — não há nenhuma. Qualquer coleção futura deve ser modelada como **relacionamento entre entidades** ou serializada explicitamente como `Data` com JSON manual. Esta regra não é opcional e vale para toda evolução do schema.

**Restrições estruturais que continuam valendo mesmo sem CloudKit** (decisão D-1). Elas vinham do CloudKit e ficaram por escolha: manter o schema compatível com sincronização é o que permite religá-la na v2 sem migração pesada. Valem obrigatoriamente para a seção 7:

1. `@Attribute(.unique)` é **proibido**. Unicidade tem que ser garantida em código.
2. Toda propriedade precisa ser **opcional ou ter valor default**.
3. Todo relacionamento precisa ser **opcional**; regra de deleção `Deny` não é permitida.
4. Depois que o sync está ligado, **só migrações leves (lightweight) são possíveis** — permanentemente. Mudança de schema que exija mapeamento manual está fora.
5. Não existe database pública nem compartilhamento entre contas iCloud (por isso a v2 precisa de backend).
6. Troca de conta iCloud no aparelho **limpa os dados locais da conta anterior**.
7. A sincronização não é em tempo real; a frequência é modulada por rede e bateria.

### 4.4 Restrições de plataforma que definem o produto

Estes são fatos documentados pela Apple, não escolhas. O desenho inteiro do app decorre deles.

| # | Restrição | Fonte | Consequência de desenho |
|---|---|---|---|
| **L1** | Live Activity fica **ativa por até 8h**; depois o sistema encerra, ela some **imediatamente** da Dynamic Island e permanece congelada na tela de bloqueio por **até 4h**. Teto duro: **12h**. | Apple, *Displaying live data with Live Activities* | A Live Activity **não pode ser** a camada permanente. Ver L2. |
| **L2** | Widget de tela de bloqueio (`accessory*`) **não expira**. | WidgetKit | O widget é a camada permanente do Bilhete. Isso é o cumprimento de P3. |
| **L3** | `dismissalPolicy: .after(data)` é **cortado em 4h** pelo sistema, independente da data passada. | `ActivityUIDismissalPolicy` | Não adianta tentar estender por aí. |
| **L4** | **Iniciar** Live Activity exige o app em **foreground**. De background retorna `ActivityAuthorizationError.visibility`. `BGAppRefreshTask`, push silencioso e geofence **não iniciam**. | Fórum Apple, resposta de DTS (thread 818467) | Renovação automática sem interação é impossível sem backend. |
| **L5** | `LiveActivityIntent` executa **sem abrir o app**, mas **só disparado por ação do usuário**: Controle da Central de Controle, Botão de Ação, botão de widget, Atalho ou Siri. | AppIntents | **É por aqui que o refixar em um toque funciona.** É o caminho central da v1. |
| **L6** | Um Controle da Central de Controle **pode** disparar um `LiveActivityIntent` diretamente, chamando `Activity.request(...)` dentro do `perform()`. Oficialmente suportado e demonstrado pela Apple (WWDC24, sessão 10157). | WWDC24 10157 | Confirma L5 como caminho viável e sem backend. |
| **L7** | Push-to-start via APNs renova sem o app aberto, **mas o payload de `start` obriga um `alert`** — o usuário recebe notificação a cada renovação. | Apple, ActivityKit push | Por isso a renovação automática ficou fora da v1 (seção 3). |
| **L8** | Widgets de tela de bloqueio rodam **sempre em modo `vibrant`**: o sistema **dessatura o conteúdo para escala de cinza** e recolore para o fundo. **Não há como exibir cor nem desativar.** | WidgetKit / fórum Apple | O widget de tela de bloqueio precisa ser desenhado com **peso e opacidade**, nunca com cor. Ver seção 16.4. |
| **L9** | Botão interativo em widget de **tela de bloqueio**: com o aparelho bloqueado, o estado visual muda na hora mas **o intent só executa depois do desbloqueio**. Se o usuário cancelar o desbloqueio, **não há API pública para detectar e reverter** o estado visual. | Fórum Apple (thread 766780) | **O botão de ação principal não vai no widget de tela de bloqueio.** Vai no Controle e no widget de tela de início. Ver regra 11.9. |
| **L10** | O **texto** de título e valor de um Controle **fica oculto na tela de bloqueio** e nos tamanhos pequenos da Central de Controle. | ControlWidget | O Controle precisa ser compreensível **só pelo símbolo**. Ver seção 16.6. |
| **L11** | Payload total da Live Activity (`ActivityAttributes` + `ContentState`) **≤ 4 KB**. | ActivityKit | Não é gargalo para texto. O gargalo é a área de tela (L12). |
| **L12** | Área da Live Activity na tela de bloqueio: largura 371–408pt, altura **84–160pt**. Não existe campo de texto nem teclado dentro dela. | HIG Live Activities | Edição só no app, via deep link. Limite prático de texto na regra 11.2. |
| **L13** | `perform()` de um Controle deve **completar de forma síncrona**. `ForegroundContinuableIntent` **não é suportado** em Controle. | ControlWidget | O Controle refixa e retorna; não abre fluxo. |
| **L14** | Toda frase de `AppShortcut` **precisa conter `\(.applicationName)`**, senão não é registrada. O código dos intents deve ficar no **target principal**, não numa extension. | AppIntents | Ver seção 13.3. |

### 4.5 Compartilhamento de dados entre app, widget e Live Activity

Padrão obrigatório:

1. **App Group** `group.com.dablab.bilhete` habilitado no target do app **e** no target da widget extension.
2. **Dados estruturados → SwiftData com App Group**: `ModelConfiguration(schema:url:)` apontando para `Library/Application Support/Bilhete.store` dentro do container do App Group. **Sem `cloudKitDatabase`** (decisão D-1). O caminho é montado à mão porque a pasta `Application Support` não existe em instalação nova e o SwiftData não a cria. As classes `@Model` ficam num **Swift Package interno compartilhado** (`BilheteCore`), incluído nos dois targets — não duplicadas.
3. **Estado pequeno → `UserDefaults(suiteName: "group.com.dablab.bilhete")`**: flag de Pro desbloqueado, preferências de aparência, flag de primeiro uso. Nunca dados de bilhete.
4. **Nas views de widget: sempre `@Query`, nunca `@State` populado à mão.** Motivo: app e widget são processos separados com `ModelContainer` distintos; mudança feita pelo widget é *remote change* para o app e a observação direta de modelo não reage a ela. Este é um bug conhecido e a única defesa é `@Query`.
5. **Ao gravar no app:** chamar `WidgetCenter.shared.reloadAllTimelines()`. O iOS limita a frequência de recarga — não confie em atualização automática.
6. **Live Activity não compartilha store**: o canal de dados é o `ContentState`. O App Group serve só para a UI da Live Activity ler assets e preferências.
7. `NSSupportsLiveActivities = YES` no Info.plist.

### 4.6 Estrutura do repositório

```
Bilhete/
├── Bilhete.xcodeproj
├── Packages/
│   └── BilheteCore/                 ← Swift Package interno, usado por todos os targets
│       └── Sources/BilheteCore/
│           ├── Models/              ← classes @Model (seção 7)
│           ├── Store/               ← BilheteStore, ModelContainer compartilhado
│           ├── Intents/             ← todos os AppIntents (camada de ação canônica)
│           ├── Entitlement/         ← EntitlementStore (StoreKit 2)
│           ├── LiveActivity/        ← BilheteAttributes, PinService
│           └── Localization/        ← pt-BR.lproj, en.lproj
├── App/                             ← target principal
│   └── Features/
│       ├── Destaque/                ← tela 10.1
│       ├── Pilha/                   ← tela 10.2
│       ├── Arquivo/                 ← tela 10.3
│       ├── Ajustes/                 ← tela 10.4
│       ├── Paywall/                 ← tela 10.5
│       └── Boasvindas/              ← telas 10.6 e 10.7
├── Widgets/                         ← widget extension (widgets + Live Activity + Controles)
├── BilheteTests/
└── DOCUMENTACAO-TECNICA.md          ← gerado ao fim (seção 19)
```

Organização por feature: componentes, hooks de dados e tipos de cada tela ficam juntos na pasta da feature.

---

## 5. Perfis de usuário e matriz de direitos

O Bilhete **não tem perfis de acesso, login nem multiusuário na v1** — é um app de uso pessoal com um único usuário por aparelho. Não existe matriz de permissões no sentido tradicional, e não existe "primeiro administrador" a semear.

O que existe e cumpre o mesmo papel de decisão antecipada é a **matriz de direitos por estado de compra**. Ela é a fonte única para todo gating de UI: o que aparece habilitado, o que aparece com selo de Pro, o que abre o paywall.

| Ação | Grátis | Pro (R$ 19,90 vitalício) |
|---|---|---|
| Criar, editar e salvar o bilhete em destaque | ✅ ilimitado | ✅ ilimitado |
| Fixar na tela de bloqueio (Live Activity) | ✅ ilimitado | ✅ ilimitado |
| Refixar pelo app | ✅ | ✅ |
| Widget de tela de bloqueio e de tela de início | ✅ | ✅ |
| Arquivar e restaurar | ✅ | ✅ |
| Compartilhar / copiar o texto | ✅ | ✅ |
| Aviso de expiração do destaque | ✅ | ✅ |
| **Bilhetes ativos** (destaque + guardados) | ✅ **até 3** | ✅ **ilimitado** |
| **Arquivo** | ✅ **até 10 mais recentes**; ao arquivar o 11º, o mais antigo é excluído definitivamente | ✅ **ilimitado** |
| **Busca no arquivo** | ❌ | ✅ |
| **Refixar pela tela de bloqueio (Controle "Refixar bilhete")** | ✅ *(grátis desde a v1.2 — decisão D-12)* | ✅ |
| **Criar bilhete pelo Controle / Botão de Ação** | ❌ (visível com selo Pro) | ✅ |
| **Siri e Atalhos** | ❌ (visível com selo Pro) | ✅ |
| **Escolha de fonte** (padrão / mono / serifada) | ❌ (só a padrão) | ✅ |

**Regra de leitura desta tabela (P5):** o ciclo completo — escrever, fixar, ver na tela, arquivar — está inteiro na coluna Grátis, para sempre. O Pro vende **capacidade e velocidade**, nunca a função básica.

**Regra de degradação:** se o direito Pro deixar de valer (reembolso, revogação via `Transaction.updates`), o app **nunca apaga dado**. Os bilhetes ativos acima de 3 e os arquivados acima de 10 permanecem visíveis e legíveis em modo somente leitura, com um aviso; a criação de novos ativos fica bloqueada até voltar a 3. Ver regra 11.11.

---

## 6. Identidade e autenticação

**Não há login, cadastro, senha nem recuperação de senha.** Esta é uma decisão de produto, não uma omissão.

| Item | Decisão |
|---|---|
| **Identidade** | **Não existe.** O app é local ao aparelho (decisão D-1): não há conta, nem iCloud, nem identificador de nenhum tipo. |
| **Criação de conta** | Não existe. Abrir o app já é estar dentro. Cumpre P2. |
| **Recuperação de acesso** | Não se aplica — não há credencial do Bilhete. Recuperar a conta iCloud é responsabilidade da Apple. |
| **Onde ficam os dados** | Sempre no container do App Group, no próprio aparelho. Nada sai dele. Ajustes **não** exibe estado de sincronização, porque não há sincronização — no lugar disso, destaca "Exportar tudo" como o caminho de backup. |
| **Troca de conta iCloud no aparelho** | Não afeta nada: o dado é local e não está atrelado a conta (decisão D-1). |
| **Direito de compra** | Vinculado ao **Apple ID**, não ao Bilhete. Restauração via `AppStore.sync()` + releitura de `Transaction.currentEntitlements`. O botão "Restaurar compras" em Ajustes é exigência de App Review, não necessidade técnica. |
| **Autorização** | Não existe camada de autorização: um único usuário, um único container privado, nenhum dado de terceiro acessível. A privacidade é garantida pelo CloudKit privado, não por política de aplicação. |
| **Credenciais privilegiadas** | Não existem. O app não tem servidor, não tem chave de API e não faz nenhuma chamada de rede própria. |

---

## 7. Modelo de dados

**Convenção de idioma (seção 18):** entidades e propriedades em **português**. No código Swift a grafia é `lowerCamelCase` (imposição da linguagem); neste documento e no `modelo-bilhete.dbml` a grafia é `snake_case`. O mapeamento é direto e está explicitado em cada tabela.

**Todas as restrições da seção 4.3 valem aqui:** sem `@Attribute(.unique)`, sem `Array`/`Set` de primitivos, tudo opcional ou com default, relacionamentos opcionais.

### 7.1 Diagrama de relacionamento

```
┌─────────────────────────┐
│       bilhete           │
│  (entidade única do     │        (v2: bilhete.casa_id → casa.id)
│   domínio na v1)        │
└─────────────────────────┘

  preferencias  →  não é entidade persistida em SwiftData.
                   Vive em UserDefaults(suiteName:) do App Group.
                   Documentada em 7.3 por completude.

  direito_pro   →  não é entidade persistida.
                   Estado derivado de Transaction.currentEntitlements (StoreKit 2),
                   com cache em UserDefaults do App Group. Documentado em 7.4.
```

A v1 tem **uma única entidade persistida**. Isso é deliberado: modelo mínimo reduz drasticamente a exposição às restrições de migração do CloudKit (4.3, item 4), que são permanentes depois que o sync liga.

### 7.2 Entidade `bilhete`

Classe SwiftData: `Bilhete` · Package: `BilheteCore/Models/Bilhete.swift`

| Coluna (`snake_case`) | Swift (`lowerCamelCase`) | Tipo | Nulo? | Default | Descrição |
|---|---|---|---|---|---|
| `id` | `id` | `UUID` | não | `UUID()` | Identificador. Gerado no cliente. **Não usa `@Attribute(.unique)`** — proibido com CloudKit; a unicidade é garantida por geração e pela conferência da regra 11.13. |
| `texto` | `texto` | `String` | não | `""` | O conteúdo do bilhete. Texto puro, sem formatação. Limite na regra 11.2. |
| `estado` | `estado` | `EstadoBilhete` | não | `.guardado` | Estado no ciclo de vida. Enum em 7.5. Máquina de estado na seção 12. |
| `ordem_pilha` | `ordemPilha` | `Int` | não | `0` | Posição na pilha de guardados. Menor valor = mais acima. Irrelevante para `em_destaque` e `arquivado`. Reordenação na regra 11.5. |
| `fixado_ate` | `fixadoAte` | `Date?` | **sim** | `nil` | Quando a Live Activity atual expira. **Nulo quando o bilhete não está fixado** — nunca esteve, ou já expirou, ou foi dispensado. Ver regra 11.6. |
| `id_atividade` | `idAtividade` | `String?` | **sim** | `nil` | `Activity.id` da Live Activity em curso, para poder atualizar e encerrar. **Nulo quando não há atividade em curso.** |
| `criado_em` | `criadoEm` | `Date` | não | `.now` | Momento da criação. Nunca muda. |
| `atualizado_em` | `atualizadoEm` | `Date` | não | `.now` | Momento da última alteração de `texto` ou `estado`. Usado para ordenar o arquivo e resolver conflito de sincronização (regra 11.14). |
| `arquivado_em` | `arquivadoEm` | `Date?` | **sim** | `nil` | Momento do arquivamento. **Nulo enquanto o bilhete não foi arquivado.** Define a ordem e o corte dos 10 do plano grátis (regra 11.4). |
| `origem` | `origem` | `OrigemBilhete` | não | `.app` | Por onde o bilhete foi criado. Existe para telemetria (seção 21) e para medir se Siri e Controle valem o custo de manutenção. Enum em 7.6. |

**Constraints e validações** (aplicadas em código, na camada `BilheteStore` — o CloudKit não permite constraint no schema):

| Regra | Onde é aplicada |
|---|---|
| No máximo **um** bilhete com `estado = em_destaque` por vez | `BilheteStore.promoverADestaque()`, transacional |
| `texto` com no máximo **280 caracteres** (regra 11.2) | Editor (UI) + `BilheteStore.salvar()` |
| `fixado_ate` só pode ser não-nulo se `estado = em_destaque` | `BilheteStore` + invariante testada (seção 22) |
| `arquivado_em` não-nulo **se e somente se** `estado = arquivado` | `BilheteStore` + invariante testada |
| Contagem de ativos ≤ 3 sem Pro (regra 11.3) | `BilheteStore.criar()` |

**Índices sugeridos:** por `estado` (toda consulta filtra por ele) e por `arquivado_em` decrescente (tela de arquivo). Em SwiftData, expressos via `@Attribute(.spotlight)` não se aplicam; o índice efetivo é o do SQLite subjacente e não é declarável — registrar aqui serve para a documentação técnica e para o caso de migração futura para GRDB.

**Estratégia de exclusão: híbrida e explícita.**

- **Arquivar não é excluir** (P4): é transição de estado, o dado permanece.
- **Excluir é definitivo** (hard delete), tanto do arquivo quanto do destaque. Motivo: não há histórico referenciando o bilhete, não há relatório, e manter lixo invisível sincronizando pelo CloudKit é custo sem benefício. O usuário é avisado antes (copy em 15.4).
- **Poda automática do arquivo grátis:** ao arquivar o 11º bilhete sem Pro, o mais antigo por `arquivado_em` é **excluído definitivamente**, com aviso prévio no momento do arquivamento (copy em 15.4). Ver regra 11.4.

### 7.3 `preferencias` — não persistida em SwiftData

Vive em `UserDefaults(suiteName: "group.com.dablab.bilhete")`. Fica fora do SwiftData por dois motivos: são valores por aparelho, e o widget precisa lê-los de forma síncrona no momento do render, sem abrir um `ModelContainer`.

| Chave | Tipo | Default | Descrição |
|---|---|---|---|
| `aparencia` | `String` | `"sistema"` | `sistema` \| `claro` \| `escuro` |
| `fonte` | `String` | `"padrao"` | `padrao` \| `mono` \| `serifada`. Só `padrao` sem Pro. |
| `texto_pequeno` | `Bool` | `false` | Reduz o corpo do texto em todas as superfícies. |
| `avisar_expiracao` | `Bool` | `true` | Liga o aviso da regra 11.7. |
| `boasvindas_concluida` | `Bool` | `false` | Controla a exibição de 10.6. |
| `dica_widget_vista` | `Bool` | `false` | Controla a dica contextual de 10.7. |
| `pro_desbloqueado` | `Bool` | `false` | **Cache** do direito. Fonte de verdade é o StoreKit (7.4). |
| `idioma` | `String` | `"sistema"` | `sistema` \| `pt-BR` \| `en`. Seletor de idioma dentro do app (decisão D-8). `sistema` mantém o comportamento do critério 8.11.3. |
| `insistencias_widget` | `Int` | `0` | Teto de duas insistências sobre o widget (spec 9.4). Sem uso desde a decisão D-7, mantida para não perder a contagem. |
| `ja_fixou_alguma_vez` | `Bool` | `false` | Metade da condição da regra 11.10. |
| `permissao_notificacao_pedida` | `Bool` | `false` | Garante que a permissão é pedida uma única vez (critério 8.7.5). |

### 7.4 `direito_pro` — não persistido

Fonte de verdade: `Transaction.currentEntitlements` do StoreKit 2, lido no lançamento e observado continuamente por `Transaction.updates`. O valor é espelhado em `preferencias.pro_desbloqueado` **exclusivamente** para que a widget extension possa aplicar o gating sem acessar o StoreKit. O app **nunca** decide direito a partir do cache: sempre relê o StoreKit ao abrir.

Produto: `com.dablab.bilhete.pro` — não-consumível, R$ 19,90.

### 7.5 Enum `estado_bilhete`

| Valor | Significado |
|---|---|
| `em_destaque` | O bilhete da vez. Exatamente um por vez (ou zero, se a pilha estiver vazia). É o que aparece nos widgets e na Live Activity. |
| `guardado` | Na pilha, esperando a vez. Não aparece em nenhuma superfície do sistema. |
| `arquivado` | Encerrado. Sai da pilha, é restaurável, e não conta para o limite de ativos. |

### 7.6 Enum `origem_bilhete`

| Valor | Significado |
|---|---|
| `app` | Criado dentro do app. |
| `siri` | Criado por comando de voz. |
| `atalho` | Criado por um Atalho. |
| `controle` | Criado pelo Controle da Central de Controle ou pelo Botão de Ação. |
| `widget` | Criado pela ação de um widget de tela de início. |

### 7.7 Dados de seed

Na primeira execução (`boasvindas_concluida == false`) o app cria **um** bilhete em destaque **vazio**. O texto de exemplo de 15.1 aparece como *placeholder*, não como conteúdo.

**Mudou na v1.2** (decisão D-9). A v1.0 mandava gravar o texto de exemplo como conteúdo do bilhete, e isso deu dois problemas em uso real: o texto ficava congelado no idioma da primeira abertura, mesmo depois de a pessoa trocar o idioma nos Ajustes (D-8), e obrigava a apagar o exemplo antes de escrever. O placeholder faz o mesmo papel, é interface, e acompanha o idioma.

### 7.8 Migrações

Versionadas com `VersionedSchema` e `SchemaMigrationPlan` do SwiftData desde a **v1**, mesmo com uma versão só. Motivo: com CloudKit ligado, só migração leve é possível para sempre (4.3, item 4), e começar sem o plano de versionamento torna qualquer evolução futura mais arriscada. `BilheteSchemaV1` é criado no dia 1.

---

## 8. Épicos e critérios de aceite

Ordem de implementação. Cada épico só é dado por concluído quando **todos** os seus critérios passam.

### 8.1 Bilhete em destaque

**Objetivo:** abrir o app e estar escrevendo, sem nenhum passo intermediário.

**Fluxo:** o app abre direto no bilhete em destaque, com o texto existente ou com o cursor no campo vazio. A pessoa digita. Não há botão de salvar. A barra inferior tem três ações: **Guardar**, **Fixar** (ou **Soltar**, conforme o estado) e **Concluir**. O menu `•••` traz Compartilhar, Copiar e Excluir. O topo dá acesso à **Pilha** e aos **Concluídos**.

**Mudou na v1.2:** "Arquivar" passou a se chamar **Concluir** (decisão D-9), o mesmo nome do botão da Live Activity — era a mesma ação com dois nomes, e isso confundia em uso real. Tocar no fundo da tela fecha o teclado (D-11), e a barra de ações permanece visível com o teclado aberto.

**Estados:** *vazio* — placeholder de 15.1 e cursor ativo. *Carregando* — nunca aparece; os dados são locais e o primeiro render é síncrono. *Erro* — falha de gravação exibe a copy de 15.5 e mantém o texto na tela; nunca descarta o que a pessoa escreveu.

**Critérios de aceite:**
1. Ao abrir o app com a pilha vazia, o cursor está ativo no campo de texto em menos de 1 segundo, sem toque adicional.
2. O texto digitado é persistido no máximo **1 segundo** após a última tecla (debounce), e também imediatamente ao sair da tela ou o app ir para background.
3. Ao digitar o 281º caractere, a entrada é bloqueada e o contador aparece em vermelho (regra 11.2).
4. Encerrar o app pelo multitarefa e reabrir preserva o texto exatamente como estava, inclusive sem ter tocado em nada além de digitar.
5. `atualizado_em` muda a cada alteração de `texto`; `criado_em` nunca muda.
6. Com a pilha vazia e sem bilhete em destaque, um novo bilhete é criado automaticamente com `estado = em_destaque`, sem pedir confirmação.

### 8.2 Pilha de guardados

**Objetivo:** guardar sem perder, e trocar o destaque em um toque.

**Fluxo:** "Guardar" move o bilhete em destaque para `guardado` no topo da pilha e cria um novo bilhete em destaque em branco. A tela da Pilha lista os guardados; tocar em um promove a destaque (o que estava em destaque vira `guardado`). Arrastar reordena.

**Estados:** *vazio* — copy de 15.2 e um botão que leva de volta ao destaque. *Erro* — não aplicável (operação local).

**Critérios de aceite:**
1. Após "Guardar", existe exatamente um bilhete com `estado = em_destaque` e ele está vazio.
2. Promover um guardado a destaque troca os dois estados numa única transação; em nenhum instante existem dois `em_destaque` nem zero (com pilha não vazia).
3. Promover a destaque um bilhete enquanto o anterior está fixado **encerra a Live Activity do anterior** e limpa `fixado_ate` e `id_atividade` dele (regra 11.6).
4. A ordem definida pelo arrasto sobrevive a fechar e reabrir o app.
5. Com 3 ativos e sem Pro, tocar em "Guardar" abre o paywall (10.5) e **não** cria o quarto bilhete (regra 11.3).
6. Com Pro, criar o 4º, o 10º e o 50º ativo funciona sem nenhum aviso.

### 8.3 Arquivar, restaurar, excluir, compartilhar

**Objetivo:** dar ao encerramento o peso de um gesto (P4).

**Fluxo:** "Arquivar" no bilhete em destaque toca a animação de encerramento (16.7), grava `arquivado_em`, encerra a Live Activity se houver, e promove o próximo da pilha a destaque (ou cria um em branco, se a pilha estiver vazia). A tela de Arquivo lista por `arquivado_em` decrescente, com restaurar e excluir por item, busca (Pro) e "Apagar tudo".

**Estados:** *vazio* — copy de 15.3. *Erro* — copy de 15.5.

**Critérios de aceite:**
1. Arquivar dispara a animação de encerramento uma única vez e o bilhete sai da tela em menos de 600 ms.
2. Após arquivar, `estado = arquivado` e `arquivado_em` está preenchido com o instante da ação.
3. Arquivar um bilhete fixado encerra a Live Activity e zera `fixado_ate` e `id_atividade` **antes** de gravar o novo estado.
4. Restaurar um arquivado o devolve como `guardado` no topo da pilha, com `arquivado_em = nil`. Se isso exceder 3 ativos sem Pro, o paywall abre e a restauração **não** acontece.
5. Sem Pro, ao arquivar o 11º bilhete, o mais antigo por `arquivado_em` é excluído definitivamente e o aviso de 15.4 aparece **antes** da ação, com opção de cancelar.
6. "Excluir" e "Apagar tudo" pedem confirmação destrutiva e são irreversíveis.
7. Compartilhar abre a share sheet do sistema com o `texto` puro, sem assinatura nem marca do app.

### 8.4 Live Activity

**Objetivo:** colocar o bilhete grande na tela de bloqueio e na Dynamic Island.

**Fluxo:** "Fixar" chama `Activity.request(...)` com o app em foreground (L4), grava `id_atividade` e `fixado_ate = agora + 8h`. A Live Activity mostra o texto e dois botões: **Concluir** (arquiva) e **Soltar** (encerra a atividade sem arquivar). Tocar no corpo abre o app no bilhete.

**Estados:** *sem permissão* — se `ActivityAuthorizationInfo().areActivitiesEnabled == false`, a ação "Fixar" fica desabilitada com a copy de 15.6 e um atalho para os Ajustes do sistema. *Expirada* — `fixado_ate` no passado; o botão volta a dizer "Fixar".

**Critérios de aceite:**
1. Tocar em "Fixar" faz o bilhete aparecer na tela de bloqueio e na Dynamic Island em menos de 2 segundos.
2. `fixado_ate` é gravado como `agora + 8h` e `id_atividade` recebe o `Activity.id`.
3. Editar o texto do bilhete fixado atualiza a Live Activity em menos de 2 segundos, sem recriá-la (o `id_atividade` não muda).
4. "Concluir" na Live Activity arquiva o bilhete e encerra a atividade sem abrir o app.
5. "Soltar" encerra a atividade com `dismissalPolicy: .immediate` e zera `fixado_ate` e `id_atividade`, **sem** arquivar.
6. Tocar no corpo da Live Activity abre o app diretamente no bilhete correspondente.
7. Existe **no máximo uma** Live Activity do Bilhete ativa a qualquer momento (regra 11.6).
8. Com texto de 280 caracteres, a Live Activity trunca com reticências sem quebrar o layout em iPhone de 393pt e de 430pt de largura.
9. Todas as três apresentações da Dynamic Island (compacta, mínima, expandida) estão implementadas e legíveis.

### 8.5 Widgets

**Objetivo:** a camada permanente (L2), para quem escolher usá-la.

**Mudou na v1.2** (decisão D-7): os quatro widgets continuam implementados e funcionando, mas **o app não os sugere mais** — a entrada dos Ajustes e o cartão do rodapé saíram. Quem quiser adicionar, adiciona pela galeria do iOS. O motivo está no changelog e no princípio P3 reescrito.

**Fluxo:** quatro famílias. `accessoryRectangular` e `accessoryInline` na tela de bloqueio; `systemSmall` e `systemMedium` na tela de início. Todas mostram o bilhete em destaque. Nos widgets de tela de início há um botão interativo "Concluir".

**Estados:** *vazio* — sem bilhete em destaque com texto, exibe a copy de 15.7 e abre o app ao toque.

**Critérios de aceite:**
1. Os quatro widgets aparecem na galeria com nome e descrição em PT-BR e EN.
2. Editar o bilhete no app atualiza os widgets em até 60 segundos, e o app chama `reloadAllTimelines()` explicitamente a cada gravação.
3. `accessoryRectangular` exibe até 3 linhas e trunca com reticências; é legível em fundo claro e escuro de tela de bloqueio, **desenhado em escala de cinza** conforme L8.
4. `accessoryInline` exibe a primeira linha do bilhete, truncada.
5. O botão "Concluir" dos widgets de tela de início arquiva o bilhete e a mudança aparece no app **sem exigir reinício** — validado com `@Query` conforme 4.5, item 4.
6. **Nenhum widget de tela de bloqueio tem botão interativo** (L9, regra 11.9).
7. Com o aparelho bloqueado e `privacySensitive` aplicado, o conteúdo é ocultado conforme a preferência do sistema.

### 8.6 Controle da Central de Controle, Botão de Ação, Siri e Atalhos

**Objetivo:** refixar e capturar sem abrir o app. É a resposta do produto ao momento mais difícil (seção 2).

**Fluxo:** dois Controles. **"Refixar bilhete"** (`ControlWidgetButton`) dispara um `LiveActivityIntent` que chama `Activity.request(...)` no `perform()`, sem abrir o app (L5, L6). **"Novo bilhete"** abre o app já no editor. Ambos podem ir para a Central de Controle, para a tela de bloqueio (no lugar da lanterna ou da câmera) e para o Botão de Ação. Os mesmos intents são publicados na Siri e no app Atalhos.

**Critérios de aceite:**
1. Os dois Controles aparecem na galeria da Central de Controle com símbolo e nome.
2. O Controle "Refixar bilhete" pode ser colocado na tela de bloqueio no lugar da lanterna ou da câmera.
3. Acionar "Refixar bilhete" com o app fechado cria a Live Activity em menos de 3 segundos **sem abrir o app**, e grava `fixado_ate` e `id_atividade`.
4. O `perform()` do Controle completa de forma síncrona; nenhum intent de Controle conforma `ForegroundContinuableIntent` (L13).
5. Os dois Controles são compreensíveis **apenas pelo símbolo**, sem depender de texto (L10).
6. "Ei Siri, criar bilhete no Bilhete" cria o bilhete e a Siri confirma por voz, sem abrir o app.
7. Toda frase de `AppShortcut` contém `\(.applicationName)` (L14).
8. Todos os `AppIntent` estão no target principal, não na extension (L14).
9. Sem Pro, acionar qualquer um dos Controles ou o comando de Siri exibe o aviso de 15.8 e abre o paywall ao tocar.

### 8.7 Aviso de expiração

**Objetivo:** o bilhete nunca sumir sem explicação (P3, persona P-C).

**Mudou na v1.2** (decisão D-7): o aviso continua igual, mas o app não oferece mais a tela 10.7. A variante de copy 15.9b, que ensinava a colocar o widget, deixou de ser o caminho principal — o aviso agora aponta para refixar.

**Fluxo:** ao fixar, agenda uma notificação local para `fixado_ate − 30 min`. Ao soltar, arquivar ou trocar o destaque, cancela. A notificação tem a ação **"Refixar"**, que abre o app, refixa automaticamente e mostra confirmação. *Nota técnica:* a ação precisa abrir o app porque iniciar Live Activity exige foreground (L4); é a única ação do produto que abre o app por imposição da plataforma, e a copy de 15.9 reflete isso.

**Critérios de aceite:**
1. Fixar agenda exatamente uma notificação para `fixado_ate − 30 min`.
2. Soltar, arquivar, excluir ou trocar o destaque cancela a notificação agendada.
3. Refixar substitui a notificação anterior; nunca existem duas agendadas para o mesmo bilhete.
4. Com `avisar_expiracao = false`, nenhuma notificação é agendada.
5. Sem permissão de notificação, o app não pede de novo a cada fixação: pede uma única vez, no primeiro "Fixar", com a copy de 15.10.
6. A ação "Refixar" da notificação resulta em Live Activity ativa e `fixado_ate` atualizado.

### 8.8 Armazenamento local e portabilidade

**Objetivo:** o dado sobrevive ao relançamento, funciona sem rede nenhuma, e tem
uma saída.

Reescrito na v1.1 pela decisão D-1: sem CloudKit, o que sobra deste épico é o que
mais importa — abrir sem perder nada, e poder levar os bilhetes embora.

**Critérios de aceite:**
1. O store abre no container do App Group e o dado sobrevive a fechar e reabrir o app, com o `VersionedSchema` e o plano de migração ativos desde a v1.
2. O app funciona integralmente offline e **nenhuma tela exibe erro de rede fora do paywall** (spec 17).
3. Ajustes **não** exibe estado de sincronização, e destaca "Exportar tudo" como o caminho de backup.
4. "Exportar tudo" (14.2) gera o arquivo com as três seções na ordem do spec, uma linha por bilhete, UTF-8 sem BOM, nome `bilhetes-AAAA-MM-DD.txt`.
5. Nenhuma classe `@Model` contém propriedade `Array` ou `Set` (4.3). Verificado por teste automatizado **e** por build phase que derruba a compilação.
6. O schema continua compatível com sincronização, para a v2 poder religar o CloudKit sem migração pesada.

### 8.9 Compra Bilhete Pro

**Objetivo:** vender capacidade sem estragar o grátis (P5).

**Fluxo:** o paywall abre quando a pessoa tenta criar o 4º ativo, tenta usar uma capacidade Pro, ou toca em "Bilhete Pro" nos Ajustes. Um produto, um preço, um botão. Compra via StoreKit 2, verificação por `VerificationResult`, `finish()` obrigatório, listener de `Transaction.updates` iniciado no lançamento.

**Critérios de aceite:**
1. O paywall **nunca** aparece antes de a pessoa ter criado seu primeiro bilhete e visto ele na tela de bloqueio (regra 11.10).
2. O preço exibido vem do StoreKit localizado, nunca de string fixa no código.
3. Concluída a compra, todas as capacidades Pro ficam disponíveis sem reiniciar o app, e `preferencias.pro_desbloqueado` é atualizado para a extension.
4. "Restaurar compras" chama `AppStore.sync()` e relê `currentEntitlements`; instalar em aparelho novo com o mesmo Apple ID restaura o Pro sem cobrança.
5. Um listener de `Transaction.updates` roda desde o lançamento e trata revogação conforme a regra 11.11.
6. Cancelar a compra no meio volta à tela anterior sem erro e sem alterar estado.
7. Sem rede, o paywall exibe a copy de 15.12 e o botão de compra fica desabilitado.

### 8.10 Ajustes

**Critérios de aceite:**
1. Trocar aparência, fonte e tamanho de texto reflete imediatamente no app **e nos widgets** (via `reloadAllTimelines()`).
2. Escolher fonte diferente da padrão sem Pro abre o paywall e não aplica a mudança.
3. Ajustes exibe o estado da sincronização (regra 11.12) e a versão do app.
4. "Como colocar na tela de bloqueio" (10.7) é alcançável a partir dos Ajustes em um toque.

### 8.11 Localização

**Critérios de aceite:**
1. Nenhuma string aparece fixa no código; tudo em `String Catalog` (`.xcstrings`).
2. PT-BR e EN completos, incluindo nomes e descrições de widgets, Controles, frases de Siri e textos do paywall.
3. Com o aparelho em qualquer idioma que não seja PT-BR, o app exibe EN.
4. Datas e o preço seguem a formatação da região do aparelho.

---

## 9. Fluxos principais ponta a ponta

### 9.1 Primeiro uso (o fluxo que decide a retenção)

1. Instala e abre. Vê **uma** tela de boas-vindas (10.6) com uma frase e um botão. Cumpre P2: nada de carrossel de 5 telas.
2. Cai no bilhete em destaque, com o exemplo de 15.1 já preenchido e selecionado — digitar substitui.
3. Escreve o primeiro bilhete.
4. Toca em **Fixar**. Nesse momento, e só nesse momento, o sistema pede permissão de Live Activity e de notificação (15.10).
5. O app mostra a dica contextual de widget (10.7): "seu bilhete some da tela em 12h — coloque o widget e ele fica pra sempre", com o passo a passo.
6. Bloqueia o telefone e vê o bilhete. **Este é o momento de valor.**
7. **Só a partir daqui** o paywall pode aparecer (regra 11.10).

### 9.2 Ciclo diário

1. Ei Siri, ou Botão de Ação, ou abre o app → escreve.
2. Fixa (ou o Controle refixa).
3. Ao longo do dia, vê na tela de bloqueio.
4. Resolveu → **Concluir** pela Live Activity, pelo widget de tela de início ou pelo app.
5. O próximo da pilha vira destaque automaticamente.

### 9.3 Caminho da exceção — o destaque expirou

1. 7h30: fixa. `fixado_ate = 15h30`.
2. 15h00: notificação "seu bilhete sai da tela em 30 minutos".
   - **(a)** Toca em "Refixar" → o app abre, refixa e confirma. Volta ao passo 1.
   - **(b)** Ignora. Às 15h30 a Live Activity encerra e some da Dynamic Island; permanece congelada na tela de bloqueio até 19h30 (L1).
   - **(c)** Aciona o Controle da tela de bloqueio → refixa **sem abrir o app** (L6). Volta ao passo 1.
3. **Em todos os casos, o widget da tela de bloqueio continua exibindo o bilhete** (L2, P3). A pessoa nunca perde a informação — perde apenas o destaque.

### 9.4 Caminho da exceção — o destaque expirou e não há widget

**Reescrito na v1.2** (decisão D-7). O app não insiste mais no widget; o caminho
de volta é o Controle e o aviso. O texto original abaixo fica registrado porque a
tela 10.7 continua pronta no código, e voltar a sugeri-la é uma linha.

#### Texto original (v1.0 e v1.1)

Este é o cenário da persona P-C e é o mais provável de causar desinstalação. Tratamento:
1. Se `dica_widget_vista == false` e a pessoa já fixou pelo menos uma vez, a dica de 10.7 aparece **uma única vez**, como cartão dispensável no rodapé do destaque, nunca como modal.
2. Se um destaque expirar sem que o widget tenha sido adicionado, a notificação de expiração usa a variante de copy 15.9b, que menciona o widget.
3. Ajustes tem entrada permanente "Como colocar na tela de bloqueio".
4. O app **nunca** insiste mais de duas vezes no total.

---

## 10. Inventário de telas e superfícies

Todas as telas são de uso pessoal — não há perfis de acesso (seção 5). O que varia é o **estado de compra**, indicado na coluna "Gating".

### 10.1 — Destaque *(tela inicial)*
- **Mostra:** o bilhete em destaque, editável em linha. Contador de caracteres (aparece a partir de 240). Barra inferior: Guardar · Fixar/Soltar · **Concluir**. Topo: acesso à **Pilha** (com contador em palavra, "3 bilhetes") e aos **Concluídos**, `•••` (Compartilhar, Copiar, Excluir), Ajustes. Rodapé: uma linha explicando as três ações, que some depois do primeiro uso. *(v1.2 — decisões D-9, D-10 e D-11.)*
- **Ações de escrita:** criar, editar, guardar, fixar, soltar, arquivar, excluir.
- **Lê/escreve:** `bilhete`, `preferencias`.
- **Estados:** vazio (placeholder 15.1) · erro de gravação (15.5) · Live Activity indisponível (15.6) · fixado (o botão vira "Soltar" e um selo mostra até quando).
- **Gating:** "Guardar" com 3 ativos e sem Pro → paywall.

### 10.2 — Pilha
- **Mostra:** o **bilhete em destaque no topo**, com o selo "na tela" e sem arrasto (v1.2, decisão D-11), seguido da lista dos `guardado` por `ordem_pilha`, com trecho do texto e data relativa. Contador "3 de 3" quando sem Pro.
- **Ações:** promover a destaque (toque), reordenar (arrasto), arquivar e excluir (swipe).
- **Lê/escreve:** `bilhete`.
- **Estados:** vazia (15.2).
- **Gating:** contador com selo Pro quando no limite.

### 10.3 — Concluídos *(chamada "Arquivo" até a v1.1 — decisão D-10)*
- **Mostra:** arquivados por `arquivado_em` decrescente, com data. Campo de busca no topo. Rodapé: "Apagar tudo".
- **Ações:** restaurar, excluir, apagar tudo, buscar.
- **Lê/escreve:** `bilhete`.
- **Estados:** vazio (15.3) · busca sem resultado · aviso de poda dos 10 (15.4).
- **Gating:** busca desabilitada com selo Pro sem Pro; contador "10 de 10" quando no limite.

### 10.4 — Ajustes
- **Mostra:** Aparência (sistema/claro/escuro) · **Idioma (sistema/português/inglês)** · Fonte (padrão/mono/serifada) · Texto pequeno · Avisar antes de expirar · Bilhete Pro / Restaurar compras · **Exportar tudo** · **Como o Bilhete funciona** (10.8) · Avaliar · Suporte · Enviar feedback · Política de privacidade · Sobre e versão. **Sem linha de estado da sincronização** (D-1) e **sem a entrada do guia do widget** (D-7).
- **Ações:** todas de preferência, mais restaurar compras.
- **Lê/escreve:** `preferencias`; lê StoreKit.
- **Estados:** Pro ativo (a linha vira "Bilhete Pro ✓").
- **Gating:** Fonte diferente de padrão → paywall.

### 10.5 — Bilhete Pro *(paywall, modal)*
- **Mostra:** título, lista de 5 capacidades (matriz da seção 5), preço vindo do StoreKit, botão de compra, "Restaurar compras", link para termos e privacidade.
- **Ações:** comprar, restaurar, fechar.
- **Lê/escreve:** StoreKit; escreve `preferencias.pro_desbloqueado`.
- **Estados:** carregando produto · produto indisponível/sem rede (15.12) · compra em andamento · compra concluída · cancelada.
- **Gating:** é a própria tela de gating. **Nunca abre antes do momento de valor** (11.10).

### 10.6 — Boas-vindas *(uma tela, primeira execução)*
- **Mostra:** o nome, uma frase de posicionamento (15.13) e um botão único.
- **Ações:** começar.
- **Lê/escreve:** `preferencias.boasvindas_concluida`.
- **Estados:** único.

### 10.7 — Como colocar na tela de bloqueio *(instrucional)*
- **Mostra:** três blocos ilustrados — adicionar o widget na tela de bloqueio, adicionar o Controle no lugar da lanterna, o que é a Live Activity e por que ela expira em 12h.
- **Ações:** avançar, fechar.
- **Lê/escreve:** `preferencias.dica_widget_vista`.
- **Estados:** único. Aparece como cartão dispensável no rodapé do Destaque (9.4) ou como tela cheia a partir dos Ajustes.

### 10.8 — Como o Bilhete funciona *(instrucional — v1.2, decisão D-10)*
- **Mostra:** o modelo do app explicado por significado, não por destino: um bilhete por vez em destaque, e o que cada ação quer dizer — **Fixar** (põe na tela de bloqueio por 8h), **Guardar** (agora não, vai para a pilha), **Concluir** (resolvi, vai para Concluídos) e **Soltar** (tira da tela sem concluir). Diz explicitamente que **o botão "Concluir" da tela de bloqueio é a mesma ação de Concluir do app** — a dúvida que apareceu no teste em aparelho. Fecha com os limites do plano grátis.
- **Ações:** ler, voltar.
- **Lê/escreve:** nada.
- **Estados:** único.
- **Por que existe:** a linha de ajuda do rodapé de 10.1 some depois do primeiro uso, e as ações continuavam parecendo equivalentes entre si. Esta tela fica disponível para sempre, nos Ajustes, e nunca interrompe.

### Superfícies do sistema (não são telas do app, mas precisam de desenho)

| # | Superfície | Família / apresentação | Conteúdo | Restrição crítica |
|---|---|---|---|---|
| S1 | Widget de tela de bloqueio | `accessoryRectangular` (~172×76pt) | até 3 linhas do bilhete | **Escala de cinza forçada** (L8) · **sem botão** (L9) |
| S2 | Widget de tela de bloqueio | `accessoryInline` | 1 linha, truncada | Escala de cinza · sem botão |
| S3 | Widget de tela de início | `systemSmall` | texto + botão Concluir | interativo permitido |
| S4 | Widget de tela de início | `systemMedium` | texto + botões Concluir e Fixar | interativo permitido |
| S5 | Live Activity — tela de bloqueio | 371–408 × 84–160pt | texto + Concluir + Soltar | não há teclado (L12) |
| S6 | Dynamic Island — compacta | ~62×37pt | símbolo + 2–3 palavras | — |
| S7 | Dynamic Island — mínima | ~37–45pt | só o símbolo | — |
| S8 | Dynamic Island — expandida | até 408×160pt | texto + 2 botões | — |
| S9 | Controle "Refixar bilhete" | `ControlWidgetButton` | só símbolo | **texto oculto na tela de bloqueio** (L10) |
| S10 | Controle "Novo bilhete" | `ControlWidgetButton` | só símbolo | idem |
| S11 | Notificação de expiração | notificação local | título + corpo + ação Refixar | — |

---

## 11. Regras de negócio

Nenhum número neste documento pode ser inferido pelo agente de código. Tudo o que é numérico está aqui.

| # | Regra | Valor | Onde é aplicada |
|---|---|---|---|
| **11.1** | Bilhetes em destaque simultâneos | Exatamente **1** (ou **0** com a pilha vazia, situação que dura só o instante entre transições) | `BilheteStore`, transacional |
| **11.2** | Tamanho máximo do texto | **280 caracteres**. Contador aparece a partir de 240. Aos 280 a entrada é bloqueada. Motivo: a Live Activity tem 84–160pt de altura (L12) e acima disso o texto fica ilegível. | Editor (UI) + `BilheteStore` |
| **11.3** | Bilhetes ativos (`em_destaque` + `guardado`) | **3** sem Pro · **ilimitado** com Pro. Arquivados **não** contam. | `BilheteStore.criar()` |
| **11.4** | Tamanho do arquivo | **10** sem Pro · **ilimitado** com Pro. Ao arquivar o 11º, o de `arquivado_em` mais antigo é **excluído definitivamente**, com confirmação prévia. | `BilheteStore.arquivar()` |
| **11.5** | Ordem da pilha | `ordem_pilha` crescente = de cima para baixo. Guardar insere no topo (`min − 1`). Reordenar reescreve a sequência inteira a partir de 0. | `BilheteStore.reordenar()` |
| **11.6** | Live Activities simultâneas do app | **1**. Fixar um bilhete com outro já fixado encerra o anterior primeiro (`.immediate`) e zera `fixado_ate` e `id_atividade` dele. | `PinService` |
| **11.7** | Aviso de expiração | Notificação local em `fixado_ate − 30 min`, se `avisar_expiracao = true`. Cancelada ao soltar, arquivar, excluir ou trocar o destaque. | `PinService` + `UserNotifications` |
| **11.8** | Duração da fixação | `fixado_ate = agora + 8h`. Não é configurável na v1 — é o limite ativo do sistema (L1), não uma escolha de produto. | `PinService` |
| **11.9** | Botões em widget de tela de bloqueio | **Proibidos.** Motivo: o intent só executa após o desbloqueio e não há API para reverter o estado visual se o desbloqueio for cancelado (L9). Ação interativa fica no Controle (S9/S10) e nos widgets de tela de início (S3/S4). | Implementação dos widgets |
| **11.10** | Primeira exibição do paywall | **Nunca** antes de a pessoa ter (a) criado um bilhete com texto **e** (b) fixado ao menos uma vez. Antes disso, ações Pro exibem o aviso de 15.8 sem abrir a compra. | `PaywallGate` |
| **11.11** | Perda do direito Pro (reembolso, revogação) | **Nenhum dado é apagado.** Ativos acima de 3 e arquivados acima de 10 continuam legíveis em modo somente leitura, com aviso. Criar novo ativo fica bloqueado até voltar a ≤ 3. Fontes voltam para a padrão. | Listener de `Transaction.updates` |
| **11.12** | ~~Estado da sincronização exibido em Ajustes~~ | **Removida na v1.1** (decisão D-1): não há sincronização, e mostrar "desligada" seria descrever uma função que o app não tem. | — |
| **11.13** | Colisão de `id` | Praticamente impossível com UUID v4, mas como o CloudKit **proíbe** `@Attribute(.unique)` (4.3), a gravação confere se já existe um bilhete com o mesmo `id` e, havendo, gera outro. | `BilheteStore.criar()` |
| **11.14** | ~~Conflito de sincronização no mesmo bilhete~~ | **Removida na v1.1** (decisão D-1): sem sincronização não há conflito. `atualizado_em` continua existindo e ordenando o que precisa de recência. | — |
| **11.15** | ~~O que não sincroniza~~ | **Removida na v1.1** (decisão D-1): nada sincroniza. `fixado_ate` e `id_atividade` continuam sendo estado local do aparelho, agora por construção. | — |
| **11.16** | Ciclo de vida ao arquivar o destaque | Ao arquivar, o primeiro da pilha (`ordem_pilha` menor) é promovido a destaque. Pilha vazia → cria um bilhete novo em branco em destaque. | `BilheteStore.arquivar()` |
| **11.17** | Debounce de gravação do editor | **1 segundo** após a última tecla; e imediato ao sair da tela, ao ir para background e ao acionar qualquer ação da barra. | Editor |
| **11.18** | Recarga de widget | `reloadAllTimelines()` após **toda** gravação que altere `texto` ou `estado` do bilhete em destaque, e após mudança de preferência visual. | `BilheteStore` + Ajustes |

**O que explicitamente não é automático:**

- O bilhete **não** é arquivado por tempo, por inatividade nem por expiração da fixação.
- A fixação **não** se renova sozinha na v1 (L4, L7). Renovar é sempre um ato do usuário.
- **Não** há detecção de duplicata, agrupamento, sugestão de texto nem qualquer inferência sobre o conteúdo.
- **Não** há ordenação automática da pilha por data ou relevância — a ordem é a que a pessoa definiu.

---

## 12. Máquina de estados do bilhete

```
                      criar
                        │
                        ▼
                 ┌─────────────┐
        promover  │ em_destaque │  guardar
      ┌──────────►│             ├──────────┐
      │           └──────┬──────┘          │
      │                  │ arquivar        ▼
      │                  │          ┌─────────────┐
      │                  │          │  guardado   │
      │                  │          └──────┬──────┘
      │                  │                 │ arquivar
      │                  ▼                 │
      │           ┌─────────────┐◄─────────┘
      └───────────┤  arquivado  │
        restaurar └──────┬──────┘
        (→ guardado)     │ excluir
                         ▼
                    [removido]
```

### Transições permitidas

| De | Para | Gatilho | Efeitos colaterais obrigatórios |
|---|---|---|---|
| — | `em_destaque` | criar com a pilha vazia | — |
| — | `guardado` | criar com destaque ocupado | `ordem_pilha = min − 1` |
| `em_destaque` | `guardado` | Guardar | Encerra a Live Activity (11.6); cria novo destaque em branco |
| `guardado` | `em_destaque` | promover | Rebaixa o destaque atual a `guardado`; encerra a Live Activity dele |
| `em_destaque` | `arquivado` | Arquivar, ou Concluir na Live Activity/widget | Encerra a Live Activity; cancela a notificação; grava `arquivado_em`; promove o próximo (11.16); aplica a poda (11.4) |
| `guardado` | `arquivado` | swipe na Pilha | Grava `arquivado_em`; aplica a poda |
| `arquivado` | `guardado` | Restaurar | Limpa `arquivado_em`; entra no topo da pilha; **bloqueado se exceder 11.3** |
| qualquer | removido | Excluir | Encerra a Live Activity se houver; cancela a notificação; hard delete |

### Transições proibidas

- `arquivado` → `em_destaque` **direto**. Restaurar sempre passa por `guardado`; promover é um segundo ato deliberado (P4: o encerramento tem peso).
- Dois `em_destaque` simultâneos, em qualquer instante (11.1).
- `fixado_ate` ou `id_atividade` não-nulos com `estado ≠ em_destaque` — é uma invariante testada (seção 22).

### Tratamento de falha

| Falha | Comportamento |
|---|---|
| `Activity.request` falha (limite do sistema, permissão negada) | Nada muda no modelo; a UI mostra 15.6. `fixado_ate` permanece nulo. |
| `Activity.request` falha **dentro de um Controle** | O Controle não tem UI para erro (L10, L13). Falha em silêncio e agenda uma notificação local com a copy de 15.15. |
| Gravação do SwiftData falha | O texto continua na tela, a UI mostra 15.5, e uma nova tentativa é feita ao sair da tela. **Nunca descartar o que a pessoa escreveu.** |
| CloudKit indisponível | Silencioso. O app funciona local; Ajustes reflete o estado (11.12). |
| StoreKit indisponível | O paywall mostra 15.12 e desabilita a compra. Nenhuma capacidade é liberada por engano. |

---

## 13. Contratos dos módulos internos

O Bilhete não tem backend nem API. O contrato que importa é o dos módulos internos e o dos App Intents — que são, na prática, a API pública do app para o sistema operacional.

### 13.1 `BilheteStore` *(BilheteCore/Store)*

Ponto único de escrita. **Nenhuma view escreve no `ModelContext` diretamente.** Motivo: as invariantes de 11.1, 11.3, 11.4 e 11.6 são transacionais e precisam de um só dono.

| Método | Entrada | Saída | Regras que aplica |
|---|---|---|---|
| `criar(texto:origem:)` | `String`, `OrigemBilhete` | `Bilhete` ou `LimiteAtingido` | 11.3, 11.13, 11.16 |
| `salvar(_:texto:)` | `Bilhete`, `String` | `Void` ou erro | 11.2, 11.17, 11.18 |
| `guardar(_:)` | `Bilhete` | novo destaque | 11.1, 11.5, 11.6 |
| `promoverADestaque(_:)` | `Bilhete` | `Void` | 11.1, 11.6 |
| `reordenar(de:para:)` | índices | `Void` | 11.5 |
| `arquivar(_:)` | `Bilhete` | `Void` ou `PodaNecessaria` | 11.4, 11.6, 11.7, 11.16 |
| `restaurar(_:)` | `Bilhete` | `Void` ou `LimiteAtingido` | 11.3, 11.5 |
| `excluir(_:)` | `Bilhete` | `Void` | 11.6, 11.7 |
| `apagarArquivo()` | — | `Void` | — |

### 13.2 `PinService` *(BilheteCore/LiveActivity)*

| Método | O que faz | Regras |
|---|---|---|
| `fixar(_:)` | `Activity.request`, grava `fixado_ate` e `id_atividade`, agenda o aviso | 11.6, 11.7, 11.8 |
| `atualizar(_:)` | `activity.update` sem recriar (mantém `id_atividade`) | 8.4.3 |
| `soltar(_:)` | `activity.end(.immediate)`, zera os dois campos, cancela o aviso | 11.6, 11.7 |
| `encerrarTodas()` | Defesa contra atividade órfã: percorre `Activity<BilheteAttributes>.activities` no lançamento e encerra o que não corresponde ao destaque atual | 11.6 |

### 13.3 App Intents — a API pública do app para o sistema

Todos no **target principal** (L14). Cada um monta em várias superfícies sem duplicação.

| Intent | Conforma | `openAppWhenRun` | Superfícies | Gating |
|---|---|---|---|---|
| `CriarBilheteIntent` | `AppIntent`, `ProvidesDialog` | `false` | Siri, Atalhos, Spotlight | Pro |
| `RefixarBilheteIntent` | `AppIntent`, `LiveActivityIntent` | `false` | Controle (S9), Botão de Ação, Siri, Atalhos | Pro |
| `NovoBilheteIntent` | `AppIntent` | `true` | Controle (S10), Botão de Ação | Pro |
| `ConcluirBilheteIntent` | `AppIntent` | `false` | botão dos widgets S3/S4 e da Live Activity S5/S8 | grátis |
| `SoltarBilheteIntent` | `AppIntent`, `LiveActivityIntent` | `false` | botão da Live Activity S5/S8 | grátis |

Frases de `AppShortcutsProvider` (todas contêm `\(.applicationName)`, conforme L14 — lista completa em 15.16).

### 13.4 `EntitlementStore` *(BilheteCore/Entitlement)*

| Método | Comportamento |
|---|---|
| `carregar()` | Lê `Transaction.currentEntitlements` no lançamento; espelha em `preferencias.pro_desbloqueado` |
| `observar()` | `Task` de longa duração sobre `Transaction.updates`, iniciada no `App.init` — captura compra em outro aparelho, Ask to Buy, código promocional, reembolso |
| `comprar()` | `product.purchase()` → valida `VerificationResult` → `transaction.finish()` obrigatório |
| `restaurar()` | `AppStore.sync()` seguido de `carregar()` |

---

## 14. Exportação e compartilhamento

Não há relatório nem importação. Existem duas saídas:

**14.1 Compartilhar o bilhete.** Share sheet do sistema com o `texto` puro, em UTF-8, **sem assinatura, sem marca, sem link do app**. Motivo: um bilhete compartilhado com marca é propaganda, e propaganda no conteúdo do usuário quebra a confiança. Copiar coloca o mesmo texto puro na área de transferência.

**14.2 Exportar tudo (Ajustes → Sobre).** Um arquivo de texto com todos os bilhetes, ativos e arquivados. Existe por conta do risco R-1 (regressão do SwiftData) e por dever de portabilidade de dados da LGPD (seção 20).

- Nome do arquivo: `bilhetes-AAAA-MM-DD.txt`
- Encoding: **UTF-8 sem BOM** (é texto puro, não CSV para Excel)
- Uma seção por estado, na ordem: em destaque, guardados (ordem da pilha), arquivados (mais recente primeiro)
- Uma linha por bilhete: `[dd/MM/yyyy HH:mm] texto`, com a data sendo `arquivado_em` quando houver e `criado_em` caso contrário
- Entrega pela share sheet do sistema

---

## 15. Copy e tom de voz

**Tom:** de pessoa para pessoa, em português brasileiro falado. Frases curtas. Sem "otimize seu fluxo de produtividade", sem exclamação, sem emoji, sem gerúndio de call center. O app fala como alguém que deixou um bilhete na sua geladeira — porque é exatamente isso que ele é.

**Este é o conteúdo final, não placeholder.** PT-BR é a versão canônica; o EN é tradução dela, não o contrário.

| # | Onde | PT-BR | EN |
|---|---|---|---|
| **15.1** | Placeholder do editor / seed | `Escreva o que você não quer esquecer` | `Write what you don't want to forget` |
| **15.2** | Pilha vazia | `Nada guardado.` / `O que estiver em destaque aparece na sua tela.` | `Nothing saved.` / `Whatever is featured shows on your screen.` |
| **15.3** | Concluídos vazio *(adaptada na v1.2 — decisão D-10)* | `Nada concluído ainda.` / `Bilhete resolvido é bilhete concluído.` | `Nothing done yet.` / `A note you've handled is a note you finish.` |
| **15.4** | Aviso de poda do arquivo | `Seu arquivo está cheio` / `Sem o Pro cabem 10 bilhetes no arquivo. Arquivar este apaga "%@" de vez.` · Botões: `Arquivar mesmo assim` · `Ver o Pro` · `Cancelar` | `Your archive is full` / `Without Pro the archive holds 10 notes. Archiving this one deletes "%@" for good.` |
| **15.5** | Erro de gravação | `Não consegui salvar agora` / `Seu texto continua aqui. Vou tentar de novo em instantes.` | `Couldn't save right now` / `Your text is still here. I'll try again shortly.` |
| **15.6** | Live Activity indisponível | `Não dá pra fixar agora` / `As Atividades ao Vivo estão desligadas para o Bilhete nos Ajustes do iPhone.` · Botão: `Abrir Ajustes` | `Can't pin right now` / `Live Activities are turned off for Bilhete in iPhone Settings.` |
| **15.7** | Widget sem bilhete | `Sem bilhete` | `No note` |
| **15.8** | Capacidade Pro tocada | `Isso é do Bilhete Pro` / `Uma compra só, pra sempre.` | `That's in Bilhete Pro` / `One purchase, forever.` |
| **15.9a** | Notificação de expiração (widget já adicionado) | `Seu bilhete sai da tela em 30 minutos` / `%@` · Ação: `Refixar` | `Your note leaves the screen in 30 minutes` |
| **15.9b** | Notificação de expiração (sem widget) | `Seu bilhete sai da tela em 30 minutos` / `Com o widget na tela de bloqueio ele fica pra sempre. Toque pra ver como.` | `Your note leaves the screen in 30 minutes` / `With the Lock Screen widget it stays for good. Tap to see how.` |
| **15.10** | Pedido de permissão (primeira fixação) | `Pra deixar o bilhete na sua tela de bloqueio, o iPhone precisa da sua permissão. É só uma vez.` | `To keep your note on the Lock Screen, iPhone needs your permission. Just once.` |
| ~~**15.11**~~ | ~~Conflito de sincronização~~ | **Removida na v1.1** (decisão D-1) | — |
| **15.12** | Paywall sem rede | `Sem conexão` / `Preciso de internet pra buscar o preço. Tente de novo daqui a pouco.` | `No connection` / `I need internet to load the price. Try again in a moment.` |
| **15.13** | Boas-vindas | `Bilhete` / `Um recado por vez, na sua tela de bloqueio.` · Botão: `Escrever o primeiro` | `Bilhete` / `One note at a time, on your Lock Screen.` · Button: `Write the first one` |
| **15.14** | Nota da exportação nos Ajustes (substitui a copy de sincronização na v1.1) | `Seus bilhetes ficam só neste iPhone. Exportar é o seu backup.` | `Your notes live only on this iPhone. Exporting is your backup.` |
| **15.15** | Falha do Controle | `Não consegui fixar` / `Abra o Bilhete e tente de novo.` | `Couldn't pin` / `Open Bilhete and try again.` |
| **15.16** | Frases de Siri | `Criar bilhete no %@` · `Novo bilhete no %@` · `Refixar meu bilhete no %@` · `Arquivar meu bilhete no %@` (`%@` = `\(.applicationName)`, obrigatório por L14) | `Create a note in %@` · `New note in %@` · `Pin my note again in %@` · `Archive my note in %@` |
| **15.17** | Título do paywall | `Bilhete Pro` / `Uma compra. Pra sempre.` | `Bilhete Pro` / `One purchase. Forever.` |
| **15.18** | Itens do paywall *(atualizado na v1.2 — D-12: refixar virou grátis e saiu da lista)* | `Bilhetes sem limite` · `Arquivo sem limite, com busca` · `Ei Siri, e Atalhos` · `Escolher a fonte` · `Criar bilhete pela Central de Controle` | `Unlimited notes` · `Unlimited archive, with search` · `Hey Siri, and Shortcuts` · `Choose your font` · `Create a note from Control Center` |
| **15.19** | Confirmação de exclusão | `Excluir este bilhete?` / `Não dá pra desfazer.` · Botões: `Excluir` · `Cancelar` | `Delete this note?` / `This can't be undone.` |
| ~~**15.20**~~ | ~~Troca de conta iCloud~~ | **Removida na v1.1** (decisão D-1) | — |

**Copy acrescentada na v1.2** (decisões D-9, D-10 e D-11). A seção 15 original não previa estes textos:

| # | Onde | PT-BR | EN |
|---|---|---|---|
| **15.21** | Ação de concluir, na barra de 10.1 e na Live Activity | `Concluir` | `Done` |
| **15.22** | Linha de ajuda no rodapé de 10.1 | `Um bilhete por vez na tela. Fixar põe ele na tela de bloqueio; Guardar deixa pra depois; Concluir é quando você resolveu.` | `One note at a time. Pin puts it on the Lock Screen; Put away is for later; Done is when you've handled it.` |
| **15.23** | Contador da pilha, no topo de 10.1 | `%lld bilhete` / `%lld bilhetes` | `%lld note` / `%lld notes` |
| **15.24** | Selo do destaque no topo da Pilha | `na tela` | `on screen` |
| **15.25** | Nota da exportação, nos Ajustes | `Seus bilhetes ficam só neste iPhone. Exportar é o seu backup.` | `Your notes live only on this iPhone. Exporting is your backup.` |

**Nomes das superfícies do sistema** (aparecem na galeria de widgets e de Controles):

| Superfície | Nome PT-BR | Descrição PT-BR |
|---|---|---|
| S1 `accessoryRectangular` | `Bilhete` | `Seu bilhete em destaque, sempre na tela de bloqueio.` |
| S2 `accessoryInline` | `Bilhete (uma linha)` | `A primeira linha do seu bilhete, acima do relógio.` |
| S3/S4 tela de início | `Bilhete` | `Seu bilhete em destaque, com um toque pra concluir.` |
| S9 Controle | `Refixar bilhete` | `Coloca seu bilhete de volta na tela, sem abrir o app.` |
| S10 Controle | `Novo bilhete` | `Abre direto no editor.` |

---

## 16. Direção visual

**Este é um app consumer mobile, sem navegação lateral.** O padrão de menu lateral estilo App Store Connect **não se aplica** e não deve ser usado em nenhuma tela.

### 16.1 Metáfora

**Papel.** O bilhete é um pedaço de papel: fundo levemente quente, cantos arredondados generosos, sombra mínima e difusa, sem borda dura. O app é o imã que segura o papel — quem tem que aparecer é o papel, não a moldura. O ideal é que a tela de destaque pareça uma folha, não um formulário.

### 16.2 Paleta

Separação estrita entre **cor de marca** e **cor semântica**. A semântica é reservada para significado e nunca é usada como decoração.

**Paleta da v1.1 — decisão D-6.** Padrão de app da Apple, com o azul do sistema
como cor de marca.

| Papel | Claro | Escuro |
|---|---|---|
| Fundo do app | `#F2F2F7` (fundo agrupado do sistema) | `#000000` |
| Papel (o cartão do bilhete) | `#FFFFFF` | `#1C1C1E` |
| Tinta (texto principal) | `#000000` | `#FFFFFF` |
| Tinta secundária | `#6C6C70` | `#98989F` |
| Hairline / divisória | `#E5E5EA` | `#38383A` |
| **Destaque (marca)** | `#007AFF` (systemBlue) | `#0A84FF` |
| Semântica — destrutivo | `#FF3B30` (systemRed) | `#FF453A` |
| Semântica — sucesso/fixado | `#34C759` (systemGreen) | `#30D158` |

A cor de marca aparece **pouco**: no estado fixado, no botão primário do paywall
e no seletor ativo dos Ajustes. Em nenhuma hipótese ela é usada para erro ou
confirmação destrutiva.

**Por que mudou.** A paleta da v1.0 — areia `#F2EFE9` com papel `#FBF9F5` — punha
fundo e cartão a 4% de distância de luminosidade, e o resultado lia como
"apagado": o papel não descolava da tela. A v1.1 troca por contraste de verdade e
pelo vocabulário de cor que a plataforma já usa.

**O que se perdeu, dito por extenso.** A v1.0 defendia o terracota porque ele
puxava da cerâmica e do barro, evitava a estética de app genérico de notas e era
distinto de tudo que está na categoria. Com o azul do sistema, essa distinção
some — a aposta passa a ser **parecer nativo** em vez de **parecer diferente**. A
metáfora de papel da seção 16.1 continua, mas na **forma**: cartão, cantos
arredondados, sombra difusa. Não mais na cor.

**O que não muda com nenhuma paleta:** o widget de tela de bloqueio é forçado a
escala de cinza pelo sistema (L8). Cor nenhuma aparece na superfície que é a
razão de ser do produto.

### 16.3 Tipografia

- **Sistema (SF Pro).** O corpo do bilhete usa `.title2`, peso `.regular`, com `lineSpacing` de 4pt. É o texto mais importante do app e precisa parecer escrito, não catalogado.
- Opções de fonte (Pro): **padrão** (SF Pro) · **mono** (SF Mono) · **serifada** (New York).
- "Texto pequeno" reduz o corpo para `.body` em todas as superfícies, inclusive widgets e Live Activity.
- Dynamic Type suportado até `.accessibility3` na tela de destaque, e o layout não pode quebrar em nenhum tamanho.

### 16.4 Widgets de tela de bloqueio (S1, S2) — a restrição mais importante

**O sistema força escala de cinza (`vibrant`) e não há como desativar** (L8). Consequências obrigatórias para o desenho:

- **Nenhuma decisão visual pode depender de cor.** Hierarquia se faz com **peso** e **opacidade**, não com matiz.
- `AccessoryWidgetBackground()` para o fundo padrão do sistema, com o texto por cima.
- Cores transparentes se comportam mal em `vibrant`; use tons escuros sólidos para o conteúdo secundário.
- Aplicar `.privacySensitive()` no texto do bilhete, respeitando a preferência do sistema para conteúdo com o aparelho bloqueado.
- **Sem botão** (L9, 11.9).

### 16.5 Live Activity (S5–S8)

- Tela de bloqueio: fundo de papel translúcido, texto em `.title3` medium, dois botões de ícone (concluir e soltar) alinhados à direita. Altura alvo de **~120pt**, teto de 160pt.
- **A Dynamic Island não aceita fundo personalizado** — é preto opaco do sistema. Compacta: símbolo à esquerda, 2–3 primeiras palavras à direita. Mínima: só o símbolo.
- Peso de texto **medium ou maior** em tudo (exigência da HIG para legibilidade em Always-On).
- Nenhuma animação acima de 2 segundos; nenhuma animação em luminância reduzida.

### 16.6 Controles (S9, S10)

**O texto fica oculto na tela de bloqueio** (L10). Os dois Controles precisam ser inequívocos só pelo símbolo:

- Refixar bilhete: `pin.fill` com tint na cor de marca.
- Novo bilhete: `square.and.pencil` com tint na cor de marca.

Nenhum outro Controle do app pode usar símbolo próximo desses dois.

### 16.7 Movimento

Um único momento de animação com identidade no app: **arquivar**. O papel desliza para baixo e some com leve rotação, em ~400 ms, com um feedback háptico `.success`. É o cumprimento visual de P4. Todo o resto usa as transições padrão do sistema — o app não tem outra animação autoral.

### 16.8 Material do iOS 26

Usar `Liquid Glass` nativo em barras e sheets, sem customização, para o app parecer parte do sistema. Não replicar o material à mão nem usar blur custom.

### 16.9 Livre para o agente escolher

- Ícones exatos de SF Symbols para as ações da barra inferior (dentro da família semântica óbvia).
- Espaçamentos internos exatos, respeitando um grid de 4pt e margem lateral de 20pt.
- Curva de animação do arquivamento, respeitando os ~400 ms.

Fora dessa lista, siga o que está escrito.

---

## 17. Requisitos não-funcionais

| Categoria | Requisito |
|---|---|
| **Abertura** | Do toque no ícone ao cursor ativo no editor: **< 1s** em iPhone 12 (o aparelho mais antigo com iOS 18 relevante). |
| **Gravação** | Persistência local do texto em **< 100 ms**. |
| **Fixação** | Do toque em "Fixar" à Live Activity visível: **< 2s**. |
| **Controle** | Do acionamento do Controle à Live Activity visível: **< 3s**, sem abrir o app. |
| **Offline** | **Funcionalidade integral offline.** A única função que depende de rede é a compra. Nenhuma tela pode exibir erro de rede fora do paywall. |
| **Acessibilidade** | VoiceOver completo em todas as telas e superfícies, com rótulos em PT-BR e EN. Dynamic Type até `.accessibility3` sem quebra. Contraste mínimo **4.5:1** para texto. Área de toque mínima **44×44pt**. Redução de movimento respeitada (a animação de arquivar vira fade). |
| **Bateria e dados** | Nenhuma tarefa periódica em background. Nenhuma requisição de rede própria. O tráfego é o do CloudKit, gerido pelo sistema. |
| **Tamanho do binário** | **< 15 MB.** Referência: o Mononote tem 7,3 MB com escopo menor. |
| **Compatibilidade** | iOS 18.0+ · iPhone 11 (A13) em diante · **iPhone apenas** (decisão D-2) · compilado com Xcode 26+ e SDK do iOS 26 (obrigatório para submissão desde 28/04/2026). |
| **Volume de dados** | Desenhado para **até 500 bilhetes** por conta. Acima disso a tela de arquivo pagina de 50 em 50. |
| **Idiomas** | PT-BR (canônico) e EN. Nenhuma string fixa no código. |
| **Privacidade de tela** | `.privacySensitive()` nos widgets de tela de bloqueio. |

---

## 18. Convenções de código, documentação e estrutura

### 18.1 Idioma

- **Camada de dados em português.** As classes `@Model`, suas propriedades, os enums e seus casos usam vocabulário **português** — são o schema persistido e espelhado no CloudKit. Grafia `lowerCamelCase` no Swift (imposição da linguagem); `snake_case` neste documento e no `.dbml`. O mapeamento está explícito na seção 7.
- **Todo o resto em inglês:** nomes de arquivo, tipos de view, funções de UI, variáveis locais, testes.
- **A fronteira é o `BilheteStore`:** de dentro dele para o banco, português; da API dele para fora, inglês. Ex.: `func archive(_ bilhete: Bilhete)` grava `bilhete.arquivadoEm`.
- Esta é uma convenção padrão do projeto. Se preferir a camada de dados em inglês, é uma linha de aviso e eu ajusto — ver assunção A-1.

### 18.2 Comentários obrigatórios

- **Toda** função, método, intent, view model e provider de widget leva comentário de cabeçalho **em português**, dizendo o que faz, o que recebe, o que devolve e **qual regra do spec implementa, com o número da seção**.
- Lógica não óbvia leva comentário inline explicando a **intenção**, nunca a sintaxe.

```swift
/// Arquiva o bilhete e promove o próximo da pilha a destaque.
/// Encerra a Live Activity e cancela o aviso antes de mudar o estado (regras 11.6 e 11.7).
/// Aplica a poda do arquivo do plano grátis (regra 11.4).
/// - Parameter bilhete: o bilhete a arquivar; precisa estar em destaque ou guardado.
/// - Throws: `PodaNecessaria` quando o arquivo grátis está cheio e falta a confirmação do usuário.
func archive(_ bilhete: Bilhete) throws {
    // encerra antes de gravar: uma atividade órfã apontando pra um bilhete
    // arquivado deixaria o texto na tela de bloqueio sem dono (regra 11.6)
    pinService.soltar(bilhete)
    ...
}
```

`// incrementa i` é ruído. `// só migração leve é possível com CloudKit ligado (4.3) — não mudar o tipo aqui` é o que se procura seis meses depois.

### 18.3 Organização

Módulo por feature (4.6): view, view model, tipos e componentes de cada tela na mesma pasta. Tudo o que é compartilhado com a widget extension vive no package `BilheteCore` — **nunca** arquivo duplicado entre targets.

### 18.4 Documentação viva

- `README.md` na raiz: setup local, capabilities a habilitar (App Groups, CloudKit, Live Activities, Push), como rodar os testes, como configurar o produto no App Store Connect.
- `DOCUMENTACAO-TECNICA.md` (seção 19), atualizado no **mesmo commit** de qualquer mudança de schema, intent, regra ou tela.

### 18.5 Configuração e segredos

O app **não tem segredo**: sem chave de API, sem endpoint, sem token. O que existe é configuração de build, em `.xcconfig` versionado:

| Chave | Valor | Público? |
|---|---|---|
| `BUNDLE_ID` | `com.dablab.bilhete` | público |
| `APP_GROUP` | `group.com.dablab.bilhete` | público |
| `CLOUDKIT_CONTAINER` | `iCloud.com.dablab.bilhete` | público |
| `PRODUTO_PRO` | `com.dablab.bilhete.pro` | público |
| *(reservado v2)* | `API_BASE_URL` | a definir |

---

## 19. Documento de documentação técnica (entregável final)

Ao terminar a implementação, o agente de código gera `DOCUMENTACAO-TECNICA.md` na raiz, em português, descrevendo o sistema **como ele ficou**, não como foi planejado. Conteúdo mínimo, nesta ordem:

1. **Modelo de dados explicado** — a entidade `bilhete`, cada propriedade em linguagem de negócio (não só o tipo), todos os valores dos enums e o que cada um significa. Mais `preferencias` e `direito_pro`, que não são persistidos em SwiftData, e por quê.
2. **Relacionamentos** — na v1 há uma entidade só; declarar isso explicitamente e registrar onde a v2 encaixa (`bilhete.casa_id`), para quem retomar o projeto entender a modelagem mínima como decisão, não como esquecimento.
3. **Regras que vivem fora da UI** — como não há banco SQL com trigger, esta seção lista **`BilheteStore`, `PinService` e `EntitlementStore`**: cada método, o que dispara, o que faz, e qual invariante garante. Deve dar para ler essa lista e entender toda a lógica que as views não mostram.
4. **Mapa tela → dados** — para cada tela de 10.1 a 10.7 e cada superfície S1–S11: o que lê, o que escreve, e por qual método do `BilheteStore` passa.
5. **Lógica por tela** — o que acontece em cada ação principal: o que é validado, o que é gravado, o que é calculado, onde (app, widget extension ou intent), e o que a pessoa vê em caso de erro.
6. **Divergências em relação a este spec** — o que foi implementado diferente e por quê. Sem esta seção o documento envelhece mentindo.

---

## 20. Privacidade, segurança e conformidade

| Item | Decisão |
|---|---|
| **Dados coletados** | Somente o que a pessoa escreve. Nenhum dado pessoal é pedido, inferido ou derivado. |
| **Onde ficam** | **Só no aparelho**, no container do App Group (decisão D-1). Nada sai dele: não há servidor, não há iCloud, não há requisição de rede própria. |
| **Quem acessa** | Só a pessoa, no próprio aparelho. **A Dab Lab não tem acesso** — não existe cópia dos dados em lugar nenhum. |
| **Retenção** | Enquanto o app estiver instalado ou até a pessoa excluir. Desinstalar apaga tudo — por isso "Exportar tudo" ganhou destaque nos Ajustes. |
| **Portabilidade (LGPD art. 18)** | "Exportar tudo" (14.2), sem pedir nada em troca. |
| **Exclusão (LGPD art. 18)** | "Apagar tudo" no arquivo e exclusão individual, ambos hard delete e imediatos. |
| **Telemetria** | Ver seção 21. **Nenhum evento carrega o texto do bilhete**, nem trecho, nem hash. Nem sequer o comprimento. |
| **Ficha de privacidade da App Store** | Declarar **"Dados não coletados"**, exatamente como o Mononote. É verdadeiro e é um diferencial de confiança que vale ser dito na descrição da loja. |
| **Segredos** | Não existem (18.5). Nenhuma credencial privilegiada, porque não há servidor. |
| **IA** | O app **não embute IA**. Sem geração, sem sugestão, sem classificação de conteúdo. Não há guardrail a definir porque não há modelo. |
| **Menores** | Classificação **4+**. Sem conteúdo gerado por terceiros, sem rede social, sem link externo além dos Ajustes do sistema, da App Store e da política de privacidade. |
| **Política de privacidade** | Publicada em URL pública antes da submissão, em PT-BR e EN, usando o documento padrão da Dab Lab. |

---

## 21. Métricas de sucesso e telemetria

### Métricas de produto (v1)

| # | Métrica | Alvo | Prazo |
|---|---|---|---|
| M1 | % de instalações que criam **e fixam** o primeiro bilhete | ≥ 60% | 90 dias |
| M2 | Retenção D7 | ≥ 25% | 90 dias |
| M3 | Conversão instalação → Pro | ≥ 2,5% (benchmark de produtividade: ~2,1% em D35) | 120 dias |
| M4 | % de destaques expirados que são **refixados** (pelo Controle, pelo aviso ou pelo app) em até 24h | ≥ 40% | 90 dias |

M4 é a métrica mais importante das quatro: ela mede se a solução para o problema das 12 horas funcionou. **Reescrita na v1.2** (decisão D-7): media a adoção do widget, e passou a medir o refixar, que é o comportamento que o produto passou a apostar. Se ela ficar baixa, o problema não é o paywall — é o custo de refixar, e aí a resposta é voltar a sugerir o widget (a tela 10.7 continua pronta no código).

### Telemetria

**Nenhuma ferramenta de analytics de terceiros na v1.** A fonte é o App Store Connect (instalações, conversão, retenção, avaliações). Motivo: SDK de terceiro contradiz a declaração "Dados não coletados" da seção 20, e a declaração vale mais para este produto do que os dados valeriam.

M1 e M4 são medidos localmente e expostos **apenas** de forma agregada e anônima, se e quando um backend existir (v2). Na v1, ficam como contadores locais que a pessoa nunca vê e que ninguém coleta. `origem` (7.6) alimenta a mesma contagem local.

---

## 22. Estratégia de teste

### Testes automatizados obrigatórios

**Invariantes do modelo** (as que, quebradas, corrompem o app):

1. Nunca existem dois bilhetes com `estado = em_destaque`.
2. `fixado_ate` e `id_atividade` só são não-nulos quando `estado = em_destaque`.
3. `arquivado_em` é não-nulo **se e somente se** `estado = arquivado`.
4. **Nenhuma classe `@Model` declara propriedade `Array` ou `Set`** (defesa contra R-1). Teste que falha o build se alguém adicionar.

**Regras de negócio** — uma bateria por regra numérica: 11.2, 11.3, 11.4, 11.5, 11.6, 11.8, 11.10, 11.11, 11.16.

**Máquina de estados** (seção 12) — toda transição permitida executa e produz os efeitos colaterais listados; toda transição proibida falha.

**Migração** — teste de abertura de um store da versão anterior em cada release, obrigatório antes de qualquer submissão, dado que só migração leve é possível com CloudKit (4.3).

**StoreKit** — via `StoreKit Testing` local: compra bem-sucedida, cancelada, restaurada, e **revogada** (regra 11.11).

### Validação manual (checklist por release)

- Live Activity em iPhone com e sem Dynamic Island.
- Widgets em tela de bloqueio clara e escura, e com papel de parede de alto contraste (verificar a legibilidade em `vibrant`, L8).
- Controle na tela de bloqueio, na Central de Controle e no Botão de Ação, com o app **fechado**.
- Fluxo completo de expiração: fixar, aguardar, receber o aviso, refixar pelo Controle.
- Sincronização entre dois aparelhos com a mesma conta, incluindo o conflito da regra 11.14.
- VoiceOver em todas as telas.
- Dynamic Type no maior tamanho de acessibilidade.

### Como testar o que depende de tempo

`fixado_ate` e o agendamento do aviso são injetados por um `Clock` substituível nos testes. **Nunca** usar `Date()` direto em código testável.

---

## 23. Riscos e mitigação

| # | Risco | Impacto | Prob. | Mitigação |
|---|---|---|---|---|
| **R-1** | **Regressão do SwiftData do iOS 26.1** (`Array`/`Set` → `Transformable`), com falha de migração e **perda de dados com iCloud ligado**. Classificada publicamente como bug sério por engenheiro da Apple, **sem correção confirmada até 08/2026**. | **Crítico** | Média | (a) Regra 4.3: **nenhuma** propriedade `Array`/`Set` no modelo, com teste automatizado que falha o build; (b) "Exportar tudo" (14.2) desde a v1; (c) `VersionedSchema` desde a v1 (7.8); (d) teste de migração obrigatório por release (seção 22); (e) modelo de **uma entidade só**, que reduz a superfície ao mínimo. |
| **R-2** | **App Review rejeita por 4.2 (Minimum Functionality)** — app de feature única. | Alto | Média | A v1 tem 7 telas, 4 widgets, 2 Controles, Live Activity, Siri e Atalhos — superfície bem acima do mínimo. Nas notas de revisão, enquadrar como **lembrete com prazo e conclusão**, não como bloco de notas. Ver seção 27. |
| **R-3** | **Live Activity fora do espírito da HIG** (que pede evento com começo e fim e desaconselha informação estática). | Médio | Baixa | A HIG não é vinculante em review, e há vários apps aprovados fazendo o mesmo (LockNote, LiveNote, Notepad Live, ScreenPin, Mononote). O `fixado_ate` dá começo e fim reais ao evento — o que alinha com a HIG por desenho, não por argumento. |
| **R-4** | **Descoberta orgânica.** A categoria tem um app com 29 mil avaliações e outro brasileiro de notas com 9,7 mil. | **Alto** | **Alta** | É o risco real do projeto. Respostas na v1: ASO 100% em PT-BR (categoria sem nenhum concorrente localizado) e ficha da loja atacando "nota na tela de bloqueio". A resposta estrutural é o compartilhamento da v2, que é o único loop viral que esta categoria admite. |
| **R-5** | **Comportamento do widget interativo na tela de bloqueio** (L9): intent só executa após o desbloqueio, sem API para reverter o estado visual. | Médio | Alta (é certo) | Já resolvido por desenho: regra 11.9 proíbe botão em widget de tela de bloqueio. A ação vive no Controle (L6, oficialmente suportado) e nos widgets de tela de início. |
| **R-6** | **Bug conhecido:** mudança feita pelo widget não aparece no app até relaunch, por serem processos com `ModelContainer` distintos. | Médio | Alta | Regra 4.5, item 4: **sempre `@Query`**, nunca `@State` populado à mão. Critério de aceite 8.5.5 valida isso explicitamente. |
| **R-7** | **ARPU brasileiro ~5x menor** que o norte-americano (US$ ~0,10 vs US$ 0,55 de receita por instalação). | Médio | Alta (é fato) | Preço único baixo, custo de infraestrutura zero na v1, e EN publicado desde o dia 1 para não fechar o mercado global de graça. |
| **R-8** | **Poda do arquivo grátis (11.4) gera avaliação de 1 estrela** por perda de dado percebida. | Médio | Média | Confirmação prévia e nominal (15.4), com opção de cancelar e de ver o Pro. Se aparecer nas avaliações, a resposta é subir o limite grátis, não remover o aviso. |
| ~~**R-9**~~ | ~~Troca de conta iCloud limpa os dados locais~~ | — | — | **Eliminado na v1.1** (decisão D-1): sem iCloud, não há o que limpar. |
| **R-11** | **Sem sincronização, perder o aparelho é perder os bilhetes** — risco criado pela decisão D-1. | Médio | Média | O backup do iPhone inclui o container do App Group, então restaurar o aparelho restaura os bilhetes. Além disso, "Exportar tudo" (14.2) ganhou destaque nos Ajustes, com a nota da copy 15.14. A v2 pode religar o CloudKit sem migração pesada. |
| **R-10** | O projeto para antes da v2 e o compartilhamento nunca sai. | Médio | Média | A v1 foi escopada para ser boa sozinha. Nenhum critério de aceite da v1 depende de feature da v2. |

---

## 24. Assunções declaradas

Decisões que **eu tomei sem perguntar**. Revise antes de gerar código — assunção não revisada vira verdade no minuto em que o agente começa a codar.

| # | Assunção | Por quê | Se você discordar |
|---|---|---|---|
| **A-1** | **Camada de dados nomeada em português** (`bilhete.texto`, `estado`, `arquivadoEm`), resto do código em inglês. | É a convenção padrão do SDD. As classes `@Model` são o schema persistido, então caem do lado português da fronteira. | É uma linha de aviso e eu troco a seção 7 e o `.dbml` para inglês. |
| **A-2** | **Limite de 280 caracteres** por bilhete. | A Live Activity tem 84–160pt de altura (L12); acima disso o texto fica ilegível na superfície que é a razão de ser do app. 280 é o teto legível com folga. | Dá para subir para 400 com fonte menor, ao custo de legibilidade na tela de bloqueio. |
| **A-3** | **Arquivados não contam** para o limite de 3 ativos. | Preserva P4: arquivar é encerramento, não deve ser punido. E dá ao usuário grátis uma saída legítima em vez de uma parede. | Se quiser mais pressão de conversão, contar arquivados no limite. Eu não recomendo. |
| **A-4** | **Arquivo grátis limitado a 10**, com poda do mais antigo. | Sem algum limite, o plano grátis vira o produto inteiro. 10 é generoso o bastante para não parecer mesquinho. | Subir para 25, ou tornar o arquivo ilimitado e cobrar só pela busca (menos receita, zero atrito). |
| **A-5** | ~~Controle, Siri e Atalhos são Pro~~ → **refixar é grátis; criar por Siri, Atalho ou Controle continua Pro** (decisão D-12, v1.2). | São o diferencial técnico da v1 e o que resolve o problema das 12h — é o valor mais defensável para amarrar ao preço. | Se a prioridade for avaliação e boca a boca, liberar o Controle no grátis e cobrar só por contagem. Muda a regra 11.10 e a seção 5. |
| **A-6** | **8h de fixação, não configurável.** | É o limite ativo do sistema (L1), não uma escolha. Oferecer "1h / 4h / 8h" adiciona decisão sem adicionar valor. | Dá para expor as opções, mas P2 diz para não fazer isso. |
| **A-7** | **Nome "Bilhete"**, bundle `com.dablab.bilhete`. | Escolha sua, registrada aqui para o agente não inventar variação. | Trocar o nome antes do primeiro commit é barato; depois do App Store Connect, não. |
| **A-8** | **Sem SDK de analytics.** | Contradiz a declaração "Dados não coletados", que vale mais para este produto do que os dados valeriam. | Se quiser dados de funil, TelemetryDeck é o menos invasivo — mas muda a ficha de privacidade da loja. |
| **A-9** | **Aviso de expiração 30 minutos antes**, ligado por padrão. | Tempo suficiente para agir sem virar incômodo. Ligado por padrão porque a persona P-C não vai procurar nos Ajustes. | 1h antes, ou desligado por padrão (e aí M4 provavelmente cai). |
| **A-10** | ~~iPad e Mac como alvos de compatibilidade~~ → **iPhone apenas** (decisão D-2, v1.1). | Sem sincronização (D-1), iPad e Mac não ganhavam nada; e o app é de tela de bloqueio de iPhone. | Voltar atrás é adicionar as famílias de dispositivo no `project.yml` e desenhar o layout — escopo próprio. |
| **A-11** | **Sem modo "vários bilhetes fixados ao mesmo tempo".** | A HIG recomenda uma Live Activity que rotaciona em vez de várias, e várias empurram a Dynamic Island para a apresentação mínima. Além disso viola P1. | É uma feature de v2, se as avaliações pedirem. |

---

## 25. Perguntas abertas

O agente de código deve **perguntar em vez de assumir** ao cruzar com qualquer item desta lista.

| # | Pergunta | Resposta (v1.1) | Quem decidiu |
|---|---|---|---|
| ~~**Q-1**~~ | Preço | **R$ 19,90 de lançamento** (decisão D-3). O app nunca exibe preço fixo — sempre o do StoreKit. | Alexandre, 15/08/2026 |
| ~~**Q-2**~~ | Publicar em espanhol? | **Não na v1.** Só PT-BR e EN (decisão D-4). | Alexandre, 15/08/2026 |
| ~~**Q-3**~~ | URLs de suporte e privacidade | **Padrão da Dab Lab** (decisão D-5): suporte no Carrd, privacidade no Notion. Centralizadas em `AppLinks.swift`. | Alexandre, 15/08/2026 |
| ~~**Q-4**~~ | Ícone do app | **Gerado a partir da direção visual**: papel sobre o azul da marca, 1024 opaco, com `CFBundleIconName` declarado à mão porque o `Info.plist` é manual. | Alexandre, 15/08/2026 |
| ~~**Q-5**~~ | Mac Catalyst e iPad | **Nenhum dos dois. iPhone apenas** (decisão D-2). | Alexandre, 15/08/2026 |
| **Q-6** | Se a regressão R-1 do SwiftData se manifestar em beta, migramos para Core Data ou seguimos com as mitigações? Essa é a única decisão que pode custar semanas. | **Em aberto.** Não se manifestou até aqui; as mitigações estão todas no lugar, inclusive a build phase que derruba a compilação. | Alexandre, ao primeiro sinal em teste |

---

## 26. Definition of Done

### Funcional
- [ ] Os 11 épicos (8.1–8.11) implementados, com **todos** os critérios de aceite passando.
- [ ] As 7 telas (10.1–10.7) e as 11 superfícies (S1–S11) implementadas.
- [ ] Todas as transições da seção 12 funcionam; todas as proibidas falham.
- [ ] Todas as regras da seção 11 implementadas com os valores **exatos** deste documento.

### Qualidade
- [x] Testes das 4 invariantes da seção 22 passando, incluindo a build phase que derruba a compilação se alguém adicionar `Array`/`Set` a um `@Model`.
- [ ] Bateria de teste por regra numérica de 11.2 a 11.16.
- [ ] Teste de migração de schema executado.
- [ ] Testes de StoreKit: compra, cancelamento, restauração e **revogação**.
- [ ] Checklist manual da seção 22 executado em aparelho real, com e sem Dynamic Island.

### Convenções
- [ ] Camada de dados nomeada em português conforme 18.1, sem propriedade fora do padrão.
- [ ] **Toda** função, intent, view model e provider comentado em português, citando a regra do spec que implementa.
- [ ] Nenhum arquivo duplicado entre targets; tudo o que é compartilhado vive em `BilheteCore`.
- [ ] Nenhuma string fixa no código.

### Não-funcional
- [ ] Abertura < 1s, fixação < 2s, Controle < 3s, medidos em iPhone 12.
- [ ] VoiceOver completo; Dynamic Type até `.accessibility3` sem quebra; contraste ≥ 4,5:1.
- [ ] App funciona integralmente offline. (Não há conta nem iCloud — decisão D-1.)
- [ ] Binário < 15 MB.

### Privacidade e loja
- [ ] Ficha de privacidade declarada como **"Dados não coletados"**, e verdadeira.
- [ ] "Exportar tudo" e "Apagar tudo" funcionando (LGPD art. 18).
- [ ] PT-BR e EN completos, inclusive nomes e descrições de widgets e Controles.
- [ ] Política de privacidade publicada em URL pública.

### Documentação
- [ ] `README.md` com setup, capabilities e como rodar os testes.
- [ ] **`DOCUMENTACAO-TECNICA.md` gerado**, com os 6 itens da seção 19, conferido contra o que foi implementado de fato.

---

## 27. Próximos passos operacionais

1. **Revisar a seção 24 (assunções)** — especialmente A-1 (idioma da camada de dados), A-5 (Controle e Siri serem Pro) e A-4 (arquivo grátis de 10). São as três que mais mudam o produto.
2. **Responder Q-1 a Q-5** da seção 25.
3. Criar o repositório e o projeto no Xcode 26.6, com deployment target iOS 18.0.
4. **Ordem de implementação:** seção 7 (modelo e `BilheteStore` com as invariantes) → 8.1 → 8.2 → 8.3 → 8.4 → 8.5 → 8.6 → 8.7 → 8.8 → 8.9 → 8.10 → 8.11. Modelo e invariantes **antes** de qualquer tela — com CloudKit, o schema é a decisão mais cara de reverter.
5. Gerar as telas com o `prompt-design-bilhete.md`, entregue junto com este spec.
6. Registrar o App ID, o App Group e o container de CloudKit no portal da Apple.
7. Criar o produto `com.dablab.bilhete.pro` no App Store Connect (depende de Q-1).
8. Preparar a ficha da loja com o skill `app-store-dablab`, usando este spec como entrada. Nas **notas de revisão**, enquadrar o app como lembrete com prazo e conclusão (mitigação de R-2).
9. TestFlight com pelo menos 5 pessoas, obrigatoriamente incluindo alguém do perfil da persona P-C.

---

## 28. Roadmap: próximas releases

### 28.1 — Bilhete compartilhado (v2) — o diferencial estratégico

**O que é:** uma pessoa escreve, o bilhete aparece na tela de bloqueio de todo mundo da casa. Qualquer um marca como resolvido e ele some da tela de todos. É o bilhete de geladeira, agora com a geladeira sendo compartilhada.

**Por que é a feature mais importante que existe fora da v1, em três razões:**

1. **É o único loop viral que a categoria admite.** Todo compartilhamento é um convite de instalação. Sem isso, a resposta ao risco R-4 é só ASO.
2. **O backend que ela exige resolve a expiração de graça.** Com servidor rodando para sincronizar entre contas, o push-to-start da APNs deixa de ser custo injustificável e vira efeito colateral — a renovação automática (28.4) sai quase de brinde.
3. **É defensável.** Copiar "uma nota por vez" é trivial; copiar uma rede de casas com bilhetes sincronizados exige backend, identidade e sincronia, coisa que os indies da cauda longa da categoria não vão fazer.

**Por que não está na v1:** CloudKit privado **não compartilha entre contas iCloud** (4.3, item 5). Exige backend próprio ou CloudKit Sharing, identidade entre pessoas, convite, e uma política de privacidade bem mais pesada. É a decisão mais cara do produto e deve ser tomada com dado de uso da v1 na mão.

**Preparação já feita na v1:** a entidade `bilhete` tem `id` gerado no cliente, `criado_em`, `atualizado_em` e `origem` — o suficiente para receber `casa_id` e `autor_id` sem reescrever a seção 7. Como só migração leve é possível com CloudKit ligado (4.3, item 4), **adicionar campos opcionais é permitido; mudar tipo ou remover campo, não.** Planejar a v2 dentro dessa restrição desde já.

### 28.2 — Prazo e recorrência
"Até as 18h", "toda segunda de manhã". Alinha com a HIG (evento com começo e fim), reduz o risco R-3 e é gating natural de paywall. Depende de decidir se o Bilhete passa a ser um lembrete com alarme, o que hoje está no anti-escopo (seção 1).

### 28.3 — Bilhete por contexto
Aparece ao chegar no mercado, ao sair de casa. **Restrição dura:** geofence **não pode iniciar** Live Activity a partir de background (L4). Só viável via notificação acionável ou Atalho de automação pessoal, que exige configuração manual. Precisa de desenho próprio, não é um "é só adicionar".

### 28.4 — Renovação automática da fixação
Push-to-start via APNs renovando a cada 8h. **Custo:** backend, e o payload de `start` **obriga um `alert`** — notificação a cada renovação. Só faz sentido depois que o backend da 28.1 existir, e mesmo assim precisa de desenho de UX para o alerta não virar incômodo. Avaliar se vale contra o Controle de um toque, que já resolve o problema sem nada disso.

### 28.5 — Apple Watch com UI dedicada
`supplementalActivityFamilies([.small])` para layout próprio no Smart Stack. Baixo custo, baixo retorno enquanto a base for pequena.

### 28.6 — Temas e cores
Só faz sentido nas superfícies que aceitam cor (tela de início, Live Activity). **Nunca** no widget de tela de bloqueio, que é forçado a escala de cinza pelo sistema (L8).

---

## 29. Protocolo de mudanças incrementais

Depois da v1 pronta, siga isto para que um ajuste pequeno não vire reescrita do app.

1. **Commit de checkpoint antes de qualquer mudança**, para ter um `git diff` confiável.
2. **Não cole este spec inteiro de novo.** Cole só o trecho novo ou alterado, ou escreva um spec adicional só da feature.
3. **Escreva a instrução como diff, não como recomeço.** Deixe explícito que o projeto já existe e funciona.
4. **Delimite nominalmente o que não deve mudar.**
5. **Peça a lista de arquivos que serão criados e alterados antes do código**, e aprove.
6. **Revise o `git diff` contra o plano aprovado.** Reverta arquivo que passou do escopo e refaça o pedido de forma mais específica.
7. **Exija a atualização do `DOCUMENTACAO-TECNICA.md` no mesmo commit.**

Modelo pronto para colar:

```
O projeto Bilhete já está implementado e funcionando. Isto é uma mudança
incremental, não um recomeço.

MUDANÇA:
<descreva só o que muda>

REFERÊNCIA NO SPEC:
seção <n> do SDD-Bilhete.md

NÃO ALTERE:
- o modelo de dados da seção 7, exceto <se aplicável>
- as invariantes testadas da seção 22
- nenhuma tela além de <lista>

ANTES DE CODAR: me mostre a lista de arquivos que você vai criar e alterar,
e espere minha aprovação.

AO TERMINAR: atualize o DOCUMENTACAO-TECNICA.md no mesmo commit, incluindo
a seção de divergências.
```

---

## Anexo — Fontes

Consultadas em **15/08/2026**.

**Restrições de plataforma**
- [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities) — limite de 8h + 4h (L1)
- [ActivityUIDismissalPolicy](https://developer.apple.com/documentation/activitykit/activityuidismissalpolicy) — corte de 4h (L3)
- [Fórum Apple, thread 818467](https://developer.apple.com/forums/thread/818467) — resposta de DTS: Live Activity exige foreground (L4)
- [Fórum Apple, thread 797676](https://developer.apple.com/forums/thread/797676) — duração máxima confirmada por DTS
- [Fórum Apple, thread 766780](https://developer.apple.com/forums/thread/766780) — widget interativo na tela de bloqueio só executa após desbloqueio (L9)
- [Fórum Apple, thread 711501](https://developer.apple.com/forums/thread/711501) — modo `vibrant` forçado em widgets de tela de bloqueio (L8)
- [HIG: Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities/) — dimensões e diretrizes (L12)
- [WWDC24, sessão 10157](https://developer.apple.com/videos/play/wwdc2024/10157/) — Controle disparando `LiveActivityIntent` (L6)
- [Creating controls to perform actions across the system](https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system) (L10, L13)
- [Starting and updating Live Activities with push notifications](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications) (L7, L11)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) — 2.5.16, 2.5.18, 4.2, 4.5.4

**Stack e versões**
- [Apple — App Store support / adoção de iOS](https://developer.apple.com/support/app-store/) — 79% em iOS 26, medido em 07/06/2026
- [Apple Developer — requisitos futuros](https://developer.apple.com/news/upcoming-requirements/?id=02032026a) — SDK do iOS 26 obrigatório desde 28/04/2026
- [Xcode 26.6 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-26_6-release-notes) — Swift 6.3
- [Fórum Apple, threads 808020 / 806161 / 808530](https://developer.apple.com/forums/thread/808020) — regressão do SwiftData no iOS 26.1 com perda de dados (R-1)
- [Fórum Apple, thread 791794](https://developer.apple.com/forums/thread/791794) — mudança do widget não aparece no app sem `@Query` (R-6)
- [ModelConfiguration.groupContainer](https://developer.apple.com/documentation/swiftdata/modelconfiguration/groupcontainer-swift.struct)
- [Fatbobman — regras de adaptação de modelo ao CloudKit](https://fatbobman.com/en/snippet/rules-for-adapting-data-models-to-cloudkit/) — restrições de 4.3
- [Transaction.currentEntitlements](https://developer.apple.com/documentation/storekit/transaction/currententitlements)
- [WWDC26, sessão 274 — What's new in SwiftData](https://developer.apple.com/videos/play/wwdc2026/274/) — APIs novas só no iOS 27

**Mercado**
- [RevenueCat — State of Subscription Apps 2026](https://www.revenuecat.com/state-of-subscription-apps) — ARPU LatAm vs América do Norte (R-7)
- [RevenueCat — Produtividade 2026](https://www.revenuecat.com/state-of-subscription-apps-2026-productivity/) — conversão de ~2,1% em D35 (M3)
- [Apple — IOF de 3,5% no Brasil](https://developer.apple.com/news/?id=yo2104n5) · [Small Business Program](https://developer.apple.com/app-store/small-business-program/)
- [Sticky Widgets](https://apps.apple.com/us/app/sticky-widgets/id1533254320) — 29 mil avaliações (R-4)
- [Mononote: One Note](https://apps.apple.com/us/app/mononote-one-note/id6788222857) — referência de escopo e de tamanho de binário
