# Documentação técnica — Bilhete v1

Escrita a partir do que foi **realmente implementado**, não do que foi planejado.
Onde o código diverge do `SDD-Bilhete.md`, a seção 6 explica o quê e o porquê.

**Estado em 16/08/2026:** os 11 épicos da seção 8 do spec implementados, 105
testes passando em 12 suítes, e o app **instalado e testado em iPhone 13 mini
real**. Deployment target iOS 18.0, iPhone apenas. O spec correspondente é a
**v1.2**.

---

## 1. Modelo de dados explicado

### A entidade `bilhete`

Classe SwiftData `Bilhete`, em
`Packages/BilheteCore/Sources/BilheteCore/Models/Bilhete.swift`. É a **única
entidade persistida** do app.

| Propriedade | Tipo | O que significa no negócio |
|---|---|---|
| `id` | `UUID` | Identificador gerado no aparelho. Não usa `@Attribute(.unique)`: a unicidade é conferida na criação (regra 11.13), varrendo os ids existentes antes de gravar. |
| `texto` | `String` | O que a pessoa escreveu. Texto puro — sem título, sem formatação, sem anexo. No máximo 280 caracteres (regra 11.2), limite que existe porque acima disso o texto fica ilegível na Live Activity, que tem 84–160pt de altura. |
| `estado` | `EstadoBilhete` | Onde o bilhete está na vida dele: em destaque, guardado ou concluído (o estado ainda se chama `arquivado` no código — o nome mudou só na interface, decisão D-10, porque renomear o caso do enum mudaria o valor persistido). Governa tudo — o que aparece na tela de bloqueio, o que conta para o limite do plano grátis, o que pode ser restaurado. |
| `ordemPilha` | `Int` | Posição na pilha de guardados. Menor valor = mais acima. Guardar insere no topo (`min − 1`); reordenar reescreve a sequência inteira a partir de 0, o que faz a ordem sobreviver a fechar e reabrir o app. Irrelevante para destaque e arquivados. |
| `fixadoAte` | `Date?` | Quando a fixação na tela de bloqueio expira: sempre `agora + 8h`, que é o limite ativo imposto pelo sistema, não uma escolha de produto. **Nulo** quando o bilhete não está fixado — nunca esteve, já expirou, ou foi solto. É estado **local do aparelho**. |
| `idAtividade` | `String?` | O `Activity.id` da Live Activity em curso, guardado para poder atualizar o texto sem recriar a atividade e para poder encerrá-la. **Nulo** quando não há atividade. Também é local do aparelho. |
| `criadoEm` | `Date` | Quando o bilhete nasceu. **Nunca muda** — nem ao editar, nem ao arquivar, nem ao restaurar. |
| `atualizadoEm` | `Date` | Quando o texto ou o estado mudou pela última vez. Ordena a pilha na tela e serve de critério de recência. Digitar e apagar de volta **não** mexe nele: gravar o mesmo texto é operação nula. |
| `arquivadoEm` | `Date?` | Quando a pessoa encerrou o bilhete. Define a ordem da tela de arquivo e o corte dos 10 do plano grátis. **Não-nulo se e somente se** `estado == .arquivado` — é uma das quatro invariantes testadas. |
| `origem` | `OrigemBilhete` | Por onde o bilhete entrou: app, Siri, Atalho, Controle ou widget. Existe para contagem local e para medir se Siri e Controle valem o custo de manutenção. **Nunca sai do aparelho** — não há SDK de analytics, e a ficha da loja declara "Dados não coletados". |

**Três restrições estruturais que o modelo obedece e não podem ser "melhoradas":**

1. **Nenhuma propriedade `Array` ou `Set`.** A regressão introduzida no iOS 26.1
   converte esses atributos para `Transformable` e quebra a migração do store.
   Há uma build phase que derruba a compilação se alguém adicionar, e um teste
   que lê o schema real do SwiftData e falha se aparecer.
2. **Nenhum `@Attribute(.unique)`.**
3. **Toda propriedade é opcional ou tem valor default.**

As duas últimas vinham do CloudKit. A decisão D-1 tirou o CloudKit do escopo,
mas as regras ficaram: manter o schema compatível com sincronização é o que
permite ligar o CloudKit depois — na v2, por exemplo — sem migração pesada.

### Enum `EstadoBilhete`

