import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'catalogo_servicos.dart';
import 'profissoes_reguladas.dart';

/// Serviço do catálogo "Outros serviços".
@immutable
class ServicoCatalogo {
  const ServicoCatalogo(
    this.nome,
    this.icone, {
    this.detalhe,
    this.palavras = const [],
  });

  final String nome;
  final IconData icone;

  /// Linha cinza nos resultados da busca.
  final String? detalhe;

  /// Outras palavras que levam a este serviço na busca.
  final List<String> palavras;
}

/// Escolha "Não sei qual serviço": a gente descobre pela descrição.
const naoSeiServico = 'Não sei';

/// Ícone por segmento do catálogo (os principais têm ícone próprio em
/// [iconeServico]).
IconData _iconeSegmento(String segmento) {
  final t = segmento.toLowerCase();
  if (t.contains('casa')) return TablerIcons.home;
  if (t.contains('limpeza')) return TablerIcons.sparkles;
  if (t.contains('mudan')) return TablerIcons.truck;
  if (t.contains('beleza')) return TablerIcons.scissors;
  if (t.contains('pessoas') || t.contains('pets')) return TablerIcons.heart;
  if (t.contains('aulas')) return TablerIcons.school;
  if (t.contains('tecnologia')) return TablerIcons.device_laptop;
  if (t.contains('eventos')) return TablerIcons.confetti;
  return TablerIcons.briefcase;
}

/// RN-161: uma profissão do catálogo como item da lista.
ServicoCatalogo _item(ProfissaoCatalogo p, {String? detalhe}) => ServicoCatalogo(
  p.nome,
  _iconeDe(p.nome) ?? _iconeSegmento(p.segmento),
  detalhe: detalhe ?? p.especialidades.take(3).join(', '),
  palavras: p.sinonimos,
);

/// RN-161: segmentos do "Outros" (cliente no local e profissional), lidos
/// de `docs/catalogo-de-servicos.md`.
List<(String, List<ServicoCatalogo>)> get gruposServicos => [
  for (final (nome, lista) in catalogoServicos.segmentos)
    if (lista.any((p) => p.local))
      (
        nome,
        [
          for (final p in lista)
            if (p.local) _item(p),
        ],
      ),
];

/// Pedido à distância: as profissões que atendem à distância.
(String, List<ServicoCatalogo>) get grupoDistancia => (
  'À distância',
  [
    for (final p in catalogoServicos.todas)
      if (p.remoto) _item(p),
  ],
);

/// RN-161: no cadastro, todos os segmentos (no local e à distância).
List<(String, List<ServicoCatalogo>)> get gruposProfissoes => [
  for (final (nome, lista) in catalogoServicos.segmentos)
    (nome, [for (final p in lista) _item(p)]),
];

/// Atalhos "Mais pedidos perto de você".
const maisPedidos = ['Chaveiro', 'Limpeza', 'Vidraceiro'];

/// Atalhos "Mais procuradas" no cadastro do profissional (C11).
const maisProcuradas = ['Diarista', 'Faz-tudo', 'Vidraceiro'];

String _simples(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i < 0 ? ch : para[i]);
  }
  return b.toString();
}

/// RN-156: profissões reguladas aceitas, para a lista do profissional.
List<ServicoCatalogo> get servicosRegulados => [
  for (final p in profissoesReguladas.reguladasAceitas)
    ServicoCatalogo(
      p.nome,
      TablerIcons.certificate,
      detalhe: 'Exige registro no ${p.conselho}',
      palavras: [for (final a in p.apelidos) a.toLowerCase()],
    ),
];

/// RN-161: busca por nome e sinônimos, sem acento e sem diferenciar
/// maiúsculas. Achou pelo sinônimo: "Também chamado de …". Com
/// [profissional], inclui as profissões reguladas (RN-156) e nunca mostra
/// as "fora do Tatu" (RN-160).
List<ServicoCatalogo> buscarServicos(String termo, {bool profissional = false}) {
  final t = _simples(termo.trim());
  if (t.isEmpty) return const [];
  final achados = <String, ServicoCatalogo>{};
  void ver(
    ServicoCatalogo s, {
    List<String>? sinonimos,
    List<String> especialidades = const [],
  }) {
    if (!profissoesReguladas.permitida(s.nome)) return;
    final chave = normalizarProfissao(s.nome);
    if (_simples(s.nome).contains(t)) {
      achados[chave] = s;
      return;
    }
    final sin = (sinonimos ?? s.palavras).where(
      (p) => _simples(p).contains(t) || t.startsWith(_simples(p)),
    );
    if (sin.isNotEmpty) {
      achados[chave] = ServicoCatalogo(
        s.nome,
        s.icone,
        detalhe: 'Também chamado de ${sin.first}',
        palavras: s.palavras,
      );
      return;
    }
    // Pela especialidade ("desentup" → Encanador · Desentupimento).
    final esp = especialidades.where((e) => _simples(e).contains(t));
    if (esp.isNotEmpty && t.length >= 4) {
      achados[chave] = ServicoCatalogo(
        s.nome,
        s.icone,
        detalhe: esp.first,
        palavras: s.palavras,
      );
    }
  }

  for (final p in catalogoServicos.todas) {
    ver(_item(p), especialidades: p.especialidades);
  }
  if (profissional) {
    for (final s in servicosRegulados) {
      if (!achados.containsKey(normalizarProfissao(s.nome))) ver(s);
    }
  }
  return achados.values.toList();
}

IconData? _iconeDe(String nome) => const {
  'Encanador': TablerIcons.droplet,
  'Eletricista': TablerIcons.bolt,
  'Pedreiro': TablerIcons.wall,
  'Pintor': TablerIcons.brush,
  'Chaveiro': TablerIcons.key,
  'Vidraceiro': TablerIcons.photo,
  'Designer': TablerIcons.palette,
  'Designer gráfico': TablerIcons.palette,
  'Programador': TablerIcons.code,
  'Professor': TablerIcons.school,
  'Contador': TablerIcons.calculator,
  'Advogado': TablerIcons.scale,
}[nome];

/// Ícone de um serviço (principais ou o do segmento no catálogo).
IconData iconeServico(String nome) {
  final p = _iconeDe(nome);
  if (p != null) return p;
  final c = catalogoServicos.porNome(nome);
  return c == null ? TablerIcons.tool : _iconeSegmento(c.segmento);
}
