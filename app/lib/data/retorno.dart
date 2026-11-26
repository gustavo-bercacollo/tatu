import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'catalogo_servicos.dart';
import 'codigo_porta.dart';
import 'plano_fixo.dart' show diaMes, diaLongo, diaCurto;
import 'profissional.dart' show taxaTatu;

/// RN-183 a RN-196: "Algo errado?" e retorno depois do serviço.
///
/// Todos os números marcados como exemplo nas regras ficam aqui. Mudou um
/// número, muda só aqui (ver "Números do retorno" em Decisões em aberto).
abstract final class RegrasRetorno {
  /// RN-45/RN-46: pagamento protegido (valor ainda retido).
  static const protegido = Duration(hours: 24);

  /// RN-186: tempo do profissional para responder ao pedido.
  static const respostaProfissional = Duration(hours: 48);

  /// RN-186/RN-213: o retorno precisa ser marcado em até 7 dias depois
  /// do pedido.
  static const marcarEm = Duration(days: 7);

  /// RN-213: até 3 horários que o cliente pode.
  static const maxHorarios = 3;

  /// RN-214: remarcar só até 12 horas antes (uma vez cada lado).
  static const antecedenciaRemarcar = Duration(hours: 12);

  /// RN-215: lembretes para os dois: na véspera (24 horas antes) e 1 hora
  /// antes.
  static const lembretes = [Duration(hours: 24), Duration(hours: 1)];

  /// RN-213: último dia para o retorno (7 dias depois do pedido, até o
  /// fim do dia).
  static DateTime limiteMarcar(DateTime pedidoEm) =>
      DateTime(pedidoEm.year, pedidoEm.month, pedidoEm.day + 7, 23, 59);

  /// RN-213: horas do profissional ao sugerir outro horário.
  static const horasSugestao = [8, 9, 10, 11, 14, 15, 16, 17];

  /// RN-187: tempo do cliente para responder "Resolveu?".
  static const resolveuEm = Duration(hours: 48);

  /// RN-189: sem escolha depois da recusa, encerra.
  static const escolhaRecusa = Duration(days: 7);

  /// RN-191: prazo da mediação humana.
  static const mediacaoDiasUteis = 3;

  /// RN-187/RN-80: espera do profissional na porta no dia do retorno.
  static const esperaNaPorta = Duration(minutes: 15);

  /// RN-188: passou disso da hora marcada sem código na porta, o
  /// profissional "não veio" (exemplo).
  static const toleranciaNaoVeio = Duration(hours: 2);

  /// RN-193: faltas do profissional que pausam a conta.
  static const faltasParaPausar = 3;
  static const janelaFaltas = Duration(days: 90);

  /// RN-193: "não procede" do cliente que tiram o retorno mediado.
  static const naoProcedeLimite = 3;
  static const janelaNaoProcede = Duration(days: 182);
  static const semRetornoMediado = Duration(days: 182);

  /// RN-198: prazo para pedir revisão de uma decisão automática.
  static const prazoRevisao = Duration(days: 7);

  /// RN-198: resposta da revisão, em dias úteis.
  static const revisaoDiasUteis = 3;

  /// RN-199: guarda das fotos e provas (exemplo: 5 anos, CDC art. 27).
  /// Depois disso são apagadas.
  static const guardaFotos = Duration(days: 365 * 5);

  /// RN-199: a foto ainda pode ficar guardada?
  static bool fotoGuardada(DateTime tiradaEm, DateTime agora) =>
      agora.difference(tiradaEm) < guardaFotos;

  /// RN-198: ainda dá para pedir revisão de uma decisão de [em]?
  static bool podePedirRevisao(DateTime em, DateTime agora) =>
      agora.difference(em) <= prazoRevisao;

  /// RN-196: reserva mensal para os serviços que o Tatu paga.
  static const reservaDaComissao = 0.01;

  /// RN-183: "Na dúvida, 90."
  static const prazoPadraoDias = retornoPadraoDias;

  /// RN-183: prazo da profissão, pelo catálogo (o pedido usa o nome do
  /// serviço: "Encanador").
  static int prazoDias(String servico) =>
      catalogoServicos.encontrar(servico)?.retornoDias ?? prazoPadraoDias;

  /// RN-183: até quando dá para pedir retorno (conta da conclusão).
  static DateTime retornoAte(String servico, DateTime concluidoEm) =>
      concluidoEm.add(Duration(days: prazoDias(servico)));

  /// RN-45: nas primeiras 24 horas, "Pagamento protegido".
  static bool protegidoAgora(DateTime concluidoEm, DateTime agora) =>
      agora.isBefore(concluidoEm.add(protegido));

  /// RN-188: com os repasses presos cobrindo o valor, devolve; senão, o
  /// Tatu paga outro profissional (até o valor do serviço).
  static ResolucaoAutomatica resolucao({
    required double valorServico,
    required double presos,
  }) => presos >= valorServico
      ? ResolucaoAutomatica.devolucao
      : ResolucaoAutomatica.outroProfissional;

