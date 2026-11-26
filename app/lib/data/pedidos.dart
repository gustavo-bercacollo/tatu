import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'codigo_porta.dart';
import 'conta.dart';
import 'notificacoes.dart';
import 'prazos.dart';
import 'conversas.dart';
import 'pagamentos.dart';
import 'retorno.dart';
import '../shared/formatadores.dart';
import 'seguranca.dart';

/// Etapas de um pedido, na ordem.
const etapasPedido = [
  'Pedido feito',
  'Valor combinado',
  'A caminho',
  'Serviço',
  'Pagamento',
];

/// RN-95/RN-96: etapas do pedido à distância (sem "A caminho"; a entrega
/// é pelo chat).
const etapasPedidoDistancia = [
  'Pedido feito',
  'Valor combinado',
  'Em andamento',
  'Entrega aprovada',
  'Pagamento do restante',
];

/// Nomes curtos das etapas à distância.
const etapasCurtasDistancia = [
  'Pedido',
  'Combinado',
  'Andamento',
  'Entrega',
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

/// RN-165: o que o cliente acompanha depois do valor confirmado.
enum EtapaAcompanhar {
  /// Valor confirmado; o profissional ainda vai sair (RN-76).
  antesDeSair,

  /// Saiu: mapa ao vivo com rota e previsão.
  aCaminho,

  /// Menos de [RegrasAcompanhar.chegando]: notificação e código na tela.
  chegando,

  /// Tocou em "Cheguei": "Passe o código".
  chegou,
}

abstract final class RegrasAcompanhar {
  /// RN-165: abaixo disso, "está chegando".
  static const chegando = Duration(minutes: 2);
}

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
    this.aindaNaoSaiu = false,
    this.saiuEm,
    this.esperandoAtraso = false,
    this.chegouEm,
    this.visita = 40,
    this.codigo = '4821',
    this.distancia = false,
    this.sinal = 0,
    this.confirmadoEm,
    this.km = 2.3,
    this.id = 0,
    this.iniciadoEm,
    this.concluidoEm,
    this.valorRetido = false,
  });

  /// RN-169: quando o código foi digitado (o serviço começou).
  final DateTime? iniciadoEm;

  /// RN-31/RN-171: o profissional tocou em "Concluir serviço"; falta o
  /// cliente confirmar (nulo antes).
  final DateTime? concluidoEm;

  /// RN-31/RN-45: "Algo errado": o valor fica retido até o suporte
  /// resolver (nada é cobrado).
  final bool valorRetido;

  /// RN-31: concluído pelo profissional, esperando o cliente confirmar.
  bool get aguardandoConfirmacao => concluidoEm != null && !valorRetido;

  /// RN-169: serviço no local em andamento (depois do código e antes de
  /// o profissional concluir).
  bool get trabalhando =>
      !distancia && etapasFeitas == 4 && concluidoEm == null;

  /// RN-45: o cliente contestou ("Algo errado" enviado): o problema está
  /// em análise e o valor fica retido.
  bool get emAnalise => valorRetido;

  /// RN-170: situação curta para a faixa da Home ("trabalhando",
  /// "em 8 min"…).
  String get situacaoCurta {
    if (distancia) return 'à distância';
    if (emAnalise) return 'em análise';
    if (aguardandoConfirmacao) return 'concluiu';
    if (trabalhando) return 'trabalhando';
    return switch (acompanhar()) {
      EtapaAcompanhar.antesDeSair => 'vai sair',
      EtapaAcompanhar.aCaminho => 'em ${minutosFaltando()} min',
      EtapaAcompanhar.chegando => 'chegando',
      EtapaAcompanhar.chegou => 'chegou',
      null => 'combinando',
    };
  }

  /// RN-169: minutos desde o início do serviço (protótipo: relógio
  /// [Prazos.aceleracao] vezes mais rápido).
  int minutosTrabalhando([DateTime? agora]) {
    final i = iniciadoEm;
    if (i == null) return 0;
    return _passou(i, agora).inMinutes;
  }

  /// RN-31: quanto falta das 2 horas para confirmar sozinho. Mesmo no
  /// protótipo são 2 horas de verdade (a confirmação não some no meio da
  /// demonstração).
  Duration faltaConfirmar([DateTime? agora]) {
    final c = concluidoEm;
    if (c == null) return Prazos.confirmarConclusao;
    final r = Prazos.confirmarConclusao - (agora ?? clock.now()).difference(c);
    return r.isNegative ? Duration.zero : r;
  }

  /// RN-90: número do pedido no app (cada chamada é um pedido, mesmo com
  /// a mesma pessoa).
  final int id;

  /// RN-76: quando o cliente confirmou o valor (conta o prazo para sair).
  final DateTime? confirmadoEm;

  /// Distância do profissional quando saiu (protótipo).
  final double km;

  /// RN-92: pedido à distância (sem visita, rota, porta nem escudo).
  final bool distancia;

  /// RN-103: sinal já pago à distância (0 = sem sinal).
  final num sinal;

  /// Etapas deste pedido (no local ou à distância; com sinal, "Valor
  /// combinado · sinal pago").
  List<String> get etapas => !distancia
      ? etapasPedido
      : [
          for (final e in etapasPedidoDistancia)
            e == 'Valor combinado' && sinal > 0 ? '$e · sinal pago' : e,
        ];
  List<String> get etapasCurtasDoPedido =>
      distancia ? etapasCurtasDistancia : etapasCurtas;

  /// RN-80: quando o profissional tocou em "Cheguei" (nulo antes).
  final DateTime? chegouEm;

  /// Valor da visita (cobrado se o cliente não aparecer, RN-81).
  final num visita;

  /// RN-39: código de 4 dígitos que o cliente passa ao profissional na
  /// porta (só o cliente vê).
  final String codigo;

  /// O profissional chegou e o cliente ainda não abriu a porta.
  bool get naPorta => chegouEm != null && etapasFeitas == 3;

  /// RN-76: o profissional passou do prazo e ainda não tocou em
  /// "Estou a caminho".
  final bool aindaNaoSaiu;

  /// Quando o profissional saiu (para o atraso, RN-78).
  final DateTime? saiuEm;

  /// O cliente escolheu "Continuar esperando" no aviso de atraso.
  final bool esperandoAtraso;

  /// Minutos previstos de chegada ("12 min" → 12).
  int get minutosChegada => int.tryParse(chegaEm.split(' ').first) ?? 0;

  /// Quanto tempo do protótipo passou desde [desde] (o relógio anda
  /// [Prazos.aceleracao] vezes mais rápido).
  static Duration _passou(DateTime desde, DateTime? agora) =>
      (agora ?? clock.now()).difference(desde) * Prazos.aceleracao;

  /// RN-165: quanto falta para chegar (zero no máximo).
  Duration faltaChegar([DateTime? agora]) {
    final s = saiuEm;
    final previsto = Duration(minutes: minutosChegada);
    if (s == null) return previsto;
    final r = previsto - _passou(s, agora);
    return r.isNegative ? Duration.zero : r;
  }

  /// "Chega em 12 min" (arredonda para cima; nunca 0).
  int minutosFaltando([DateTime? agora]) {
    final r = faltaChegar(agora);
    final m = (r.inSeconds / 60).ceil();
    return m < 1 ? 1 : m;
  }

  /// Distância que falta (protótipo: proporcional ao tempo).
  double kmFaltando([DateTime? agora]) {
    final total = minutosChegada;
    if (total <= 0) return 0;
    return km * faltaChegar(agora).inSeconds / (total * 60);
  }

  /// RN-76: minutos que faltam do prazo para sair.
  int minutosParaSair([DateTime? agora]) {
    final c = confirmadoEm;
    final r = c == null
        ? Prazos.estouACaminho
        : Prazos.estouACaminho - _passou(c, agora);
    if (r.isNegative) return 0;
    return (r.inSeconds / 60).ceil();
  }

  /// RN-165: etapa do acompanhamento (nula à distância, antes do valor
  /// confirmado ou depois do código).
  EtapaAcompanhar? acompanhar([DateTime? agora]) {
    if (distancia) return null;
    if (etapasFeitas == 2) return EtapaAcompanhar.antesDeSair;
    if (etapasFeitas != 3) return null;
    if (chegouEm != null) return EtapaAcompanhar.chegou;
    if (saiuEm == null) return EtapaAcompanhar.antesDeSair;
    return faltaChegar(agora) < RegrasAcompanhar.chegando
        ? EtapaAcompanhar.chegando
        : EtapaAcompanhar.aCaminho;
  }

  /// RN-166: o cliente só vê a posição do profissional entre "Estou a
  /// caminho" e o código digitado.
  bool get mostraLocalizacao =>
      !distancia && etapasFeitas == 3 && saiuEm != null;

  /// RN-165: a Home mostra "[nome] chega em X min" (só a caminho).
  bool get aCaminho => mostraLocalizacao && chegouEm == null;

  PedidoAndamento copiar({
    int? etapasFeitas,
    num? sinal,
    bool? aindaNaoSaiu,
    DateTime? saiuEm,
    bool? esperandoAtraso,
    DateTime? chegouEm,
    DateTime? confirmadoEm,
    String? codigo,
    int? id,
    DateTime? iniciadoEm,
    DateTime? concluidoEm,
    bool? valorRetido,
  }) => PedidoAndamento(
    servico: servico,
    profissao: profissao,
    profissional: profissional,
    nota: nota,
    endereco: endereco,
    valor: valor,
    pagamento: pagamento,
    etapasFeitas: etapasFeitas ?? this.etapasFeitas,
    chegaEm: chegaEm,
    descricao: descricao,
    aindaNaoSaiu: aindaNaoSaiu ?? this.aindaNaoSaiu,
    saiuEm: saiuEm ?? this.saiuEm,
    esperandoAtraso: esperandoAtraso ?? this.esperandoAtraso,
    chegouEm: chegouEm ?? this.chegouEm,
    visita: visita,
    codigo: codigo ?? this.codigo,
    distancia: distancia,
    sinal: sinal ?? this.sinal,
    confirmadoEm: confirmadoEm ?? this.confirmadoEm,
    km: km,
    id: id ?? this.id,
    iniciadoEm: iniciadoEm ?? this.iniciadoEm,
    concluidoEm: concluidoEm ?? this.concluidoEm,
    valorRetido: valorRetido ?? this.valorRetido,
  );

  /// "A Luiza", "O Carlos".
  String get artigoNome =>
      '${profissao.endsWith('a') ? 'A' : 'O'} $primeiroNome';

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
  String get situacao => naPorta ? 'Chegou' : etapas[etapasFeitas - 1];
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
    this.online = false,
    this.chegaEm = '~15 min',
    this.contestarAte,
    this.concluidoEm,
    this.valorServico,
  });

  /// RN-45/RN-171: até quando dá para contestar (24 h da confirmação).
  final DateTime? contestarAte;

  /// RN-183: quando a conclusão foi confirmada (o prazo de retorno conta
  /// daqui). Nulo nos pedidos cancelados.
  final DateTime? concluidoEm;

  /// RN-192: só o valor do serviço (sem visita nem gorjeta) volta numa
  /// devolução. Nulo = o total.
  final double? valorServico;

  /// Valor do serviço para devolução (RN-192).
  double get servicoParaDevolver => valorServico ?? lerReais(valor);

  /// RN-183: até quando dá para pedir retorno.
  DateTime? get retornoAte => concluidoEm == null
      ? null
      : RegrasRetorno.retornoAte(servico, concluidoEm!);

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
    online: online,
    chegaEm: chegaEm,
    contestarAte: contestarAte,
    concluidoEm: concluidoEm,
    valorServico: valorServico,
  );
}

