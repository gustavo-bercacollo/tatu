import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// RN-150: os Termos de Uso e a Política de Privacidade vêm dos `.md` de
/// `docs/` (fonte única), empacotados no app. Nenhum texto legal é escrito
/// à mão no código. Depois, os mesmos arquivos são servidos por uma URL
/// pública (decisão em aberto).

enum TipoDocumento { termos, politica }

extension TipoDocumentoInfo on TipoDocumento {
  /// Caminho do asset (o `pubspec.yaml` empacota `../docs/*.md`).
  String get arquivo => switch (this) {
    TipoDocumento.termos => '../docs/termos-de-uso.md',
    TipoDocumento.politica => '../docs/politica-de-privacidade.md',
  };

  /// Título na tela.
  String get titulo => switch (this) {
    TipoDocumento.termos => 'Termos de uso',
    TipoDocumento.politica => 'Política de privacidade',
  };

  /// Seções em destaque no índice (escolha de tela, não texto legal).
  List<String> get principais => switch (this) {
    TipoDocumento.termos => const ['3', '4', '5', '7', '8'],
    TipoDocumento.politica => const ['2', '4', '5', '7', '9'],
  };
}

/// Uma seção "## ..." do documento.
@immutable
class SecaoDocumento {
  const SecaoDocumento({required this.titulo, required this.corpo});

  /// "8. Valor, pagamento e taxa".
  final String titulo;

  /// Texto em markdown simples (parágrafos, listas, tabelas, **negrito**).
  final String corpo;

  /// "8" (nulo para "Anexo I").
  String? get numero => RegExp(r'^(\d+)\.').firstMatch(titulo)?.group(1);
}

/// Uma linha de "Histórico de versões".
@immutable
class VersaoDocumento {
  const VersaoDocumento({
    required this.versao,
    required this.data,
    required this.mudou,
  });

  final String versao;

  /// Nula enquanto a data for um campo a preencher ("[DATA DE PUBLICAÇÃO]").
  final DateTime? data;
  final String mudou;

  /// RN-151: o que mudou, em itens (frases separadas por "." ou ";").
  List<String> get itens => [
    for (final p in mudou.split(RegExp(r'(?<=[.;])\s+')))
      if (p.trim().isNotEmpty) p.trim(),
  ];
}

const _meses = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho',
  'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

/// "18 de novembro de 2026" → data; campo a preencher → nulo.
DateTime? lerData(String texto) {
  final t = texto.trim().toLowerCase();
  final m = RegExp(r'^(\d{1,2}) de ([a-zç]+) de (\d{4})$').firstMatch(t);
  if (m != null) {
    final mes = _meses.indexOf(m.group(2)!);
    if (mes >= 0) {
      return DateTime(int.parse(m.group(3)!), mes + 1, int.parse(m.group(1)!));
    }
  }
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(t);
  if (iso != null) return DateTime.parse(t);
  final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(t);
  if (br != null) {
    return DateTime(
      int.parse(br.group(3)!),
      int.parse(br.group(2)!),
      int.parse(br.group(1)!),
    );
  }
  return null;
}

/// "18 de novembro de 2026".
String dataPorExtenso(DateTime d) => '${d.day} de ${_meses[d.month - 1]} de ${d.year}';

/// Documento lido do `.md`.
@immutable
class DocumentoLegal {
  const DocumentoLegal({
    required this.tipo,
    required this.versao,
    required this.vigencia,
    required this.essencial,
    required this.secoes,
    required this.historico,
  });

  /// Enquanto o `.md` traz "[DATA DE PUBLICAÇÃO]" (rascunho), vale esta
  /// data. TODO(jurídico): some quando a data for preenchida no documento.
  static final vigenciaRascunho = DateTime(2026, 11, 18);

  final TipoDocumento tipo;
  final String versao;

  /// RN-151: data a partir da qual esta versão vale.
  final DateTime vigencia;

  /// "O essencial em 1 minuto" (itens em markdown).
  final List<String> essencial;
  final List<SecaoDocumento> secoes;
  final List<VersaoDocumento> historico;

  String get titulo => tipo.titulo;

  /// Seções numeradas ("23 seções"; o Anexo não conta).
  int get numeradas => secoes.where((s) => s.numero != null).length;

  /// "Versão 1.0 · 18 de novembro de 2026".
  String get rotuloVersao => 'Versão $versao · ${dataPorExtenso(vigencia)}';

  /// Linha do histórico desta versão.
  VersaoDocumento? get desta =>
      historico.where((h) => h.versao == versao).firstOrNull;

  /// RN-151: versão que valia em [data] (pedidos em andamento seguem a
  /// versão em que foram feitos).
  String versaoEm(DateTime data) {
    String? achada;
    DateTime? melhor;
    for (final h in historico) {
      // Data a preencher (rascunho): vale a data do rascunho.
      final d = h.data ?? (h.versao == versao ? vigencia : vigenciaRascunho);
      if (d.isAfter(data)) continue;
      if (melhor == null || d.isAfter(melhor)) {
        melhor = d;
        achada = h.versao;
      }
    }
    return achada ?? (historico.isEmpty ? versao : historico.first.versao);
  }

