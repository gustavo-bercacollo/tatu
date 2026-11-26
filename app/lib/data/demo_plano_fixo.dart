import 'dart:async';

import 'package:clock/clock.dart';

import 'conta.dart';
import 'conversas.dart';
import 'conversas_profissional.dart';
import 'plano_fixo.dart';
import 'servico_profissional.dart';

/// Demonstração do selo "Plano fixo" (RN-200 a RN-205). Só roda ao abrir
/// o app (main.dart); os testes começam sem planos.
///
/// Cliente: plano mensal com a Júlia (diarista), visita hoje, uma visita
/// feita e uma cobrança. Profissional (Luiza Vilela): plano ativo com o
/// Roberto (visita hoje) e plano pausado com o Bruno.
///
/// Com [simularSaida], a Júlia sai para a visita de hoje depois desse tempo
/// (RN-206: o card muda para "a caminho").
///
/// Com [visitaHojeDoCliente] falso, a visita da Júlia fica para amanhã: o
/// cliente abre o app sem nada em andamento (a demonstração começa no
/// primeiro chamado).
void sementeDemoPlanoFixo({
  Duration? simularSaida,
  bool visitaHojeDoCliente = true,
}) {
  final agora = clock.now();
  final dia = agora.weekday == DateTime.sunday
      ? DateTime.monday
      : agora.weekday;
  // Amanhã, sem domingo (domingo → segunda).
  final amanha = agora.weekday >= DateTime.saturday
      ? DateTime.monday
      : agora.weekday + 1;
  final inicio = DateTime(
    agora.year,
    agora.month,
    agora.day,
  ).subtract(const Duration(days: 7));

  PlanoFixo? plano({
    required String cliente,
    required String profissional,
    required String profissao,
    bool feminino = true,
    bool clienteFeminina = true,
    int? diaDaVisita,
  }) {
    final p = planosFixos.pedir(
      cliente: cliente,
      profissional: profissional,
      endereco: 'Rua das Flores, 120 · $cliente',
      frequencia: FrequenciaPlano.mensal,
      visitasPorSemana: 1,
      dias: [diaDaVisita ?? dia],
      horario: '9:00',
      profissao: profissao,
      feminino: feminino,
      clienteFeminina: clienteFeminina,
      agora: agora,
    );
    if (p == null) return null;
    planosFixos
      ..enviarValor(p, 150)
      ..confirmar(p, cartao: 'Visa 4242', inicio: inicio);
    // A visita da semana passada já foi feita.
    for (final v in p.visitas) {
      if (v.dia.isBefore(DateTime(agora.year, agora.month, agora.day))) {
        v.situacao = SituacaoVisita.feita;
      }
    }
    return p;
  }

  // ---------- Cliente ----------
  final julia = plano(
    cliente: conta.nomeCompleto,
    profissional: 'Júlia Costa',
    profissao: 'Diarista',
    diaDaVisita: visitaHojeDoCliente ? null : amanha,
  );
  final hoje = julia?.visitaDeHoje(agora);
  if (julia != null && hoje != null && simularSaida != null) {
    Timer(simularSaida, () => planosFixos.saiuParaVisita(hoje));
  }
  // RN-233: o mês passado, com as 4 visitas pagas (uma por semana).
  julia?.cobrancas.add(
    CobrancaPlano(
      visitasFeitas: 4,
      total: 600,
      comissao: RegrasPlanoFixo.comissao(600),
      visitas: [
        for (var s = 4; s >= 1; s--)
          VisitaCobrada(inicio.subtract(Duration(days: 7 * s)), valor: 150),
      ],
    ),
  );
  if (!conversas.conversas.any((c) => c.nome == 'Júlia Costa')) {
    conversas.conversas.insert(
      1,
      Conversa(
        nome: 'Júlia Costa',
        profissao: 'Diarista',
        feminino: true,
        servico: 'Diarista',
        descricao: 'Limpeza da casa',
        rua: 'Rua das Flores',
        quando: 'ontem',
        concluidoEm: '18 nov',
        mensagens: [
          MensagemChat(texto: 'Tudo limpinho! Deixei a chave.'),
          MensagemChat(texto: 'Obrigada, Júlia! Até a próxima.', minha: true),
        ],
      ),
    );
  }

  // ---------- Profissional ----------
  plano(
    cliente: 'Roberto Alves',
    profissional: 'Luiza Vilela',
    profissao: 'Diarista',
    clienteFeminina: false,
  );
  final bruno = plano(
    cliente: 'Bruno Santos',
    profissional: 'Luiza Vilela',
    profissao: 'Diarista',
    clienteFeminina: false,
  );
  if (bruno != null) {
    bruno
      ..status = StatusPlano.pausado
      ..visitas.clear();
  }
  if (!conversasProfissional.conversas.any((c) => c.nome == 'Bruno Santos')) {
    conversasProfissional.conversas.add(
      ConversaProfissional(
        chamado: const ChamadoNovo(
          cliente: 'Bruno Santos',
          feminino: false,
          resumo: 'Limpeza semanal',
          profissao: 'Diarista',
          bairro: 'Pinheiros',
          distanciaKm: 2.0,
        ),
        ultima: 'Combinado.',
        quando: 'ontem',
        concluidaPor: 150,
        concluidaEm: '10 nov',
      ),
    );
  }
}
