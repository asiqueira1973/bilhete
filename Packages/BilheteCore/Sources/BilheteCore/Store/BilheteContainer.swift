import Foundation
import SwiftData

/// Abre o `ModelContainer` compartilhado entre o app e a widget extension
/// (spec 4.5, item 2).
///
/// O store fica no container do App Group para os dois processos abrirem o
/// mesmo arquivo. **Não há `cloudKitDatabase`**: a decisão D-1 tirou o CloudKit
/// e a sincronização do escopo da v1, então o dado é local ao aparelho e o
/// caminho de backup é o "Exportar tudo" (spec 14.2) mais o backup do iPhone.
public enum BilheteContainer {

    /// Container compartilhado do app e do widget.
    ///
    /// - Returns: o `ModelContainer` do schema `BilheteSchemaV1`, apontando para
    ///   o arquivo dentro do App Group.
    ///
    /// Se a abertura falhar, o app não tem como funcionar — não há segunda
    /// fonte de dado — então a falha é fatal e explícita, em vez de virar um
    /// container em memória que perderia tudo em silêncio.
    public static var shared: ModelContainer {
        guard let container = optional else {
            fatalError("Não foi possível abrir o store do Bilhete")
        }
        return container
    }

    /// Container compartilhado que **não derruba o processo** se falhar.
    ///
    /// - Returns: o container, ou `nil` quando o store não abre.
    ///
    /// É o que a widget extension usa: um widget que falha em abrir o store deve
    /// mostrar o estado vazio (copy 15.7), nunca travar — widget que trava
    /// aparece como espaço em branco na tela de bloqueio da pessoa.
    public static let optional: ModelContainer? = try? make()

    /// Monta o container do schema versionado.
    ///
    /// - Parameter inMemory: quando `true`, cria um store descartável em
    ///   memória. É o que os testes usam para cada caso começar limpo.
    /// - Returns: o `ModelContainer` pronto para uso.
    /// - Throws: o erro do SwiftData quando o store não abre.
    ///
    /// Usa `BilheteMigrationPlan` desde a v1 (spec 7.8) para que a evolução
    /// futura do schema tenha onde encaixar e para o teste de migração da
    /// seção 22 ter alvo.
    public static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: BilheteSchemaV1.self)

        let configuration: ModelConfiguration = if inMemory {
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            ModelConfiguration(schema: schema, url: try storeURL())
        }

        return try ModelContainer(
            for: schema,
            migrationPlan: BilheteMigrationPlan.self,
            configurations: [configuration]
        )
    }

    /// Caminho do arquivo do store dentro do App Group.
    ///
    /// - Returns: a URL de `Library/Application Support/Bilhete.store` no
    ///   container compartilhado.
    /// - Throws: `CocoaError.fileNoSuchFile` se o App Group não estiver
    ///   disponível para o processo.
    ///
    /// O caminho é montado à mão, em vez de usar `groupContainer:`, porque a
    /// pasta `Application Support` do App Group não existe em instalação nova e
    /// o SwiftData não a cria — o store falharia ao abrir na primeira execução.
    private static func storeURL() throws -> URL {
        let fileManager = FileManager.default
        guard let group = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: AppConfig.appGroup
        ) else {
            throw CocoaError(.fileNoSuchFile)
        }

        let supportDirectory = group
            .appending(path: "Library", directoryHint: .isDirectory)
            .appending(path: "Application Support", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: supportDirectory, withIntermediateDirectories: true)

        return supportDirectory.appending(path: AppConfig.storeFileName)
    }
}
