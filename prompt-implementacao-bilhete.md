# Prompt de implementação — Bilhete v1

**Como usar:** coloque `SDD-Bilhete.md`, `CLAUDE.md` e este arquivo na raiz do projeto. Abra o Claude Code nessa pasta e cole o bloco abaixo.

**Antes de colar, confira:** você já respondeu a **Q-1** (preço) e revisou as assunções **A-1**, **A-4** e **A-5** da seção 24? Elas mudam código. Se ainda não, o agente vai perguntar — o que também funciona, só custa uma rodada.

---

```
Implemente o app iOS "Bilhete" a partir da especificação em ./SDD-Bilhete.md.
Leia o documento inteiro antes de qualquer coisa.

ANTES DE CODAR: monte um plano e uma lista de tarefas e me mostre para aprovação.
Não escreva código antes disso.

ORDEM DE IMPLEMENTAÇÃO — obrigatória:
1. Seção 7 (modelo de dados) + BilheteStore da seção 13.1, com as invariantes da
   seção 22 testadas. Modelo e invariantes ANTES de qualquer tela: com CloudKit
   ligado só migração leve é possível para sempre (seção 4.3), então o schema é
   a decisão mais cara de reverter.
2. Épicos na ordem: 8.1 → 8.2 → 8.3 → 8.4 → 8.5 → 8.6 → 8.7 → 8.8 → 8.9 → 8.10 → 8.11.

ESCOPO: só o que está na seção 3 "Dentro da v1". NÃO implemente nada da seção 28
(roadmap): nem bilhete compartilhado, nem prazo/recorrência, nem bilhete por
contexto, nem renovação automática por push, nem UI dedicada de Apple Watch,
nem temas.

REGRAS DE DESEMPATE: os 5 princípios da seção 0. Qualquer dúvida de UX, copy ou
trade-off resolve a favor deles.

CONVENÇÃO DE IDIOMA (seção 18.1): a camada de dados é nomeada em PORTUGUÊS —
classes @Model, propriedades, enums e seus casos (bilhete.texto, estado,
arquivadoEm), em lowerCamelCase no Swift. Todo o resto do código, nomes de
arquivo, funções de UI e testes em INGLÊS. A fronteira é o BilheteStore.

COMENTÁRIOS (seção 18.2): toda função, intent, view model e provider de widget
leva comentário de cabeçalho EM PORTUGUÊS dizendo o que faz, o que recebe, o que
devolve e QUAL REGRA DO SPEC IMPLEMENTA, com o número da seção. Lógica não óbvia
leva comentário inline explicando a intenção, nunca a sintaxe.

SIGA LITERALMENTE, sem inventar valor:
- a matriz de direitos da seção 5 (todo gating de UI sai dela)
- as 18 regras numéricas da seção 11
- a máquina de estados da seção 12, incluindo as transições proibidas
- as 14 restrições de plataforma da seção 4.4 (L1 a L14) — são fatos
  documentados da Apple, não escolhas. Em especial: proibido botão em widget
  de tela de bloqueio (L9/11.9) e proibida propriedade Array/Set em @Model (4.3)
- a copy da seção 15 — é texto final, não placeholder

VALIDE cada épico contra TODOS os seus critérios de aceite antes de seguir para
o próximo.

PERGUNTE EM VEZ DE ASSUMIR ao cruzar com qualquer item da seção 25 (perguntas
abertas Q-1 a Q-6).

AO FINAL: gere o DOCUMENTACAO-TECNICA.md na raiz, em português, com os 6 itens
da seção 19, escrito a partir do que foi realmente implementado — incluindo a
seção de divergências em relação ao spec.
```

---

## Prompts auxiliares

### Só o alicerce (se quiser validar o modelo antes de subir telas)

Recomendado. O schema é a decisão mais cara de reverter com CloudKit ligado, e vale conferir antes de ter dez telas em cima dele.

```
Leia ./SDD-Bilhete.md.

Implemente APENAS:
- o package BilheteCore com a entidade da seção 7 e os dois enums (7.5 e 7.6)
- o BilheteStore da seção 13.1, com todos os métodos e as regras que cada um aplica
- o VersionedSchema BilheteSchemaV1 (7.8)
- os testes das 4 invariantes da seção 22, INCLUINDO o que falha o build se
  alguém adicionar propriedade Array ou Set a uma classe @Model
- a bateria de teste das regras 11.2, 11.3, 11.4, 11.5, 11.16
- os testes de todas as transições da seção 12, permitidas e proibidas

NÃO implemente nenhuma tela, nenhum widget, nenhum intent e nenhuma Live Activity
ainda. Ao terminar, me mostre a saída dos testes.
```

### Só as superfícies do sistema (o pedaço com mais armadilha)

```
Leia ./SDD-Bilhete.md, com atenção especial à seção 4.4 (restrições L1 a L14),
à seção 4.5 (compartilhamento entre app, widget e Live Activity) e à seção 10
(superfícies S1 a S11).

Implemente a widget extension inteira: os 4 widgets, a Live Activity com as 3
apresentações de Dynamic Island, e os 2 Controles da Central de Controle.

Atenção obrigatória a estes quatro pontos, que são onde este pedaço costuma
quebrar:
- L8: widget de tela de bloqueio é escala de cinza forçada. Hierarquia por peso
  e opacidade, nunca por cor.
- L9 + regra 11.9: PROIBIDO botão em widget de tela de bloqueio.
- 4.5 item 4: nas views de widget, SEMPRE @Query, NUNCA @State populado à mão.
  Critério de aceite 8.5.5 valida exatamente isso.
- L6: o Controle "Refixar bilhete" dispara LiveActivityIntent chamando
  Activity.request(...) dentro do perform(), sem abrir o app. O perform() precisa
  completar de forma síncrona (L13).
```

### Retomar depois de uma pausa

```
Leia ./SDD-Bilhete.md e ./DOCUMENTACAO-TECNICA.md.

Me diga: quais épicos da seção 8 já estão implementados, quais critérios de
aceite ainda não passam, e o que você recomenda fazer em seguida. Não escreva
código ainda.
```

### Mudança incremental (depois da v1 pronta)

Use o modelo da seção 29 do spec. Regra que mais economiza retrabalho: **peça a lista de arquivos que serão criados e alterados antes do código, e aprove.**