  /// RN-192: só o valor do serviço volta. Do profissional sai o que ele
  /// recebeu; a comissão o Tatu devolve do próprio caixa.
  static Devolucao devolucao(double valorServico, {double fracao = 1}) {
    final total = valorServico * fracao;
    final doTatu = total * taxaTatu;
    return Devolucao(
      total: total,
      doProfissional: total - doTatu,
      doTatu: doTatu,
    );
  }

  /// RN-193: faltas dentro da janela pausam a conta.
  static bool pausaPorFaltas(List<DateTime> faltas, DateTime agora) =>
      faltas.where((f) => agora.difference(f) < janelaFaltas).length >=
      faltasParaPausar;

  /// RN-193: 3 "não procede" em 6 meses tiram o retorno mediado por 6
  /// meses (contados do último). Devolve até quando (nulo = pode pedir).
  static DateTime? semRetornoMediadoAte(
    List<DateTime> naoProcede,
    DateTime agora,
  ) {
    final recentes = naoProcede
        .where((d) => agora.difference(d) < janelaNaoProcede)
        .toList()
      ..sort();
    if (recentes.length < naoProcedeLimite) return null;
    final ate = recentes.last.add(semRetornoMediado);
    return agora.isBefore(ate) ? ate : null;
  }

  /// RN-191: prazo da mediação em dias úteis (pula sábado e domingo).
  static DateTime prazoMediacao(DateTime desde) =>
      somarDiasUteis(desde, mediacaoDiasUteis);

  /// [dias] úteis depois de [desde] (pula sábado e domingo).
  static DateTime somarDiasUteis(DateTime desde, int dias) {
    var d = desde;
    var faltam = dias;
    while (faltam > 0) {
      d = d.add(const Duration(days: 1));
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
        faltam--;
      }
    }
    return d;
  }
}

const _mesesCurtos = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

/// "02 fev" (dia com dois dígitos, como no recibo e no cartão do retorno).
String dataCurta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_mesesCurtos[d.month - 1]}';

/// RN-207: etapas do retorno no card da Atividade (cliente).
const etapasRetorno = ['Agendado', 'A caminho', 'Retorno', 'Feito'];

/// "26 nov, 21:00".
String diaHora(DateTime d) =>
    '${diaMes(d)}, ${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

/// "Sexta, 28 nov · 14h".
String quandoRetorno(DateTime d) {
  final dia = diaLongo(d.weekday);
  final h = d.minute == 0
      ? '${d.hour}h'
      : '${d.hour}h${d.minute.toString().padLeft(2, '0')}';
  return '${dia[0].toUpperCase()}${dia.substring(1)}, ${diaMes(d)} · $h';
}

/// RN-213: períodos do dia para o retorno.
enum PeriodoDia {
  manha('Manhã', 'de manhã', 8, 12),
  tarde('Tarde', 'à tarde', 12, 18),
  noite('Noite', 'à noite', 18, 21);

  const PeriodoDia(this.nome, this.expressao, this.inicio, this.fim);

  /// "Manhã".
  final String nome;

  /// "de manhã" / "à tarde".
  final String expressao;
  final int inicio;
  final int fim;

  /// "8h–12h".
  String get faixa => '${inicio}h–${fim}h';

  /// "8h às 12h".
  String get faixaLonga => '${inicio}h às ${fim}h';

  /// Horas cheias dentro do período (manhã: 8h a 11h).
  List<int> get horas => [for (var h = inicio; h < fim; h++) h];
}

/// RN-213: um dia e um período que o cliente pode.
@immutable
class OpcaoHorario {
  const OpcaoHorario(this.dia, this.periodo);

  /// Só a data (a hora é do período).
  final DateTime dia;
  final PeriodoDia periodo;

  /// Já começou: fica apagado na grade.
  bool passou(DateTime agora) =>
      !agora.isBefore(DateTime(dia.year, dia.month, dia.day, periodo.inicio));

  /// Dentro do período, na hora [h].
  DateTime as(int h) => DateTime(dia.year, dia.month, dia.day, h);

  @override
  bool operator ==(Object other) =>
      other is OpcaoHorario &&
      other.periodo == periodo &&
      other.dia.year == dia.year &&
      other.dia.month == dia.month &&
      other.dia.day == dia.day;

  @override
  int get hashCode => Object.hash(dia.year, dia.month, dia.day, periodo);
}