| Caso | Valor cru | O que significa |
|---|---|---|
| `emDestaque` | `em_destaque` | O bilhete da vez. Existe exatamente **um**, ou zero no instante entre transições. É o único que aparece nos widgets e na Live Activity. |
| `guardado` | `guardado` | Está na pilha, esperando a vez. Não aparece em nenhuma superfície do sistema. |
| `arquivado` | `arquivado` | Encerrado. Sai da pilha, pode ser restaurado, e **não conta** para o limite de bilhetes ativos. |

`EstadoBilhete.contaComoAtivo` é o que implementa a última frase: arquivar
libera espaço no plano grátis, de propósito — arquivar é encerramento e não pode
ser punido.

### Enum `OrigemBilhete`

`app`, `siri`, `atalho`, `controle`, `widget`. Só contagem local.

### `preferencias` — não persistida em SwiftData

Vive em `UserDefaults(suiteName: "group.com.dablab.bilhete")`, classe
`Preferences`. Fica fora do SwiftData por dois motivos: são valores **por
aparelho**, e a widget extension precisa lê-los de forma síncrona no momento do
render, sem abrir um `ModelContainer`.

| Chave | Default | Para quê |
|---|---|---|
| `aparencia` | `sistema` | Sistema, claro ou escuro |
| `fonte` | `padrao` | Escolha da pessoa. Quem desenha usa `fonteEfetiva`, que devolve `padrao` quando o Pro não está ativo — **sem apagar a escolha**, que volta a valer se o direito voltar |
| `texto_pequeno` | `false` | Reduz o corpo do texto em todas as superfícies |
| `avisar_expiracao` | `true` | Liga o aviso 30 minutos antes. Nasce **ligado** porque a persona que mais precisa dele não vai procurar nos Ajustes |
| `boasvindas_concluida` | `false` | Controla a tela de boas-vindas |
| `dica_widget_vista` | `false` | Controlava o cartão e a tela do guia da tela de bloqueio. Sem uso desde a decisão D-7, mantida para não perder o histórico |
| `pro_desbloqueado` | `false` | **Cache** do direito, só para a widget extension aplicar o gating sem acessar o StoreKit |
| `insistencias_widget` | `0` | Teto de duas insistências sobre o widget. Sem uso desde a D-7 |
| `ja_fixou_alguma_vez` | `false` | Metade da condição que libera o paywall |
| `permissao_notificacao_pedida` | `false` | Garante que a permissão é pedida **uma única vez** |
| `idioma` | `sistema` | Idioma do app (D-8): `sistema`, `pt-BR` ou `en`. A widget extension não é afetada — é outro processo |

As quatro últimas chaves não estavam na tabela 7.3 da v1.0 do spec; foram necessárias para
cumprir regras que o spec pede (teto de insistências, momento de valor,
permissão única). Estão registradas na seção 6.

### `direito_pro` — não persistido

Fonte de verdade: `Transaction.currentEntitlements` do StoreKit 2, lido no
lançamento e observado continuamente por `Transaction.updates`. O valor é
espelhado em `preferencias.pro_desbloqueado` **exclusivamente** para a extension.
O app nunca decide direito a partir do cache — sempre relê o StoreKit ao abrir e
ao abrir o paywall.

Produto: `com.dablab.bilhete.pro`, não-consumível, R$ 19,90.

---

## 2. Relacionamentos

**Não há nenhum.** A v1 tem uma entidade só, e isso é decisão de modelagem, não
esquecimento: modelo mínimo reduz ao mínimo a exposição às restrições de
migração, que são permanentes uma vez que o sync liga.

Onde a v2 encaixa: `bilhete.casaId` e `bilhete.autorId`, ambos **opcionais**,
para o bilhete compartilhado entre pessoas. A migração leve permite adicionar
campo opcional; **mudar tipo ou remover campo, não**. Quem retomar o projeto
deve planejar dentro dessa restrição.

O `VersionedSchema` (`BilheteSchemaV1`) e o `SchemaMigrationPlan`
(`BilheteMigrationPlan`) existem desde o dia 1, com uma versão só, justamente
para que essa evolução tenha onde acontecer.

---

## 3. Regras que vivem fora da UI

Não há banco SQL com trigger: toda regra que as telas não mostram vive em três
tipos.

### 3.1 `BilheteStore` — o ponto único de escrita

`Packages/BilheteCore/Sources/BilheteCore/Store/BilheteStore.swift`.
**Nenhuma view escreve no `ModelContext`.** As invariantes são transacionais e
precisam de um dono só.

Os números da seção 11 vivem aqui como constantes nomeadas: `activeLimitFree` 3,
`archiveLimitFree` 10, `textLimit` 280, `counterThreshold` 240, `pinDuration` 8h,
`expiryWarningLead` 30 min, `saveDebounce` 1s.

