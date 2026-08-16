# Prompt de design — Bilhete

> **ATUALIZAÇÃO v1.1 — 15/08/2026.** Duas mudanças valem para todas as telas
> descritas abaixo:
>
> **1. Paleta nova (decisão D-6).** Ignore a paleta de areia e terracota citada
> mais adiante neste prompt. A paleta vigente é o padrão de app da Apple:
>
> | Papel | Claro | Escuro |
> |---|---|---|
> | Fundo do app | `#F2F2F7` | `#000000` |
> | Cartão | `#FFFFFF` | `#1C1C1E` |
> | Tinta | `#000000` | `#FFFFFF` |
> | Tinta secundária | `#6C6C70` | `#98989F` |
> | Hairline | `#E5E5EA` | `#38383A` |
> | Marca | `#007AFF` | `#0A84FF` |
> | Destrutivo | `#FF3B30` | `#FF453A` |
> | Sucesso / fixado | `#34C759` | `#30D158` |
>
> A metáfora de papel continua na **forma** — cartão, cantos arredondados,
> sombra mínima e difusa —, não na cor. A cor de marca aparece pouco: estado
> fixado, botão primário do paywall, seletor ativo dos Ajustes. Nunca em erro
> nem em confirmação destrutiva.
>
> **2. Sem sincronização (decisão D-1).** A tela de Ajustes **não** tem linha de
> estado da sincronização. No lugar dela há **"Exportar tudo"**, com a nota
> "Seus bilhetes ficam só neste iPhone. Exportar é o seu backup."
>
> O app é **iPhone apenas** (decisão D-2) — não desenhe layout de iPad.
>
> **3. Mudanças de v1.2 (16/08/2026), vindas do teste em aparelho:**
>
> - A tela **10.3 chama-se "Concluídos"**, não "Arquivo", e é alcançada pelo
>   topo da tela 10.1, ao lado da Pilha — não pelo menu `•••`.
> - A barra inferior de 10.1 é **Guardar · Fixar/Soltar · Concluir** (o antigo
>   "Arquivar"), com uma linha de ajuda no rodapé que some depois do primeiro uso.
> - O topo de 10.1 mostra o contador da pilha em palavra ("3 bilhetes") e cai
>   para ícone + número em tela estreita.
> - A **Pilha (10.2) lista o bilhete em destaque no topo**, com o selo "na tela",
>   sem arrasto e sem swipe.
> - Existe uma tela nova, **10.8 "Como o Bilhete funciona"**, alcançada pelos
>   Ajustes: explica Fixar, Guardar, Concluir e Soltar por significado.
> - Os Ajustes têm **Idioma** (sistema/português/inglês) e **não** têm mais a
>   entrada do guia do widget.
> - O primeiro bilhete **nasce vazio**: o texto de exemplo é placeholder.


**Como usar:** cole todo o conteúdo abaixo da linha divisória no Claude Design (ou no Claude com pedido de artifact HTML). Ele foi escrito a partir das seções 10 (inventário de telas), 15 (copy) e 16 (direção visual) do `SDD-Bilhete.md` v1.0 e não contém nenhuma tela nem nenhuma copy que não estejam no spec.

**Dica de execução:** peça primeiro o **bloco 1** (fundações + tela 10.1) e valide a direção visual antes de mandar o resto. Telas geradas em cima de uma direção não aprovada custam mais para corrigir do que para refazer.

---

Você vai desenhar todas as telas e superfícies de um app iOS chamado **Bilhete**.

## O que é o app

Bilhete é o bilhete de geladeira do seu iPhone. A pessoa escreve uma coisa que precisa lembrar, ela fica grande na tela de bloqueio, e ela arquiva quando resolveu. Um bilhete por vez em destaque; os outros ficam numa pilha atrás.

É um **app consumer mobile em iOS 18+, sem navegação lateral**. Não use menu lateral, sidebar, dashboard ou qualquer padrão de painel administrativo em nenhuma tela.

