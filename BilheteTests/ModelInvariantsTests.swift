import Foundation
import SwiftData
import Testing
@testable import BilheteCore

/// As quatro invariantes do modelo (spec 22).
///
/// São as que, quebradas, corrompem o app: duas notas em destaque, atividade
/// órfã na tela de bloqueio, arquivo inconsistente, ou a regressão do SwiftData
/// que faz perder dado na migração.
@MainActor
@Suite("Invariantes do modelo (seção 22)")
struct ModelInvariantsTests {

    // MARK: - Invariante 1

    @Test("Nunca existem dois bilhetes em destaque, em nenhuma operação")
    func neverTwoFeatured() throws {
        let h = try TestHarness(isPro: true)

        let primeiro = try h.makeFeatured(texto: "um")
        h.expectInvariantsHold()

        let novo = try h.store.stash(primeiro)
        h.expectInvariantsHold()
        try h.store.save(novo, texto: "dois")

        try h.store.promoteToFeatured(primeiro)
        h.expectInvariantsHold()

        try h.store.archive(primeiro)
        h.expectInvariantsHold()

        #expect(h.store.allNotes().count { $0.estado == .emDestaque } == 1)
    }

    // MARK: - Invariante 2

    @Test("fixadoAte e idAtividade só são não-nulos com estado em destaque")
    func pinFieldsOnlyOnFeatured() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured()

        // Simula o que o PinService do épico 8.4 grava ao fixar (regra 11.8).
        bilhete.fixadoAte = h.dates.now.addingTimeInterval(BilheteStore.pinDuration)
        bilhete.idAtividade = "activity-123"
        h.expectInvariantsHold()

        // Guardar tira o bilhete do destaque: os dois campos precisam sair
        // junto, senão sobra atividade órfã (regra 11.6).
        try h.store.stash(bilhete)
        #expect(bilhete.fixadoAte == nil)
        #expect(bilhete.idAtividade == nil)
        h.expectInvariantsHold()
    }

    @Test("A invariante 2 acusa quando os campos de fixação sobrevivem à troca de estado")
    func pinFieldsInvariantDetectsViolation() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured()

        // Escreve direto no modelo, sem passar pelo store, exatamente o estado
        // que a invariante existe para proibir.
        bilhete.estado = .guardado
        bilhete.fixadoAte = h.dates.now

        #expect(!h.store.invariantViolations().isEmpty)
    }

    // MARK: - Invariante 3

    @Test("arquivadoEm é não-nulo se e somente se o estado é arquivado")
    func archivedDateIffArchived() throws {
        let h = try TestHarness(isPro: true)
        let bilhete = try h.makeFeatured()
        #expect(bilhete.arquivadoEm == nil)

        try h.store.archive(bilhete)
        #expect(bilhete.estado == .arquivado)
        #expect(bilhete.arquivadoEm != nil)
        h.expectInvariantsHold()

        try h.store.restore(bilhete)
        #expect(bilhete.estado == .guardado)
        #expect(bilhete.arquivadoEm == nil)
        h.expectInvariantsHold()
    }

    // MARK: - Invariante 4 — defesa contra o risco R-1

    @Test("Nenhuma propriedade do schema persistido é Array ou Set")
    func noCollectionPropertiesInSchema() throws {
        // Lê o schema que o SwiftData realmente persiste, em vez de olhar o
        // código-fonte: se alguém adicionar a propriedade, ela aparece aqui.
        let schema = Schema(versionedSchema: BilheteSchemaV1.self)

        for entity in schema.entities {
            for attribute in entity.attributes {
                let tipo = String(describing: attribute.valueType)
                let proibido = tipo.contains("Array<") || tipo.contains("Set<")
                #expect(
                    !proibido,
                    """
                    \(entity.name).\(attribute.name) é do tipo \(tipo) — proibido pela regra 4.3 \
                    do spec (risco R-1: a regressão do iOS 26.1 converte Array/Set em \
                    Transformable e quebra a migração do store). Modele como relacionamento \
                    entre entidades ou serialize como Data com JSON manual.
                    """
                )
            }
        }
    }

    @Test("A build phase que derruba o build por Array/Set está no lugar")
    func buildPhaseGuardIsWired() throws {
        // A invariante 4 do spec pede um teste "que falha o build". Quem derruba
        // o build é o script de pre-build; este caso garante que ele existe, é
        // executável e continua ligado ao target. Rodar o script daqui não é
        // possível: `Process` não existe no iOS, e os testes rodam no simulador.
        // A prova de que ele reprova um modelo com Array é feita na linha de
        // comando e está registrada no README e na documentação técnica.
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let script = root.appendingPathComponent("Scripts/check-no-model-collections.sh")

        #expect(FileManager.default.isExecutableFile(atPath: script.path))

        let projeto = try String(contentsOf: root.appendingPathComponent("project.yml"), encoding: .utf8)
        #expect(projeto.contains("check-no-model-collections.sh"))
        #expect(projeto.contains("preBuildScripts"))
    }
}
