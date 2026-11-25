import 'package:flutter/foundation.dart';

import 'profissional.dart' show taxaTatu;

/// Como o serviço foi (ou vai ser) pago.
enum SituacaoGanho { aguardando, pago }

/// Serviço feito pelo profissional (lista da Atividade e dos Ganhos).
@immutable
class ServicoFeito {
  const ServicoFeito(
    this.cliente,
    this.profissao,
    this.quando,
    this.valor,
    this.situacao, {
    this.gorjeta = 0,
  });

  final String cliente;
  final String profissao;

  /// "hoje, 11:20", "ontem", "2 nov".
  final String quando;

  /// O que o profissional recebe pelo serviço (já sem a taxa).
  final double valor;
  final SituacaoGanho situacao;

  /// RN-141/RN-143: gorjeta do cliente, 100% do profissional (sem a taxa
  /// do Tatu).
  final double gorjeta;

  /// Serviço + gorjeta.
  double get recebido => valor + gorjeta;
}

/// Resumo de um período (Hoje, Semana, Mês).
@immutable
class ResumoGanhos {
  const ResumoGanhos({
    required this.nome,
    required this.bruto,
    required this.aReceber,
    required this.quantidade,
    required this.anterior,
    required this.comparacao,
    this.gorjetas = 0,
    this.esperandoCliente = 0,
    this.barras = const [],
    this.rotulos = const [],
    this.dias = const [],
    this.atual = -1,
  });

  /// "de hoje", "da semana", "do mês" (depois de "Total").
  final String nome;

  /// Valor dos serviços pagos, antes da taxa do Tatu.
  final double bruto;

  /// RN-141/RN-143: gorjetas do período (sem taxa).
  final double gorjetas;

  /// Ainda não caiu (serviço esperando o cliente confirmar, RN-171, ou
  /// dentro das 24 horas do repasse, RN-35). Não entra no total.
  final double aReceber;

  /// Quantos esperam o cliente confirmar a conclusão (RN-171).
  final int esperandoCliente;

  /// Serviços pagos no período.
  final int quantidade;

  /// Total do período anterior (para "R$ 52 a mais que …").
  final double anterior;

  /// "que ontem", "que na semana passada", "que no mês passado".
  final String comparacao;

  /// Ganhos por dia (só na semana).
  final List<double> barras;
  final List<String> rotulos;

  /// Nome por extenso de cada barra (aparece ao tocar nela).
  final List<String> dias;

  /// Índice do dia de hoje nas barras.
  final int atual;

  /// RN-35: taxa do Tatu, só sobre os serviços (a gorjeta não paga taxa).
  double get taxa => bruto * taxaTatu;

  /// Recebido: serviços menos a taxa, mais as gorjetas.
  double get total => bruto - taxa + gorjetas;

  /// Diferença para o período anterior (positiva = ganhou mais).
  double get diferenca => total - anterior;

  /// Média por serviço (com a gorjeta).
  double get media => quantidade == 0 ? 0 : total / quantidade;
}

/// Próximo repasse para o Pix (RN-35: em até 24 horas).
@immutable
class ProximoPix {
  const ProximoPix({required this.valor, required this.quando});

  final double valor;

  /// "amanhã às 14:58".
  final String quando;
}

/// Ganhos e serviços do profissional. Versão simulada (sem backend).
class GanhosRepo {
  const GanhosRepo();

  List<ServicoFeito> get servicos => const [
    ServicoFeito(
      'Rafael Gomes',
      'Encanador',
      'hoje, 11:20',
      150,
      SituacaoGanho.aguardando,
    ),
    ServicoFeito(
      'Ana Julia',
      'Encanador',
      'hoje, 14:58',
      135,
      SituacaoGanho.pago,
      gorjeta: 10,
    ),
    ServicoFeito(
      'Marcos Lima',
      'Eletricista',
      'ontem',
      198,
      SituacaoGanho.pago,
      gorjeta: 20,
    ),
    ServicoFeito('Paula Dias', 'Encanador', 'seg', 99, SituacaoGanho.pago),
    ServicoFeito('Joana Reis', 'Encanador', '2 nov', 81, SituacaoGanho.pago),
  ];

  List<ServicoFeito> get aguardando => [
    for (final s in servicos)
      if (s.situacao == SituacaoGanho.aguardando) s,
  ];

  List<ServicoFeito> get concluidos => [
    for (final s in servicos)
      if (s.situacao != SituacaoGanho.aguardando) s,
  ];

  /// RN-35: o próximo Pix (o pagamento mais recente ainda nas 24 horas).
  ProximoPix get proximoPix =>
      const ProximoPix(valor: 145, quando: 'amanhã às 14:58');

  ResumoGanhos get hoje => const ResumoGanhos(
    nome: 'de hoje',
    bruto: 150,
    gorjetas: 10,
    aReceber: 150,
    esperandoCliente: 1,
    quantidade: 1,
    anterior: 218,
    comparacao: 'que ontem',
  );

  ResumoGanhos get semana => const ResumoGanhos(
    nome: 'da semana',
    bruto: 480,
    gorjetas: 30,
    aReceber: 150,
    esperandoCliente: 1,
    quantidade: 3,
    anterior: 410,
    comparacao: 'que na semana passada',
    barras: [99, 218, 145, 0, 0, 0, 0],
    rotulos: ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
    dias: [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ],
    atual: 2,
  );

  ResumoGanhos get mes => const ResumoGanhos(
    nome: 'do mês',
    bruto: 1820,
    gorjetas: 60,
    aReceber: 150,
    esperandoCliente: 1,
    quantidade: 12,
    anterior: 1540,
    comparacao: 'que no mês passado',
  );
}

/// Instância única usada pelo app enquanto não há backend.
const ganhos = GanhosRepo();
