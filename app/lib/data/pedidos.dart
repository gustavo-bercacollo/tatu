import 'package:flutter/foundation.dart';

/// Etapas de um pedido, na ordem.
const etapasPedido = [
  'Pedido feito',
  'Valor combinado',
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
  });

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
  const BuscaSegundoPlano({required this.servico, required this.endereco});

  final String servico;
  final String endereco;
}

/// Pedido concluído e pago.
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
    this.avaliacao,
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

  /// Para agrupar a lista ("Novembro").
  final String mes;

  /// Estrelas que a pessoa deu (null = ainda não avaliou).
  final int? avaliacao;
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
    busca = const BuscaSegundoPlano(
      servico: 'Eletricista',
      endereco: 'Rua das Flores, 120',
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
        hora: '14:20',
        mes: 'Novembro',
        avaliacao: 5,
      ),
      PedidoConcluido(
        servico: 'Eletricista',
        profissao: 'Eletricista',
        profissional: 'Rafael Lima',
        descricao: 'Tomada sem energia',
        endereco: 'Rua das Flores, 120',
        pagamento: 'Pix',
        valor: r'R$ 220,00',
        dia: '02 nov',
        hora: '10:05',
        mes: 'Novembro',
      ),
    ];
    notifyListeners();
  }

  void cancelarAndamento() {
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
