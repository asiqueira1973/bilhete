import Foundation

/// "Exportar tudo" — o arquivo de texto com todos os bilhetes (spec 14.2).
///
/// Existe por dois motivos, e os dois importam mais depois da decisão D-1 (sem
/// CloudKit): é o **único caminho de backup** fora do backup do iPhone, e é o
/// cumprimento do direito de portabilidade da LGPD, art. 18 (spec 20).
///
/// Não pede nada em troca: nem e-mail, nem conta, nem Pro.
@MainActor
public enum BilheteExporter {

    /// Monta o conteúdo do arquivo de exportação.
    ///
    /// - Parameters:
    ///   - store: de onde saem os bilhetes.
    ///   - dates: fonte de "agora", para o nome do arquivo (seção 22).
    /// - Returns: o texto completo, em UTF-8 sem BOM — é texto puro, não CSV
    ///   para Excel (spec 14.2).
    ///
    /// Uma seção por estado, na ordem do spec: em destaque, guardados na ordem
    /// da pilha, arquivados do mais recente para o mais antigo. Uma linha por
    /// bilhete, no formato `[dd/MM/yyyy HH:mm] texto`, com a data sendo
    /// `arquivadoEm` quando houver e `criadoEm` caso contrário.
    public static func makeText(store: BilheteStore, dates: DateSource = SystemDateSource()) -> String {
        var linhas: [String] = []

        if let destaque = store.featured() {
            linhas.append(Secao.destaque.titulo)
            linhas.append(linha(for: destaque))
            linhas.append("")
        }

        let pilha = store.stack()
        if !pilha.isEmpty {
            linhas.append(Secao.guardados.titulo)
            linhas.append(contentsOf: pilha.map(linha(for:)))
            linhas.append("")
        }

        let arquivo = store.archived()
        if !arquivo.isEmpty {
            linhas.append(Secao.arquivados.titulo)
            linhas.append(contentsOf: arquivo.map(linha(for:)))
            linhas.append("")
        }

        return linhas.joined(separator: "\n")
    }

    /// Nome do arquivo exportado (spec 14.2).
    ///
    /// - Parameter dates: fonte de "agora".
    /// - Returns: `bilhetes-AAAA-MM-DD.txt`.
    public static func fileName(dates: DateSource = SystemDateSource()) -> String {
        let formatador = DateFormatter()
        formatador.dateFormat = "yyyy-MM-dd"
        formatador.locale = Locale(identifier: "en_US_POSIX")
        return "bilhetes-\(formatador.string(from: dates.now)).txt"
    }

    /// Escreve o arquivo em disco, pronto para a share sheet.
    ///
    /// - Parameters:
    ///   - store: de onde saem os bilhetes.
    ///   - dates: fonte de "agora".
    /// - Returns: a URL do arquivo temporário, ou `nil` se a escrita falhar.
    public static func writeFile(store: BilheteStore, dates: DateSource = SystemDateSource()) -> URL? {
        let url = FileManager.default.temporaryDirectory.appending(path: fileName(dates: dates))
        let texto = makeText(store: store, dates: dates)
        // UTF-8 sem BOM: `String.write` não escreve BOM, que é exatamente o que
        // o spec 14.2 pede.
        try? texto.write(to: url, atomically: true, encoding: .utf8)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    /// Títulos das seções do arquivo.
    private enum Secao: String {
        case destaque, guardados, arquivados

        var titulo: String {
            switch self {
            case .destaque: "# EM DESTAQUE"
            case .guardados: "# GUARDADOS"
            case .arquivados: "# ARQUIVADOS"
            }
        }
    }

    /// Formata uma linha do arquivo.
    ///
    /// - Parameter bilhete: o bilhete a exportar.
    /// - Returns: `[dd/MM/yyyy HH:mm] texto`.
    private static func linha(for bilhete: Bilhete) -> String {
        let data = bilhete.arquivadoEm ?? bilhete.criadoEm
        let formatador = DateFormatter()
        formatador.dateFormat = "dd/MM/yyyy HH:mm"
        // O texto do bilhete pode ter quebras de linha; achatar mantém uma
        // linha por bilhete, como o spec 14.2 pede.
        let texto = bilhete.texto.replacingOccurrences(of: "\n", with: " ")
        return "[\(formatador.string(from: data))] \(texto)"
    }
}