| Método | Quem dispara | O que faz | Invariante que garante |
|---|---|---|---|
| `ensureFeatured(origem:)` | Abertura do app; intent "Novo bilhete" | Devolve o destaque atual; sem destaque, promove o primeiro da pilha; pilha vazia, cria um em branco | Sempre existe exatamente um destaque |
| `create(texto:origem:)` | Editor, Siri, Atalhos | Cria em destaque se não houver nenhum, senão guardado no topo da pilha | Limite de 3 ativos sem Pro; id único; texto ≤ 280 |
| `save(_:texto:)` | Editor, a cada 1s de silêncio | Grava o texto, atualiza `atualizadoEm`, atualiza a Live Activity e recarrega os widgets | Texto ≤ 280; gravar o mesmo texto é operação nula |
| `stash(_:)` | Botão "Guardar" | Move o destaque para o topo da pilha e abre um novo destaque em branco | Encerra a Live Activity antes de mudar o estado; barra o quarto ativo sem Pro |
| `promoteToFeatured(_:)` | Toque num item da pilha | Troca os dois estados numa gravação só | Nunca dois destaques; encerra a atividade do que sai |
| `reorder(from:to:)` | Arrasto na pilha | Reescreve `ordemPilha` de todos, de 0 em diante | Ordem sem buracos, que sobrevive ao relançamento |
| `archive(_:confirmingPrune:)` | Botão "Arquivar", swipe, Live Activity, widget, Siri | Encerra a atividade, cancela o aviso, grava `arquivadoEm`, promove o próximo, aplica a poda | Encerrar acontece **antes** de gravar o estado; poda só com confirmação |
| `pruneVictimText()` | Tela, antes de animar | Consulta **pura**: diz qual bilhete seria apagado se mais um fosse arquivado | Nenhum efeito colateral — perguntar não arquiva |
| `restore(_:)` | Swipe no arquivo | Devolve como guardado no topo, limpa `arquivadoEm` | Bloqueia se passar de 3 ativos sem Pro; nunca volta direto a destaque |
| `delete(_:)` | Menu •••, swipe | Encerra a atividade, cancela o aviso, apaga em definitivo, repõe o destaque se era ele | Hard delete; sempre sobra um destaque |
| `deleteAllArchived()` | "Apagar tudo" | Esvazia o arquivo | Não toca em ativos |
| `invariantViolations()` | Testes | Confere as três invariantes de estado do modelo | Usada ao fim de **toda** operação em **todos** os testes |

**Um caso que merece ser lido com atenção:** repor o destaque depois de guardar,
arquivar ou excluir **ignora o limite de 3 ativos**. É deliberado e está isolado
num método privado — deixar a pessoa sem destaque nenhum quebraria o app inteiro,
inclusive os widgets. A regra "sempre exatamente um destaque" vence a regra do
limite nesse instante.

### 3.2 `PinService` — o dono da Live Activity

`Packages/BilheteCore/Sources/BilheteCore/LiveActivity/PinService.swift`. É o
único lugar do app que fala com o ActivityKit, e o único que escreve `fixadoAte`
e `idAtividade`.

| Método | Quem dispara | O que faz |
|---|---|---|
| `fixar(_:)` | Botão "Fixar"; Controle "Refixar"; ação da notificação | Encerra qualquer atividade anterior, chama `Activity.request`, grava `fixadoAte = agora + 8h` e o `idAtividade`, agenda o aviso, marca que a pessoa já fixou uma vez e recarrega os widgets |
| `atualizar(_:)` | `BilheteStore.save` | `activity.update` **sem recriar** — o `idAtividade` não muda e as 8 horas não reiniciam sem a pessoa pedir |
| `soltar(_:)` | Guardar, promover outro, arquivar, excluir, botão "Soltar" | Encerra com `.immediate`, zera os dois campos e cancela o aviso. **Não arquiva** |
| `encerrarTodas(exceto:)` | Lançamento; antes de cada fixação | Garante no máximo uma atividade do app viva |
| `reconciliar(destaque:)` | Lançamento | Encerra atividades órfãs e limpa `fixadoAte`/`idAtividade` quando a atividade já morreu — por expiração ou porque o app foi encerrado antes de encerrá-la |

**Falhas:** `activitiesDisabled` quando a pessoa desligou Atividades ao Vivo nos
Ajustes do iPhone (a tela mostra a copy 15.6 com atalho para os Ajustes);
`requestFailed` para qualquer outra falha. Em nenhum dos dois casos o modelo
muda — `fixadoAte` permanece nulo.

