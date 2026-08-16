#if DEBUG
import BilheteCore
import Foundation

/// Semeia bilhetes de exemplo para a captura das imagens da App Store.
///
/// **Só existe em DEBUG.** Em Release este arquivo inteiro desaparece do binário.
///
/// Existe porque digitar pelo simulador perde acento e o corretor automático
/// muda palavra — e imagem de loja com "dentists" no lugar de "dentista" é
/// exatamente o tipo de detalhe que envelhece mal. Com isto, regerar as imagens
/// depois de qualquer mudança de tela é um comando, não meia hora de digitação.
enum DemoData {

    /// Apaga tudo e cria o cenário das imagens da loja.
    ///
    /// - Parameter store: o ponto único de escrita (spec 13.1).
    ///
    /// O cenário é o do fluxo 9.2 do spec: um bilhete em destaque, dois
    /// guardados esperando a vez, e dois já concluídos.
    static func seed(into store: BilheteStore) {
        for bilhete in store.allNotes() {
            try? store.delete(bilhete)
        }

        // Os concluídos entram primeiro, para ficarem embaixo na ordem por data.
        for texto in ["pagar o boleto do condomínio", "comprar pão na padaria da esquina"] {
            if let bilhete = try? store.create(texto: texto) {
                try? store.archive(bilhete, confirmingPrune: true)
            }
        }

        // Depois os guardados, do mais antigo para o mais recente.
        for texto in ["ligar pra dentista até sexta", "renovar o seguro do carro"] {
            _ = try? store.create(texto: texto)
        }

        // Por último o destaque, que é o que aparece na tela e nos widgets.
        if let destaque = try? store.ensureFeatured() {
            try? store.save(destaque, texto: "levar o Téo no dentista às 15h")
        }
    }

    /// Diz se o app foi lançado para captura de imagens.
    static var isRequested: Bool {
        ProcessInfo.processInfo.arguments.contains("-BilheteDemoData")
    }
}
#endif