## Princípios que decidem qualquer dúvida

1. **Uma coisa por vez.** Existe sempre exatamente um bilhete em destaque, e é ele que aparece. Tudo o mais está guardado. Não desenhe lista de notas como tela principal.
2. **Escrever custa um toque.** Do ícone ao cursor piscando não pode haver tela intermediária, modal nem dica.
3. **O bilhete nunca some sozinho.** A Live Activity expira em 12h por imposição do sistema, mas o widget da tela de bloqueio é permanente.
4. **Arquivar é o gesto de encerramento.** Deliberado, satisfatório e reversível. Não é sinônimo de excluir.
5. **Grátis é útil de verdade.** Escrever, fixar, ver e arquivar funcionam sem pagar. O paywall vende capacidade, nunca o básico.

---

# Direção visual

## Metáfora

**Papel.** O bilhete é um pedaço de papel: fundo levemente quente, cantos arredondados generosos, sombra mínima e difusa, sem borda dura. O app é o imã que segura o papel — quem tem que aparecer é o papel, não a moldura. A tela principal deve parecer uma folha, não um formulário.

## Paleta

Separação estrita entre cor de marca e cor semântica. A semântica é reservada para significado e **nunca** é usada como decoração.

| Papel | Claro | Escuro |
|---|---|---|
| Fundo do app | `#F2EFE9` (areia) | `#121212` |
| Papel (cartão do bilhete) | `#FBF9F5` | `#1E1D1B` |
| Tinta (texto principal) | `#1B1A18` | `#F2EFE9` |
| Tinta secundária | `#6E6A62` | `#9C978D` |
| Hairline / divisória | `#E3DED4` | `#2C2A27` |
| **Destaque (marca)** | `#C86A2E` (terracota) | `#E08A4C` |
| Semântica — destrutivo | `#B3261E` | `#F2836A` |
| Semântica — sucesso / fixado | `#3E7C4F` | `#6FAE7E` |

O terracota puxa de cerâmica e barro, não do amarelo de post-it. Ele aparece **pouco**: no estado fixado, no botão primário do paywall e no seletor ativo dos Ajustes. **Nunca** use terracota para erro ou ação destrutiva.

Entregue **modo claro e modo escuro** de todas as telas.

## Tipografia

- Sistema, SF Pro. O corpo do bilhete usa `.title2`, peso regular, entrelinha +4pt. É o texto mais importante do app e precisa parecer escrito, não catalogado.
- Opções de fonte disponíveis ao usuário Pro: padrão (SF Pro), mono (SF Mono), serifada (New York).
- Grid de 4pt, margem lateral de 20pt.
- Dynamic Type até `.accessibility3` sem quebrar o layout — mostre pelo menos a tela principal nesse tamanho.

## Movimento

Um único momento de animação com identidade: **arquivar**. O papel desliza para baixo e some com leve rotação, em ~400 ms, com feedback háptico de sucesso. Todo o resto usa as transições padrão do iOS. Se você entregar estados de animação, entregue esse.

## Material

Use `Liquid Glass` nativo do iOS 26 em barras e sheets, sem customização. Não replique o material à mão nem invente blur.

---

# Telas do app

Desenhe exatamente estas sete telas. Não invente nenhuma outra.

## 10.1 — Destaque *(tela inicial)*

O coração do app. Abre direto aqui, com o cursor ativo.

- **Corpo:** o bilhete em destaque, editável em linha, sobre o cartão de papel ocupando a maior parte da tela.
- **Topo:** acesso à Pilha (com contador de guardados), menu `•••` (Excluir · Compartilhar · Copiar), acesso aos Ajustes.
- **Barra inferior, três ações:** **Guardar** · **Fixar** (vira **Soltar** quando fixado, e **Refixar** quando expirado) · **Arquivar**.
- **Contador de caracteres:** aparece a partir de 240; fica vermelho em 280, que é o limite.
- **Selo de fixado:** quando fixado, um selo discreto em verde-sucesso mostra até quando ("na tela até 15:30").