### 3.3 `EntitlementStore` — o direito de compra

`Packages/BilheteCore/Sources/BilheteCore/Entitlement/EntitlementStore.swift`.

| Método | Quem dispara | O que faz |
|---|---|---|
| `carregar()` | Lançamento e abertura do paywall | Relê `currentEntitlements`, busca o produto, espelha o direito no cache e recarrega os widgets |
| `observar()` | `App.init` | `Task` de longa duração sobre `Transaction.updates` — captura compra em outro aparelho, Ask to Buy, código promocional e revogação |
| `comprar()` | Botão do paywall | `product.purchase()`, valida o `VerificationResult`, `finish()` obrigatório. Assinatura inválida não libera nada |
| `restaurar()` | "Restaurar compras" | `AppStore.sync()` seguido de `carregar()` |

**Perder o direito não apaga dado nenhum.** Os ativos acima de 3 e os arquivados
acima de 10 continuam lá, legíveis; o que volta a valer é o bloqueio de criação
de novos ativos e a fonte padrão. Há teste que prova isso com 5 ativos
preservados após a revogação.

### 3.4 `PaywallGate` — quando a compra pode aparecer

O paywall **nunca** aparece antes de a pessoa ter (a) criado um bilhete com texto
**e** (b) fixado ao menos uma vez. Antes disso, tocar numa capacidade Pro mostra
só o aviso "Isso é do Bilhete Pro / Uma compra só, pra sempre", sem oferecer a
compra. O motivo é de produto: o momento de valor é ver o próprio bilhete na tela
de bloqueio, e cobrar antes disso é cobrar por uma promessa que a pessoa ainda
não viu cumprida.

### 3.5 `ExpiryWarningScheduler` — o único aviso do produto

Agenda a notificação para `fixadoAte − 30 min`, com identificador derivado do id
do bilhete — é isso que faz refixar **substituir** o aviso em vez de empilhar.
Cancela ao soltar, arquivar, excluir ou trocar o destaque. Não agenda nada se a
preferência estiver desligada.

A copy tem duas variantes, e a escolha é feita com um fato, não com um palpite:
`WidgetCenter.currentConfigurations()` diz se a pessoa **tem** o widget de tela
de bloqueio instalado. Quem tem recebe o próprio texto do bilhete; quem não tem
recebe a variante que ensina a colocar o widget.

---

## 4. Mapa tela → dados

| Tela | Lê | Escreve | Por qual método |
|---|---|---|---|
| **10.1 Destaque** | `@Query` de todos os bilhetes, filtrando o destaque em memória; `Preferences` | `texto`, `estado`, campos de fixação | `save`, `stash`, `archive`, `delete`, `PinService.fixar/soltar` |
| **10.2 Pilha** | `@Query`, filtrando `guardado` | `estado`, `ordemPilha` | `promoteToFeatured`, `reorder`, `archive`, `delete` |
| **10.3 Concluídos** | `@Query`, filtrando `arquivado`; `Preferences.pro_desbloqueado` para a busca | `estado`, `arquivadoEm` | `restore`, `delete`, `deleteAllArchived` |
| **10.4 Ajustes** | `Preferences`; `EntitlementStore`; versão do bundle | Todas as preferências | Direto nas `Preferences`; `EntitlementStore.restaurar`; `BilheteExporter.writeFile` |
| **10.5 Paywall** | `EntitlementStore` (produto e preço do StoreKit) | `pro_desbloqueado`, via `EntitlementStore` | `comprar`, `restaurar` |
| **10.6 Boas-vindas** | `Preferences.boasvindas_concluida` | A mesma chave; semeia o primeiro bilhete | `ensureFeatured` + `save` |
| **10.7 Guia do widget** | — | `dica_widget_vista` | Sem porta de entrada desde a D-7; continua no código |
| **10.8 Como o Bilhete funciona** | — | nada | Nenhum: é só leitura (D-10) |

| Superfície | Lê | Escreve |
|---|---|---|
| **S1** `accessoryRectangular` | `@Query` do store compartilhado | nada — **não tem botão** |
| **S2** `accessoryInline` | idem | nada |
| **S3** `systemSmall` | idem | `archive`, pelo intent "Concluir" |
| **S4** `systemMedium` | idem | `archive`; "Fixar" abre o app, porque iniciar Live Activity exige foreground |
| **S5–S8** Live Activity | `ContentState` (texto e expiração) | `archive` e `soltar`, pelos intents |
| **S9** Controle "Refixar" | store compartilhado | `fixadoAte`, `idAtividade` |
| **S10** Controle "Novo bilhete" | — | `ensureFeatured`; abre o app |
| **S11** Notificação | — | `fixar`, pela ação "Refixar" |

