import 'package:clock/clock.dart';

import '../shared/formatadores.dart';
import 'canal_tatu.dart';
import 'conta.dart';
import 'ganhos.dart';
import 'profissional.dart';
import 'retorno.dart';

/// Liga o retorno (RN-183 a RN-196) ao resto do app: faltas e dívida do
/// profissional, repasses presos e as mensagens do canal do Tatu.
/// Versão simulada: cliente e profissional estão no mesmo aparelho; cada
/// lado só recebe o que é dele (pelo nome da conta).

bool _ehOProfissional(String nome) =>
    profissional.nome.isNotEmpty && nome == profissional.nome;

bool _ehOCliente(String nome) => nome == conta.nomeCompleto;

/// RN-185/RN-188: repasses presos que cobrem a devolução. Do profissional
/// da demo, o que ele tem a receber; dos outros (simulados), o valor preso.
double saldoPresoDe(String nome) {
  final presos = retornos.presosDe(nome);
  if (!_ehOProfissional(nome)) return presos;
  final aReceber = ganhos.semana.aReceber;
  return presos < aReceber ? presos : aReceber;
}

/// RN-193: soma 1 falta ao profissional.
void faltaNoRetorno(String nome) {
  if (_ehOProfissional(nome)) profissional.registrarFalta();
}

/// RN-188: confere os prazos (48 h, 7 dias, não veio, "Resolveu?").
void conferirPrazosRetorno({DateTime? agora}) {
  final antes = {
    for (final r in retornos.retornos) r: r.situacao,
  };
  retornos.conferirPrazos(
    agora: agora,
    presos: saldoPresoDe,
    falta: faltaNoRetorno,
  );
  for (final r in retornos.retornos) {
    if (antes[r] != r.situacao &&
        r.situacao == SituacaoRetorno.resolvidoAutomatico) {
      _cobrar(r, RegrasRetorno.devolucao(r.valorServico));
      _avisarResolvidoAutomatico(r);
    }
  }
  // RN-215: lembretes na véspera e 1 hora antes, para os dois.
  final hoje = agora ?? clock.now();
  for (final r in retornos.retornos) {
    for (final d in retornos.lembretesDevidos(r, agora: hoje)) {
      _lembrar(r, d, hoje);
    }
  }
  // RN-199: fotos guardadas além do prazo são apagadas.
  retornos.apagarFotosAntigas(agora: agora);
}

/// RN-215: lembrete do retorno marcado, pelo canal do Tatu de cada lado.
void _lembrar(PedidoRetorno r, Duration antes, DateTime agora) {
  final m = r.marcadoPara!;
  final q = quandoRetorno(m);
  final quando = '${q[0].toLowerCase()}${q.substring(1)}';
  final resumo = antes >= const Duration(hours: 24)
      ? 'Retorno amanhã'
      : 'Retorno em 1 hora';
  final id = 'retorno-lembrete-${r.servico}-${m.toIso8601String()}-'
      '${antes.inMinutes}';
  if (_ehOCliente(r.cliente)) {
    canalTatu.cliente.receber(
      MensagemTatu(
        id: '$id-cliente',
        em: agora,
        resumo: '$resumo com ${r.oProfissional}',
        texto:
            'Lembrete: o retorno com ${r.oProfissional} é $quando. Na hora, '
            'passe o código ${r.codigo}.',
      ),
    );
  }
  if (_ehOProfissional(r.profissional)) {
    canalTatu.profissional.receber(
      MensagemTatu(
        id: '$id-profissional',
        em: agora,
        resumo: '$resumo com ${r.oCliente}',
        texto:
            'Lembrete: o retorno com ${r.oCliente} é $quando. Peça o código '
            'na porta para começar.',
      ),
    );
  }
}

/// P157 · RN-198: o profissional recebe a decisão automática pelo canal
/// do Tatu, com "Pedir revisão".
void _avisarResolvidoAutomatico(PedidoRetorno r) {
  if (!_ehOProfissional(r.profissional)) return;
  canalTatu.profissional.receber(mensagemResolvidoAutomatico(r));
}

