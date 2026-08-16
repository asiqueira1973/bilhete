# App Store Connect — Bilhete

Pacote pronto para colar. Gerado a partir do `SDD-Bilhete.md` v1.2 e do código
como ele ficou. Todos os campos de texto foram medidos com o script de limites —
o resultado está no fim do documento.

**Identificadores reais deste app** (conferidos no `Bilhete.xcconfig` e nos
entitlements, não presumidos):

| | |
|---|---|
| Bundle ID do app | `com.dablab.bilhete` |
| Bundle ID da extension de widgets | `com.dablab.bilhete.widgets` |
| App Group | `group.com.dablab.bilhete` |
| Produto de compra no app | `com.dablab.bilhete.pro` |
| Team ID | `XGZW6Y6K25` |
| Versão / build | 1.0 (1) |
| Deployment target | iOS 18.0, iPhone apenas |

> **Cuidado com o `.pro`:** ele é o **identificador do produto de compra**, não o
> Bundle ID do app. Quem registra `com.dablab.bilhete.pro` como App ID no portal
> perde o identificador e depois não consegue usá-lo na compra. O App ID é
> `com.dablab.bilhete`.

---

## 0. developer.apple.com — o que conferir antes

Como a assinatura do projeto é automática e o app já roda no seu iPhone, o Xcode
**já criou** quase tudo. Aqui você confere, não cria.

**Certificates, Identifiers & Profiles → Identifiers → App IDs**

1. `com.dablab.bilhete` deve existir, do tipo App (explícito).
   Capability marcada: **App Groups**. Só ela.
2. `com.dablab.bilhete.widgets` deve existir, também com **App Groups**.

**Identifiers → App Groups**

3. `group.com.dablab.bilhete` deve existir e estar associado aos dois App IDs
   acima. É por ele que o app e os widgets abrem o mesmo banco — se estiver
   errado, o widget aparece vazio.

**O que NÃO precisa ser ligado** (marcar por precaução aqui custa caro depois,
porque cada capability extra vira um entitlement que a App Review pode
questionar):

- Push Notifications — o aviso de expiração é notificação **local**; a Live
  Activity nunca é atualizada por push (`NSSupportsLiveActivitiesFrequentUpdates`
  está `false`).
- SiriKit — App Intents modernos não usam a capability de Siri.
- iCloud / CloudKit — removido pela decisão D-1.
- Sign in with Apple, Associated Domains, HealthKit, Background Modes — nada
  disso existe no app.
- In-App Purchase não aparece como capability a ligar: já vem habilitada em todo
  App ID.

**Membership**

4. Confirme que o Apple Developer Program está ativo e que não há contrato
   pendente. Contrato vencido bloqueia o envio do build sem dizer o motivo com
   clareza.

---

## 0.1 App Store Connect → Business — faça isso primeiro

**Este é o item de maior prazo do roteiro inteiro e o único que não depende de
você.** Sem o contrato de apps pagos ativo, o produto de compra no app não pode
ser enviado para revisão, e você só descobre isso no fim.

Em **Business** (ou Agreements, Tax and Banking):

1. Aceite o **Paid Applications Agreement**.
2. Preencha as informações **fiscais** (Brasil e Estados Unidos — o formulário
   americano é obrigatório mesmo vendendo só no Brasil).
3. Cadastre a conta **bancária** que recebe.

Só siga para o resto quando o contrato estiver como **Active**. Isso pode levar
de horas a dias, dependendo da validação bancária. Comece por aqui e faça o
resto enquanto processa.

---

## 1. App Information

| Campo | Valor |
|---|---|
| **Nome** | `Bilhete` |
| **Subtítulo** | `Um recado na tela de bloqueio` |
| **Idioma principal** | Português (Brasil) |
| **Bundle ID** | `com.dablab.bilhete` |
| **SKU** | `bilhete-ios-001` |
| **Categoria primária** | Productivity |
| **Categoria secundária** | Utilities |
| **Copyright** | `© 2026 Alexandre Siqueira` |
| **User Access** | Full Access |

