import 'package:flutter/foundation.dart';

import 'seguranca.dart';

/// Etapas de um pedido, na ordem.
const etapasPedido = [
  'Pedido feito',
  'Valor combinado',
  'A caminho',
  'Serviço',
  'Pagamento',
];

/// Nomes curtos das etapas (linha do tempo na horizontal).
const etapasCurtas = [
  'Pedido',
  'Combinado',
  'A caminho',
  'Serviço',
  'Pagamento',
];

/// Pedido com profissional, ainda não concluído.
@immutable
class PedidoAndamento {
  const PedidoAndamento({
    required this.servico,
    required this.profissao,
    required this.profissional,
    required this.nota,
    required this.endereco,
    required this.valor,
    required this.pagamento,
    required this.etapasFeitas,
    this.chegaEm = '12 min',
    this.descricao = 'Vazamento na pia',
  });

  /// O que a pessoa pediu (ex.: "Vazamento na pia").
  final String descricao;

  /// Previsão de chegada (ex.: "12 min").
  final String chegaEm;

  /// Serviço pedido ("Encanador").
  final String servico;

  /// Profissão de quem atende ("Encanadora").
  final String profissao;
  final String profissional;
  final String nota;
  final String endereco;
  final String valor;
  final String pagamento;

  /// Quantas etapas de [etapasPedido] já aconteceram.
  final int etapasFeitas;

  String get primeiroNome => profissional.split(' ').first;

  /// Situação mostrada no selo verde (última etapa feita).
  String get situacao => etapasPedido[etapasFeitas - 1];
}

/// Pedido sem ninguém aceitar ainda: a busca continua em segundo plano.
@immutable
class BuscaSegundoPlano {
  BuscaSegundoPlano({
    required this.servico,
    required this.endereco,
    this.descricao = '',
    DateTime? desde,
  }) : desde = desde ?? DateTime.now();

  final String servico;
  final String endereco;

  /// O que a pessoa escreveu (ex.: "tomada da sala sem energia").
  final String descricao;

  /// Quando a busca começou.
  final DateTime desde;

  /// "há 12 min", "agora", "há 1 h".
  String get haQuanto {
    final m = DateTime.now().difference(desde).inMinutes;
    if (m < 1) return 'agora';
    if (m < 60) return 'há $m min';
    return 'há ${m ~/ 60} h';
  }
}

/// Avaliação que a pessoa deu ao profissional.
@immutable
class AvaliacaoEnviada {
  const AvaliacaoEnviada({
    required this.nota,
    this.tags = const [],
    this.comentario = '',
  });

  final int nota;
  final List<String> tags;
  final String comentario;
}

/// Pedido concluído (pago) ou cancelado.
@immutable
class PedidoConcluido {
  const PedidoConcluido({
    required this.servico,
    required this.profissao,
    required this.profissional,
    required this.descricao,
    required this.endereco,
    required this.pagamento,
    required this.valor,
    required this.dia,
    required this.hora,
    required this.mes,
    this.ano = '2026',
    this.numero = '#TT-48213',
    this.minhaAvaliacao,
    this.editavelAte,
    this.cancelado = false,
    this.pagoPorFora = false,
    this.online = false,
    this.chegaEm = '~15 min',
  });

  final String servico;
  final String profissao;
  final String profissional;
  final String descricao;
  final String endereco;
  final String pagamento;
  final String valor;

  /// "04 nov".
  final String dia;
  final String hora;
  final String ano;

  /// Para agrupar a lista ("Novembro").
  final String mes;

  /// Número do pedido no recibo ("#TT-48213").
  final String numero;

  /// O que a pessoa avaliou (null = ainda não avaliou).
  final AvaliacaoEnviada? minhaAvaliacao;

  /// Até quando dá para editar a avaliação ("09 nov").
  final String? editavelAte;

  /// Cancelado: sem valor, sem recibo e sem avaliação.
  final bool cancelado;

  /// Pago direto ao profissional: o recibo vira "Comprovante".
  final bool pagoPorFora;

  /// O profissional está online agora (para "Pedir de novo").
  final bool online;

  /// Previsão de chegada se chamar de novo.
  final String chegaEm;

  /// Estrelas que a pessoa deu (null = ainda não avaliou).
  int? get avaliacao => minhaAvaliacao?.nota;

  String get primeiroNome => profissional.split(' ').first;

  /// Profissional mulher (para "a Luiza", "Educada"…).
  bool get feminino => profissao.endsWith('a');