/// P157 · "Resolvido automaticamente · Devolução de R$ X · 1 falta".
MensagemTatu mensagemResolvidoAutomatico(PedidoRetorno r) {
  final em = r.decididoEm ?? clock.now();
  final motivo = switch (r.falha) {
    FalhaProfissional.naoMarcou =>
      'você não marcou o retorno em ${RegrasRetorno.marcarEm.inDays} dias',
    FalhaProfissional.naoVeio => 'você não veio no retorno marcado',
    _ =>
      'você não respondeu em '
          '${RegrasRetorno.respostaProfissional.inHours} horas',
  };
  final devolucao = r.resolucao == ResolucaoAutomatica.devolucao;
  return MensagemTatu(
    id: 'automatico-${r.servico}',
    em: em,
    resumo: 'Retorno resolvido automaticamente',
    texto:
        'Oi, ${profissional.primeiroNome}! ${r.clienteFeminina ? 'A' : 'O'} '
        '${r.primeiroCliente} pediu um retorno do serviço de '
        '${r.diaServico} e $motivo.',
    decisao: DecisaoTatu(
      titulo: devolucao
          ? 'Devolução de ${reais(r.valorServico)}'
          : 'Outro profissional vai refazer',
      texto: devolucao
          ? 'Descontada dos seus próximos repasses.'
          : 'Até ${reais(r.valorServico)}, descontado dos seus próximos '
                'repasses.',
      rodape: '1 falta registrada',
      rodapeAviso: true,
      automatica: true,
      revisaoServico: r.servico,
      revisaoEm: em,
      revisaoQuem: r.profissional,
    ),
    textoDepois:
        'Algo impediu sua resposta? Peça revisão em até '
        '${RegrasRetorno.prazoRevisao.inDays} dias. Uma pessoa do Tatu '
        'analisa.',
  );
}

/// RN-188: o profissional não apareceu no retorno marcado.
void naoVeioNoRetorno(PedidoRetorno r) {
  retornos.naoVeio(r, presos: saldoPresoDe, falta: faltaNoRetorno);
  _cobrar(r, RegrasRetorno.devolucao(r.valorServico));
  _avisarResolvidoAutomatico(r);
}

/// RN-192: o que o profissional recebeu sai dos presos; sem saldo, vira
/// dívida ligada à conta dele no Tatu. A comissão o Tatu devolve.
void _cobrar(PedidoRetorno r, Devolucao d) {
  if (!_ehOProfissional(r.profissional) || d.total <= 0) return;
  final saldo = saldoPresoDe(r.profissional);
  final falta = d.doProfissional - saldo;
  if (falta > 0) profissional.registrarDivida(falta);
}

/// RN-191: a pessoa do suporte decide. Encerra o pedido, desconta do
/// profissional, conta faltas e avisa os dois pelo canal do Tatu.
void decidirRetorno(PedidoRetorno r, DecisaoMediacao d, {DateTime? agora}) {
  final faltaAntes = profissional.faltasRetorno.length;
  retornos.decidir(r, d, agora: agora, falta: faltaNoRetorno);
  final contouFalta =
      d != DecisaoMediacao.naoProcede &&
      r.motivoMediacao != MotivoMediacao.continuouProblema;
  if (d == DecisaoMediacao.refazerComOutro) {
    _cobrar(r, RegrasRetorno.devolucao(r.valorServico));
  } else if (d.fracao > 0) {
    _cobrar(r, RegrasRetorno.devolucao(r.valorServico, fracao: d.fracao));
  }
  final em = agora ?? clock.now();
  if (_ehOCliente(r.cliente)) {
    canalTatu.cliente.receber(mensagemDecisaoCliente(r, d, em));
  }
  if (_ehOProfissional(r.profissional) ||
      profissional.faltasRetorno.length > faltaAntes) {
    canalTatu.profissional.receber(
      mensagemDecisaoProfissional(r, d, em, contouFalta: contouFalta),
    );
  }
}

