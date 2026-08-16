#!/usr/bin/env python3
"""Gera/atualiza o String Catalog do app (épico 8.11).

PT-BR é a versão canônica (spec 15); o EN é tradução dela. A copy que existe na
seção 15 do spec entra literalmente — é texto final, não placeholder. Onde o
spec nomeia um controle só em português (a barra inferior, por exemplo), o EN é
tradução minha e está registrada na seção de divergências.
"""
import json, os, pathlib, sys

# Mora no repositório de propósito: o catálogo é **gerado** por este script.
# Editar o .xcstrings à mão funciona até alguém rodar o script de novo e
# sobrescrever — foi o que aconteceu com "Concluir" no teste em aparelho.
PATH = pathlib.Path(__file__).resolve().parent.parent / "App/Resources/Localizable.xcstrings"

# chave: (pt-BR, en, comentário com a referência do spec)
NEW = {
    # ── 10.6 Boas-vindas — copy 15.13 ─────────────────────────────────────
    "welcome.title":        ("Bilhete", "Bilhete", "15.13 — título da tela de boas-vindas (10.6)"),
    "welcome.subtitle":     ("Um recado por vez, na sua tela de bloqueio.",
                             "One note at a time, on your Lock Screen.", "15.13"),
    "welcome.button":       ("Escrever o primeiro", "Write the first one", "15.13 — botão único"),

    # ── 10.1 Destaque ─────────────────────────────────────────────────────
    "editor.placeholder":   ("Escreva o que você não quer esquecer",
                             "Write what you don't want to forget", "15.1 — placeholder e seed (7.7)"),
    "editor.accessibility": ("Bilhete em destaque", "Featured note", "VoiceOver do editor (spec 17)"),
    "editor.counter":       ("%1$d de %2$d caracteres", "%1$d of %2$d characters",
                             "11.2 — contador a partir de 240"),

    "action.stash":         ("Guardar", "Put away", "8.2 — barra inferior de 10.1"),
    "action.pin":           ("Fixar", "Pin", "8.4 — barra inferior de 10.1"),
    "action.repin":         ("Refixar", "Pin again", "8.4"),
    "action.unpin":         ("Soltar", "Unpin", "8.4"),
    "action.archive":       ("Concluir", "Done",
                             "8.3 — barra inferior de 10.1. Mesmo nome do botão da Live Activity (D-9): é a mesma ação, e dois nomes confundiam"),
    "action.delete":        ("Excluir", "Delete", "15.19 — menu ••• de 10.1"),
    "action.share":         ("Compartilhar", "Share", "14.1 — menu ••• de 10.1"),
    "action.copy":          ("Copiar", "Copy", "14.1 — menu ••• de 10.1"),
    "action.cancel":        ("Cancelar", "Cancel", "15.19"),
    "action.more":          ("Mais ações", "More actions", "VoiceOver do menu ••• de 10.1"),
    "hint.flow":            ("Um bilhete por vez na tela. Fixar põe ele na tela de bloqueio; Guardar deixa pra depois; Concluir é quando você resolveu.",
                             "One note at a time. Pin puts it on the Lock Screen; Put away is for later; Done is when you've handled it.",
                             "10.1 — explicação do fluxo, mostrada enquanto a pessoa ainda não guardou nem concluiu nada"),
    "action.doneTyping":    ("Pronto", "Done",
                             "10.1 — botão da barra do teclado; fecha o teclado para ver o bilhete inteiro"),

    "nav.stack":            ("Pilha", "Stack", "10.2 — acesso no topo de 10.1"),
    "nav.done":             ("Concluídos", "Done", "10.3 — acesso no topo de 10.1 (D-10)"),
    "nav.stack.count":      ("Pilha, %d guardados", "Stack, %d put away", "VoiceOver do contador da pilha"),
    "nav.settings":         ("Ajustes", "Settings", "10.4"),

    # ── Erros e confirmações ──────────────────────────────────────────────
    "error.save.title":     ("Não consegui salvar agora", "Couldn't save right now", "15.5"),
    "error.save.body":      ("Seu texto continua aqui. Vou tentar de novo em instantes.",
                             "Your text is still here. I'll try again shortly.", "15.5"),
    "delete.confirm.title": ("Excluir este bilhete?", "Delete this note?", "15.19"),
    "delete.confirm.body":  ("Não dá pra desfazer.", "This can't be undone.", "15.19"),
    # ── 10.2 Pilha (épico 8.2) ────────────────────────────────────────────
    "stack.title":          ("Pilha", "Stack", "10.2 — título da tela"),
    "stack.empty.title":    ("Nada guardado.", "Nothing saved.", "15.2"),
    "stack.empty.body":     ("O que estiver em destaque aparece na sua tela.",
                             "Whatever is featured shows on your screen.", "15.2"),
    "stack.empty.button":   ("Voltar ao destaque", "Back to the featured note",
                             "8.2 — botão do estado vazio"),
    "stack.counter":        ("%1$d de %2$d", "%1$d of %2$d", "10.2 — contador no limite grátis (11.3)"),
    "stack.featured.badge": ("na tela", "on screen",
                             "10.2 — selo do bilhete em destaque, listado no topo da pilha (D-11)"),
    "stack.promote.hint":   ("Toque para pôr em destaque", "Tap to feature this note",
                             "VoiceOver do item da pilha (8.2)"),
    "badge.pro":            ("PRO", "PRO", "Selo de capacidade Pro (matriz da seção 5)"),

    # ── Aviso de capacidade Pro — copy 15.8 ───────────────────────────────
    "pro.notice.title":     ("Isso é do Bilhete Pro", "That's in Bilhete Pro", "15.8"),
    "pro.notice.body":      ("Uma compra só, pra sempre.", "One purchase, forever.", "15.8"),
    "pro.notice.see":       ("Ver o Pro", "See Pro", "15.4 — botão que leva ao paywall (10.5)"),

    # ── 10.3 Arquivo (épico 8.3) ──────────────────────────────────────────
    "archive.title":        ("Concluídos", "Done", "10.3 — título da tela. Renomeado de \"Arquivo\" (D-10): o lugar leva o nome da ação que leva até ele"),
    "archive.empty.title":  ("Nada concluído ainda.", "Nothing done yet.", "15.3, adaptada ao nome novo (D-10)"),
    "archive.empty.body":   ("Bilhete resolvido é bilhete concluído.",
                             "A note you've handled is a note you finish.", "15.3, adaptada ao nome novo (D-10)"),
    "archive.search":       ("Buscar", "Search", "10.3 — campo de busca (capacidade Pro)"),
    "archive.search.empty": ("Nada encontrado.", "Nothing found.", "10.3 — busca sem resultado"),
    "archive.restore":      ("Restaurar", "Restore", "8.3 — ação por item"),
    "archive.deleteAll":    ("Apagar tudo", "Delete all", "10.3 — rodapé"),
    "archive.deleteAll.title": ("Apagar todos os concluídos?", "Delete all done notes?",
                               "8.3.6 — confirmação destrutiva"),
    "archive.deleteAll.body":  ("São %d bilhetes. Não dá pra desfazer.",
                               "That's %d notes. This can't be undone.", "8.3.6"),

    # ── Aviso de poda do arquivo grátis — copy 15.4 ───────────────────────
    "prune.title":          ("Seu arquivo está cheio", "Your archive is full", "15.4"),
    "prune.body":           ("Sem o Pro cabem 10 bilhetes no arquivo. Arquivar este apaga \"%@\" de vez.",
                             "Without Pro the archive holds 10 notes. Archiving this one deletes \"%@\" for good.",
                             "15.4"),
    "prune.confirm":        ("Arquivar mesmo assim", "Archive anyway", "15.4 — botão"),

    # ── 8.4 Fixar / Live Activity ─────────────────────────────────────────
    "pin.unavailable.title": ("Não dá pra fixar agora", "Can't pin right now", "15.6"),
    "pin.unavailable.body":  ("As Atividades ao Vivo estão desligadas para o Bilhete nos Ajustes do iPhone.",
                              "Live Activities are turned off for Bilhete in iPhone Settings.", "15.6"),
    "pin.unavailable.settings": ("Abrir Ajustes", "Open Settings", "15.6 — botão"),
    "pin.badge":             ("Na tela até %@", "On screen until %@",
                              "10.1 — selo do estado fixado; a seção 15 não define esta copy"),

    # ── 8.7 Permissão e guia da tela de bloqueio (10.7) ───────────────────
    "notif.permission.body": ("Pra deixar o bilhete na sua tela de bloqueio, o iPhone precisa da sua permissão. É só uma vez.",
                              "To keep your note on the Lock Screen, iPhone needs your permission. Just once.", "15.10"),
    "notif.permission.ok":   ("Entendi", "Got it", "15.10 — botão; a seção 15 não define esta copy"),

    "guide.title":           ("Como colocar na tela de bloqueio", "How to put it on the Lock Screen", "10.7"),
    "guide.card.title":      ("Seu bilhete some da tela em 12 horas", "Your note leaves the screen in 12 hours",
                              "9.4 — cartão dispensável no rodapé do destaque"),
    "guide.card.body":       ("Com o widget ele fica pra sempre. Toque pra ver como.",
                              "With the widget it stays for good. Tap to see how.", "9.4"),
    "guide.step1.title":     ("O widget na tela de bloqueio", "The Lock Screen widget", "10.7 — bloco 1"),
    "guide.step1.body":      ("Segure a tela de bloqueio, toque em Personalizar, escolha a tela e toque na área abaixo do relógio. Procure por Bilhete.",
                              "Press and hold the Lock Screen, tap Customize, pick the screen and tap the area below the clock. Look for Bilhete.", "10.7 — bloco 1"),
    "guide.step2.title":     ("O Controle no lugar da lanterna", "The control instead of the flashlight", "10.7 — bloco 2"),
    "guide.step2.body":      ("Na mesma tela de personalizar, toque no botão da lanterna ou da câmera e troque por Refixar bilhete. Um toque devolve seu bilhete pra tela.",
                              "On the same customize screen, tap the flashlight or camera button and swap it for Pin note again. One tap puts your note back on the screen.", "10.7 — bloco 2"),
    "guide.step3.title":     ("Por que o bilhete sai da tela", "Why the note leaves the screen", "10.7 — bloco 3"),
    "guide.step3.body":      ("O destaque grande é uma Atividade ao Vivo, e o iPhone encerra toda Atividade ao Vivo depois de 12 horas. O widget não tem esse limite — por isso ele é o que segura seu bilhete.",
                              "The big highlight is a Live Activity, and iPhone ends every Live Activity after 12 hours. The widget has no such limit — that's why it's what holds your note.", "10.7 — bloco 3, explica L1 e L2"),
    "guide.done":            ("Pronto", "Done", "10.7 — botão de fechar"),

    # ── 10.5 Paywall (épico 8.9) — copy 15.17, 15.18, 15.12 ───────────────
    "paywall.title":        ("Bilhete Pro", "Bilhete Pro", "15.17"),
    "paywall.subtitle":     ("Uma compra. Pra sempre.", "One purchase. Forever.", "15.17"),
    "paywall.item1":        ("Bilhetes sem limite", "Unlimited notes", "15.18"),
    "paywall.item2":        ("Arquivo sem limite, com busca", "Unlimited archive, with search", "15.18"),
    "paywall.item3":        ("Ei Siri, e Atalhos", "Hey Siri, and Shortcuts", "15.18"),
    "paywall.item4":        ("Escolher a fonte", "Choose your font", "15.18"),
    "paywall.item5":        ("Criar bilhete pela Central de Controle",
                             "Create a note from Control Center",
                             "15.18 — substitui \"Refixar pela tela de bloqueio\", que virou grátis (D-12)"),
    "paywall.buy":          ("Comprar por %@", "Buy for %@",
                             "10.5 — botão de compra; o preço vem do StoreKit (critério 8.9.2)"),
    "paywall.restore":      ("Restaurar compras", "Restore purchases", "10.5 — exigência de App Review"),
    "paywall.owned":        ("Bilhete Pro ✓", "Bilhete Pro ✓", "10.5 — estado de já comprado"),
    "paywall.offline.title": ("Sem conexão", "No connection", "15.12"),
    "paywall.offline.body": ("Preciso de internet pra buscar o preço. Tente de novo daqui a pouco.",
                             "I need internet to load the price. Try again in a moment.", "15.12"),
    "paywall.terms":        ("Termos e privacidade", "Terms and privacy", "10.5 — rodapé"),
    "paywall.close":        ("Fechar", "Close", "10.5"),

    # ── 10.4 Ajustes (épico 8.10) ─────────────────────────────────────────
    "settings.title":       ("Ajustes", "Settings", "10.4"),
    "settings.appearance":  ("Aparência", "Appearance", "10.4 — 7.3 chave aparencia"),
    "settings.language":    ("Idioma", "Language", "10.4 — seletor de idioma dentro do app"),
    "settings.language.system": ("Sistema", "System", "10.4 — segue o iPhone (critério 8.11.3)"),
    "settings.language.pt":     ("Português", "Portuguese", "10.4"),
    "settings.language.en":     ("Inglês", "English", "10.4"),
    "settings.appearance.system": ("Sistema", "System", "7.3"),
    "settings.appearance.light":  ("Claro", "Light", "7.3"),
    "settings.appearance.dark":   ("Escuro", "Dark", "7.3"),
    "settings.font":        ("Fonte", "Font", "10.4 — capacidade Pro (seção 5)"),
    "settings.font.default": ("Padrão", "Default", "16.3 — SF Pro"),
    "settings.font.mono":   ("Mono", "Mono", "16.3 — SF Mono"),
    "settings.font.serif":  ("Serifada", "Serif", "16.3 — New York"),
    "settings.smallText":   ("Texto pequeno", "Small text", "7.3 — chave texto_pequeno"),
    "settings.warn":        ("Avisar antes de expirar", "Warn before it expires", "7.3 — regra 11.7"),
    "settings.guide":       ("Como colocar na tela de bloqueio", "How to put it on the Lock Screen",
                             "10.7 — a um toque dos Ajustes (critério 8.10.4)"),
    "settings.pro":         ("Bilhete Pro", "Bilhete Pro", "10.4"),
    "settings.pro.active":  ("Bilhete Pro ✓", "Bilhete Pro ✓", "10.4 — estado com Pro ativo"),
    "settings.restore":     ("Restaurar compras", "Restore purchases", "10.4 — exigência de App Review"),
    "settings.rate":        ("Avaliar o Bilhete", "Rate Bilhete", "10.4"),
    "settings.feedback":    ("Enviar feedback", "Send feedback", "10.4"),
    "settings.export":      ("Exportar tudo", "Export everything", "14.2 — portabilidade (LGPD art. 18)"),
    "settings.export.note": ("Seus bilhetes ficam só neste iPhone. Exportar é o seu backup.",
                             "Your notes live only on this iPhone. Exporting is your backup.",
                             "D-1 — sem sincronização, esta é a única saída de dados"),
    "settings.about":       ("Sobre", "About", "10.4"),
    "settings.howItWorks":  ("Como o Bilhete funciona", "How Bilhete works",
                             "10.4 — abre a tela de conceitos (D-10)"),

    # ── Tela de conceitos (D-10) ──────────────────────────────────────────
    "concepts.title":       ("Como o Bilhete funciona", "How Bilhete works", "D-10"),
    "concepts.intro":       ("Um bilhete por vez fica em destaque — e é ele que aparece na sua tela de bloqueio. O resto espera a vez.",
                             "One note at a time is featured — and that's the one that shows on your Lock Screen. The rest wait their turn.", "D-10"),
    "concepts.pin.title":   ("Fixar", "Pin", "D-10"),
    "concepts.pin.body":    ("Põe o bilhete grande na tela de bloqueio, por 8 horas. Depois disso o iPhone encerra sozinho — é limite do sistema, não do app — e você fixa de novo quando quiser.",
                             "Puts the note big on the Lock Screen, for 8 hours. After that iPhone ends it on its own — a system limit, not the app's — and you pin it again whenever you want.", "D-10"),
    "concepts.stash.title": ("Guardar", "Put away", "D-10"),
    "concepts.stash.body":  ("Manda o bilhete para a pilha e abre um novo em branco. É o \"agora não\": ele continua ativo e volta ao destaque com um toque.",
                             "Sends the note to the stack and opens a blank one. It's the \"not now\": it stays active and comes back with one tap.", "D-10"),
    "concepts.done.title":  ("Concluir", "Done", "D-10"),
    "concepts.done.body":   ("É o \"resolvi isso\". O bilhete sai da tela e vai para Concluídos, de onde pode voltar se você precisar. O botão Concluir da tela de bloqueio faz exatamente a mesma coisa, sem abrir o app.",
                             "It's the \"I've handled it\". The note leaves the screen and goes to Done, where you can bring it back if you need. The Done button on the Lock Screen does exactly the same thing, without opening the app.", "D-10"),
    "concepts.unpin.title": ("Soltar", "Unpin", "D-10"),
    "concepts.unpin.body":  ("Tira o bilhete da tela de bloqueio sem concluir. Ele continua em destaque no app, inteiro.",
                             "Takes the note off the Lock Screen without finishing it. It stays featured in the app, untouched.", "D-10"),
    "concepts.limits.title": ("Quantos cabem", "How many fit", "D-10"),
    "concepts.limits.body": ("Sem o Pro, três bilhetes ativos ao mesmo tempo — o em destaque mais os guardados. Os concluídos não contam.",
                             "Without Pro, three active notes at a time — the featured one plus the ones you put away. Done notes don't count.", "D-10"),
    "settings.version":     ("Versão %@", "Version %@", "10.4"),
    "settings.privacy":     ("Política de privacidade", "Privacy policy", "10.4 — link D-5"),
    "settings.support":     ("Suporte", "Support", "10.4 — link D-5"),
}








def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


catalog = {"sourceLanguage": "pt-BR", "strings": {}, "version": "1.0"}
if PATH.exists():
    catalog = json.loads(PATH.read_text())

for key, (pt, en, comment) in NEW.items():
    entry = catalog["strings"].setdefault(key, {})
    entry["extractionState"] = "manual"
    entry["comment"] = comment
    entry["localizations"] = {"pt-BR": unit(pt), "en": unit(en)}

PATH.parent.mkdir(parents=True, exist_ok=True)
PATH.write_text(json.dumps(catalog, indent=2, ensure_ascii=False, sort_keys=True) + "\n")
print(f"{PATH}: {len(catalog['strings'])} chaves")
