import Foundation
import SwiftData

/// Versão 1 do schema persistido (spec 7.8).
///
/// O `VersionedSchema` existe desde o dia 1 mesmo havendo uma versão só. Motivo
/// original: com CloudKit ligado só migração leve é possível, para sempre
/// (spec 4.3, item 4). A decisão D-1 tirou o CloudKit, mas o plano fica —
/// começar sem versionamento torna qualquer evolução futura mais arriscada, e
/// manter isso é o que permite religar o sync depois sem migração pesada.
public enum BilheteSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    public static var models: [any PersistentModel.Type] { [Bilhete.self] }
}

/// Plano de migração do store (spec 7.8).
///
/// Com uma versão só não há estágio nenhum. O tipo existe para que a v2 tenha
/// onde encaixar `migrateV1toV2` sem precisar reestruturar a abertura do
/// `ModelContainer`, e para que o teste de migração da seção 22 tenha um alvo
/// desde já.
public enum BilheteMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] { [BilheteSchemaV1.self] }

    public static var stages: [MigrationStage] { [] }
}