/// P233 · decisão para o cliente.
MensagemTatu mensagemDecisaoCliente(
  PedidoRetorno r,
  DecisaoMediacao d,
  DateTime em,
) {
  final valor = reais(r.valorServico * (d.fracao == 0 ? 1 : d.fracao));
  final decisao = switch (d) {
    DecisaoMediacao.devolver100 || DecisaoMediacao.devolver50 => DecisaoTatu(
      titulo: 'Devolvemos $valor',
      texto: 'No ${r.pagamento}, em até 7 dias.',
      rodape: 'O pedido foi encerrado',
    ),
    DecisaoMediacao.refazerComOutro => DecisaoTatu(
      titulo: 'O Tatu paga outro ${r.servicoNome.toLowerCase()}',
      texto: 'Até ${reais(r.valorServico)}, sem custo para você.',
      rodape: 'O pedido foi encerrado',
    ),
    DecisaoMediacao.naoProcede => const DecisaoTatu(
      titulo: 'Não procede',
      texto: 'Pelas fotos e pelo chat, o serviço foi feito como combinado.',
      rodape: 'O pedido foi encerrado',
    ),
  };
  return MensagemTatu(
    id: 'decisao-cliente-${r.servico}',
    em: em,
    resumo: 'Decisão do Tatu sobre o seu retorno',
    texto:
        'Oi, ${r.primeiroCliente}! Analisamos o seu pedido de retorno do '
        'serviço ${r.profissionalFeminino ? 'da' : 'do'} '
        '${r.primeiroProfissional} (${r.diaServico}).',
    decisao: decisao,
    textoDepois: 'Obrigado por avisar. Isso ajuda a manter o Tatu confiável.',
  );
}

/// P156 · decisão para o profissional.
MensagemTatu mensagemDecisaoProfissional(
  PedidoRetorno r,
  DecisaoMediacao d,
  DateTime em, {
  required bool contouFalta,
}) {
  final valor = reais(r.valorServico * (d.fracao == 0 ? 1 : d.fracao));
  final falta = switch (r.motivoMediacao) {
    MotivoMediacao.contestouRecusa => 'A recusa sem motivo contou 1 falta',
    MotivoMediacao.contestouOutroProblema =>
      '"É outro problema" não procedeu e contou 1 falta',
    _ => null,
  };
  final rodape = contouFalta && falta != null
      ? falta
      : 'O pedido foi encerrado';
  final decisao = switch (d) {
    DecisaoMediacao.devolver100 || DecisaoMediacao.devolver50 => DecisaoTatu(
      titulo: 'Devolução de $valor',
      texto: 'O valor será descontado dos seus próximos repasses.',
      rodape: rodape,
      rodapeAviso: contouFalta && falta != null,
    ),
    DecisaoMediacao.refazerComOutro => DecisaoTatu(
      titulo: 'Outro profissional vai refazer',
      texto:
          'Até ${reais(r.valorServico)}, descontado dos seus próximos '
          'repasses.',
      rodape: rodape,
      rodapeAviso: contouFalta && falta != null,
    ),
    DecisaoMediacao.naoProcede => const DecisaoTatu(
      titulo: 'Não procede',
      texto: 'Nada será descontado. Seus repasses foram soltos.',
      rodape: 'O pedido foi encerrado',
    ),
  };
  return MensagemTatu(
    id: 'decisao-profissional-${r.servico}',
    em: em,
    resumo: 'Decisão do Tatu sobre um retorno',
    texto:
        'Oi, ${profissional.primeiroNome.isEmpty ? r.primeiroProfissional : profissional.primeiroNome}! '
        'Analisamos o pedido de retorno ${r.clienteFeminina ? 'da' : 'do'} '
        '${r.primeiroCliente} (serviço de ${r.diaServico}).',
    decisao: decisao,
    textoDepois: 'Esta decisão encerra o pedido.',
  );
}