/// Pedidos do cliente. Versão simulada (sem backend).
class PedidosRepo extends ChangeNotifier {
  PedidosRepo() {
    restaurar();
  }

  /// O pedido aberto agora (as telas e os prazos usam este).
  PedidoAndamento? andamento;

  /// RN-90: o cliente pode ter vários profissionais ao mesmo tempo; os
  /// outros pedidos em andamento ficam aqui.
  final _outros = <PedidoAndamento>[];
  int _ultimoId = 0;

  /// Buscas em segundo plano (uma por pedido sem ninguém ainda).
  final buscas = <BuscaSegundoPlano>[];

  /// RN-229: profissionais que ficaram sem acordo de valor; não recebem de
  /// novo o mesmo pedido.
  final recusados = <String>{};
  late List<PedidoConcluido> concluidos;

  /// Todos os pedidos em andamento, em pilha: o mais novo em cima. Abrir
  /// um pedido não muda a ordem.
  List<PedidoAndamento> get andamentos =>
      [?andamento, ..._outros]..sort((a, b) => b.id.compareTo(a.id));

  /// A busca mais recente (compatibilidade com as telas de um pedido).
  BuscaSegundoPlano? get busca => buscas.firstOrNull;

  bool get semNadaEmAndamento => andamentos.isEmpty && buscas.isEmpty;