**Estados a entregar:**

| Estado | Conteúdo |
|---|---|
| Vazio | Placeholder: `Escreva o que você não quer esquecer` |
| Escrevendo | Texto médio, contador oculto |
| Perto do limite | 265 caracteres, contador visível |
| Fixado | Selo verde, botão como "Soltar" |
| Expirado | Botão como "Refixar", sem selo |
| Erro de gravação | `Não consegui salvar agora` / `Seu texto continua aqui. Vou tentar de novo em instantes.` — o texto **continua na tela** |
| Live Activity indisponível | `Não dá pra fixar agora` / `As Atividades ao Vivo estão desligadas para o Bilhete nos Ajustes do iPhone.` · Botão `Abrir Ajustes` |
| Com cartão de dica | Cartão dispensável no rodapé levando à tela 10.7 |

**Gating:** tocar em "Guardar" com 3 bilhetes ativos e sem Pro abre o paywall (10.5).

**Não existe botão de salvar.** A gravação é automática.

## 10.2 — Pilha

- **Mostra:** os bilhetes guardados, na ordem definida pela pessoa, cada um com um trecho do texto e a data relativa.
- **Ações:** tocar promove a destaque · arrastar reordena · swipe arquiva ou exclui.
- **Contador:** "3 de 3" quando sem Pro e no limite, com selo Pro ao lado.

**Estados:** lista com 4–5 itens · **vazia:** `Nada guardado.` / `O que estiver em destaque aparece na sua tela.` · no limite grátis, com o contador destacado.

## 10.3 — Arquivo

- **Mostra:** arquivados do mais recente para o mais antigo, com data. Campo de busca no topo. Rodapé com "Apagar tudo".
- **Ações:** restaurar · excluir · apagar tudo · buscar.

**Estados a entregar:**

| Estado | Conteúdo |
|---|---|
| Lista | 6–8 itens com datas variadas |
| Vazio | `Nada arquivado ainda.` / `Bilhete resolvido é bilhete arquivado.` |
| Busca sem resultado | — |
| Busca bloqueada (sem Pro) | Campo de busca desabilitado com selo Pro |
| No limite grátis | Contador "10 de 10" |
| Aviso de poda | `Seu arquivo está cheio` / `Sem o Pro cabem 10 bilhetes no arquivo. Arquivar este apaga "comprar pão" de vez.` · Botões: `Arquivar mesmo assim` · `Ver o Pro` · `Cancelar` |
| Confirmação de exclusão | `Excluir este bilhete?` / `Não dá pra desfazer.` · `Excluir` · `Cancelar` |

## 10.4 — Ajustes

Lista em grupos, no estilo nativo do iOS. **Sem sidebar.**

- **Aparência** — sistema / claro / escuro
- **Fonte** — padrão / mono / serifada *(selo Pro; escolher outra sem Pro abre o paywall)*
- **Texto pequeno** — toggle
- **Avisar antes de expirar** — toggle
- **Como colocar na tela de bloqueio** — leva à 10.7
- **Estado da sincronização** — `Sincronizando com o iCloud` · `Sincronização desligada` · `Não consegui sincronizar`
- **Bilhete Pro** — abre o paywall, ou vira `Bilhete Pro ✓` quando ativo
- **Restaurar compras**
- **Avaliar** · **Enviar feedback** · **Sobre** e versão

**Estados:** sem Pro (com selos) · com Pro · sincronização em cada um dos três estados.

## 10.5 — Bilhete Pro *(paywall, modal)*

Um produto, um preço, um botão. Nada de comparação de planos, nada de contagem regressiva, nada de "mais popular".

