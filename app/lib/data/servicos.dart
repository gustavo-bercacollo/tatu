import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

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

const _chaveiro = ServicoCatalogo(
  'Chaveiro',
  TablerIcons.key,
  detalhe: 'Fechaduras e cópias de chave',
  palavras: ['chave', 'fechadura', 'tranca'],
);
const _vidraceiro = ServicoCatalogo(
  'Vidraceiro',
  TablerIcons.photo,
  detalhe: 'Vidros, janelas e box',
  palavras: ['vidro', 'janela', 'box', 'espelho'],
);

/// Grupos da lista "Outros serviços".
const gruposServicos = <(String, List<ServicoCatalogo>)>[
  (
    'Casa e reparos',
    [
      _chaveiro,
      ServicoCatalogo(
        'Marceneiro',
        TablerIcons.tool,
        detalhe: 'Móveis sob medida e reparos',
        palavras: ['madeira', 'movel', 'porta'],
      ),
      _vidraceiro,
      ServicoCatalogo(
        'Serralheiro',
        TablerIcons.tool,
        detalhe: 'Portões, grades e solda',
        palavras: ['portao', 'grade', 'solda'],
      ),
      ServicoCatalogo(
        'Gesseiro',
        TablerIcons.brush,
        detalhe: 'Forro, sanca e drywall',
        palavras: ['gesso', 'forro', 'drywall'],
      ),
    ],
  ),
  (
    'Aparelhos e clima',
    [
      ServicoCatalogo(
        'Ar-condicionado',
        TablerIcons.snowflake,
        detalhe: 'Instalação, limpeza e conserto',
        palavras: ['ar condicionado', 'split'],
      ),
      ServicoCatalogo(
        'Técnico de TV',
        TablerIcons.device_tv,
        detalhe: 'TV, som e antena',
        palavras: ['televisao', 'antena'],
      ),
      ServicoCatalogo(
        'Eletrodomésticos',
        TablerIcons.bolt,
        detalhe: 'Geladeira, máquina e fogão',
        palavras: ['geladeira', 'maquina de lavar', 'fogao', 'microondas'],
      ),
    ],
  ),
];

/// Atalhos "Mais pedidos perto de você".
const maisPedidos = ['Chaveiro', 'Limpeza', 'Vidraceiro'];

/// Só aparecem na busca (e nos atalhos).
const _soNaBusca = [
  ServicoCatalogo(
    'Desentupidora',
    TablerIcons.droplet,
    detalhe: 'Pia, ralo, vaso e esgoto',
    palavras: ['desentup', 'entup', 'ralo', 'esgoto', 'vaso'],
  ),
  ServicoCatalogo(
    'Encanador',
    TablerIcons.droplet,
    detalhe: 'Também resolve entupimento',
    palavras: ['desentup', 'entup', 'cano', 'vazamento'],
  ),
  ServicoCatalogo(
    'Limpeza',
    TablerIcons.sparkles,
    detalhe: 'Faxina e limpeza pós-obra',
    palavras: ['faxina', 'diarista'],
  ),
];

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

/// Busca por nome ou palavra (sem diferenciar acentos e maiúsculas).
List<ServicoCatalogo> buscarServicos(String termo) {
  final t = _simples(termo.trim());
  if (t.isEmpty) return const [];
  final todos = [
    for (final (_, lista) in gruposServicos) ...lista,
    ..._soNaBusca,
  ];
  return [
    for (final s in todos)
      if (_simples(s.nome).contains(t) ||
          s.palavras.any((p) => _simples(p).startsWith(t) || t.startsWith(p)))
        s,
  ];
}

/// Ícone de um serviço (principais da Home ou do catálogo).
IconData iconeServico(String nome) {
  const principais = {
    'Encanador': TablerIcons.droplet,
    'Eletricista': TablerIcons.bolt,
    'Pedreiro': TablerIcons.wall,
    'Pintor': TablerIcons.brush,
  };
  final p = principais[nome];
  if (p != null) return p;
  for (final (_, lista) in gruposServicos) {
    for (final s in lista) {
      if (s.nome == nome) return s.icone;
    }
  }
  return TablerIcons.tool;
}
