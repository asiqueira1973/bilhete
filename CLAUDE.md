# Bilhete — instruções do projeto

Este arquivo é lido automaticamente a cada sessão. Ele resume as regras permanentes do projeto. **A fonte de verdade é o `SDD-Bilhete.md`** — em qualquer divergência, o spec vence, e este arquivo deve ser corrigido.

## Decisões tomadas depois do spec v1.0 (elas vencem o spec)

Decididas por Alexandre em 15/08/2026, antes da primeira linha de código. O `SDD-Bilhete.md` não foi reescrito; a lista completa das consequências está na seção de divergências do `DOCUMENTACAO-TECNICA.md`.

| # | Decisão | O que muda no spec |
|---|---|---|
| **D-1** | **Sem CloudKit e sem sincronização.** SwiftData 100% local no container do App Group. | Cai o item 10 da seção 3, o épico 8.8 como escrito, as regras 11.12, 11.14 e 11.15, as copies 15.11, 15.14 e 15.20, a linha "Estado da sincronização" de 10.4 e o risco R-9. O modelo da seção 7 **fica idêntico** (sem `Array`/`Set`, sem `.unique`, tudo opcional ou com default, `VersionedSchema` desde o dia 1) para poder ligar o sync depois sem migração pesada. "Exportar tudo" (14.2) vira o único caminho de backup fora do backup do iPhone. |
| **D-2** | **iPhone apenas.** | Cai iPad e Mac Catalyst (Q-5, assunção A-10). |
| **D-3** | **Preço de lançamento R$ 19,90.** | Substitui os R$ 29,90 da seção 5 e da 7.4. O app nunca exibe preço fixo — sempre o do StoreKit (Q-1). |
| **D-4** | **Só PT-BR e EN.** | Confirma a seção 3 item 13; espanhol fica fora (Q-2). |
| **D-5** | **Links definitivos:** suporte `https://suportedablab.carrd.co/`, privacidade no Notion padrão da Dab Lab. | Resolve Q-3. Centralizados em `AppLinks.swift`. |
| **D-7** | **O app deixou de sugerir o widget de tela de bloqueio.** A entrada dos Ajustes e o cartão do rodapé saíram; a tela 10.7 continua no código, sem porta de entrada. O caminho padrão passa a ser o destaque de 12h. | Contraria a resposta que o spec dava ao "momento mais difícil" (seção 2) e ao princípio P3: **sem o widget, o bilhete some da tela sozinho depois de 12h.** A aposta é que instalar widget é mais difícil do que refixar. O que sustenta o produto agora é o par Controle (refixa num toque, sem abrir o app) + aviso 30 minutos antes. Se a métrica M4 (spec 21) não puder mais ser medida, é consequência disto. Alexandre, testando no aparelho em 15/08/2026. |
| **D-8** | **Seletor de idioma dentro do app** (Ajustes → Idioma: Sistema / Português / Inglês). | Amplia o critério 8.11.3, que mandava seguir só o idioma do aparelho. `sistema` continua sendo o padrão. **A widget extension não é afetada** — é outro processo e segue o idioma do iPhone. |
| **D-9** | **"Arquivar" passou a se chamar "Concluir" no app**, igual ao botão da Live Activity. E o **primeiro bilhete nasce vazio**, sem o texto de exemplo da seção 7.7. | A mesma ação tinha dois nomes (8.1 dizia "Arquivar", 8.4 dizia "Concluir") e isso confundia — o próprio Alexandre perguntou a diferença entre Guardar e Arquivar. O texto semeado, por ser **conteúdo**, ficava congelado no idioma da primeira abertura e ainda obrigava a apagar o exemplo antes de escrever; o placeholder faz o mesmo papel e acompanha o idioma. A tela "Arquivo" continua se chamando Arquivo — é o lugar, não a ação. |
| **D-10** | **"Arquivo" virou "Concluídos"**, com acesso no topo ao lado da Pilha (saiu do menu •••), contador da pilha com palavra ("3 bilhetes"), e uma tela **"Como o Bilhete funciona"** nos Ajustes. | Renomear alinha o lugar à ação que leva até ele (D-9). A tela de conceitos existe porque a dica de rodapé some depois do primeiro uso e as ações continuavam parecendo iguais — ela explica Fixar, Guardar, Concluir e Soltar por significado, e diz explicitamente que o botão "Concluir" da tela de bloqueio é a mesma ação de Concluir. Adapta as copies 15.3 ao nome novo. Alexandre, testando no aparelho em 15/08/2026. |
| **D-11** | **A Pilha lista o bilhete em destaque no topo**, com o selo "na tela", e **tocar no fundo da tela do destaque fecha o teclado**. | O bilhete em destaque não aparecia em lista nenhuma: quando a fixação expirava, parecia ter sumido do app. Ele continua com estado `emDestaque` — a regra 11.1 não muda —, é só a lista que passou a mostrá-lo, sem arrastar e sem swipe. O toque no fundo resolve o beco sem saída de quem abre o teclado num bilhete vazio: não havia o que rolar para dispensar, nem botão de saída. Alexandre, testando no aparelho em 15/08/2026. |
| **D-12** | **Refixar pela tela de bloqueio virou grátis.** O Controle "Refixar bilhete" não confere mais o direito Pro. O paywall parou de vendê-lo e passou a listar "Criar bilhete pela Central de Controle". | Corrige um buraco criado pela D-7: sem o widget sugerido, refixar é o único caminho de volta em um toque quando a fixação expira — e cobrar por ele deixava o plano grátis sem rede de segurança, contra o princípio P5. Muda a matriz da seção 5, a assunção A-5 e a copy 15.18. Criar bilhete pela Siri, Atalho ou Controle continua Pro. Alexandre, testando o Controle no aparelho em 16/08/2026. |
| **D-6** | **Paleta nova: padrão de app da Apple com azul do sistema.** Fundo agrupado `#F2F2F7` / `#000000`, cartão `#FFFFFF` / `#1C1C1E`, marca `#007AFF` / `#0A84FF`, destrutivo `systemRed`, sucesso `systemGreen`. Ícone regenerado em azul. | Substitui a paleta inteira da seção 16.2. Motivo: a paleta de areia e terracota lia como "apagada" — fundo e papel a 4% de distância. **O que se perde:** o argumento de 16.2 de que o terracota distinguia o app da categoria; a aposta passa a ser parecer nativo em vez de parecer diferente. O estado "fixado" continua na cor de marca, como 16.2 manda. A metáfora de papel da 16.1 permanece na forma (cartão, cantos, sombra), não mais na cor. **Nada disso aparece no widget de tela de bloqueio**, que é escala de cinza forçada (L8). |