String _maiuscula(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// RN-213: "Hoje", "Amanhã", "Sexta".
String nomeDoDia(DateTime d, DateTime agora) {
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final dia = DateTime(d.year, d.month, d.day);
  final dif = dia.difference(hoje).inDays;
  if (dif == 0) return 'Hoje';
  if (dif == 1) return 'Amanhã';
  return _maiuscula(diaLongo(d.weekday));
}

/// RN-213: "Sexta de manhã".
String textoOpcao(OpcaoHorario o, DateTime agora) =>
    '${nomeDoDia(o.dia, agora)} ${o.periodo.expressao}';

/// RN-213: "sex de manhã" (lista curta no card da sugestão).
String textoOpcaoCurto(OpcaoHorario o) =>
    '${diaCurto(o.dia.weekday).toLowerCase()} ${o.periodo.expressao}';

/// RN-213: "sexta, 27 nov, 9h" (botões das folhas).
String quandoCurto(DateTime d) {
  final h = d.minute == 0
      ? '${d.hour}h'
      : '${d.hour}h${d.minute.toString().padLeft(2, '0')}';
  return '${diaLongo(d.weekday)}, ${diaMes(d)}, $h';
}

/// RN-214: pedido de remarcação esperando o outro lado escolher a hora.
@immutable
class Remarcacao {
  const Remarcacao({
    required this.doCliente,
    required this.dia,
    required this.periodo,
  });

  final bool doCliente;
  final DateTime dia;
  final PeriodoDia periodo;

  OpcaoHorario get opcao => OpcaoHorario(dia, periodo);
}

/// RN-188: o que acontece quando o profissional falha.
enum ResolucaoAutomatica { devolucao, outroProfissional }

/// RN-192: quanto volta ao cliente e de onde sai.
@immutable
class Devolucao {
  const Devolucao({
    required this.total,
    required this.doProfissional,
    required this.doTatu,
  });

  final double total;

  /// Descontado dos repasses presos e futuros do profissional.
  final double doProfissional;

  /// A comissão, devolvida pelo Tatu.
  final double doTatu;
}

/// RN-184: foto tirada na hora pela câmera do app (nunca da galeria).
@immutable
class FotoProva {
  const FotoProva({required this.tiradaEm, this.imagem});

  /// Nula no protótipo quando não há câmera (só a marca de data e hora).
  final Uint8List? imagem;
  final DateTime tiradaEm;
}

/// Motivos do cliente em "O que deu errado?" (nas primeiras 24 horas).
const motivosAlgoErrado = [
  'Ficou mal feito',
  'Não terminou o serviço',
  'Cobrou diferente do combinado',
  'Outro motivo',
];

/// RN-186: motivos obrigatórios da recusa.
const motivosRecusaRetorno = [
  'Não é o mesmo problema',
  'Mau uso depois do serviço',
  'Não consigo ir até lá',
  'Outro motivo',
];

/// RN-191: as 4 decisões fixas da mediação.
enum DecisaoMediacao {
  refazerComOutro('Refazer com outro profissional'),
  devolver50('Devolver 50%'),
  devolver100('Devolver 100%'),
  naoProcede('Não procede');

  const DecisaoMediacao(this.rotulo);
  final String rotulo;

  /// Fração do valor do serviço que volta ao cliente.
  double get fracao => switch (this) {
    DecisaoMediacao.devolver50 => 0.5,
    DecisaoMediacao.devolver100 => 1,
    _ => 0,
  };
}

/// RN-190: os 3 casos que vão para a mediação humana.
enum MotivoMediacao {
  contestouRecusa,
  continuouProblema,
  contestouOutroProblema,
}

/// Em que ponto está o pedido de retorno.
enum SituacaoRetorno {
  /// RN-186: esperando o profissional (48 horas).
  aguardando,

  /// RN-186/RN-187: aceito e marcado.
  aceito,

  /// RN-186: "É outro problema": foto no local + novo valor (RN-181).
  outroProblema,

  /// RN-186/RN-189: recusado com motivo; o cliente escolhe.
  recusado,

  /// RN-187: o profissional fez o retorno; falta "Resolveu?".
  feito,

  /// RN-187: cliente ausente no dia: dado como cumprido.
  cumpridoAusente,

  /// RN-188: resolvido sozinho a favor do cliente.
  resolvidoAutomatico,

  /// RN-190/RN-191: na mediação do Tatu.
  emMediacao,

  /// Encerrado (resolveu, "Ok, entendi", decisão do Tatu, prazos).
  encerrado,
}

/// RN-198: decisões tomadas só pelo sistema, que podem ser revistas.
enum DecisaoAutomatica {
  devolucaoAutomatica('Devolução automática'),
  falta('Falta'),
  cumpridoAusente('Retorno dado como cumprido'),
  resolvidoSemResposta('Resolvido por falta de resposta'),
  pausaPorFaltas('Pausa por faltas');

  const DecisaoAutomatica(this.rotulo);
  final String rotulo;
}

/// RN-198: pedido de revisão na fila do suporte.
@immutable
class PedidoRevisao {
  const PedidoRevisao({
    required this.decisao,
    required this.quem,
    required this.pedidoEm,
    this.servico,
  });

  final DecisaoAutomatica decisao;

  /// Nome de quem pediu (cliente ou profissional).
  final String quem;

  /// Número do serviço (nulo na pausa por faltas).
  final String? servico;
  final DateTime pedidoEm;

  /// Uma pessoa do Tatu responde até aqui.
  DateTime get respostaAte =>
      RegrasRetorno.somarDiasUteis(pedidoEm, RegrasRetorno.revisaoDiasUteis);
}

/// RN-188: por que a resolução automática aconteceu.
enum FalhaProfissional { naoRespondeu, naoMarcou, naoVeio }

/// RN-194: o pacote de provas de um serviço, guardado sozinho para
/// responder a contestações no cartão (chargeback).
@immutable
class PacoteProvas {
  const PacoteProvas({
    required this.servico,
    required this.valorConfirmado,
    required this.confirmadoEm,
    required this.codigoPorta,
    required this.fotos,
    required this.chat,
    required this.conclusaoConfirmadaEm,
  });

  /// Número do pedido ("#TT-48213").
  final String servico;
  final double valorConfirmado;
  final DateTime confirmadoEm;
  final String? codigoPorta;
  final List<FotoProva> fotos;
  final List<String> chat;
  final DateTime conclusaoConfirmadaEm;
}

/// Pedido de retorno de um serviço (RN-184: um por serviço).
class PedidoRetorno {
  PedidoRetorno({
    required this.servico,
    required this.servicoNome,
    required this.descricaoServico,
    required this.diaServico,
    required this.profissional,
    required this.profissionalFeminino,
    required this.cliente,
    required this.clienteFeminina,
    required this.valorServico,
    required this.descricao,
    required this.fotos,
    required this.pedidoEm,
    required this.retido,
    this.motivo,
    this.pagamento = 'Visa 4242',
    List<OpcaoHorario>? horarios,
    this.urgente = false,
  }) : horarios = horarios ?? [];

  /// Número do serviço ("#TT-48213").
  final String servico;

  /// "Encanador" (para "Chamar outro encanador").
  final String servicoNome;

  /// "Vazamento na pia".
  final String descricaoServico;

  /// "04 nov".
  final String diaServico;

  final String profissional;
  final bool profissionalFeminino;
  final String cliente;
  final bool clienteFeminina;

  /// RN-192: só o valor do serviço (sem visita nem gorjeta).
  final double valorServico;

  /// O que o cliente escreveu.
  final String descricao;

  /// RN-184: fotos tiradas na hora.
  final List<FotoProva> fotos;
  final DateTime pedidoEm;

  /// RN-46: pedido nas primeiras 24 horas: o valor continua retido.
  final bool retido;

  /// Motivo de "O que deu errado?" (nas primeiras 24 horas).
  final String? motivo;

  /// Onde a devolução cai ("Visa 4242").
  final String pagamento;

  SituacaoRetorno situacao = SituacaoRetorno.aguardando;

  /// RN-186: aceito e marcado para.
  DateTime? marcadoPara;

  /// RN-213: até 3 horários que o cliente pode.
  List<OpcaoHorario> horarios;

  /// RN-213/RN-215: "É urgente? Pedir para hoje, se der".
  bool urgente;

  /// RN-213: horário que o profissional sugeriu (esperando o cliente).
  DateTime? sugerido;

  /// RN-214: cada lado remarca uma vez.
  bool remarcouCliente = false;
  bool remarcouProfissional = false;

  /// RN-214: remarcação esperando o outro lado.
  Remarcacao? remarcacao;

  /// RN-215: lembretes já enviados (pela antecedência).
  final lembretesEnviados = <Duration>{};

  /// RN-213: último dia para o retorno.
  DateTime get marcarAte => RegrasRetorno.limiteMarcar(pedidoEm);

  /// RN-213: aceito, mas ainda sem horário combinado.
  bool get semHorario =>
      situacao == SituacaoRetorno.aceito && marcadoPara == null;

  /// RN-187: o retorno começa com o código na porta (RN-39).
  String codigo = RegrasCodigo.gerar();

  /// RN-207: o profissional saiu para o retorno (pílula "8 min").
  bool aCaminho = false;
  int minutosParaChegar = 8;

  /// RN-186: motivo da recusa.
  String? motivoRecusa;

  /// RN-186: "É outro problema": foto no local e descrição.
  FotoProva? fotoNoLocal;
  String? outroProblema;

  /// RN-187: quando o retorno foi feito (conta o "Resolveu?").
  DateTime? feitoEm;

  /// RN-188.
  FalhaProfissional? falha;
  ResolucaoAutomatica? resolucao;

  /// RN-190/RN-191.
  MotivoMediacao? motivoMediacao;
  DateTime? mediacaoDesde;
  DecisaoMediacao? decisao;

  /// RN-189: recusado e o cliente ainda não escolheu.
  DateTime? recusadoEm;

  /// RN-198: quando o sistema decidiu sozinho (resolução automática,
  /// cumprido por ausência ou "resolvido" sem resposta).
  DateTime? decididoEm;

  /// RN-187/RN-198: encerrado porque o cliente não respondeu "Resolveu?".
  bool resolvidoSemResposta = false;

  /// RN-198: decisão automática deste retorno (nula = nenhuma).
  DecisaoAutomatica? get decisaoAutomatica => switch (situacao) {
    SituacaoRetorno.resolvidoAutomatico => DecisaoAutomatica.devolucaoAutomatica,
    SituacaoRetorno.cumpridoAusente => DecisaoAutomatica.cumpridoAusente,
    SituacaoRetorno.encerrado when resolvidoSemResposta =>
      DecisaoAutomatica.resolvidoSemResposta,
    _ => null,
  };

  String get primeiroProfissional => profissional.split(' ').first;
  String get primeiroCliente => cliente.split(' ').first;

  /// "a Luiza", "o Carlos".
  String get oProfissional =>
      '${profissionalFeminino ? 'a' : 'o'} $primeiroProfissional';
  String get oCliente => '${clienteFeminina ? 'a' : 'o'} $primeiroCliente';

  /// RN-186: até quando o profissional responde.
  DateTime get respondaAte => pedidoEm.add(RegrasRetorno.respostaProfissional);

  /// RN-185: retorno aberto prende os repasses do profissional.
  bool get aberto =>
      situacao != SituacaoRetorno.encerrado &&
      situacao != SituacaoRetorno.resolvidoAutomatico &&
      situacao != SituacaoRetorno.cumpridoAusente;

  /// RN-190: uma mediação por serviço.
  bool get jaMediado => mediacaoDesde != null;
}

/// Retornos do app (cliente e profissional). Versão simulada.
class RetornosRepo extends ChangeNotifier {
  RetornosRepo() {
    restaurar();
  }

  final retornos = <PedidoRetorno>[];

  /// RN-193: "não procede" do cliente da conta (datas).
  final naoProcedeCliente = <DateTime>[];

  /// RN-198: fila de revisões para o suporte.
  final revisoes = <PedidoRevisao>[];

  /// RN-198: [quem] já pediu revisão desta decisão?
  PedidoRevisao? revisaoDe(String quem, DecisaoAutomatica d, String? servico) =>
      revisoes
          .where(
            (r) => r.quem == quem && r.decisao == d && r.servico == servico,
          )
          .firstOrNull;

  /// RN-198: pede a revisão (até 7 dias da decisão; uma por decisão).
  /// Devolve o pedido, ou nulo se passou do prazo ou já pediu.
  PedidoRevisao? pedirRevisao({
    required DecisaoAutomatica decisao,
    required String quem,
    required DateTime decididoEm,
    String? servico,
    DateTime? agora,
  }) {
    final hoje = agora ?? clock.now();
    if (!RegrasRetorno.podePedirRevisao(decididoEm, hoje)) return null;
    if (revisaoDe(quem, decisao, servico) != null) return null;
    final p = PedidoRevisao(
      decisao: decisao,
      quem: quem,
      servico: servico,
      pedidoEm: hoje,
    );
    revisoes.add(p);
    notifyListeners();
    return p;
  }

  /// RN-199: apaga as fotos guardadas há mais do prazo.
  void apagarFotosAntigas({DateTime? agora}) {
    final hoje = agora ?? clock.now();
    bool velha(FotoProva f) => !RegrasRetorno.fotoGuardada(f.tiradaEm, hoje);
    for (final r in retornos) {
      r.fotos.removeWhere(velha);
      if (r.fotoNoLocal != null && velha(r.fotoNoLocal!)) r.fotoNoLocal = null;
    }
    for (final e in provas.entries.toList()) {
      final p = e.value;
      if (p.fotos.any(velha)) {
        provas[e.key] = PacoteProvas(
          servico: p.servico,
          valorConfirmado: p.valorConfirmado,
          confirmadoEm: p.confirmadoEm,
          codigoPorta: p.codigoPorta,
          fotos: [
            for (final f in p.fotos)
              if (!velha(f)) f,
          ],
          chat: p.chat,
          conclusaoConfirmadaEm: p.conclusaoConfirmadaEm,
        );
      }
    }
    final pronto = fotoServicoPronto;
    if (pronto != null && velha(pronto)) fotoServicoPronto = null;
    notifyListeners();
  }

  /// RN-194: pacote de provas de cada serviço, pelo número.
  final provas = <String, PacoteProvas>{};

  /// RN-192: dívidas sem saldo, ligadas à conta no Tatu (identificada
  /// pelo CPF, só dígitos; não é negativação). Com dívida, não recebe
  /// chamados nem abre outra conta até quitar.
  final dividasPorCpf = <String, double>{};

  bool cpfComDivida(String cpf) =>
      (dividasPorCpf[cpf.replaceAll(RegExp(r'\D'), '')] ?? 0) > 0;

  /// RN-40: a última foto do serviço pronto (protótipo: o profissional e o
  /// cliente estão no mesmo aparelho; no backend vai com o serviço).
  FotoProva? fotoServicoPronto;

  void restaurar() {
    retornos
      ..clear()
      // Protótipo: um pedido de retorno chegando para a profissional da
      // demo (Júlia, serviço de 04 nov).
      ..add(
        PedidoRetorno(
          servico: '#TT-47002',
          servicoNome: 'Encanador',
          descricaoServico: 'Troca de torneira',
          diaServico: '04 nov',
          profissional: 'Luiza Vilela',
          profissionalFeminino: true,
          cliente: 'Júlia Costa',
          clienteFeminina: true,
          valorServico: 120,
          descricao: 'A torneira voltou a pingar no mesmo lugar.',
          fotos: [
            FotoProva(tiradaEm: clock.now()),
            FotoProva(tiradaEm: clock.now()),
          ],
          pedidoEm: clock.now(),
          retido: false,
          horarios: _horariosDemo(clock.now()),
        ),
      );
    naoProcedeCliente.clear();
    revisoes.clear();
    provas.clear();
    dividasPorCpf.clear();
    fotoServicoPronto = null;
    notifyListeners();
  }

  /// O retorno de um serviço (pelo número).
  PedidoRetorno? doServico(String numero) =>
      retornos.where((r) => r.servico == numero).firstOrNull;

  /// O retorno mais recente com [profissional] (lado do cliente).
  PedidoRetorno? comProfissional(String profissional) => retornos.reversed
      .where((r) => r.profissional == profissional)
      .firstOrNull;

  /// O retorno mais recente de [cliente] (lado do profissional).
  PedidoRetorno? doCliente(String cliente) =>
      retornos.reversed.where((r) => r.cliente == cliente).firstOrNull;

  /// RN-185: retornos abertos de [profissional] (prendem repasses).
  Iterable<PedidoRetorno> abertosDe(String profissional) =>
      retornos.where((r) => r.profissional == profissional && r.aberto);

  /// RN-185: quanto fica preso dos repasses de [profissional].
  double presosDe(String profissional) =>
      abertosDe(profissional).fold(0, (s, r) => s + r.valorServico);

  /// RN-193: o cliente da conta perdeu o retorno mediado?
  DateTime? semRetornoMediadoAte([DateTime? agora]) =>
      RegrasRetorno.semRetornoMediadoAte(
        naoProcedeCliente,
        agora ?? clock.now(),
      );

  /// RN-184: um pedido por serviço.
  bool podePedir(String numero) => doServico(numero) == null;

  /// RN-45/RN-184: o cliente pede o retorno.
  PedidoRetorno? pedir(PedidoRetorno r) {
    if (!podePedir(r.servico)) return null;
    retornos.add(r);
    notifyListeners();
    return r;
  }

  // ---------- Profissional (RN-186) ----------

  /// RN-213: "Aceitar retorno": o profissional escolhe uma das opções do
  /// cliente e a hora; fica marcado, sem confirmação do cliente. Vale
  /// também depois de o cliente mandar novos horários ([quando] nulo =
  /// aceitou e ainda vai marcar; a RN-188 conta o prazo).
  bool aceitar(PedidoRetorno r, DateTime? quando, {DateTime? agora}) {
    final pode =
        r.situacao == SituacaoRetorno.aguardando ||
        (r.semHorario && quando != null);
    if (!pode) return false;
    if (quando != null && quando.isAfter(r.marcarAte)) return false;
    r
      ..situacao = SituacaoRetorno.aceito
      ..marcadoPara = quando
      ..sugerido = null;
    notifyListeners();
    return true;
  }

  /// RN-213: nenhuma opção serve: o profissional aceita e sugere outro
  /// horário (até 7 dias depois do pedido); o cliente confirma.
  bool sugerirHorario(PedidoRetorno r, DateTime quando, {DateTime? agora}) {
    final hoje = agora ?? clock.now();
    final pode = r.situacao == SituacaoRetorno.aguardando || r.semHorario;
    if (!pode || quando.isAfter(r.marcarAte) || !quando.isAfter(hoje)) {
      return false;
    }
    r
      ..situacao = SituacaoRetorno.aceito
      ..marcadoPara = null
      ..sugerido = quando;
    notifyListeners();
    return true;
  }

  /// RN-213: o cliente confirma o horário sugerido.
  bool confirmarSugerido(PedidoRetorno r) {
    final s = r.sugerido;
    if (!r.semHorario || s == null) return false;
    r
      ..marcadoPara = s
      ..sugerido = null;
    notifyListeners();
    return true;
  }

  /// RN-213: "Escolher outro": o cliente manda novos horários; o
  /// profissional escolhe de novo.
  bool novosHorarios(
    PedidoRetorno r,
    List<OpcaoHorario> horarios, {
    bool urgente = false,
  }) {
    if (!r.semHorario || horarios.isEmpty) return false;
    r
      ..horarios = horarios.take(RegrasRetorno.maxHorarios).toList()
      ..urgente = urgente
      ..sugerido = null;
    notifyListeners();
    return true;
  }

  // ---------- Remarcar (RN-214) ----------

  /// [cliente] ainda pode remarcar? Uma vez cada lado, até 12 horas antes.
  bool podeRemarcar(PedidoRetorno r, {required bool cliente, DateTime? agora}) {
    final m = r.marcadoPara;
    if (r.situacao != SituacaoRetorno.aceito || m == null || r.aCaminho) {
      return false;
    }
    if (r.remarcacao != null) return false;
    if (cliente ? r.remarcouCliente : r.remarcouProfissional) return false;
    final hoje = agora ?? clock.now();
    return !hoje.isAfter(m.subtract(RegrasRetorno.antecedenciaRemarcar));
  }

  /// RN-214: quem pede escolhe o dia e o período (dentro do prazo).
  bool pedirRemarcar(
    PedidoRetorno r, {
    required bool cliente,
    required DateTime dia,
    required PeriodoDia periodo,
    DateTime? agora,
  }) {
    if (!podeRemarcar(r, cliente: cliente, agora: agora)) return false;
    final o = OpcaoHorario(dia, periodo);
    if (o.as(periodo.inicio).isAfter(r.marcarAte)) return false;
    if (o.passou(agora ?? clock.now())) return false;
    r.remarcacao = Remarcacao(doCliente: cliente, dia: dia, periodo: periodo);
    if (cliente) {
      r.remarcouCliente = true;
    } else {
      r.remarcouProfissional = true;
    }
    notifyListeners();
    return true;
  }

  /// RN-214: o outro lado escolhe a hora e confirma.
  bool confirmarRemarcar(PedidoRetorno r, int hora) {
    final p = r.remarcacao;
    if (p == null || !p.periodo.horas.contains(hora)) return false;
    r
      ..marcadoPara = p.opcao.as(hora)
      ..remarcacao = null
      ..lembretesEnviados.clear();
    notifyListeners();
    return true;
  }

  /// RN-215: lembretes que já podem sair (e marca como enviados).
  List<Duration> lembretesDevidos(PedidoRetorno r, {DateTime? agora}) {
    final m = r.marcadoPara;
    if (r.situacao != SituacaoRetorno.aceito || m == null) return const [];
    final hoje = agora ?? clock.now();
    if (!hoje.isBefore(m)) return const [];
    final devidos = [
      for (final d in RegrasRetorno.lembretes)
        if (!r.lembretesEnviados.contains(d) &&
            !hoje.isBefore(m.subtract(d)))
          d,
    ];
    r.lembretesEnviados.addAll(devidos);
    return devidos;
  }

  /// "Recusar": motivo obrigatório.
  bool recusar(PedidoRetorno r, String motivo, {DateTime? agora}) {
    if (motivo.trim().isEmpty || r.situacao != SituacaoRetorno.aguardando) {
      return false;
    }
    r
      ..situacao = SituacaoRetorno.recusado
      ..motivoRecusa = motivo
      ..recusadoEm = agora ?? clock.now();
    notifyListeners();
    return true;
  }

  /// "É outro problema": foto no local obrigatória (depois vem o valor).
  bool outroProblema(PedidoRetorno r, FotoProva foto, String descricao) {
    if (r.situacao != SituacaoRetorno.aguardando) return false;
    r
      ..situacao = SituacaoRetorno.outroProblema
      ..fotoNoLocal = foto
      ..outroProblema = descricao;
    notifyListeners();
    return true;
  }

  /// RN-207: o profissional saiu para o retorno marcado.
  void saiuParaRetorno(PedidoRetorno r, {int minutos = 8}) {
    if (r.situacao != SituacaoRetorno.aceito || r.marcadoPara == null) return;
    r
      ..aCaminho = true
      ..minutosParaChegar = minutos;
    notifyListeners();
  }

  /// RN-187: o código na porta foi digitado e o retorno terminou.
  /// Devolve falso com o código errado.
  bool digitarCodigo(PedidoRetorno r, String codigo, {DateTime? agora}) {
    if (r.situacao != SituacaoRetorno.aceito || codigo != r.codigo) {
      return false;
    }
    feito(r, agora: agora);
    return true;
  }

  void feito(PedidoRetorno r, {DateTime? agora}) {
    r
      ..situacao = SituacaoRetorno.feito
      ..feitoEm = agora ?? clock.now();
    notifyListeners();
  }

  /// RN-187: o cliente não estava no dia: dado como cumprido.
  void clienteAusente(PedidoRetorno r, {DateTime? agora}) {
    r
      ..situacao = SituacaoRetorno.cumpridoAusente
      ..decididoEm = agora ?? clock.now();
    notifyListeners();
  }

  // ---------- Cliente ----------

  /// RN-187: "Sim, resolveu" encerra; "Não, continua o problema" vai à
  /// mediação (RN-190).
  void resolveu(PedidoRetorno r, bool sim, {DateTime? agora}) {
    if (sim) {
      r.situacao = SituacaoRetorno.encerrado;
      notifyListeners();
      return;
    }
    mediar(r, MotivoMediacao.continuouProblema, agora: agora);
  }

  /// RN-189: "Ok, entendi" encerra.
  void okEntendi(PedidoRetorno r) {
    r.situacao = SituacaoRetorno.encerrado;
    notifyListeners();
  }

  /// RN-190: só nos 3 casos e uma vez por serviço. RN-193: sem retorno
  /// mediado, não abre. Devolve se abriu.
  bool mediar(PedidoRetorno r, MotivoMediacao motivo, {DateTime? agora}) {
    final hoje = agora ?? clock.now();
    if (r.jaMediado || semRetornoMediadoAte(hoje) != null) return false;
    r
      ..situacao = SituacaoRetorno.emMediacao
      ..motivoMediacao = motivo
      ..mediacaoDesde = hoje;
    notifyListeners();
    return true;
  }

  // ---------- Prazos (RN-187 a RN-189) ----------

  /// Confere os prazos de todos os retornos e resolve o que venceu.
  /// [presos] diz quanto o profissional tem de repasses presos.
  /// [falta] registra a falta do profissional (RN-193).
  void conferirPrazos({
    DateTime? agora,
    double Function(String profissional)? presos,
    void Function(String profissional)? falta,
  }) {
    final hoje = agora ?? clock.now();
    var mudou = false;
    for (final r in retornos) {
      switch (r.situacao) {
        case SituacaoRetorno.aguardando when hoje.isAfter(r.respondaAte):
          _resolverSozinho(
            r,
            FalhaProfissional.naoRespondeu,
            presos,
            falta,
            agora: hoje,
          );
          mudou = true;
        // RN-213: sem horário combinado até 7 dias depois do pedido.
        case SituacaoRetorno.aceito
            when r.marcadoPara == null && hoje.isAfter(r.marcarAte):
          _resolverSozinho(
            r,
            FalhaProfissional.naoMarcou,
            presos,
            falta,
            agora: hoje,
          );
          mudou = true;
        case SituacaoRetorno.aceito
            when r.marcadoPara != null &&
                hoje.isAfter(
                  r.marcadoPara!.add(RegrasRetorno.toleranciaNaoVeio),
                ):
          // RN-188: não apareceu (sem código na porta).
          _resolverSozinho(
            r,
            FalhaProfissional.naoVeio,
            presos,
            falta,
            agora: hoje,
          );
          mudou = true;
        case SituacaoRetorno.feito
            when hoje.difference(r.feitoEm!) > RegrasRetorno.resolveuEm:
          // RN-187: sem resposta em 48 horas, resolvido.
          r
            ..situacao = SituacaoRetorno.encerrado
            ..resolvidoSemResposta = true
            ..decididoEm = hoje;
          mudou = true;
        case SituacaoRetorno.recusado
            when hoje.difference(r.recusadoEm!) > RegrasRetorno.escolhaRecusa:
          // RN-189: sem escolha em 7 dias, encerra.
          r.situacao = SituacaoRetorno.encerrado;
          mudou = true;
        default:
      }
    }
    if (mudou) notifyListeners();
  }

  /// RN-188: o profissional não veio (sem código na porta).
  void naoVeio(
    PedidoRetorno r, {
    double Function(String profissional)? presos,
    void Function(String profissional)? falta,
  }) {
    _resolverSozinho(r, FalhaProfissional.naoVeio, presos, falta);
    notifyListeners();
  }

  void _resolverSozinho(
    PedidoRetorno r,
    FalhaProfissional motivo,
    double Function(String)? presos,
    void Function(String)? falta, {
    DateTime? agora,
  }) {
    r.decididoEm = agora ?? clock.now();
    // Os presos deste próprio retorno contam (RN-185).
    final saldo = presos?.call(r.profissional) ?? presosDe(r.profissional);
    r
      ..falha = motivo
      ..resolucao = RegrasRetorno.resolucao(
        valorServico: r.valorServico,
        presos: saldo,
      )
      ..situacao = SituacaoRetorno.resolvidoAutomatico;
    falta?.call(r.profissional);
  }

  // ---------- Mediação (RN-191) ----------

  /// A pessoa do suporte decide. A decisão encerra o pedido, sem recurso.
  /// RN-193: "não procede" conta para o cliente; recusa ou "outro
  /// problema" derrubados contam falta para o profissional.
  void decidir(
    PedidoRetorno r,
    DecisaoMediacao d, {
    DateTime? agora,
    void Function(String profissional)? falta,
  }) {
    if (r.situacao != SituacaoRetorno.emMediacao) return;
    r
      ..decisao = d
      ..situacao = SituacaoRetorno.encerrado;
    if (d == DecisaoMediacao.naoProcede) {
      naoProcedeCliente.add(agora ?? clock.now());
    } else if (r.motivoMediacao != MotivoMediacao.continuouProblema) {
      falta?.call(r.profissional);
    }
    notifyListeners();
  }

  /// RN-194: guarda o pacote de provas ao confirmar a conclusão.
  void guardarProvas(PacoteProvas p) {
    provas[p.servico] = p;
    notifyListeners();
  }
}

/// Demo: amanhã de manhã e depois de amanhã à tarde.
List<OpcaoHorario> _horariosDemo(DateTime agora) => [
  OpcaoHorario(
    DateTime(agora.year, agora.month, agora.day + 1),
    PeriodoDia.manha,
  ),
  OpcaoHorario(
    DateTime(agora.year, agora.month, agora.day + 2),
    PeriodoDia.tarde,
  ),
];

/// Instância única usada pelo app enquanto não há backend.
final retornos = RetornosRepo();
