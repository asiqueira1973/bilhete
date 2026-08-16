# Bilhete

App iOS que deixa uma nota na tela de bloqueio. Um bilhete em destaque por vez;
os outros ficam numa pilha atrás.

- **Fonte de verdade do produto:** [`SDD-Bilhete.md`](SDD-Bilhete.md)
- **Regras permanentes do projeto:** [`CLAUDE.md`](CLAUDE.md) — inclui as decisões
  D-1 a D-6, que **vencem o spec** onde houver conflito
- **Como ficou implementado:** [`DOCUMENTACAO-TECNICA.md`](DOCUMENTACAO-TECNICA.md)

## Setup local

Requer Xcode 26+ e XcodeGen (`brew install xcodegen`).

```bash
cd ~/Bilhete && xcodegen generate && open Bilhete.xcodeproj
```

O `.xcodeproj` é **gerado** — não edite pelo Xcode esperando que a mudança
sobreviva. Alterou target, arquivo ou configuração? Mexa no `project.yml` e rode
`xcodegen generate` de novo.

## Estrutura

```
Bilhete/
├── project.yml                  ← a verdade sobre targets e configuração
├── Bilhete.xcconfig             ← bundle id, App Group, produto do StoreKit
├── Bilhete.storekit             ← loja local para desenvolvimento e teste
├── Packages/BilheteCore/        ← tudo que app e widget compartilham
│   └── Sources/BilheteCore/
│       ├── Models/              ← @Model, enums e schema versionado (spec 7)
│       ├── Store/               ← BilheteStore, container, exportação (13.1)
│       ├── Intents/             ← todos os App Intents (13.3)
│       ├── Entitlement/         ← EntitlementStore e PaywallGate (13.4)
│       ├── LiveActivity/        ← BilheteAttributes e PinService (13.2)
│       ├── Notifications/       ← aviso de expiração e avisos de Controle
│       ├── Preferences/         ← UserDefaults do App Group (7.3)
│       └── Resources/           ← paleta e strings compartilhadas
├── App/                         ← target principal, uma pasta por tela
├── Widgets/                     ← 4 widgets, Live Activity e 2 Controles
├── BilheteTests/                ← 105 testes
├── BilheteUITests/              ← captura do print da loja
└── Scripts/                     ← guarda da invariante 22.4
```

## Capabilities a habilitar no portal da Apple

| Capability | Onde | Valor |
|---|---|---|
| App Groups | app **e** widget extension | `group.com.dablab.bilhete` |
| Live Activities | app | `NSSupportsLiveActivities` já no `Info.plist` |
| Push Notifications | — | **não é necessária.** Não há push; a renovação da fixação é sempre ato do usuário (L4, L7) |
| iCloud / CloudKit | — | **não é necessária** (decisão D-1: o app é local) |

## Como rodar os testes

```bash
xcodebuild test -scheme Bilhete -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:BilheteTests
```

São 105 casos em 12 suítes: as 4 invariantes do modelo, uma bateria por regra
numérica da seção 11, a máquina de estados inteira (permitidas e proibidas), o
editor, o arquivo, o `PinService`, as restrições dos widgets, os intents e
Controles, o armazenamento, o StoreKit e a localização.

**A guarda da invariante 22.4 não é um teste, é uma build phase.** Adicionar uma
propriedade `Array` ou `Set` a uma classe `@Model` **derruba a compilação**:

```
error: .../Bilhete.swift declara propriedade Array/Set em classe @Model —
proibido pela invariante 22.4 / regra 4.3 do spec (risco R-1).
** BUILD FAILED **
```

Para rodar a guarda à mão:

```bash
SRCROOT=~/Bilhete bash Scripts/check-no-model-collections.sh
```

## Print do in-app purchase para o App Store Connect

O App Store Connect exige uma imagem da tela de compra na revisão do produto.
O arquivo pronto está em `app-store/bilhete-pro-iap-1242x2688.png`. Para gerar de
novo depois de mexer no paywall:

```bash
xcodebuild test -scheme Bilhete -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:BilheteUITests
```

O teste liga a loja local (`SKTestSession`), abre o paywall com o preço real do
StoreKit e salva o PNG; o caminho sai no log como `PAYWALL_SCREENSHOT_PATH=`.
Depois é só redimensionar para 1242 × 2688.

## Configurar o produto no App Store Connect

| Campo | Valor |
|---|---|
| Tipo | Não-consumível |
| ID do produto | `com.dablab.bilhete.pro` |
| Nome de referência | Bilhete Pro |
| Preço | R$ 19,90 (decisão D-3 — o app **nunca** exibe preço fixo, sempre o do StoreKit) |
| Print de revisão | `app-store/bilhete-pro-iap-1242x2688.png` |

O mesmo id vive em três lugares e precisa bater: `Bilhete.xcconfig`
(`PRODUTO_PRO`), `Bilhete.storekit` e `AppConfig.proProductID`.

## O que só se valida em aparelho real

O simulador não prova: Controle na tela de bloqueio no lugar da lanterna, o
Botão de Ação, o acionamento do Controle com o app fechado dentro dos 3 segundos,
Siri por voz, legibilidade dos widgets em `vibrant` com papel de parede de alto
contraste, e os números de desempenho da seção 17 medidos em iPhone 12. A lista
completa está na seção de pendências da documentação técnica.