**Sobre o nome:** "Bilhete" é uma palavra comum em português e pode já estar
tomada na App Store brasileira. O nome é reservado no momento em que você cria o
registro do app — então **faça isso cedo**, antes de investir em qualquer outra
coisa. Se o nome estiver indisponível, a alternativa que preserva a busca é
`Bilhete: recado na tela` (24 caracteres), mantendo o mesmo subtítulo.

---

## 2. Version Information (versão 1.0)

### Texto promocional (142/170)

```
Escreva uma coisa que você não pode esquecer. Ela fica grande na sua tela de bloqueio até você resolver. Sem conta, sem nuvem, sem assinatura.
```

### Descrição (1.967/4.000)

```
Bilhete é o bilhete de geladeira do seu iPhone.

Você escreve uma coisa que precisa lembrar. Ela fica grande na sua tela de bloqueio, na frente dos olhos, e sai de lá quando você resolve. Só isso.

Não é app de tarefas: não tem projeto, prazo, prioridade nem categoria. Não é app de notas: não tem pasta, título nem formatação. É o equivalente digital do papel preso na geladeira — uma coisa, visível, que some quando você dá conta dela.

UMA COISA POR VEZ
Um bilhete fica em destaque, e é ele que aparece na tela de bloqueio. O que pode esperar fica numa pilha atrás, e volta com um toque. Aqui não vira lista de quarenta itens que você para de abrir.

NA TELA QUE VOCÊ JÁ OLHA
• Recado grande na tela de bloqueio e na Dynamic Island
• Botões de concluir e soltar direto da tela bloqueada, sem abrir o app
• Widgets de tela de bloqueio e de tela de início
• Controle na Central de Controle e no Botão de Ação
• Aparece sozinho no Apple Watch, no Smart Stack

Uma observação honesta: o iPhone encerra a fixação depois de 8 horas — é limite do sistema, não do app. O Bilhete avisa 30 minutos antes e devolve o recado para a tela com um toque, sem abrir nada.

FICA NO SEU IPHONE
Não tem conta, não tem login, não tem nuvem. O que você escreve não sai do aparelho: não existe servidor, e nem nós temos acesso. Dá para exportar tudo quando quiser.

QUATRO AÇÕES, E ACABOU
Fixar põe o recado na tela de bloqueio. Guardar é o "agora não". Concluir é o "resolvi isso" — e não apaga: dá para conferir depois. Soltar tira da tela sem concluir.

GRÁTIS DE VERDADE
Escrever, fixar, refixar, ver na tela e concluir são grátis, para sempre. Sem anúncio e sem assinatura.

BILHETE PRO — uma compra, pra sempre
• Bilhetes sem limite (no grátis são três ativos)
• Concluídos sem limite, com busca (no grátis, os dez mais recentes)
• Ei Siri e Atalhos
• Criar bilhete pela Central de Controle
• Escolher a fonte

Em português do Brasil e em inglês. iPhone com iOS 18 ou mais recente.
```

### Keywords (99/100 bytes)

```
lembrete,nota,anotacao,lembrar,esquecer,widget,tarefas,aviso,rapido,offline,privado,memoria,adesivo
```

Sem acento de propósito: o campo é limitado em **bytes**, e cada letra acentuada
custa dois. A busca da Apple normaliza acentuação, então "anotacao" também casa
com quem digita "anotação". Nenhuma palavra do Nome ou do Subtítulo aparece aqui
— elas já contam para a indexação e repeti-las desperdiçaria bytes.

### Novidades desta versão

```
Primeira versão do Bilhete.
```

### Capturas de tela

Use as sete peças de `app-store/telas-1242x2688/`, na ordem definida em
`prompt-claude-design-telas-loja.md`. Tamanho 6,5" (1242 × 2688). A App Store
deriva os tamanhos menores a partir dessas.

