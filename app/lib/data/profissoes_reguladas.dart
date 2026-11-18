import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// RN-156 a RN-160: profissões reguladas. A lista vem de
/// `docs/profissoes-reguladas.md` (fonte única), empacotado no app.

/// Onde a profissão atende (coluna "No local / À distância").
enum AtendeEm { local, distancia, ambos }

/// Uma profissão da lista.
@immutable
class ProfissaoTatu {
  const ProfissaoTatu({
    required this.nome,
    required this.regulada,
    required this.permitida,
    this.apelidos = const [],
    this.conselho,
    this.exige,
    this.ondeConferir,
    this.atende = AtendeEm.ambos,
    this.motivo,
  });

  /// Nome no Tatu ("Personal trainer").
  final String nome;

  /// Outros nomes da mesma linha ("Profissional de educação física").
  final List<String> apelidos;

  /// RN-156: exige registro no conselho ou órgão.
  final bool regulada;

  /// RN-160: "Fora do Tatu por enquanto" não pode ser cadastrada.
  final bool permitida;

  /// "CREF", "OAB", "CNH"…
  final String? conselho;

  /// "Registro no CREF" (texto da coluna "O que exige", sem **).
  final String? exige;

  /// "Consulta do CONFEF/CREF".
  final String? ondeConferir;
  final AtendeEm atende;

  /// Fora do Tatu: o motivo.
  final String? motivo;

  /// RN-156: o registro é a CNH (lida no documento da verificação).
  bool get usaCnh => conselho == 'CNH';

  bool chamaSe(String outro) {
    final n = normalizarProfissao(outro);
    return normalizarProfissao(nome) == n ||
        apelidos.any((a) => normalizarProfissao(a) == n);
  }
}

String _semAcento(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i < 0 ? ch : para[i]);
  }
  return b.toString();
}

/// "Advogada" e "Advogado(a)" → "advogad"; sem acento, sem "(a)".
String normalizarProfissao(String s) {
  var t = _semAcento(s.replaceAll('(a)', '').trim());
  t = t.replaceAll(RegExp(r'\s+'), ' ');
  // Gênero: tira a última vogal de cada palavra (advogado/advogada).
  return t
      .split(' ')
      .map((p) => p.length > 3 && RegExp(r'[ao]$').hasMatch(p)
          ? p.substring(0, p.length - 1)
          : p)
      .join(' ');
}

/// "Engenheiro(a) (civil, elétrico…)" → ["Engenheiro"];
/// "Personal trainer / profissional de educação física" → os dois;
/// "Médico(a) (CRM), dentista (CRO)" → ["Médico", "Dentista"].
List<String> _nomesDaCelula(String celula, {bool varios = false}) {
  var c = celula.replaceAll('(a)', '').replaceAll('**', '');
  // Detalhes entre parênteses saem antes de separar os nomes.
  if (!varios) c = c.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
  final partes = varios
      ? c.split(RegExp(r',\s*'))
      : c.split(RegExp(r'\s+/\s+|,\s*|\s+ou\s+'));
  final nomes = <String>[];
  for (var p in partes) {
    p = p.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
    if (p.isEmpty || p == 'etc.') continue;
    nomes.add(p[0].toUpperCase() + p.substring(1));
  }
  return nomes;
}

AtendeEm _atende(String s) => switch (s.trim().toLowerCase()) {
  'no local' => AtendeEm.local,
  'à distância' => AtendeEm.distancia,
  _ => AtendeEm.ambos,
};

/// Lê o `.md` (tabelas das seções 1, 2 e 3).
List<ProfissaoTatu> lerProfissoes(String md) {
  final lista = <ProfissaoTatu>[];
  var secao = 0;
  for (final linha in md.replaceAll('\r\n', '\n').split('\n')) {
    final l = linha.trim();
    final s = RegExp(r'^## (\d)\.').firstMatch(l);
    if (s != null) {
      secao = int.parse(s.group(1)!);
      continue;
    }
    if (l.startsWith('## ')) {
      secao = 0;
      continue;
    }
    if (!l.startsWith('|') || l.contains('---')) continue;
    final c = l.split('|').map((x) => x.trim()).toList();
    if (c.length < 3 || c[1].startsWith('Profissão')) continue;
    switch (secao) {
      case 1:
        if (c.length < 5) continue;
        final nomes = _nomesDaCelula(c[1]);
        final conselho = RegExp(r'\*\*([^*]+)\*\*').firstMatch(c[2])?.group(1);
        lista.add(
          ProfissaoTatu(
            nome: nomes.first,
            apelidos: nomes.skip(1).toList(),
            regulada: true,
            permitida: true,
            conselho: conselho,
            exige: c[2].replaceAll('**', ''),
            ondeConferir: c[3],
            atende: _atende(c[4]),
          ),
        );
      case 2:
        for (final n in _nomesDaCelula(c[1])) {
          lista.add(ProfissaoTatu(nome: n, regulada: false, permitida: true));
        }
      case 3:
        // "Médico(a) (CRM), dentista (CRO)": o conselho vem entre parênteses.
        for (final parte in c[1].replaceAll('(a)', '').split(RegExp(r',\s*'))) {
          final conselho = RegExp(r'\(([A-Z]+)\)').firstMatch(parte)?.group(1);
          for (final n in _nomesDaCelula(parte, varios: true)) {
            lista.add(
              ProfissaoTatu(
                nome: n,
                regulada: true,
                permitida: false,
                conselho: conselho,
                motivo: c.length > 2 ? c[2] : null,
              ),
            );
          }
        }
    }
  }
  return lista;
}

/// Lê o `.md` (assets agora; URL pública depois).
abstract class FonteProfissoes {
  Future<String> ler();
}

class FonteProfissoesAssets implements FonteProfissoes {
  const FonteProfissoesAssets();

  @override
  Future<String> ler() =>
      rootBundle.loadString('../docs/profissoes-reguladas.md', cache: false);
}

/// Lista carregada. Versão simulada.
class ProfissoesReguladasRepo extends ChangeNotifier {
  FonteProfissoes fonte = const FonteProfissoesAssets();
  List<ProfissaoTatu> lista = const [];

  Future<void> carregar() async {
    if (lista.isNotEmpty) return;
    lista = lerProfissoes(await fonte.ler());
    notifyListeners();
  }

  /// Testes: lista já lida.
  void definir(List<ProfissaoTatu> l) {
    lista = l;
    notifyListeners();
  }

  ProfissaoTatu? porNome(String nome) =>
      lista.where((p) => p.chamaSe(nome)).firstOrNull;

  /// RN-156: exige registro?
  bool regulada(String nome) => porNome(nome)?.regulada == true &&
      porNome(nome)?.permitida == true;

  /// RN-160: pode ser cadastrada? (fora da lista = profissão livre)
  bool permitida(String nome) => porNome(nome)?.permitida ?? true;

  /// RN-156: reguladas aceitas (aparecem em "Outras profissões").
  List<ProfissaoTatu> get reguladasAceitas => [
    for (final p in lista)
      if (p.regulada && p.permitida) p,
  ];
}

/// Instância única usada pelo app.
final profissoesReguladas = ProfissoesReguladasRepo();