**Todas as views de widget usam `@Query`.** App e widget são processos separados
com containers distintos: mudança feita por um é *remote change* para o outro, e
a observação direta de modelo não reage. A entrada de timeline é deliberadamente
**vazia** — se ela carregar o conteúdo, o bug volta.

---

## 5. Lógica por tela

### 10.1 Destaque

- **Abrir:** o app garante um destaque (promove da pilha ou cria em branco) e põe
  o cursor no campo. O foco é pedido **depois** que o campo existe na árvore de
  views; pedir no mesmo ciclo do primeiro render é ignorado em silêncio.
- **Digitar:** cada tecla reinicia um debounce de 1 segundo. Sair da tela, ir
  para background ou tocar em qualquer ação da barra grava na hora. A entrada é
  cortada em 280 caracteres; o contador aparece a partir de 240 e fica vermelho
  no limite. **Falha de gravação mantém o texto na tela** e mostra "Não consegui
  salvar agora / Seu texto continua aqui".
- **Guardar:** grava, encerra a Live Activity, move para o topo da pilha e abre
  um destaque em branco. Com 3 ativos e sem Pro, nada acontece e o caminho do Pro
  abre.
- **Fixar:** na primeira vez, mostra a explicação da permissão **antes** de o
  sistema perguntar; depois pede a permissão uma única vez. Fixado, o botão vira
  "Soltar" e um selo diz até quando. Atividades ao Vivo desligadas → copy 15.6
  com atalho para os Ajustes do iPhone.
- **Arquivar:** confere a poda **antes** de animar (mostrar o papel saindo e
  trazer de volta seria mentir). Sem poda pendente: háptico de sucesso, o papel
  desliza para baixo com leve rotação em 400 ms, e só então grava. Com redução de
  movimento, vira fade.
- **•••:** compartilhar e copiar entregam o **texto puro**, sem assinatura, sem
  marca e sem link do app. Excluir pede confirmação destrutiva.

### 10.2 Pilha

Lista por `ordemPilha`, com trecho e data relativa. Tocar promove e volta ao
destaque. Arrastar reordena e a ordem persiste. Swipe arquiva ou exclui. No
limite do plano grátis, um selo "3 de 3 PRO" no topo leva ao Pro.

### 10.3 Arquivo

Lista por `arquivadoEm` decrescente. A busca é capacidade Pro: sem Pro o campo
aparece **desabilitado com o selo**, porque esconder a capacidade seria esconder
o que o Pro vende. Restaurar volta como guardado no topo — e, se isso passar de 3
ativos sem Pro, **nada acontece** com o bilhete. "Apagar tudo" mostra a contagem
antes de apagar.

### 10.4 Ajustes

Aparência, fonte, texto pequeno e aviso; guia da tela de bloqueio; Bilhete Pro e
restaurar; exportar tudo; avaliar, suporte, feedback, privacidade e versão.
Mudar qualquer preferência visual recarrega os widgets. Escolher fonte Pro sem
Pro **não aplica** a mudança.

### 10.5 Paywall

Título, as cinco capacidades, o preço vindo do StoreKit e um botão. Sem produto
ou sem rede, mostra "Sem conexão / Preciso de internet pra buscar o preço" e o
botão fica desabilitado — nenhuma capacidade é liberada por engano.

### 10.6 e 10.7

Boas-vindas: uma frase, um botão, e o seed do primeiro bilhete com o texto de
exemplo **já selecionado**, para digitar substituir. Guia: três blocos — o
widget, o Controle, e por que o destaque sai da tela. Aparece como cartão
dispensável no rodapé do destaque depois da primeira fixação, ou inteiro a partir
dos Ajustes. O app nunca insiste mais de duas vezes.

---

## 6. Divergências em relação ao spec

### 6.1 Decisões de produto tomadas depois do spec v1.0