## O que é

App iOS que deixa uma nota na tela de bloqueio. Um bilhete em destaque por vez; os outros ficam numa pilha atrás. SwiftUI, SwiftData **local no App Group**, ActivityKit, WidgetKit, App Intents, StoreKit 2. Sem backend e **sem sincronização**.

- Bundle: `com.dablab.bilhete` · App Group: `group.com.dablab.bilhete`
- iPhone apenas (`TARGETED_DEVICE_FAMILY = 1`). Sem iPad, sem Mac Catalyst.
- Deployment target **iOS 18.0** (os Controles da Central de Controle exigem 18+)
- Compilar com Xcode 26+ e SDK do iOS 26 — obrigatório para submissão desde 28/04/2026

## Princípios de desempate (seção 0 do spec)

1. **Uma coisa por vez** — exatamente um bilhete em destaque, e é ele que aparece na tela.
2. **Escrever custa um toque** — do ícone ao cursor não pode haver nada no meio.
3. **O bilhete nunca some sozinho** — a Live Activity expira, o widget não.
4. **Arquivar é o gesto de encerramento** — deliberado, satisfatório, reversível. Não é excluir.
5. **Grátis é útil de verdade** — escrever, fixar, ver e arquivar são grátis para sempre.

## Convenções de código

**Idioma.** Camada de dados em **português**: classes `@Model`, propriedades, enums e seus casos (`bilhete.texto`, `estado`, `arquivadoEm`), em `lowerCamelCase` no Swift. Todo o resto — nomes de arquivo, tipos de view, funções de UI, variáveis locais, testes — em **inglês**. A fronteira é o `BilheteStore`: `func archive(_ bilhete: Bilhete)` grava `bilhete.arquivadoEm`.

**Comentários.** Toda função, intent, view model e provider de widget leva comentário de cabeçalho **em português** dizendo o que faz, o que recebe, o que devolve e **qual regra do spec implementa, com o número da seção**. Lógica não óbvia leva comentário inline explicando a **intenção**, nunca a sintaxe.

```swift
/// Arquiva o bilhete e promove o próximo da pilha a destaque.
/// Encerra a Live Activity e cancela o aviso antes de mudar o estado (regras 11.6 e 11.7).
/// Aplica a poda do arquivo do plano grátis (regra 11.4).
func archive(_ bilhete: Bilhete) throws {
    // encerra antes de gravar: atividade órfã deixaria o texto na tela
    // de bloqueio sem dono (regra 11.6)
    pinService.soltar(bilhete)
```

