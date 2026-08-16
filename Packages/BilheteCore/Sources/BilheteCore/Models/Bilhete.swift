import Foundation
import SwiftData

/// O bilhete — única entidade persistida da v1 (spec 7.1 e 7.2).
///
/// Modelo mínimo é decisão deliberada, não esquecimento: uma entidade só reduz
/// ao mínimo a exposição às restrições permanentes de migração (spec 4.3).
/// A v2 (spec 28.1) encaixa `casaId` e `autorId` **opcionais** aqui sem
/// reescrever nada — migração leve permite adicionar campo opcional, mas nunca
/// mudar tipo nem remover campo.
///
/// Propriedades nomeadas em português por serem o schema persistido (spec 18.1).
///
/// Regras estruturais que este modelo obedece e que **não podem ser
/// "melhoradas"** (spec 4.3):
/// 1. Nenhum `@Attribute(.unique)` — nem em `id`. A unicidade é conferida em
///    código pela regra 11.13.
/// 2. Toda propriedade é opcional ou tem valor default.
/// 3. Nenhuma propriedade `Array` ou `Set` (risco R-1). Há build phase que
///    derruba o build e teste de reflexão que falha, caso alguém adicione.
///
/// Estas três valem mesmo depois da decisão D-1 (sem CloudKit): a regressão do
/// item 3 é local, e manter o schema compatível com sync deixa a porta aberta
/// para ligar o CloudKit depois sem migração pesada.
@Model
public final class Bilhete {

    /// Identificador gerado no cliente. Sem `@Attribute(.unique)` por decisão de
    /// schema; a conferência de colisão é feita na criação (regra 11.13).
    public var id: UUID = UUID()

    /// O conteúdo do bilhete. Texto puro, sem formatação, sem título, sem
    /// markdown (anti-escopo da seção 1). Máximo de 280 caracteres (regra 11.2).
    public var texto: String = ""

    /// Estado no ciclo de vida (spec 7.5). Transições na seção 12.
    public var estado: EstadoBilhete = EstadoBilhete.guardado

    /// Posição na pilha de guardados: menor valor = mais acima. Irrelevante
    /// para `emDestaque` e `arquivado` (regra 11.5).
    public var ordemPilha: Int = 0

    /// Quando a Live Activity atual expira, sempre `agora + 8h` (regra 11.8).
    /// Nulo quando o bilhete não está fixado — nunca esteve, já expirou, ou foi
    /// solto. É estado **local do aparelho**.
    public var fixadoAte: Date?

    /// `Activity.id` da Live Activity em curso, para poder atualizar e encerrar
    /// sem recriar (regra 11.6). Nulo quando não há atividade em curso. Também
    /// é estado local do aparelho.
    public var idAtividade: String?

    /// Momento da criação. Nunca muda (critério de aceite 8.1.5).
    public var criadoEm: Date = Date.now

    /// Momento da última alteração de `texto` ou `estado` (critério 8.1.5).
    /// Ordena o arquivo.
    public var atualizadoEm: Date = Date.now

    /// Momento do arquivamento. Nulo enquanto o bilhete não foi arquivado.
    /// Define a ordem da tela de arquivo e o corte dos 10 do plano grátis
    /// (regra 11.4). É não-nulo se e somente se `estado == .arquivado` —
    /// invariante 3 da seção 22.
    public var arquivadoEm: Date?

    /// Por onde o bilhete foi criado (spec 7.6). Contagem local apenas.
    public var origem: OrigemBilhete = OrigemBilhete.app

    /// Cria um bilhete com todos os campos explícitos.
    ///
    /// As datas entram por parâmetro em vez de serem lidas de `Date()` aqui
    /// dentro: quem constrói é o `BilheteStore`, que recebe um `DateSource`
    /// injetável — exigência da seção 22 para o que depende de tempo ser
    /// testável.
    ///
    /// - Parameters:
    ///   - id: identificador; o store confere colisão antes de gravar (11.13).
    ///   - texto: conteúdo, já validado em 280 caracteres pelo store (11.2).
    ///   - estado: estado inicial (7.5).
    ///   - ordemPilha: posição na pilha; o store calcula `min − 1` ao guardar
    ///     (11.5).
    ///   - criadoEm: instante da criação, vindo do `DateSource`.
    ///   - atualizadoEm: instante da última alteração, vindo do `DateSource`.
    ///   - origem: superfície que originou o bilhete (7.6).
    public init(
        id: UUID,
        texto: String,
        estado: EstadoBilhete,
        ordemPilha: Int,
        criadoEm: Date,
        atualizadoEm: Date,
        origem: OrigemBilhete
    ) {
        self.id = id
        self.texto = texto
        self.estado = estado
        self.ordemPilha = ordemPilha
        self.criadoEm = criadoEm
        self.atualizadoEm = atualizadoEm
        self.origem = origem
        // Os três campos de estado transitório nascem nulos por definição:
        // bilhete recém-criado não está fixado nem arquivado (invariantes 2 e 3
        // da seção 22).
        self.fixadoAte = nil
        self.idAtividade = nil
        self.arquivadoEm = nil
    }
}