| # | Decisão | O que muda |
|---|---|---|
| **D-1** | **Sem CloudKit e sem sincronização** | Cai o item 10 da seção 3, o épico 8.8 como escrito, as regras 11.12 (estado da sincronização), 11.14 (conflito) e 11.15 (o que não sincroniza), as copies 15.11, 15.14 e 15.20, a linha de sincronização dos Ajustes e o risco R-9. O modelo da seção 7 **ficou idêntico**, para poder religar o sync depois. "Exportar tudo" virou o único backup fora do backup do iPhone e ganhou destaque nos Ajustes |
| **D-2** | **iPhone apenas** | Sem iPad, sem Mac Catalyst. O critério 8.8.1 ("aparece no iPad em 60s") deixou de existir junto com o sync |
| **D-3** | **R$ 19,90 de lançamento** | Substitui os R$ 29,90 da seção 5 e 7.4. O app nunca exibe preço fixo |
| **D-4** | **Só PT-BR e EN** | Confirma a seção 3; espanhol fora |
| **D-5** | **Links definitivos** | Suporte no Carrd, privacidade no Notion, ambos em `AppLinks.swift` |
| **D-6** | **Paleta nova: padrão Apple com azul do sistema** | Substitui a paleta inteira da seção 16.2. Fundo `#F2F2F7`/`#000000`, cartão `#FFFFFF`/`#1C1C1E`, marca `#007AFF`/`#0A84FF`, semânticas `systemRed` e `systemGreen`. Ícone regenerado em azul. **O que se perde:** o argumento de 16.2 de que o terracota distinguia o app da categoria — a aposta passou a ser parecer nativo em vez de parecer diferente. A metáfora de papel de 16.1 sobrevive na forma, não na cor |

### 6.1.1 Decisões nascidas do teste em aparelho (v1.2)

| # | Decisão | O que muda |
|---|---|---|
| **D-7** | **O app deixou de sugerir o widget de tela de bloqueio.** A tela 10.7 continua no código, sem porta de entrada. | Contraria a resposta que o spec dava ao "momento mais difícil": **sem o widget, o bilhete sai da tela sozinho depois de 12h.** O princípio P3 foi reescrito para "o bilhete nunca se perde", e a métrica M4 passou a medir o refixar em vez da adoção do widget. O que sustenta o produto agora é o par Controle + aviso de 30 minutos |
| **D-8** | **Seletor de idioma dentro do app.** | Amplia o critério 8.11.3. `sistema` continua o padrão. **A widget extension não é afetada** — é outro processo e segue o idioma do iPhone. A troca é feita marcando o `locale` em cada resolução de string: trocar o `Bundle.main` sozinho não bastava, porque `String(localized:)` resolve no instante da chamada |
| **D-9** | **"Arquivar" virou "Concluir"** e o primeiro bilhete **nasce vazio**. | A mesma ação tinha dois nomes (8.1 dizia "Arquivar", 8.4 dizia "Concluir"). O texto semeado, por ser conteúdo, ficava congelado no idioma da primeira abertura |
| **D-10** | **"Arquivo" virou "Concluídos"**, com acesso no topo ao lado da Pilha, contador em palavra, e a tela **"Como o Bilhete funciona"** (10.8). | O topo usa `ViewThatFits`: em tela estreita cai para ícone + número, em vez de truncar palavra no meio |
| **D-11** | **A Pilha lista o destaque no topo** e **tocar no fundo fecha o teclado**. | O bilhete em destaque não aparecia em lista nenhuma e parecia sumir quando a fixação expirava. O estado dele **não** mudou: continua `emDestaque`, e a regra 11.1 vale igual |
| **D-12** | **Refixar pela tela de bloqueio virou grátis.** O `RefixarBilheteIntent` não confere mais `temPro()`, e o paywall passou a listar "Criar bilhete pela Central de Controle" no lugar. | Corrige um buraco aberto pela D-7: sem o widget sugerido, refixar é o único caminho de volta em um toque quando a fixação expira, e cobrar por ele deixava o plano grátis sem rede de segurança — contra o princípio P5. Muda a matriz da seção 5 do spec, a assunção A-5 e a copy 15.18. Criar bilhete por Siri, Atalho ou Controle **continua Pro**. Coberto pelos testes `repinIsFree` e `createBySiriIsGated` |

### 6.1.2 Três bugs encontrados só em aparelho

Ficam registrados porque nenhum deles aparecia no simulador, e todos os três eram
de arquitetura, não de acabamento:

1. **Dois `ModelContainer` sobre o mesmo arquivo.** Os intents abriam um container
   novo a cada toque, enquanto o app usava o compartilhado — e `LiveActivityIntent`
   roda **dentro do processo do app**. O que o botão da tela de bloqueio gravava, a
   tela não via: "Concluir" e "Soltar" pareciam fazer a mesma coisa, e o bilhete
   parecia sumir. Corrigido usando o container compartilhado, mais uma releitura do
   arquivo quando o app volta ao primeiro plano.