  /// Lê o markdown do documento.
  static DocumentoLegal ler(TipoDocumento tipo, String md) {
    final linhas = md.replaceAll('\r\n', '\n').split('\n');
    final v = RegExp(
      r'\*\*Versão\s+([\d.]+)\s*·\s*Vigente a partir de\s+([^*]+)\*\*',
    ).firstMatch(md);
    final versao = v?.group(1) ?? '1.0';
    final vigencia = lerData(v?.group(2) ?? '') ?? vigenciaRascunho;

    final secoes = <SecaoDocumento>[];
    var essencial = <String>[];
    var historico = <VersaoDocumento>[];
    String? titulo;
    var corpo = <String>[];

    void fechar() {
      final t = titulo;
      if (t == null) return;
      final texto = corpo.join('\n').trim().replaceAll(RegExp(r'\n-{3,}$'), '');
      if (t.startsWith('O essencial')) {
        essencial = [
          for (final l in texto.split('\n'))
            if (l.startsWith('- ')) l.substring(2).trim(),
        ];
      } else if (t.startsWith('Histórico de versões')) {
        historico = [];
        for (final l in texto.split('\n')) {
          if (!l.startsWith('|') || l.contains('---')) continue;
          final c = l.split('|').map((x) => x.trim()).toList();
          if (c.length < 4 || c[1] == 'Versão') continue;
          historico.add(
            VersaoDocumento(versao: c[1], data: lerData(c[2]), mudou: c[3]),
          );
        }
      } else {
        secoes.add(SecaoDocumento(titulo: t, corpo: texto.trim()));
      }
    }

    for (final l in linhas) {
      if (l.startsWith('## ')) {
        fechar();
        titulo = l.substring(3).trim();
        corpo = [];
      } else if (titulo != null) {
        if (l.trim() == '---') continue;
        corpo.add(l);
      }
    }
    fechar();
    return DocumentoLegal(
      tipo: tipo,
      versao: versao,
      vigencia: vigencia,
      essencial: essencial,
      secoes: secoes,
      historico: historico,
    );
  }
}

/// Lê os documentos (assets agora; URL pública depois).
abstract class FonteDocumentos {
  Future<String> ler(TipoDocumento tipo);
}

class FonteDocumentosAssets implements FonteDocumentos {
  const FonteDocumentosAssets();

  @override
  // Sem cache do Flutter: ele guardaria até uma leitura que falhou.
  Future<String> ler(TipoDocumento tipo) =>
      rootBundle.loadString(tipo.arquivo, cache: false);
}

/// Documentos carregados. Versão simulada com cache em memória.
class DocumentosLegaisRepo extends ChangeNotifier {
  FonteDocumentos fonte = const FonteDocumentosAssets();
  final _cache = <TipoDocumento, DocumentoLegal>{};

  DocumentoLegal? doc(TipoDocumento tipo) => _cache[tipo];
  DocumentoLegal? get termos => _cache[TipoDocumento.termos];
  DocumentoLegal? get politica => _cache[TipoDocumento.politica];

  Future<DocumentoLegal> carregar(TipoDocumento tipo) async {
    final pronto = _cache[tipo];
    if (pronto != null) return pronto;
    final d = DocumentoLegal.ler(tipo, await fonte.ler(tipo));
    _cache[tipo] = d;
    notifyListeners();
    return d;
  }

  Future<void> carregarTodos() async {
    for (final t in TipoDocumento.values) {
      await carregar(t);
    }
  }

  /// Testes e capturas: documento já lido.
  void definir(DocumentoLegal d) {
    _cache[d.tipo] = d;
    notifyListeners();
  }

  void restaurar() {
    _cache.clear();
    fonte = const FonteDocumentosAssets();
    notifyListeners();
  }
}

/// Instância única usada pelo app.
final documentosLegais = DocumentosLegaisRepo();

/// Demonstração e testes (RN-151): a próxima versão de [d], com o que
/// mudou como no desenho C74. Não é texto legal.
DocumentoLegal versaoNovaDemo(DocumentoLegal d, {DateTime? vigencia}) {
  final quando = vigencia ?? DateTime(2026, 12, 3);
  final partes = d.versao.split('.');
  final nova = '${partes.first}.${(int.tryParse(partes.last) ?? 0) + 1}';
  return DocumentoLegal(
    tipo: d.tipo,
    versao: nova,
    vigencia: quando,
    essencial: d.essencial,
    secoes: d.secoes,
    historico: [
      ...d.historico,
      VersaoDocumento(
        versao: nova,
        data: quando,
        mudou:
            'Plano fixo: até 2 visitas por semana. Gorjeta opcional depois '
            'do serviço.',
      ),
    ],
  );
}