- **Título:** `Bilhete Pro` / `Uma compra. Pra sempre.`
- **As cinco capacidades, nesta ordem:**
  1. `Bilhetes sem limite`
  2. `Arquivo sem limite, com busca`
  3. `Refixar pela tela de bloqueio, num toque`
  4. `Ei Siri, e Atalhos`
  5. `Escolher a fonte`
- **Preço:** exibido como `R$ 29,90` (vem do StoreKit em produção, nunca fixo no código)
- **Botão primário em terracota** · `Restaurar compras` como link discreto · links de termos e privacidade no rodapé

**Estados:** carregando o produto · pronto para comprar · comprando · concluído · **sem rede:** `Sem conexão` / `Preciso de internet pra buscar o preço. Tente de novo daqui a pouco.` com o botão desabilitado.

## 10.6 — Boas-vindas *(uma tela só, primeira execução)*

- `Bilhete` / `Um recado por vez, na sua tela de bloqueio.`
- Botão único: `Escrever o primeiro`

Uma tela. Não faça carrossel de cinco telas — isso viola o princípio 2.

## 10.7 — Como colocar na tela de bloqueio *(instrucional)*

Três blocos ilustrados, com desenho de tela dentro de cada um:

1. **Adicionar o widget na tela de bloqueio** — é o que faz o bilhete ficar pra sempre
2. **Adicionar o Controle** no lugar da lanterna ou da câmera — refixa em um toque
3. **O que é a Live Activity** e por que ela expira em 12 horas

Aparece de dois jeitos: como **cartão dispensável no rodapé** da tela 10.1, e como **tela cheia** a partir dos Ajustes. Entregue as duas apresentações.

---

# Superfícies do sistema

Estas não são telas do app, mas são onde o produto realmente vive. Desenhe todas, **em cima de um mockup de tela de bloqueio de iPhone com foto de fundo** para dar contexto real.

## S1 — Widget de tela de bloqueio `accessoryRectangular` (~172×76pt)

Até 3 linhas do bilhete, truncadas com reticências.

**Restrição obrigatória, não negociável:** o iOS força modo `vibrant` nos widgets de tela de bloqueio — **o sistema dessatura tudo para escala de cinza e não há como desativar.** Portanto:

- **Nenhuma decisão visual pode depender de cor.** Faça hierarquia com **peso e opacidade**, nunca com matiz.
- Desenhe este widget **em escala de cinza** e mostre como ele fica sobre fundo claro e sobre fundo escuro.
- **Sem botão nenhum.** (Botão em widget de tela de bloqueio só executa depois do desbloqueio e não há como reverter o estado visual se o desbloqueio for cancelado.)
- Estado vazio: `Sem bilhete`

## S2 — Widget de tela de bloqueio `accessoryInline`

Uma linha, acima do relógio. Mesma restrição de escala de cinza. Sem botão.

## S3 — Widget de tela de início `systemSmall`

Aqui **pode ter cor** e **pode ter botão**. Texto do bilhete + um botão "Concluir".

## S4 — Widget de tela de início `systemMedium`

Texto do bilhete + botões "Concluir" e "Fixar".

## S5 — Live Activity na tela de bloqueio (371–408 × 84–160pt, alvo ~120pt)

- Fundo de papel translúcido, texto em `.title3` peso medium, dois botões de ícone alinhados à direita: **Concluir** e **Soltar**.
- Peso de texto medium ou maior em tudo — exigência da Apple para legibilidade em Always-On.
- Não existe teclado nem campo de texto aqui: a edição só acontece no app.
- Mostre com texto curto (~40 caracteres) e com texto no limite (280, truncado).

## S6 — Dynamic Island compacta (~62×37pt)

Símbolo à esquerda, 2–3 primeiras palavras à direita. **Fundo preto opaco do sistema — não aceita fundo personalizado.**

## S7 — Dynamic Island mínima (~37–45pt)

Só o símbolo.