  PedidoConcluido avaliado(AvaliacaoEnviada a) => PedidoConcluido(
    servico: servico,
    profissao: profissao,
    profissional: profissional,
    descricao: descricao,
    endereco: endereco,
    pagamento: pagamento,
    valor: valor,
    dia: dia,
    hora: hora,
    mes: mes,
    ano: ano,
    numero: numero,
    minhaAvaliacao: a,
    editavelAte: editavelAte,
    cancelado: cancelado,
    pagoPorFora: pagoPorFora,
    online: online,
    chegaEm: chegaEm,
  );
}

/// Pedidos do cliente. Versão simulada (sem backend).
class PedidosRepo extends ChangeNotifier {
  PedidosRepo() {
    restaurar();
  }

  PedidoAndamento? andamento;
  BuscaSegundoPlano? busca;
  late List<PedidoConcluido> concluidos;

  bool get semNadaEmAndamento => andamento == null && busca == null;

  void restaurar() {
    andamento = const PedidoAndamento(
      servico: 'Encanador',
      profissao: 'Encanadora',
      profissional: 'Luiza Souza',
      nota: '4,9',
      endereco: 'Rua das Flores, 120',
      valor: r'R$ 150,00',
      pagamento: 'Visa 4242',
      etapasFeitas: 3,
    );
    busca = BuscaSegundoPlano(
      servico: 'Eletricista',
      endereco: 'Rua das Flores, 120',
      descricao: 'tomada da sala sem energia',
      desde: DateTime.now().subtract(const Duration(minutes: 12)),
    );
    concluidos = const [
      PedidoConcluido(
        servico: 'Encanador',
        profissao: 'Encanadora',
        profissional: 'Luiza Souza',
        descricao: 'Vazamento na pia',
        endereco: 'Rua das Flores, 120',
        pagamento: 'Visa 4242',
        valor: r'R$ 150,00',
        dia: '04 nov',
        hora: '15:02',
        mes: 'Novembro',
        numero: '#TT-48213',
        editavelAte: '11 nov',
        online: true,
      ),
      PedidoConcluido(
        servico: 'Eletricista',
        profissao: 'Eletricista',
        profissional: 'Rafael Lima',
        descricao: 'Tomada sem energia',
        endereco: 'Rua das Flores, 120',
        pagamento: 'Pago direto',
        valor: r'R$ 220,00',
        dia: '02 nov',
        hora: '10:05',
        mes: 'Novembro',
        numero: '#TT-47960',
        pagoPorFora: true,
        editavelAte: '09 nov',
        minhaAvaliacao: AvaliacaoEnviada(
          nota: 5,
          tags: ['Pontual', 'Educado'],
          comentario: 'Chegou no horário e explicou\ntudo direitinho.',
        ),
      ),
      PedidoConcluido(
        servico: 'Pintor',
        profissao: 'Pintor',
        profissional: 'Marcos Dias',
        descricao: 'Parede da sala',
        endereco: 'Rua das Flores, 120',
        pagamento: '',
        valor: '',
        dia: '28 out',
        hora: '09:30',
        mes: 'Novembro',
        numero: '#TT-47710',
        cancelado: true,
      ),
    ];
    notifyListeners();
  }

  /// Guarda (ou troca) a avaliação de um pedido concluído.
  void avaliar(PedidoConcluido p, AvaliacaoEnviada a) {
    concluidos = [
      for (final c in concluidos) c.numero == p.numero ? c.avaliado(a) : c,
    ];
    notifyListeners();
  }

  /// A pessoa aceitou o profissional: vira o pedido em andamento e a
  /// busca em segundo plano (se houver) acaba.
  void aceitar(PedidoAndamento p) {
    seguranca.encerrarAlerta(cliente: true);
    andamento = p;
    busca = null;
    notifyListeners();
  }

  void cancelarAndamento() {
    seguranca.encerrarAlerta(cliente: true);
    andamento = null;
    notifyListeners();
  }

  /// Ninguém aceitou ainda: o pedido segue buscando em segundo plano.
  void buscarEmSegundoPlano(BuscaSegundoPlano b) {
    busca = b;
    notifyListeners();
  }

  void cancelarBusca() {
    busca = null;
    notifyListeners();
  }

  /// Versão atual de um pedido concluído (pelo número).
  PedidoConcluido atual(PedidoConcluido p) =>
      concluidos.firstWhere((c) => c.numero == p.numero, orElse: () => p);

  /// Para a demo dos estados vazios.
  void limpar() {
    andamento = null;
    busca = null;
    concluidos = const [];
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final pedidos = PedidosRepo();
