import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// Artigo da central de ajuda. Sem [secoes] o texto ainda não foi escrito.
@immutable
class Artigo {
  const Artigo(this.titulo, {this.resumo, this.secoes = const [], this.atalho});

  final String titulo;
  final String? resumo;
  final List<(String titulo, String texto)> secoes;

  /// Em vez de texto, leva a uma tela do app (ex.: Ganhos).
  final AtalhoAjuda? atalho;

  bool get temTexto => secoes.isNotEmpty;
}

/// Telas do app que um artigo pode abrir direto.
enum AtalhoAjuda { ganhos }

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
      'Pague com cartão (até 6x) ou Pix. Quando você confirma o valor, '
          'ele fica reservado e só é cobrado no fim do serviço.',
    ),
    (
      'Sempre pelo Tatu',
      'Todo pagamento passa pelo app. Assim você tem recibo e o Tatu '
          'pode ajudar se algo der errado.',
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
const perguntasFrequentes = [
  artigoPagamento,
  Artigo('O profissional não apareceu'),
  Artigo('Como cancelar um pedido?'),
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
List<Artigo> buscarAjuda(
  String termo, [
  List<AssuntoAjuda> assuntos = assuntosAjuda,
]) {
  final t = _semAcento(termo.trim());
  if (t.isEmpty) return const [];
  final vistos = <Artigo>{};
  return [
    for (final a in assuntos)
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
    this.rotulo = 'Pedido',
    this.titulo,
    this.iniciais,
    this.saudacao,
  });

  final String servico;
  final String profissional;

  /// "Pedido" (cliente) ou "Chamado" (profissional), no cartão do chat.
  final String rotulo;

  /// Título na lista (padrão: "Encanador · Luiza").
  final String? titulo;

  /// Mostra as iniciais (cliente do chamado) em vez do ícone.
  final String? iniciais;

  /// Segunda mensagem do suporte (padrão: "Vi seu pedido com a …").
  final String? saudacao;

  String get tituloLista => titulo ?? '$servico · $profissional';

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

/// Conteúdo da central de ajuda: um para o cliente, outro para o
/// profissional. As telas são as mesmas.
@immutable
class ConteudoAjuda {
  const ConteudoAjuda({
    required this.assuntos,
    required this.perguntas,
    required this.opcoesSuporte,
    required this.recentes,
    required this.tituloRecentes,
    required this.semRecente,
    required this.respostaSuporte,
    this.profissional = false,
  });

  final List<AssuntoAjuda> assuntos;
  final List<Artigo> perguntas;

  /// "Sobre o que é?": (título, detalhe). A primeira leva à lista de
  /// recentes.
  final List<(String, String?)> opcoesSuporte;
  final List<PedidoRecente> recentes;

  /// "Qual pedido?" / "Qual chamado?".
  final String tituloRecentes;

  /// "Não é sobre um pedido" / "Não é sobre um chamado".
  final String semRecente;

  /// Resposta do atendente à primeira mensagem (simulada).
  final String respostaSuporte;
  final bool profissional;
}

const conteudoCliente = ConteudoAjuda(
  assuntos: assuntosAjuda,
  perguntas: perguntasFrequentes,
  opcoesSuporte: [
    ('Um pedido recente', 'Escolha qual'),
    ('Pagamento ou cobrança', null),
    ('Minha conta', null),
    ('Segurança ou denúncia', null),
    ('Outro assunto', null),
  ],
  recentes: pedidosRecentes,
  tituloRecentes: 'Qual pedido?',
  semRecente: 'Não é sobre um pedido',
  respostaSuporte: 'Já estou vendo, um instante.',
);

// ---------- Profissional ----------

const _quandoRecebo = Artigo(
  'Quando recebo meu dinheiro?',
  resumo: 'Todo pagamento passa pelo app.',
  secoes: [
    (
      'No seu Pix',
      'Cai no seu Pix em até 1 dia útil depois que o serviço é concluído, '
          'já sem a taxa de 10%.',
    ),
    (
      'Valor garantido',
      'Quando o cliente confirma o valor, ele fica reservado. A visita é '
          'sua mesmo se o serviço não acontecer.',
    ),
  ],
);

const _taxa = Artigo(
  'Como funciona a taxa de 10%?',
  resumo: 'O Tatu só cobra quando você recebe por um serviço.',
  secoes: [
    (
      'Por serviço',
      'Descontamos 10% do total (visita + serviço). Num total de '
          'R\$ 190,00, cai R\$ 171,00 no seu Pix.',
    ),
    (
      'Grátis',
      'Cadastro, perfil e receber chamados não têm taxa.',
    ),
  ],
);

const _semChamados = Artigo('Por que não recebo chamados?');

const assuntosAjudaProfissional = [
  AssuntoAjuda('Chamados e clientes', TablerIcons.briefcase, [_semChamados]),
  AssuntoAjuda('Ganhos e Pix', TablerIcons.wallet, [
    _quandoRecebo,
    _taxa,
    Artigo('Cliente quer pagar por fora'),
    Artigo('Trocar minha chave Pix'),
    Artigo('O Pix não caiu'),
    Artigo('Ver meus ganhos', atalho: AtalhoAjuda.ganhos),
  ]),
  AssuntoAjuda('Cadastro e verificação', TablerIcons.id, []),
  AssuntoAjuda('Segurança', TablerIcons.shield_check, []),
];

/// Chamados recentes do profissional, mais recentes primeiro.
const chamadosRecentes = [
  PedidoRecente(
    rotulo: 'Chamado',
    servico: 'Ana Martins',
    profissional: '',
    titulo: 'Ana Martins · R\$ 150',
    iniciais: 'Ana Martins',
    resumo: 'Vazamento na pia · Pago pelo app',
    descricao: 'R\$ 150,00 · Pago pelo app',
    quando: 'Hoje',
    icone: TablerIcons.user,
    saudacao: 'Como posso ajudar com esse chamado?',
  ),
  PedidoRecente(
    rotulo: 'Chamado',
    servico: 'Júlia Costa',
    profissional: '',
    titulo: 'Júlia Costa · R\$ 90',
    iniciais: 'Júlia Costa',
    resumo: 'Troca de torneira · Pago pelo app',
    descricao: 'R\$ 90,00 · Pago pelo app',
    quando: 'ontem',
    icone: TablerIcons.user,
    saudacao: 'Como posso ajudar com esse chamado?',
  ),
  PedidoRecente(
    rotulo: 'Chamado',
    servico: 'Roberto Alves',
    profissional: '',
    titulo: 'Roberto Alves · R\$ 220',
    iniciais: 'Roberto Alves',
    resumo: 'Chuveiro queimado · Pago pelo app',
    descricao: 'R\$ 220,00 · Pago pelo app',
    quando: '02 nov',
    icone: TablerIcons.user,
    saudacao: 'Como posso ajudar com esse chamado?',
  ),
];

const conteudoProfissional = ConteudoAjuda(
  assuntos: assuntosAjudaProfissional,
  perguntas: [_quandoRecebo, _taxa, _semChamados],
  opcoesSuporte: [
    ('Um chamado recente', 'Escolha qual'),
    ('Ganhos ou Pix', null),
    ('Cadastro e verificação', null),
    ('Segurança ou denúncia', null),
    ('Outro assunto', null),
  ],
  recentes: chamadosRecentes,
  tituloRecentes: 'Qual chamado?',
  semRecente: 'Não é sobre um chamado',
  respostaSuporte: 'Vou verificar o repasse, um instante.',
  profissional: true,
);
