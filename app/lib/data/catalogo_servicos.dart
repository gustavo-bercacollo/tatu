import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// RN-161: catálogo de profissões por segmento, com sinônimos e
/// especialidades. Vem de `docs/catalogo-de-servicos.md` (fonte única),
/// empacotado no app; nada da lista é escrito à mão no código.

/// Como a profissão atende (coluna "Atende": L, D ou L/D).
enum AtendeCatalogo { local, distancia, ambos }

@immutable
class ProfissaoCatalogo {
  const ProfissaoCatalogo({
    required this.nome,
    required this.segmento,
    required this.atende,
    this.sinonimos = const [],
    this.especialidades = const [],
    this.regulada = false,
    this.retornoDias = retornoPadraoDias,
    this.fixo = false,
  });

  /// RN-209: costuma virar plano fixo (coluna "Fixo": Sim). Só então o card
  /// de Concluídos mostra "Tornar fixa/fixo".
  final bool fixo;

  /// RN-183: prazo para o cliente pedir retorno, contado da conclusão
  /// (coluna "Retorno": 30 dias não durável, 90 durável).
  final int retornoDias;

  /// "Encanador" (sem o "(a)" do documento).
  final String nome;
  final String segmento;
  final AtendeCatalogo atende;

  /// "bombeiro hidráulico", "hidráulica"…
  final List<String> sinonimos;
  final List<String> especialidades;

  /// Marcada com "Reg." no catálogo (ver `profissoes-reguladas.md`).
  final bool regulada;

  bool get local => atende != AtendeCatalogo.distancia;
  bool get remoto => atende != AtendeCatalogo.local;
}

/// "Professor(a) particular" → "Professor particular".
String _limpar(String s) => s
    .replaceAll(RegExp(r'\(a\)|\(as\)|\(s\)'), '')
    .replaceAll(RegExp(r'\s*\(Reg\.[^)]*\)'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// RN-183: "Na dúvida, 90 dias."
const retornoPadraoDias = 90;

/// "90 dias" → 90 (sem número, o padrão).
int _dias(String? s) =>
    int.tryParse(RegExp(r'\d+').firstMatch(s ?? '')?.group(0) ?? '') ??
    retornoPadraoDias;

AtendeCatalogo _atende(String s) => switch (s.trim().toUpperCase()) {
  'L' => AtendeCatalogo.local,
  'D' => AtendeCatalogo.distancia,
  _ => AtendeCatalogo.ambos,
};

/// Lê os segmentos ("## 1. Casa e reformas") e as tabelas.
List<(String, List<ProfissaoCatalogo>)> lerCatalogo(String md) {
  final segmentos = <(String, List<ProfissaoCatalogo>)>[];
  String? atual;
  var lista = <ProfissaoCatalogo>[];
  // Colunas lidas pelo cabeçalho ("Profissão", "Atende", "Retorno"…), para
  // o documento poder ganhar colunas sem quebrar a leitura.
  var col = <String, int>{};
  void fechar() {
    if (atual != null && lista.isNotEmpty) segmentos.add((atual, lista));
  }

  for (final linha in md.replaceAll('\r\n', '\n').split('\n')) {
    final l = linha.trim();
    final s = RegExp(r'^## \d+\.\s+(.+)$').firstMatch(l);
    if (s != null) {
      fechar();
      atual = s.group(1)!.trim();
      lista = [];
      continue;
    }
    if (l.startsWith('## ')) {
      fechar();
      atual = null;
      lista = [];
      continue;
    }
    if (atual == null || !l.startsWith('|') || l.contains('---')) continue;
    final c = l.split('|').map((x) => x.trim()).toList();
    if (c.length > 1 && c[1] == 'Profissão') {
      col = {for (final (i, n) in c.indexed) n: i};
      continue;
    }
    if (c.length < 6) continue;
    String? de(String nome) {
      final i = col[nome];
      return i == null || i >= c.length ? null : c[i];
    }

    final nome = de('Profissão') ?? c[1];
    final sinonimos = de('Também chamado de') ?? '';
    lista.add(
      ProfissaoCatalogo(
        nome: _limpar(nome),
        segmento: atual,
        atende: _atende(de('Atende') ?? ''),
        sinonimos: [
          for (final x in sinonimos.split(','))
            if (_limpar(x).isNotEmpty) _limpar(x),
        ],
        especialidades: [
          for (final x in (de('Especialidades') ?? '').split('·'))
            if (x.trim().isNotEmpty) _limpar(x),
        ],
        regulada: nome.contains('Reg.') || sinonimos.contains('Reg.'),
        retornoDias: _dias(de('Retorno')),
        fixo: (de('Fixo') ?? '').trim().toLowerCase() == 'sim',
      ),
    );
  }
  fechar();
  return segmentos;
}

/// Lê o `.md` (assets agora; URL pública depois).
abstract class FonteCatalogo {
  Future<String> ler();
}

class FonteCatalogoAssets implements FonteCatalogo {
  const FonteCatalogoAssets();

  @override
  Future<String> ler() =>
      rootBundle.loadString('../docs/catalogo-de-servicos.md', cache: false);
}

/// Catálogo carregado. Versão simulada.
class CatalogoServicosRepo extends ChangeNotifier {
  FonteCatalogo fonte = const FonteCatalogoAssets();
  List<(String, List<ProfissaoCatalogo>)> segmentos = const [];

  Iterable<ProfissaoCatalogo> get todas =>
      segmentos.expand((s) => s.$2);

  Future<void> carregar() async {
    if (segmentos.isNotEmpty) return;
    segmentos = lerCatalogo(await fonte.ler());
    notifyListeners();
  }

  ProfissaoCatalogo? porNome(String nome) =>
      todas.where((p) => p.nome == nome).firstOrNull;

  /// A profissão do catálogo para um nome do app, mesmo quando o app usa
  /// um nome curto ou um sinônimo ("Montador" → Montador de móveis,
  /// "Limpeza" → Diarista, "Encanadora" → Encanador). Ordem: nome exato,
  /// sinônimo ("Também chamado de"), nome no masculino. Nulo = fora do
  /// catálogo.
  ProfissaoCatalogo? encontrar(String nome) {
    final exato = porNome(nome);
    if (exato != null) return exato;
    final n = _normal(nome);
    if (n.isEmpty) return null;
    bool mesmoNome(ProfissaoCatalogo p) => _normal(p.nome) == n;
    bool sinonimo(ProfissaoCatalogo p) =>
        p.sinonimos.any((s) => _normal(s) == n);
    final achou =
        todas.where(mesmoNome).firstOrNull ??
        todas.where(sinonimo).firstOrNull;
    if (achou != null) return achou;
    // "Encanadora", "Diarista" já é igual: tira o "a" do feminino.
    if (n.endsWith('a') && n.length > 3) {
      final m = n.substring(0, n.length - 1);
      return todas.where((p) => _normal(p.nome) == m).firstOrNull;
    }
    return null;
  }
}

/// Minúsculas, sem acento e sem espaços sobrando (para comparar nomes).
String _normal(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().trim().split('')) {
    final i = de.indexOf(ch);
    b.write(i < 0 ? ch : para[i]);
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// Instância única usada pelo app.
final catalogoServicos = CatalogoServicosRepo();