## S8 — Dynamic Island expandida (até 408×160pt)

Texto do bilhete + os dois botões.

## S9 — Controle "Refixar bilhete"

`ControlWidgetButton` com símbolo `pin.fill`, tint terracota.

**Restrição:** o texto de título e valor **fica oculto na tela de bloqueio** e nos tamanhos pequenos da Central de Controle. O Controle precisa ser inequívoco **só pelo símbolo**. Mostre-o nas três superfícies: Central de Controle, tela de bloqueio (no lugar da lanterna) e Botão de Ação.

## S10 — Controle "Novo bilhete"

`square.and.pencil`, tint terracota. Mesma restrição. Não pode ser confundível com o S9.

## S11 — Notificação de expiração

Duas variantes:

- **Com widget já adicionado:** `Seu bilhete sai da tela em 30 minutos` / *(o texto do bilhete)* · ação `Refixar`
- **Sem widget:** `Seu bilhete sai da tela em 30 minutos` / `Com o widget na tela de bloqueio ele fica pra sempre. Toque pra ver como.`

---

# Fluxo entre as telas

Desenhe as telas como um fluxo, não soltas. A sequência de primeiro uso é a que mais importa, porque é ela que decide a retenção:

1. Instala e abre → **10.6 Boas-vindas**, uma tela, um botão
2. → **10.1 Destaque**, com o texto de exemplo já preenchido e selecionado; digitar substitui
3. Escreve o primeiro bilhete
4. Toca em **Fixar** → o sistema pede permissão: `Pra deixar o bilhete na sua tela de bloqueio, o iPhone precisa da sua permissão. É só uma vez.`
5. → cartão de dica **10.7** aparece no rodapé
6. Bloqueia o telefone e vê o bilhete em **S1 + S5** — **este é o momento de valor**
7. Só a partir daqui o paywall **10.5** pode aparecer

E o fluxo de exceção, que é a razão de existir do Controle:

- O destaque expira → **S11** notificação → ou toca em "Refixar", ou aciona o **S9** Controle direto da tela de bloqueio → volta a ficar fixado
- Em todos os casos, **S1 continua exibindo o bilhete**. A pessoa nunca perde a informação; perde só o destaque.

---

# Copy

Toda a copy deste prompt é **texto final em português do Brasil**, não placeholder. Use exatamente como está escrita, sem reescrever, sem "melhorar", sem adicionar exclamação e sem emoji.

O tom é de pessoa para pessoa, em português falado. Frases curtas. Sem "otimize seu fluxo de produtividade", sem gerúndio de call center. O app fala como alguém que deixou um bilhete na sua geladeira — porque é exatamente isso que ele é.

Onde você precisar de texto de exemplo dentro dos bilhetes (para preencher listas e mockups), use estes, que são o uso real do produto:

- `comprar pão`
- `ligar pra dentista até sexta`
- `levar a Sofia no inglês às 14h`
- `boleto do condomínio vence dia 10`
- `a Dona Maria vem terça de manhã`
- `não esquecer o carregador`

---

# O que entregar

1. **Modo claro e modo escuro** de todas as sete telas.
2. As **onze superfícies do sistema**, sobre um mockup real de tela de bloqueio de iPhone com foto de fundo.
3. Os **estados** listados em cada tela — vazio, erro e gating são tão importantes quanto o estado feliz, e são justamente os que costumam ficar de fora.
4. A tela 10.1 em **Dynamic Type no maior tamanho de acessibilidade**, provando que o layout não quebra.
5. Uma **folha de estilo**: paleta aplicada, escala tipográfica, espaçamentos, componentes recorrentes (cartão de papel, linha de lista, selo Pro, botão da barra inferior).

Se algo neste prompt entrar em conflito com o que parece uma boa prática genérica de design de app, **siga este prompt** — as restrições aqui vêm de limitações reais e documentadas da plataforma iOS, não de preferência estética.