**Escrita.** Nenhuma view escreve no `ModelContext` direto. Todo write passa pelo `BilheteStore` — as invariantes 11.1, 11.3, 11.4 e 11.6 são transacionais e precisam de um só dono.

**Strings.** Nenhuma string fixa no código. Tudo em String Catalog, PT-BR e EN. A copy final está na seção 15 do spec — é texto definitivo, não placeholder.

Onde a seção 15 **não** define a versão EN (rótulos de botão, títulos de tela, textos de acessibilidade), traduza direto e siga em frente — decisão do Alexandre em 15/08/2026, não precisa perguntar. Registre a tradução na seção de divergências do `DOCUMENTACAO-TECNICA.md`.

**Estrutura.** Módulo por feature. Tudo compartilhado com a widget extension vive no package `BilheteCore` — nunca duplique arquivo entre targets.

## Regras que não podem ser quebradas

Estas vêm de limitações documentadas da plataforma, não de preferência. Não "melhore" nenhuma delas.

- **Proibido `Array` ou `Set` de primitivos em classes `@Model`.** Regressão do iOS 26.1 converte para `Transformable` e causa falha de migração (`NSCocoaErrorDomain 134140`). Sem correção confirmada. Vale mesmo sem iCloud (D-1): a falha de migração é local. Há build phase que quebra o build. (spec 4.3, risco R-1)
- **Proibido `@Attribute(.unique)`.** Unicidade em código, regra 11.13. Mesmo sem CloudKit (D-1), o schema é mantido compatível com sync para não fechar a porta da v2.
- **Proibido botão em widget de tela de bloqueio.** Com o aparelho bloqueado o intent só executa após o desbloqueio, e não há API pra reverter o estado visual se a pessoa cancelar. Ação interativa vive nos Controles e nos widgets de tela de início. (L9, regra 11.9)
- **Widget de tela de bloqueio é escala de cinza forçada** (modo `vibrant`, sem opção). Hierarquia por peso e opacidade, nunca por cor. (L8)
- **Sempre `@Query` nas views de widget**, nunca `@State` populado à mão. App e widget são processos separados; mudança do widget é *remote change* pro app e a observação direta não reage. (spec 4.5 item 4)
- **Iniciar Live Activity exige foreground.** De background retorna `ActivityAuthorizationError.visibility`. Renovação só por ação do usuário: Controle, Botão de Ação, Atalho ou Siri. (L4, L5)
- **`perform()` de Controle completa de forma síncrona.** `ForegroundContinuableIntent` não é suportado em Controle. (L13)
- **Toda frase de `AppShortcut` contém `\(.applicationName)`**, senão não é registrada. Todos os `AppIntent` ficam no **target principal**, não na extension. (L14)
- **Máximo uma Live Activity do app por vez** (regra 11.6) e **máximo um bilhete em destaque** (regra 11.1).

## Números — todos vêm da seção 11, nenhum se infere

| | |
|---|---|
| Texto do bilhete | 280 caracteres (contador a partir de 240) |
| Bilhetes ativos | 3 sem Pro · ilimitado com Pro (arquivados não contam) |
| Arquivo | 10 sem Pro (poda o mais antigo, com confirmação) · ilimitado com Pro |
| Duração da fixação | 8h |
| Aviso de expiração | 30 min antes |
| Debounce de gravação | 1s |
| Preço | R$ 19,90 vitalício (lançamento, D-3) — `com.dablab.bilhete.pro` |

## Escopo

Só a seção 3 "Dentro da v1". **Nada da seção 28** (roadmap): bilhete compartilhado, prazo e recorrência, bilhete por contexto, renovação automática por push, UI de Apple Watch, temas.

## Antes de dar um épico por pronto

Todos os critérios de aceite dele, na seção 8. Sem exceção.

**Não pare entre um épico e outro esperando aprovação.** Valide os critérios, reporte o resultado e siga para o próximo. Só interrompa quando houver decisão a tomar — item da seção 25, divergência do spec, ou trade-off que muda o produto. Decisão do Alexandre em 15/08/2026.

## Ao mudar qualquer coisa

Atualize o `DOCUMENTACAO-TECNICA.md` **no mesmo commit**, incluindo a seção de divergências em relação ao spec.

## Diante de dúvida

Se a dúvida for de UX, copy ou trade-off → resolva pelos 5 princípios acima.
Se for um item da **seção 25 (perguntas abertas Q-1 a Q-6)** → **pergunte, não assuma.**