  /// Pedido em andamento com [profissional] (pelo nome).
  PedidoAndamento? doProfissional(String profissional) =>
      andamentos.where((p) => p.profissional == profissional).firstOrNull;

  /// Abre [p] (vira o pedido atual); o que estava aberto continua na
  /// lista.
  void abrir(PedidoAndamento p) {
    final atual = andamento;
    if (atual == null || atual.id == p.id) return;
    final i = _outros.indexWhere((o) => o.id == p.id);
    if (i < 0) return;
    _pararRelogios();
    final escolhido = _outros.removeAt(i);
    _outros.insert(0, atual);
    andamento = escolhido;
    notifyListeners();
  }

  /// O pedido aberto saiu (cancelado, devolvido, encerrado): abre o
  /// próximo da lista, se houver.
  void _tirarAtual() {
    andamento = _outros.isEmpty ? null : _outros.removeAt(0);
  }

  /// Abertura do app: nenhum pedido em andamento nem busca (os testes
  /// usam [restaurar], que já traz um pedido a caminho).
  void comecarSemAndamento() {
    _pararRelogios();
    andamento = null;
    _outros.clear();
    buscas.clear();
    notifyListeners();
  }

  void restaurar() {
    _pararRelogios();
    devolvido = null;
    ausente = null;
    avisos.clear();
    confirmadoSozinho = null;
    recusados.clear();
    _outros.clear();
    buscas.clear();
    andamento = PedidoAndamento(
      servico: 'Encanador',
      profissao: 'Encanadora',
      profissional: 'Luiza Souza',
      nota: '4,9',
      endereco: 'Rua das Flores, 120',
      valor: r'R$ 150,00',
      pagamento: 'Visa 4242',
      etapasFeitas: 3,
      saiuEm: clock.now(),
    );
    buscas.add(
      BuscaSegundoPlano(
        servico: 'Eletricista',
        endereco: 'Rua das Flores, 120',
        descricao: 'tomada da sala sem energia',
        desde: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    );
    concluidos = [
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
        concluidoEm: DateTime(2026, 11, 4, 15, 2),
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
        numero: '#TT-47960',
        editavelAte: '09 nov',
        concluidoEm: DateTime(2026, 11, 2, 10, 5),
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

  /// A pessoa aceitou o profissional: vira o pedido aberto. RN-90: os
  /// outros pedidos em andamento continuam; só acaba a busca em segundo
  /// plano deste mesmo serviço (se houver).
  void aceitar(PedidoAndamento p) {
    _pararRelogios();
    seguranca.encerrarAlerta(cliente: true);
    final atual = andamento;
    if (atual != null) _outros.insert(0, atual);
    // RN-90: cada chamada é um pedido novo, mesmo com a mesma pessoa.
    // RN-39: cada atendimento no local tem um código novo.
    andamento = p.copiar(
      id: ++_ultimoId,
      codigo: p.distancia ? null : RegrasCodigo.gerar(),
    );
    final i = buscas.indexWhere((b) => b.servico == p.servico);
    if (i >= 0) buscas.removeAt(i);
    notifyListeners();
  }

  /// RN-228/RN-229: o cliente recusou o último valor de [profissional]:
  /// o pedido com ele sai de "Em andamento" sem custo e ele não recebe de
  /// novo o mesmo pedido. Devolve o pedido que saiu (nulo se não havia).
  PedidoAndamento? semAcordo(String profissional) {
    recusados.add(profissional);
    final p = doProfissional(profissional);
    if (p == null) {
      notifyListeners();
      return null;
    }
    abrir(p);
    cancelarAndamento();
    return p;
  }

  void cancelarAndamento() {
    _pararRelogios();
    seguranca.encerrarAlerta(cliente: true);
    _tirarAtual();
    notifyListeners();
  }

  // ---------- Profissional que não aparece (RN-76 a RN-78) ----------

  Timer? _prazoSaida;
  Timer? _prazoResposta;
  Timer? _prazoChegada;
  Timer? _prazoEspera;
  Timer? _prazoCodigo;
  Timer? _prazoConclusao;
  Timer? _prazoConfirmar;

  /// Protótipo: a profissional conclui sozinha um tempo depois do código
  /// (o app do cliente não tem como concluir). Desligado nos testes.
  static bool demoConclusao = true;

  /// Protótipo: depois do "Cheguei", o profissional digita o código
  /// sozinho (o app do cliente não tem o que tocar). Desligado nos
  /// testes de ausência.
  static bool demoCodigo = true;

  /// RN-165: notificações mandadas ao celular (protótipo: só guarda).
  final avisos = <String>[];

  /// RN-77: pedido que voltou à busca porque o profissional não confirmou
  /// que vinha. A tela do pedido usa para abrir a busca de novo.
  PedidoAndamento? devolvido;

  void _pararRelogios() {
    _prazoSaida?.cancel();
    _prazoResposta?.cancel();
    _prazoChegada?.cancel();
    _prazoEspera?.cancel();
    _prazoCodigo?.cancel();
    _prazoConclusao?.cancel();
    _prazoConfirmar?.cancel();
  }

  /// O cliente confirmou o valor (RN-76). Protótipo: o profissional não
  /// toca em "Estou a caminho", para mostrar o fluxo de quem não aparece.
  void valorConfirmado({num sinal = 0}) {
    final p = andamento;
    if (p == null) return;
    _pararRelogios();
    // RN-95: à distância, confirmado o valor, vai direto para Em
    // andamento (sem prazo para sair, rota nem porta). RN-103: o sinal
    // é cobrado agora.
    if (p.distancia) {
      andamento = p.copiar(etapasFeitas: 3, sinal: sinal);
      notifyListeners();
      return;
    }
    andamento = p.copiar(
      etapasFeitas: 2,
      aindaNaoSaiu: false,
      confirmadoEm: clock.now(),
    );
    _prazoSaida = Timer(Prazos.naDemo(Prazos.estouACaminho), aindaNaoSaiu);
    notifyListeners();
  }

  /// RN-76: passou o prazo e o profissional ainda não saiu. Ele recebe
  /// "Ainda vai?"; o cliente vê "Ainda não saiu".
  void aindaNaoSaiu() {
    final p = andamento;
    if (p == null) return;
    andamento = p.copiar(aindaNaoSaiu: true);
    _prazoResposta?.cancel();
    _prazoResposta = Timer(Prazos.naDemo(Prazos.aindaVai), naoConfirmou);
    notifyListeners();
  }

  /// O profissional tocou em "Estou a caminho" (ou "Sim, estou saindo").
  void saiu() {
    final p = andamento;
    if (p == null) return;
    _pararRelogios();
    andamento = p.copiar(
      etapasFeitas: 3,
      aindaNaoSaiu: false,
      saiuEm: clock.now(),
    );
    notifyListeners();
  }

  /// RN-77: sem resposta (ou "Não consigo ir"): o pedido volta sozinho à
  /// busca e nada é cobrado.
  void naoConfirmou() {
    final p = andamento;
    if (p == null) return;
    _pararRelogios();
    seguranca.encerrarAlerta(cliente: true);
    devolvido = p;
    _tirarAtual();
    buscas.insert(
      0,
      BuscaSegundoPlano(
        servico: p.servico,
        endereco: p.endereco,
        descricao: p.descricao,
      ),
    );
    notifyListeners();
  }

  /// A tela já abriu a busca de novo.
  void consumirDevolvido() => devolvido = null;

  /// RN-78: minutos além do previsto, quando já passou do
  /// [Prazos.fatorAtraso] × tempo previsto de chegada (senão, nulo).
  int? minutosDeAtraso([DateTime? agora]) {
    final p = andamento;
    final saiu = p?.saiuEm;
    if (p == null || saiu == null || p.etapasFeitas != 3) return null;
    if (p.chegouEm != null) return null;
    final previsto = p.minutosChegada;
    if (previsto <= 0) return null;
    // Protótipo: o relógio anda [Prazos.aceleracao] vezes mais rápido.
    final passou =
        (agora ?? clock.now()).difference(saiu).inSeconds *
        Prazos.aceleracao ~/
        60;
    if (passou < previsto * Prazos.fatorAtraso) return null;
    return passou - previsto;
  }

  /// "Continuar esperando": não pergunta de novo neste pedido.
  void esperarAtrasado() {
    final p = andamento;
    if (p == null) return;
    andamento = p.copiar(esperandoAtraso: true);
    // Protótipo: quem esperou vê o profissional chegar pouco depois.
    _prazoChegada?.cancel();
    _prazoChegada = Timer(Prazos.naDemo(const Duration(minutes: 3)), chegou);
    notifyListeners();
  }

  // ---------- Cliente que não aparece (RN-80 a RN-82) ----------

  /// RN-81: pedido encerrado porque o cliente não apareceu; a tela aberta
  /// mostra "Você não estava no local".
  PedidoAndamento? ausente;

  /// RN-80: o profissional tocou em "Cheguei": o cliente vê a porta e
  /// começa a espera de [Prazos.esperaCliente].
  void chegou() {
    final p = andamento;
    if (p == null || p.chegouEm != null) return;
    _pararRelogios();
    andamento = p.copiar(etapasFeitas: 3, chegouEm: clock.now());
    _prazoEspera = Timer(Prazos.naDemo(Prazos.esperaCliente), clienteAusente);
    if (demoCodigo) {
      _prazoCodigo = Timer(
        Prazos.naDemo(const Duration(minutes: 2)),
        codigoDigitado,
      );
    }
    notifyListeners();
  }

  /// RN-100: o cliente aprovou a entrega à distância; o restante é
  /// cobrado e o pedido está pago: sai de "Em andamento" e vai para
  /// "Concluídos" (com o [valor] total e a forma de [pagamento]).
  void entregaAprovada({String valor = '', String pagamento = ''}) {
    final p = andamento;
    if (p == null || !p.distancia) return;
    _pararRelogios();
    concluidos = [
      _concluido(p, valor: valor, pagamento: pagamento),
      ...concluidos,
    ];
    _tirarAtual();
    notifyListeners();
  }

  static const _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  /// O pedido pago como fica em "Concluídos" (data e hora de agora).
  PedidoConcluido _concluido(
    PedidoAndamento p, {
    required String valor,
    required String pagamento,
  }) {
    final agora = clock.now();
    String dois(int n) => n.toString().padLeft(2, '0');
    final mes = _meses[agora.month - 1];
    return PedidoConcluido(
      servico: p.servico,
      profissao: p.profissao,
      profissional: p.profissional,
      descricao: p.descricao,
      endereco: p.distancia ? 'À distância' : p.endereco,
      pagamento: pagamento.isEmpty ? p.pagamento : pagamento,
      valor: valor.isEmpty ? p.valor : valor,
      dia: '${dois(agora.day)} ${mes.substring(0, 3).toLowerCase()}',
      hora: '${dois(agora.hour)}:${dois(agora.minute)}',
      mes: mes,
      ano: '${agora.year}',
      numero: '#TT-${48300 + p.id}',
      online: true,
      contestarAte: agora.add(Prazos.contestar),
      concluidoEm: agora,
      // RN-192: a visita nunca volta numa devolução.
      valorServico: (lerReais(valor.isEmpty ? p.valor : valor) - p.visita)
          .clamp(0, double.infinity)
          .toDouble(),
    );
  }

  /// RN-165: menos de 2 min: avisa no celular (uma vez por pedido).
  void avisarChegando() {
    final p = andamento;
    if (p == null || p.acompanhar() != EtapaAcompanhar.chegando) return;
    final texto = '${p.artigoNome} está chegando';
    if (avisos.contains(texto)) return;
    if (notificacoes.ligado('caminho')) avisos.add(texto);
  }

  /// RN-39: o profissional digitou o código certo: o serviço começa
  /// sozinho e a localização para de ser mostrada (RN-166).
  void codigoDigitado() {
    final p = andamento;
    if (p == null) return;
    _pararRelogios();
    // RN-169: começa o serviço (hora de início e tempo correndo).
    andamento = p.copiar(etapasFeitas: 4, iniciadoEm: clock.now());
    if (demoConclusao) {
      _prazoConclusao = Timer(
        Prazos.naDemo(const Duration(minutes: 25)),
        profissionalConcluiu,
      );
    }
    notifyListeners();
  }

  /// RN-31/RN-171: o profissional tocou em "Concluir serviço". Nada é
  /// cobrado ainda: o cliente recebe a notificação e confirma. Sem
  /// resposta em [Prazos.confirmarConclusao], confirma sozinho.
  void profissionalConcluiu() {
    final p = andamento;
    if (p == null || p.distancia || p.etapasFeitas != 4) return;
    if (p.concluidoEm != null) return;
    _pararRelogios();
    andamento = p.copiar(concluidoEm: clock.now());
    if (notificacoes.ligado('pagamento')) {
      avisos.add('${p.artigoNome} concluiu o serviço');
    }
    _prazoConfirmar = Timer(
      // 2 horas de verdade, também no protótipo.
      Prazos.confirmarConclusao,
      () => confirmarConclusao(automatico: true),
    );
    notifyListeners();
  }

  /// RN-31: confirmou sozinho (sem resposta em 2 h); a tela aberta usa
  /// para seguir para a avaliação.
  PedidoConcluido? confirmadoSozinho;

  /// RN-31: "Sim, confirmar" (ou 2 h sem resposta): cobra (captura a
  /// reserva) e o pedido vai para "Concluídos". As 24 h para contestar
  /// contam a partir daqui (RN-171). Devolve o pedido concluído.
  PedidoConcluido? confirmarConclusao({bool automatico = false}) {
    final p = andamento;
    if (p == null || !p.aguardandoConfirmacao) return null;
    _pararRelogios();
    final feito = _concluido(p, valor: p.valor, pagamento: p.pagamento);
    concluidos = [feito, ...concluidos];
    // RN-226: cobra a reserva; se as novas tentativas falharem, fica a
    // pendência na Home (o profissional recebe de qualquer jeito).
    pagamentos.cobrarAoConcluir(lerReais(p.valor));
    if (automatico) confirmadoSozinho = feito;
    // RN-194: guarda sozinho o pacote de provas (chargeback).
    final agora = clock.now();
    retornos.guardarProvas(
      PacoteProvas(
        servico: feito.numero,
        valorConfirmado: lerReais(p.valor),
        confirmadoEm: p.confirmadoEm ?? agora,
        codigoPorta: p.distancia ? null : p.codigo,
        fotos: [?retornos.fotoServicoPronto],
        chat: [
          for (final m
              in conversas.conversas
                  .where((c) => c.nome == p.profissional)
                  .expand((c) => c.mensagens))
            if (m.texto != null)
              '${m.minha ? 'Cliente' : 'Profissional'}: ${m.texto}',
        ],
        conclusaoConfirmadaEm: agora,
      ),
    );
    _tirarAtual();
    notifyListeners();
    return feito;
  }

  /// RN-31/RN-45: "Algo errado": o valor fica retido e abre a
  /// contestação. Nada é cobrado até o suporte resolver.
  void algoErrado() {
    final p = andamento;
    if (p == null || !p.aguardandoConfirmacao) return;
    _pararRelogios();
    andamento = p.copiar(valorRetido: true);
    notifyListeners();
  }

  /// RN-81: a espera acabou e o profissional tocou em "Cliente não
  /// apareceu": o chamado acaba e só a visita é cobrada. Conta para a
  /// pausa da conta (RN-82).
  void clienteAusente() {
    final p = andamento;
    if (p == null) return;
    _pararRelogios();
    seguranca.encerrarAlerta(cliente: true);
    ausente = p;
    _tirarAtual();
    conta.registrarAusencia();
    notifyListeners();
  }

  /// A tela já mostrou "Você não estava no local".
  void consumirAusente() => ausente = null;

  /// Ninguém aceitou ainda: o pedido segue buscando em segundo plano.
  /// RN-90: cada pedido sem ninguém ainda tem a sua busca.
  void buscarEmSegundoPlano(BuscaSegundoPlano b) {
    buscas.insert(0, b);
    notifyListeners();
  }

  /// Cancela [b] (sem ela, a mais recente).
  void cancelarBusca([BuscaSegundoPlano? b]) {
    if (buscas.isEmpty) return;
    buscas.remove(b ?? buscas.first);
    notifyListeners();
  }

  /// Versão atual de um pedido concluído (pelo número).
  PedidoConcluido atual(PedidoConcluido p) =>
      concluidos.firstWhere((c) => c.numero == p.numero, orElse: () => p);

  /// Para a demo dos estados vazios.
  void limpar() {
    _pararRelogios();
    andamento = null;
    _outros.clear();
    buscas.clear();
    concluidos = const [];
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final pedidos = PedidosRepo();