2. **Botão de Live Activity só executa com `LiveActivityIntent`.** O `ConcluirBilheteIntent`
   era só `AppIntent`, e por isso o toque na tela de bloqueio não fazia nada.
3. **Foco não é teclado.** O layout decidia pela `@FocusState`, e com teclado físico
   — ou logo depois de o teclado descer — o campo continuava focado sem teclado na
   tela, deixando a barra de ações escondida. Agora o layout escuta
   `keyboardWillShow`/`keyboardWillHide` **e** o foco.

### 6.1.3 Três defeitos encontrados só na hora de publicar

Nenhum dos três quebrava o app, e nenhum aparecia em compilação nem em teste —
todos só se manifestaram na esteira de publicação, em 16/08/2026:

1. **`TARGETED_DEVICE_FAMILY` sobrescrito pelo XcodeGen.** O `project.yml` declarava
   `"1"` (iPhone) no `settings.base` do projeto, mas o XcodeGen escreve o padrão
   `"1,2"` do tipo de produto **dentro de cada target**, e ajuste de target vence
   ajuste de projeto. O binário saía anunciando suporte a iPad, e a validação da
   App Store recusou o envio exigindo as quatro orientações de multitarefa do
   iPad — que um app retrato de iPhone não tem. O sintoma anterior era o aviso de
   archive "All interface orientations must be supported unless the app requires
   full screen", fácil de descartar como inofensivo. Corrigido declarando
   `TARGETED_DEVICE_FAMILY: "1"` nas `settings.base` do target do app **e** da
   widget extension. Conferência: `xcodebuild -showBuildSettings … | grep
   TARGETED_DEVICE_FAMILY` precisa devolver um único `1`, e o `UIDeviceFamily` do
   `Info.plist` compilado precisa ser `{1}` nos dois bundles.
2. **Copy do produto de compra desatualizada.** O `Bilhete.storekit` ainda descrevia
   "refixar pela tela de bloqueio" como capacidade Pro, sobra de antes da D-12 — e é
   esse o texto que vai para o App Store Connect. As duas localizações foram
   reescritas para a lista real de capacidades pagas.
3. **Capturas da loja com canal alfa.** As peças geradas para a ficha vinham com
   canal de transparência, que o App Store Connect recusa no upload. Removido
   compondo sobre branco — as peças já eram opacas, então o resultado é idêntico
   pixel a pixel. Os originais ficaram em `app-store/prints para a loja/originais-com-alpha/`.

### 6.2 Divergências de implementação

| Onde | O spec diz | O que foi feito | Por quê |
|---|---|---|---|
| Nomes dos erros do store | `LimiteAtingido`, `PodaNecessaria` (13.1) | `BilheteStoreError.limitReached`, `.pruneRequired` | A regra 18.1 diz que fora da fronteira do store é inglês. Mapeamento registrado aqui |
| Nomes dos métodos do store | `criar`, `salvar`, `guardar`… (13.1) | `create`, `save`, `stash`, `promoteToFeatured`, `reorder`, `archive`, `restore`, `delete`, `deleteAllArchived` | Mesma regra 18.1, com o exemplo do próprio spec (`func archive(_ bilhete:)` grava `bilhete.arquivadoEm`) |
| Onde vivem os App Intents | "Todos no target principal" (13.3) vs. "BilheteCore/Intents" (4.6) | Em `BilheteCore`, linkado ao app **e** à extension | Cumpre L14 na substância (o código está no binário do app) e permite ao botão do widget enxergar o tipo sem duplicar arquivo, o que 18.3 proíbe |
| Consultas por estado | — | Filtragem em memória, não por `#Predicate` | O app é desenhado para 500 bilhetes; assim o comportamento não depende de como o SwiftData resolve enum em predicado |
| `ConcluirBilheteIntent` e poda | Aviso nominal antes de podar (11.4) | Arquiva com a poda já confirmada | O intent não tem tela para pedir confirmação, e um botão "Concluir" que não conclui é pior |
| `ArquivarBilheteIntent` | Não está na tabela 13.3 | Criado | A frase "Arquivar meu bilhete no Bilhete" está na copy 15.16. **Não** confere Pro: a matriz da seção 5 põe arquivar na coluna grátis |
| Aviso Pro no Controle | "Exibe o aviso 15.8 e abre o paywall ao tocar" (8.6.9) | Notificação local com a copy 15.8, que leva ao app | O Controle não tem UI para alerta (L10, L13). Mesma mecânica que o próprio spec usa para a falha de fixação |
| Botão "Fixar" do `systemMedium` | Widget interativo (S4) | É um `Link` que abre o app, não um `Button(intent:)` | Iniciar Live Activity exige foreground (L4): um intent falharia em silêncio |
| Acesso ao Arquivo | Só a partir dos Ajustes (design) | Também no menu ••• do destaque | Um toque a menos para a tela que a pessoa mais visita depois de arquivar |
| Chaves de preferência | 7 chaves (7.3) | 10 chaves | `insistencias_widget`, `ja_fixou_alguma_vez` e `permissao_notificacao_pedida` são necessárias para cumprir 9.4, 11.10 e 8.7.5 |
| Barra inferior em Dynamic Type grande | — | Empilha na vertical nos tamanhos de acessibilidade | Lado a lado, os rótulos viravam uma letra por linha, o que reprova a seção 17 |
| Copy em EN | A seção 15 define só parte | Traduzi o que faltava | Autorizado pelo Alexandre em 15/08/2026: rótulos de botão, títulos de tela, textos de acessibilidade e o guia da tela 10.7 |
| Copy 15.3 | "Nada arquivado ainda." | "Nada concluído ainda." | A tela mudou de nome (D-10); manter "arquivado" contradiria o título. O teste de copy literal foi atualizado **com o registro da divergência**, não afrouxado |
| Catálogo de strings | — | É **gerado** por `Scripts/make-strings.py` | Editar o `.xcstrings` à mão funciona até alguém rodar o script e sobrescrever — foi o que aconteceu uma vez com "Concluir". O script mora no repositório com esse aviso no cabeçalho |
| Xcode | 26.6 / Swift 6.3 (4.1) | 26.1.1 / Swift 6.2.1 | É o que está instalado. Nenhuma API da v1 depende de 26.6 |

