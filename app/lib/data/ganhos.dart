import 'package:flutter/foundation.dart';

/// Como o serviço foi (ou vai ser) pago.
enum SituacaoGanho { aguardando, pago }

/// Serviço feito pelo profissional (lista da Atividade).
@immutable
class ServicoFeito {
  const ServicoFeito(
    this.cliente,
    this.profissao,
    this.quando,
    this.valor,
    this.situacao,
  );

  final String cliente;
  final String profissao;

  /// "hoje, 11:20", "ontem", "2 nov".
  final String quando;

  /// O que o profissional recebe (já sem a taxa).
  final double valor;
  final SituacaoGanho situacao;
}

/// Resumo de um período (Hoje, Semana, Mês).
@immutable
class ResumoGanhos {
  const ResumoGanhos({
    required this.nome,
    required this.peloApp,
    required this.aReceber,
    this.barras = const [],
    this.rotulos = const [],
    this.atual = -1,
  });

  /// "de hoje", "da semana", "do mês" (depois de "Total").
  final String nome;
  final double peloApp;
  final double aReceber;

  /// Ganhos por dia (só na semana).
  final List<double> barras;
  final List<String> rotulos;

  /// Índice do dia de hoje nas barras.
  final int atual;

  /// O "a receber" não entra no total.
  double get total => peloApp;
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
    ),
    ServicoFeito(
      'Marcos Lima',
      'Eletricista',
      'ontem',
      220,
      SituacaoGanho.pago,
    ),
    ServicoFeito('Paula Dias', 'Encanador', '2 nov', 81, SituacaoGanho.pago),
  ];

  List<ServicoFeito> get aguardando => [
    for (final s in servicos)
      if (s.situacao == SituacaoGanho.aguardando) s,
  ];

  List<ServicoFeito> get concluidos => [
    for (final s in servicos)
      if (s.situacao != SituacaoGanho.aguardando) s,
  ];

  ResumoGanhos get hoje => const ResumoGanhos(
    nome: 'de hoje',
    peloApp: 135,
    aReceber: 150,
  );

  ResumoGanhos get semana => const ResumoGanhos(
    nome: 'da semana',
    peloApp: 436,
    aReceber: 150,
    barras: [81, 220, 135, 0, 0, 0, 0],
    rotulos: ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
    atual: 2,
  );

  ResumoGanhos get mes => const ResumoGanhos(
    nome: 'do mês',
    peloApp: 1699,
    aReceber: 150,
  );
}

/// Instância única usada pelo app enquanto não há backend.
const ganhos = GanhosRepo();