---

## 3. App Privacy

**Resposta: "Data Not Collected" — nenhum dado é coletado.**

Isto não é uma simplificação. O app não tem servidor, não tem conta, não faz
nenhuma chamada de rede própria e não embute nenhum SDK de terceiro — os únicos
frameworks importados são da Apple (SwiftUI, SwiftData, ActivityKit, WidgetKit,
AppIntents, StoreKit, UserNotifications). A seção 21 do spec descartou analytics
de terceiro exatamente para poder declarar isto (spec 20 e 21).

No questionário, responda **"No"** para a primeira pergunta ("Do you or your
third-party partners collect data from this app?") e o formulário encerra.

Detalhe que costuma gerar dúvida: a compra no app passa pelo StoreKit, mas quem
coleta esse dado é a Apple, na relação dela com o usuário — não é coleta do app,
e não muda a resposta.

---

## 4. URLs obrigatórias

| Campo | Valor |
|---|---|
| **Support URL** | `https://suportedablab.carrd.co/` |
| **Marketing URL** | deixar vazio |
| **Privacy Policy URL** | o documento Notion "Política de Privacidade — Aplicativos da Dab Lab" |

Os dois já estão dentro do app, em `AppConfig.swift`, e são os mesmos que vão na
ficha — o link que a Apple vê e o que o usuário toca são o mesmo.

### Seção nova a acrescentar no documento de privacidade

O texto padrão da Dab Lab fala de Firebase, Crashlytics, Analytics e permissões
de câmera e galeria. **Nada disso existe no Bilhete**, e deixar o texto genérico
valendo criaria uma contradição direta com a resposta "Data Not Collected" da
seção anterior — duas fontes dizendo coisas diferentes sobre o mesmo app é
atrito na revisão. Acrescente esta seção ao documento, usando a mesma numeração:

> ## Bilhete
>
> **1. Coleta de Dados**
> O Bilhete não coleta nenhum dado. Não há cadastro, login, conta nem
> identificador de usuário de qualquer tipo. O aplicativo não utiliza Firebase,
> Google Analytics, Crashlytics ou qualquer ferramenta de análise ou de registro
> de falhas de terceiros. Os textos que você escreve são o único conteúdo que
> existe no aplicativo, e eles nunca são enviados a lugar nenhum.
>
> **2. Uso dos Dados**
> Os bilhetes que você escreve são usados exclusivamente para serem exibidos a
> você — na tela do aplicativo, na tela de bloqueio do seu iPhone e nos widgets
> que você escolher adicionar. Não há nenhum outro uso, nem processamento
> automatizado, nem análise de conteúdo, nem inteligência artificial.
>
> **3. Armazenamento e Segurança**
> Todo o conteúdo fica armazenado **apenas no seu iPhone**, em uma área privada
> do aplicativo protegida pelo próprio sistema operacional (App Group). Não
> existe servidor, não existe cópia em nuvem e não há sincronização com outros
> aparelhos. A Dab Lab não tem acesso ao que você escreve — não porque prometemos
> não olhar, mas porque não existe cópia em lugar nenhum para ser olhada. Ao
> desinstalar o aplicativo, todo o conteúdo é apagado junto. Por isso o aplicativo
> oferece a opção "Exportar tudo", nos Ajustes, para você guardar uma cópia por
> conta própria.
>
> **4. Compartilhamento com Terceiros**
> Nenhum dado é compartilhado com terceiros, porque nenhum dado sai do aparelho.
> A única transação com um serviço externo é a compra opcional do Bilhete Pro,
> processada inteiramente pela Apple através da App Store — a Dab Lab não recebe
> nem armazena dados de pagamento.
>
> **Permissões solicitadas**
> O Bilhete pede autorização para **Notificações**, usada para um único aviso
> local, trinta minutos antes de o bilhete sair da tela de bloqueio; esse aviso é
> opcional e pode ser desligado nos Ajustes do aplicativo. E pede autorização
> para **Atividades ao Vivo**, que é o recurso que coloca o bilhete na tela de
> bloqueio. O aplicativo **não** utiliza câmera, galeria de fotos, microfone,
> localização, contatos, calendário nem Bluetooth.
>
> **5. Contato**
> alexandre@dablab.com.br

---

## 5. Pricing and Availability

| Campo | Valor |
|---|---|
| **Preço do app** | Grátis (Tier 0) |
| **Disponibilidade** | All Countries or Regions |

### Compra no app

| Campo | Valor |
|---|---|
| **Tipo** | Non-Consumable |
| **Product ID** | `com.dablab.bilhete.pro` |
| **Reference Name** | `Bilhete Pro` |
| **Preço** | R$ 19,90 (decisão D-3) |
| **Family Sharing** | desligado |

**Display Name (pt-BR):** `Bilhete Pro`
**Descrição (pt-BR):**
```
Bilhetes sem limite, concluídos sem limite com busca, Ei Siri e Atalhos, criar bilhete pela Central de Controle, e escolher a fonte.
```

**Display Name (en-US):** `Bilhete Pro`
**Descrição (en-US):**
```
Unlimited notes, unlimited done list with search, Hey Siri and Shortcuts, create a note from Control Center, and choose your font.
```

**Screenshot de revisão:** `app-store/bilhete-pro-iap-1242x2688.png` — já gerado.

**Review notes do produto:**
```
O paywall abre por Ajustes > Bilhete Pro, ou automaticamente ao tentar criar um quarto bilhete ativo. O ciclo básico do app — escrever, fixar na tela de bloqueio, refixar e concluir — é grátis e não passa pelo paywall em momento nenhum. O preço exibido vem sempre do StoreKit, nunca fixo no código. "Restaurar compras" está em Ajustes.
```

O produto e a versão 1.0 do app precisam ser enviados **juntos** para revisão na
primeira submissão. Se você enviar o app sem o produto, ele é aprovado sem a
compra e o paywall fica quebrado em produção.

---

## 6. App Review Information

| Campo | Valor |
|---|---|
| **Sign-in required** | **Não** — o app não tem conta, login nem cadastro |
| **Contato** | Alexandre / Siqueira · alexandre@dablab.com.br |
| **Demo account** | não se aplica |

### Notes (2.215/4.000)

```
O app não tem conta, login nem cadastro — abre direto no editor, sem tela de entrada. Não há credencial de teste a fornecer.

Privacidade: nada sai do aparelho. Não há servidor, backend, SDK de analytics nem chamada de rede própria. Os dados ficam no container do App Group (group.com.dablab.bilhete). A ficha de privacidade declara "Data Not Collected", e isso é literal.

Permissões que o app pede, e por quê:
- Notificações: um único aviso local, 30 minutos antes de a fixação na tela de bloqueio expirar. É opcional e pode ser desligado em Ajustes do app.
- Atividades ao Vivo (Live Activities): é o recurso central do produto — o bilhete aparece na tela de bloqueio e na Dynamic Island.
O app não usa câmera, galeria, microfone, localização, contatos, calendário nem Bluetooth.

Como testar o fluxo principal:
1. Abra o app. O cursor já está no bilhete — escreva qualquer coisa.
2. Toque em "Fixar". Aceite o pedido de Atividades ao Vivo.
3. Bloqueie a tela: o bilhete aparece grande, com os botões Concluir e Soltar.
4. Toque em "Concluir" na tela de bloqueio, sem desbloquear: o bilhete sai da tela e vai para Concluídos, dentro do app.

Compra no app (In-App Purchase):
É uma compra única, não-consumível (com.dablab.bilhete.pro). O paywall abre por Ajustes > Bilhete Pro, ou ao tentar criar um quarto bilhete ativo. O ciclo básico do app — escrever, fixar, refixar, ver na tela e concluir — é grátis e não passa pelo paywall em nenhum momento. "Restaurar compras" está em Ajustes. O preço exibido vem sempre do StoreKit, nunca fixo no código.

Widgets e Controle (opcionais, não precisam ser testados para o app funcionar):
- Widgets de tela de bloqueio e de tela de início são adicionados pelo iOS, do jeito padrão.
- Há dois Controles na Central de Controle: "Refixar bilhete" (grátis) e "Novo bilhete" (Pro).
- Os widgets de tela de bloqueio não têm botão, de propósito: com o aparelho bloqueado o intent só executaria depois do desbloqueio, e não há como reverter o estado visual se a pessoa cancelar.

Idiomas: português do Brasil e inglês. O app segue o idioma do iPhone e também permite escolher em Ajustes > Idioma.

Support website: https://suportedablab.carrd.co/
Contato: alexandre@dablab.com.br
```

---

## 7. App Encryption Documentation

**Resposta: "None of the algorithms mentioned above".**

O app não implementa criptografia nenhuma e não faz sequer chamada de rede
própria. A única comunicação externa é o StoreKit, framework da Apple.

Isto **já está declarado no binário** — `ITSAppUsesNonExemptEncryption` está como
`false` no `App/Info.plist`. Por causa disso o build não deve aparecer com
"Missing Compliance" no App Store Connect. Se aparecer mesmo assim, responda pelo
formulário com a mesma resposta acima.

---

## 8. Content Rights

**Resposta: "No, it does not contain, show, or access third-party content".**

Todo o conteúdo é escrito pela própria pessoa. Não há conteúdo licenciado
embutido: as fontes oferecidas no Pro são as do sistema (padrão, mono,
serifada), e os ícones são SF Symbols da Apple.

---

## 9. Classificação etária (expectativa: 4+)

Não há conteúdo gerado por usuário visível a terceiros, rede social, chat,
mensagens, IA generativa, compras de terceiros, apostas, álcool, violência nem
navegador embutido. O único conteúdo é o texto que a própria pessoa escreve, no
próprio aparelho, visível só para ela.

No questionário, responda "Nenhum" para todas as categorias de conteúdo. Duas
perguntas que costumam confundir:

- **"O app tem conteúdo gerado por usuários?"** — Não. A pergunta se refere a
  conteúdo de outras pessoas visível dentro do app. Texto que só o dono do
  aparelho escreve e só ele vê não conta.
- **"O app tem acesso irrestrito à web?"** — Não. Os únicos links saem para a
  página de suporte, a política de privacidade e os Ajustes do iOS, todos no
  navegador do sistema.

Resultado esperado: **4+**, conforme a seção 20 do spec.

---

## 10. Build e envio

1. Confirme `MARKETING_VERSION = 1.0` e `CURRENT_PROJECT_VERSION = 1` no
   `Bilhete.xcconfig` (já estão).
2. `xcodegen generate` para garantir que o projeto reflete o `project.yml`.
3. No Xcode: destino **Any iOS Device (arm64)** → Product → Archive.
4. No Organizer: Distribute App → App Store Connect → Upload.
5. O build leva de minutos a cerca de uma hora para aparecer processado.
6. Anexe o build à versão 1.0, anexe o produto de compra, e envie para revisão.

**A compilação precisa ser com Xcode 26 e SDK do iOS 26** — é exigência da Apple
para submissão desde 28/04/2026.

---

## Verificação de limites

Medido com `check_limits.py`, não estimado:

```
Nome: 7/30 caracteres [OK]
Subtítulo: 29/30 caracteres [OK]
Texto promocional: 142/170 caracteres [OK]
Descrição: 1967/4000 caracteres [OK]
Keywords: 99/100 bytes [OK]
Notas da versão (What's New): 27/4000 caracteres [OK]
Notas de revisão (App Review): 2215/4000 caracteres [OK]
```