### 6.3 Afordâncias que existem só em DEBUG

Duas, ambas compiladas fora do Release: `-BilheteCapturePaywall` e
`-BilheteCaptureSettings`, que abrem a tela direto para captura de imagem. Servem
ao print do App Store Connect e à comparação de paletas.

O `StoreKitTest` **não** é linkado ao app — só aos alvos de teste, que é onde ele
pertence. Tentar linká-lo ao app não compila, e é melhor assim: esse framework
num binário de loja é caminho curto para rejeição.

### 6.4 O que ainda não foi validado

Automatizado: 105 testes cobrem as 4 invariantes, as regras numéricas, a máquina
de estados inteira, o editor, o arquivo, o `PinService`, as restrições dos
widgets, os intents, o armazenamento, o StoreKit e a localização.

**Já validado em iPhone 13 mini**, entre 15 e 16/08/2026:

- Botões "Concluir" e "Soltar" da Live Activity acionados da tela de bloqueio, com
  o aparelho bloqueado, e o resultado refletido no app.
- Toque no corpo da Live Activity abrindo o app **no bilhete correspondente**.
- O Controle "Refixar bilhete" na tela de bloqueio: refixa e devolve o bilhete
  para a tela.
- O aviso de expiração chegando sozinho (sem confirmação de qual dos dois avisos
  disparou — ver abaixo).

**Falta validar em tela ou em aparelho:**

1. Diálogo nominal de poda com o arquivo cheio de 10 bilhetes.
2. Cronometragem da animação de encerramento contra os 600 ms, e o fallback de
   fade com redução de movimento.
3. Atualização do texto da Live Activity sem recriar a atividade; truncamento com
   280 caracteres em 393pt e 430pt; as três apresentações da Dynamic Island.
4. Widgets adicionados de fato: legibilidade em escala de cinza com papel de
   parede claro e escuro, a linha do `accessoryInline`, e o ciclo completo de
   concluir pelo widget e ver no app sem reiniciar.
5. O acionamento do Controle com o app **fechado** dentro dos 3 segundos, o Botão
   de Ação e o comando de voz da Siri.
6. Distinguir o aviso de 30 minutos do aviso de expiração: o telefone apitou, mas
   não ficou registrado qual dos dois foi, nem a ação "Refixar" da notificação.
7. Compra e cancelamento pelo botão do paywall, com a folha do sistema na tela.
   O TestFlight abre esse caminho: a compra em sandbox não cobra.
8. Os números da seção 17 medidos em iPhone 12: abertura < 1s, fixação < 2s,
   Controle < 3s, binário < 15 MB.
9. VoiceOver ponta a ponta.

Os itens 3, 4 e 5 **exigem aparelho real**; o resto é simulador.
