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
  });

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
    if (c.length < 6 || c[1] == 'Profissão') continue;
    lista.add(
      ProfissaoCatalogo(
        nome: _limpar(c[1]),
        segmento: atual,
        atende: _atende(c[2]),
        sinonimos: [
          for (final x in c[3].split(','))
            if (_limpar(x).isNotEmpty) _limpar(x),
        ],
        especialidades: [
          for (final x in c[4].split('·'))
            if (x.trim().isNotEmpty) _limpar(x),
        ],
        regulada: c[1].contains('Reg.') || c[3].contains('Reg.'),
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
}

/// Instância única usada pelo app.
final catalogoServicos = CatalogoServicosRepo();
