import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// Artigo da central de ajuda. Sem [secoes] o texto ainda não foi escrito.
@immutable
class Artigo {
  const Artigo(this.titulo, {this.resumo, this.secoes = const []});

  final String titulo;
  final String? resumo;
  final List<(String titulo, String texto)> secoes;

  bool get temTexto => secoes.isNotEmpty;
}

/// Assunto da ajuda com seus artigos.
@immutable
class AssuntoAjuda {
  const AssuntoAjuda(
    this.titulo,
    this.icone,
    this.artigos, {
    this.soNaBusca = const [],
  });

  final String titulo;
  final IconData icone;

  /// Artigos listados na tela do assunto.
  final List<Artigo> artigos;

  /// Artigos que só aparecem na busca.
  final List<Artigo> soNaBusca;
}

const artigoPagamento = Artigo(
  'Como funciona o pagamento?',
  resumo: 'Você combina o valor com o profissional\nno chat e confirma antes do serviço.',
  secoes: [
    (
      'Pelo app',
      'Pague com cartão ou Pix. A cobrança só acontece depois que você confirma o valor.',
    ),
    (
      'Direto ao profissional',
      'Também pode pagar por fora. Nesse caso, vocês dois confirmam o pagamento no app.',
    ),
  ],
);

const assuntosAjuda = [
  AssuntoAjuda('Pedidos e profissionais', TablerIcons.tool, [
    Artigo('O profissional não apareceu'),
    Artigo('Como cancelar um pedido?'),
  ]),
  AssuntoAjuda(
    'Pagamento e valores',
    TablerIcons.credit_card,
    [
      artigoPagamento,
      Artigo('Posso pagar direto ao profissional?'),
      Artigo('Cobraram o valor errado'),
      Artigo('Como pedir reembolso?'),
      Artigo('Como adicionar ou trocar cartão?'),
      Artigo('Pagar com Pix'),
    ],
    soNaBusca: [
      Artigo('Pix não foi confirmado'),
      Artigo('Chave Pix do profissional'),
    ],
  ),
  AssuntoAjuda('Conta e acesso', TablerIcons.user, []),
  AssuntoAjuda('Segurança', TablerIcons.shield_check, []),
];

/// Perguntas frequentes da tela Ajuda.
final perguntasFrequentes = [
  artigoPagamento,
  assuntosAjuda[0].artigos[0],
  assuntosAjuda[0].artigos[1],
];

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

/// Busca nos títulos dos artigos (sem diferenciar acentos e maiúsculas).
List<Artigo> buscarAjuda(String termo) {
  final t = _semAcento(termo.trim());
  if (t.isEmpty) return const [];
  final vistos = <Artigo>{};
  return [
    for (final a in assuntosAjuda)
      for (final artigo in [...a.artigos, ...a.soNaBusca])
        if (_semAcento(artigo.titulo).contains(t) && vistos.add(artigo)) artigo,
  ];
}

/// Pedido recente, para o suporte saber do que se trata.
@immutable
class PedidoRecente {
  const PedidoRecente({
    required this.servico,
    required this.profissional,
    required this.resumo,
    required this.descricao,
    required this.quando,
    required this.icone,
  });

  final String servico;
  final String profissional;

  /// Curto, na lista ("Vazamento na pia").
  final String resumo;

  /// Completo, no chat ("Vazamento na pia da cozinha").
  final String descricao;
  final String quando;
  final IconData icone;
}

/// Mais recentes primeiro. Versão simulada (sem backend).
const pedidosRecentes = [
  PedidoRecente(
    servico: 'Encanador',
    profissional: 'Luiza',
    resumo: 'Vazamento na pia',
    descricao: 'Vazamento na pia da cozinha',
    quando: 'Hoje',
    icone: TablerIcons.droplet,
  ),
  PedidoRecente(
    servico: 'Eletricista',
    profissional: 'Carlos',
    resumo: 'Tomada sem energia',
    descricao: 'Tomada sem energia',
    quando: '12 out',
    icone: TablerIcons.bolt,
  ),
  PedidoRecente(
    servico: 'Pintor',
    profissional: 'Marcos',
    resumo: 'Parede da sala',
    descricao: 'Parede da sala',
    quando: '28 set',
    icone: TablerIcons.brush,
  ),
];
