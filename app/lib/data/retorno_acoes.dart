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
    }
  }
}

/// RN-188: o profissional não apareceu no retorno marcado.
void naoVeioNoRetorno(PedidoRetorno r) {
  retornos.naoVeio(r, presos: saldoPresoDe, falta: faltaNoRetorno);
  _cobrar(r, RegrasRetorno.devolucao(r.valorServico));
}

/// RN-192: o que o profissional recebeu sai dos presos; sem saldo, vira
/// dívida no CPF. A comissão o Tatu devolve.
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
