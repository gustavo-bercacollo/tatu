import 'package:clock/clock.dart';
import '../shared/formatadores.dart';
import 'package:flutter/foundation.dart';

import 'conta.dart';
import 'plano_fixo.dart' show diaMes;
import 'regras_distancia.dart';
import 'regras_valor.dart';
import 'suspensao.dart';
import 'ligacao.dart';
import 'pagamento.dart';
import 'pagamentos.dart';

/// Situação de uma mensagem enviada pela pessoa.
enum EnvioMensagem { enviada, falhou }

/// Mensagem do chat com o profissional: texto ou foto.
class MensagemChat {
  MensagemChat({
    this.texto,
    this.minha = false,
    this.foto = false,
    this.imagem,
    this.hora,
    this.envio = EnvioMensagem.enviada,
    this.concluido,
    this.dia,
    this.arquivo,
    this.arquivoDetalhe,
    this.previaEm,
    this.entrega,
    this.entregueEm,
    this.marcador,
    this.bloqueada = false,
    this.link,
    this.divisor,
    this.divisorNota,
  });

  /// RN-179/RN-181: começa um atendimento novo na mesma conversa (pílula
  /// preta: "Novo pedido · 24 nov · Vazamento no banheiro").
  MensagemChat.divisor(String divisor, {String? nota})
    : this(divisor: divisor, divisorNota: nota);

  /// Texto da pílula preta (nulo = não é divisor).
  final String? divisor;

  /// Nota embaixo do divisor ("Ele aparece na sua Atividade.").
  final String? divisorNota;

  /// RN-120: arquivo barrado; só quem enviou vê o aviso.
  final bool bloqueada;

  /// RN-125: entrega por link do site (no lugar do arquivo).
  final String? link;

  /// RN-42: marco "Serviço concluído · R$ 190,00 · 04 nov" no meio da
  /// conversa, que continua aberta depois dele.
  MensagemChat.concluido(String concluido) : this(concluido: concluido);

  /// Separador de dia ("12 nov").
  MensagemChat.dia(String dia) : this(dia: dia);

  /// RN-99: prévia protegida enviada em [em] (só abre no app, expira).
  MensagemChat.previa(DateTime em, {bool minha = false})
    : this(previaEm: em, minha: minha);

  /// RN-100: entrega número [n] (1 ou 2) com o arquivo.
  MensagemChat.entrega(
    int n, {
    required String arquivo,
    required String detalhe,
    required DateTime em,
    bool minha = false,
  }) : this(
         entrega: n,
         arquivo: arquivo,
         arquivoDetalhe: detalhe,
         entregueEm: em,
         minha: minha,
       );

  /// Pílula cinza no meio da conversa ("Valor confirmado · sinal pago").
  MensagemChat.marcador(String marcador) : this(marcador: marcador);

  /// RN-96: arquivo enviado (entrega à distância), ex.: "logo.pdf".
  final String? arquivo;

  /// "PDF · 2,4 MB".
  final String? arquivoDetalhe;

  /// Texto do marco de serviço concluído (RN-42).
  final String? concluido;

  /// Texto do separador de dia.
  final String? dia;

  /// RN-99: quando a prévia protegida foi enviada (nulo = não é prévia).
  final DateTime? previaEm;

  /// RN-100/RN-101: número da entrega (nulo = não é entrega).
  final int? entrega;

  /// Quando a entrega foi enviada (RN-100: aprova sozinha em 48 h).
  final DateTime? entregueEm;

  /// Pílula cinza centralizada.
  final String? marcador;

  /// Não é um balão comum (marco, dia, arquivo, prévia, entrega…).
  bool get especial =>
      concluido != null ||
      dia != null ||
      arquivo != null ||
      previaEm != null ||
      entrega != null ||
      marcador != null ||
      divisor != null ||
      bloqueada;

  final String? texto;
  final bool minha;

  /// Mensagem de foto ([imagem] pode ser nula enquanto carrega ou na demo).
  final bool foto;
  final Uint8List? imagem;
  final String? hora;
  EnvioMensagem envio;

  /// RN-134: denunciada por quem está vendo; some só da conversa dele
  /// e vira "Mensagem denunciada · em análise".
  bool denunciada = false;
}

/// RN-100 a RN-105: em que ponto está a entrega à distância de um valor.
enum SituacaoEntrega {
  /// Nenhuma entrega ainda.
  semEntrega,

  /// Entrega enviada, esperando o cliente.
  aguardando,

  /// RN-101: o cliente pediu ajuste depois da 1ª entrega.
  ajustePedido,

  /// RN-100: aprovada (pelo cliente ou sozinha em 48 h).
  aprovada,

  /// RN-104: reembolso pedido depois da 2ª entrega.
  reembolsoEmAnalise,

  /// RN-105: o prazo acabou sem entrega e o cliente pediu o sinal de volta.
  sinalDeVoltaPedido,
}

/// Motivos do pedido de reembolso (RN-104).
const motivosReembolso = [
  'Diferente do combinado',
  'Qualidade ruim',
  'Outro motivo',
];

/// Estado da entrega à distância de um valor confirmado.
class EntregaDistancia {
  EntregaDistancia({required this.confirmadoEm});

  /// Quando o valor foi confirmado (o prazo da RN-89 conta daqui).
  final DateTime confirmadoEm;
  int enviadas = 0;
  SituacaoEntrega situacao = SituacaoEntrega.semEntrega;

  /// RN-101: o que o cliente pediu para mudar.
  String? ajuste;

  /// RN-104: motivo do reembolso.
  String? motivo;

  /// RN-105: tocou em "Esperar mais".
  bool esperandoMais = false;

  bool get ultima => enviadas >= RegrasDistancia.maxEntregas;
}

/// Conversa com um profissional sobre um pedido.
/// Em que ponto está o valor que o profissional enviou.
enum SituacaoValor {
  aguardandoVoce,
  pediuOutro,
  confirmado,

  /// RN-229: passou da validade (ou o pedido foi cancelado): o card vira
  /// uma linha cinza e não dá mais para confirmar.
  expirado,
}

/// RN-229: valor que expirou porque a mesma pessoa mandou outro: fica no
/// lugar em que foi enviado, como linha cinza.
@immutable
class ValorExpirado {
  const ValorExpirado({
    required this.total,
    required this.em,
    required this.ancora,
  });

  final double total;
  final DateTime em;

  /// RN-230: depois de quantas mensagens ele foi enviado.
  final int? ancora;
}

/// Valor enviado pelo profissional: visita + serviço. [rodada] é qual
/// dos 3 valores possíveis este é.
class ValorProposta {
  ValorProposta({
    required this.visita,
    required this.servico,
    this.rodada = 1,
    this.situacao = SituacaoValor.aguardandoVoce,
    this.pedido,
    this.descricao,
    this.novo = false,
    this.distancia = false,
    this.parcelas = 1,
    this.sinal = 0,
    DateTime? enviadoEm,
    Duration? validade,
    this.ancora,
  }) : enviadoEm = enviadoEm ?? clock.now(),
       validade = validade ?? RegrasValor.validadeDo(distancia: distancia);

  /// RN-229: quando chegou e por quanto tempo vale.
  final DateTime enviadoEm;
  final Duration validade;
  DateTime get valeAte => enviadoEm.add(validade);

  /// RN-229: quando expirou (nulo = não expirou).
  DateTime? expiradoEm;

  /// RN-230: depois de quantas mensagens ele foi enviado (nulo = ainda
  /// não fixado; o chat fixa na primeira vez que mostra).
  int? ancora;

  /// RN-102/RN-103: sinal cobrado ao confirmar (0 = sem sinal).
  final double sinal;

  /// RN-103: o que falta cobrar depois do sinal.
  double get restante => total - sinal;

  /// O que este valor cobre ("troca da tubulação"), quando não é o
  /// primeiro serviço da conversa.
  final String? descricao;

  /// RN-87: valor novo numa conversa que já teve serviço concluído.
  final bool novo;

  /// RN-95: serviço à distância (só Serviço, sem visita).
  final bool distancia;

  /// RN-91: em quantas vezes o cliente vai pagar (1 = à vista).
  int parcelas;

  double visita;
  double servico;
  int rodada;
  SituacaoValor situacao;

  /// Valor que o cliente pediu (quando pediu outro).
  double? pedido;

  /// RN-222 a RN-224: o pagamento deste valor (nulo = ainda não tentou).
  PagamentoValor? pagamento;

  double get total => visita + servico;
}

class Conversa {
  Conversa({
    required this.nome,
    required this.profissao,
    required this.feminino,
    required this.servico,
    required this.descricao,
    required this.rua,
    required this.quando,
    required this.mensagens,
    bool emAndamento = false,
    this.online = false,
    this.naoLidas = 0,
    this.concluidoEm,
    this.valor,
    this.distancia = false,
  // ignore: prefer_initializing_formals (parâmetro com nome não pode ser privado)
  }) : _emAndamento = emAndamento;

  /// RN-129 a RN-132: o Tatu encerrou este atendimento porque uma das
  /// contas foi suspensa. O chat fica só para leitura e o histórico
  /// fica guardado como prova.
  Encerramento? encerramento;

  bool get encerrada => encerramento != null;

  /// RN-300/RN-301: o cliente recusou o último valor. A conversa fica só
  /// para leitura, com "Sem acordo de valor", e sai de "Em andamento".
  bool semAcordo = false;

  /// RN-140: o serviço do valor atual terminou (some o ligar).
  bool servicoConcluido = false;

  /// RN-140: o balão "Agora dá para ligar pelo Tatu" já foi visto.
  bool dicaLigarVista = false;

  /// RN-140: ligar só do valor confirmado até o serviço ser concluído.
  bool get podeLigar => RegrasLigacao.disponivel(
    valorConfirmado: valor?.situacao == SituacaoValor.confirmado,
    concluido: servicoConcluido,
    encerrado: encerrada,
  );

  /// RN-132: o nome some e vira "Conta indisponível".
  String get nomeVisivel => encerrada ? 'Conta indisponível' : nome;

  /// RN-92: pedido à distância.
  final bool distancia;

  /// RN-100 a RN-105: entrega à distância do valor confirmado.
  EntregaDistancia? entrega;

  /// Valor enviado pelo profissional (null = ainda não enviou).
  ValorProposta? valor;

  /// RN-229: valores que expiraram porque veio outro (linhas cinza).
  final valoresExpirados = <ValorExpirado>[];

  /// RN-230: onde cada card (plano, retorno…) fica na conversa: depois de
  /// quantas mensagens.
  final ancoras = <String, int>{};

  final String nome;
  final String profissao;

  /// Para os textos "a Luiza" / "Ela não vê que foi você".
  final bool feminino;
  final String servico;
  final String descricao;
  final String rua;
  final String quando;
  final List<MensagemChat> mensagens;

  /// RN-179/RN-181: volta a "Em andamento" quando começa um atendimento
  /// novo na mesma conversa.
  bool _emAndamento;

  /// RN-129: encerrada pelo Tatu, sai de "Em andamento".
  bool get emAndamento => _emAndamento && !encerrada && !semAcordo;
  final bool online;
  int naoLidas;

  /// Data em que o último serviço terminou. RN-42: a conversa não fecha;
  /// só vai para "Anteriores".
  final String? concluidoEm;

  String get primeiroNome => nome.split(' ').first;
  bool get concluida => concluidoEm != null;
  String get artigo => feminino ? 'a' : 'o';

  String get ultima {
    final m = mensagens.lastWhere(
      (m) => m.concluido == null && m.dia == null && m.divisor == null,
      orElse: () => mensagens.last,
    );
    return m.foto ? 'Foto' : (m.texto ?? m.concluido ?? '');
  }
}

/// Conversas do cliente. Versão simulada (sem backend nem internet real).
class ConversasRepo extends ChangeNotifier {
  ConversasRepo() {
    restaurar();
  }

  late List<Conversa> conversas;

  /// Cobrança do pedido em andamento esperando o pagamento.
  bool cobrancaPendente = false;

  /// Simula ficar sem internet: as mensagens novas não são enviadas.
  bool semInternet = false;

  Iterable<Conversa> get emAndamento => conversas.where((c) => c.emAndamento);
  Iterable<Conversa> get anteriores => conversas.where((c) => !c.emAndamento);

  void restaurar() {
    conversas = [
      Conversa(
        nome: 'Luiza Souza',
        profissao: 'Encanadora',
        feminino: true,
        servico: 'Encanador',
        descricao: 'Vazamento na pia da cozinha',
        rua: 'Rua das Flores',
        quando: 'agora',
        emAndamento: true,
        online: true,
        naoLidas: 2,
        mensagens: [
          MensagemChat(texto: 'Oi! Vi o vazamento, posso hoje.'),
          MensagemChat(texto: 'Ótimo, pode vir agora?', minha: true),
          MensagemChat(texto: 'Chego em 12 min.'),
        ],
        valor: ValorProposta(visita: 40, servico: 150),
      ),
      Conversa(
        nome: 'Rafael Lima',
        profissao: 'Eletricista',
        feminino: false,
        servico: 'Eletricista',
        descricao: 'Tomada sem energia',
        rua: 'Rua das Flores',
        quando: 'ontem',
        concluidoEm: '02 nov',
        // RN-42 e RN-87: a conversa continua depois do serviço e o
        // Rafael manda um novo valor (RN-91: dá para parcelar).
        mensagens: [
          MensagemChat(texto: 'Tomada trocada. Qualquer coisa, me chama.'),
          MensagemChat.concluido('Serviço concluído · R\$ 220,00 · 02 nov'),
          MensagemChat.dia('12 nov'),
          MensagemChat(
            texto: 'O quadro de luz está desarmando toda hora.',
            minha: true,
          ),
          MensagemChat(texto: 'Consigo passar aí hoje. Já te mando o valor.'),
        ],
        valor: ValorProposta(
          visita: 0,
          servico: 1200,
          descricao: 'troca do quadro de luz',
          novo: true,
        ),
      ),
      Conversa(
        nome: 'Marcos Dias',
        profissao: 'Pintor',
        feminino: false,
        servico: 'Pintor',
        descricao: 'Parede da sala',
        rua: 'Rua das Flores',
        quando: '28 out',
        concluidoEm: '28 out',
        mensagens: [MensagemChat(texto: 'Posso passar amanhã.')],
      ),
    ];
    cobrancaPendente = false;
    semInternet = false;
    notifyListeners();
  }

  /// Conversa nova com quem a pessoa acabou de aceitar (fica no topo).
  Conversa comecar({
    required String nome,
    required String profissao,
    required bool feminino,
    required String servico,
    required String rua,
    bool distancia = false,
    String? descricao,
  }) {
    // RN-179: "Pedir de novo" aceito pela mesma pessoa de um serviço já
    // concluído: a conversa é a mesma, mas o atendimento é novo.
    final anterior = conversas
        .where((c) => c.nome == nome && !c.emAndamento && !c.encerrada)
        .firstOrNull;
    if (anterior != null) {
      anterior
        .._emAndamento = true
        ..servicoConcluido = false
        ..dicaLigarVista = false
        ..entrega = null
        ..mensagens.addAll([
          MensagemChat.divisor(
            'Novo pedido · ${diaMes(clock.now())} · '
            '${descricao ?? servico}',
          ),
          MensagemChat(
            texto: 'Oi ${conta.nome}! Aceitei, já te mando o valor.',
            hora: horaAgora(),
          ),
        ])
        // RN-179: segue o fluxo normal (valor, confirmação, código…).
        // Protótipo: o valor já chega enviado.
        ..valor = ValorProposta(visita: 40, servico: 110);
      conversas = [anterior, for (final c in conversas) if (c != anterior) c];
      notifyListeners();
      return anterior;
    }
    // RN-87/RN-90: a mesma pessoa de novo continua a conversa (nada some).
    final atual = conversas
        .where((c) => c.nome == nome && c.emAndamento)
        .firstOrNull;
    if (atual != null) {
      atual.mensagens.add(
        MensagemChat(
          texto: 'Oi! Aceitei também o seu pedido de ${servico.toLowerCase()}.',
          hora: horaAgora(),
        ),
      );
      conversas = [atual, for (final c in conversas) if (c != atual) c];
      notifyListeners();
      return atual;
    }
    final c = Conversa(
      nome: nome,
      profissao: profissao,
      feminino: feminino,
      servico: servico,
      descricao: descricao ?? servico,
      rua: rua,
      quando: 'agora',
      emAndamento: true,
      online: true,
      distancia: distancia,
      mensagens: [
        MensagemChat(
          texto: distancia
              ? 'Oi! Aceitei seu pedido. Me conta o que você imagina?'
              : 'Oi! Aceitei seu pedido. Posso ir agora.',
          hora: horaAgora(),
        ),
      ],
      // RN-26: o profissional manda o valor (visita + serviço) pelo chat;
      // o cliente confirma o total uma vez. Protótipo: já chega enviado.
      // RN-95: à distância, só o serviço.
      valor: distancia
          ? ValorProposta(visita: 0, servico: 250, distancia: true, sinal: 75)
          : ValorProposta(visita: 40, servico: 150),
    );
    conversas = [c, ...conversas];
    notifyListeners();
    return c;
  }

  /// RN-300: o cliente recusou o 3º valor: nada é cobrado e a conversa
  /// fica só para leitura.
  void recusarValor(Conversa c) {
    c.semAcordo = true;
    notifyListeners();
  }

  /// O cliente confirma o valor: fica reservado e só é cobrado no fim.
  /// À distância, começa a entrega e o sinal é cobrado agora (RN-103).
  /// RN-222/RN-223: confirma o valor reservando no [cartao] (o padrão,
  /// se nulo) ou com o Pix pago ([pix]). Reserva recusada: nada muda no
  /// atendimento (o profissional não sai) e o card mostra "Cartão
  /// recusado". Devolve se o pagamento ficou garantido.
  bool confirmarValor(Conversa c, {Cartao? cartao, bool pix = false}) {
    final v = c.valor;
    if (v == null) return false;
    if (v.pagamento?.expirado ?? false) return false;
    if (v.situacao == SituacaoValor.expirado) return false;
    final usado = cartao ?? pagamentos.padrao;
    if (!pix && !pagamentos.reservar(usado)) {
      v.pagamento = PagamentoValor(
        situacao: SituacaoPagamento.recusado,
        desde: v.pagamento?.desde,
        cartaoRecusado: usado?.titulo,
      );
      notifyListeners();
      return false;
    }
    v.pagamento = PagamentoValor(situacao: SituacaoPagamento.garantido);
    v.situacao = SituacaoValor.confirmado;
    // RN-140: valor novo confirmado, a ligação volta a existir.
    c.servicoConcluido = false;
    // RN-181: novo valor confirmado no chat de um serviço concluído vira
    // um atendimento novo (aparece na Atividade). Sem confirmação, nada.
    if (v.novo) c._emAndamento = true;
    if (c.distancia) {
      c.entrega = EntregaDistancia(confirmadoEm: clock.now());
      c.mensagens.add(
        MensagemChat.marcador(
          v.sinal > 0
              ? 'Valor confirmado · sinal de ${reaisInteiros(v.sinal)} pago'
              : 'Valor confirmado · ${reais(v.total)}',
        ),
      );
    }
    notifyListeners();
    return true;
  }

  /// RN-224: "Pagar com Pix": gera o código (vale 30 minutos). O prazo
  /// para pagar continua contando do primeiro "Cartão recusado".
  void gerarPix(Conversa c) {
    final v = c.valor;
    if (v == null || (v.pagamento?.garantido ?? false)) return;
    final agora = clock.now();
    v.pagamento = PagamentoValor(
      situacao: SituacaoPagamento.pixAguardando,
      desde: v.pagamento?.desde ?? agora,
      cartaoRecusado: v.pagamento?.cartaoRecusado,
      pixAte: agora.add(RegrasPagamento.validadePix),
    );
    notifyListeners();
  }

  /// RN-223/RN-224: sem pagamento no prazo, o valor expira: nada é
  /// cobrado, o profissional fica livre e ninguém leva falta.
  void conferirPagamento(Conversa c, {DateTime? agora}) {
    final p = c.valor?.pagamento;
    if (p == null || !p.pendente) return;
    if ((agora ?? clock.now()).isBefore(p.prazo)) return;
    p.situacao = SituacaoPagamento.expirado;
    c.mensagens.add(
      MensagemChat.marcador('Valor expirado sem pagamento · nada foi cobrado'),
    );
    notifyListeners();
  }

  // ---------- Entrega à distância (RN-99 a RN-105) ----------

  /// RN-99: o profissional manda uma prévia protegida (protótipo).
  void receberPrevia(Conversa c, {DateTime? em}) {
    c.mensagens.add(MensagemChat.previa(em ?? clock.now()));
    notifyListeners();
  }

  /// RN-100/RN-101: o profissional manda uma entrega (no máximo 2): um
  /// arquivo ou, RN-125, o link do site.
  void receberEntrega(
    Conversa c, {
    DateTime? em,
    String? arquivo,
    String? detalhe,
    String? link,
  }) {
    final e = c.entrega;
    if (e == null || e.ultima) return;
    e
      ..enviadas += 1
      ..situacao = SituacaoEntrega.aguardando;
    c.mensagens.add(
      MensagemChat(
        entrega: e.enviadas,
        arquivo:
            link ??
            arquivo ??
            (e.enviadas == 1 ? 'entrega-final.zip' : 'entrega-final-v2.zip'),
        arquivoDetalhe: link != null
            ? 'Link do site · verificado'
            : detalhe ?? 'ZIP · 8 MB',
        entregueEm: em ?? clock.now(),
        link: link,
      ),
    );
    notifyListeners();
  }

  // ---------- Conta suspensa (RN-128 a RN-132) ----------

  /// Em que ponto está o atendimento desta conversa ([ponto] vem do
  /// pedido em andamento quando o profissional já saiu).
  AtendimentoAberto atendimentoDe(Conversa c, {PontoAtendimento? ponto}) {
    final v = c.valor;
    final confirmado = v?.situacao == SituacaoValor.confirmado;
    return AtendimentoAberto(
      ponto:
          ponto ??
          (confirmado
              ? PontoAtendimento.confirmado
              : PontoAtendimento.combinando),
      visita: v?.visita ?? 0,
      servico: v?.servico ?? 0,
      sinal: confirmado ? (v?.sinal ?? 0) : 0,
      entregas: c.entrega?.enviadas ?? 0,
      parcelas: v?.parcelas ?? 1,
      feminino: c.feminino,
    );
  }

  /// RN-129/RN-130: o profissional desta conversa foi suspenso. A reserva
  /// é liberada, o sinal sem entrega volta e o Tatu avisa no chat.
  Encerramento profissionalSuspenso(
    Conversa c, {
    PontoAtendimento? ponto,
    DateTime? agora,
  }) {
    final e = RegrasSuspensao.profissionalSuspenso(
      atendimentoDe(c, ponto: ponto),
      agora ?? clock.now(),
    );
    c.encerramento = e;
    notifyListeners();
    return e;
  }

  /// RN-129/RN-131: a conta do cliente (esta) foi suspensa. Todos os
  /// atendimentos em andamento são encerrados; o profissional recebe pelo
  /// que já fez. Devolve o encerramento de cada um.
  /// [pontos]: ponto de cada atendimento pelo nome do profissional (vem
  /// do pedido em andamento).
  List<Encerramento> clienteSuspenso({
    Map<String, PontoAtendimento> pontos = const {},
  }) {
    final r = <Encerramento>[];
    for (final c in conversas.where((c) => c.emAndamento).toList()) {
      final e = RegrasSuspensao.clienteSuspenso(
        atendimentoDe(c, ponto: pontos[c.nome]),
      );
      c.encerramento = e;
      r.add(e);
    }
    notifyListeners();
    return r;
  }

  /// RN-140: o serviço foi concluído; a ligação deixa de existir.
  void concluirServico(Conversa c) {
    c.servicoConcluido = true;
    notifyListeners();
  }

  /// RN-140: o balão do ligar aparece uma vez.
  void verDicaLigar(Conversa c) {
    c.dicaLigarVista = true;
    notifyListeners();
  }

  /// RN-134: a mensagem denunciada some só da conversa de quem denunciou.
  void denunciarMensagem(MensagemChat m) {
    m.denunciada = true;
    notifyListeners();
  }

  /// RN-123: o arquivo denunciado some do chat de quem denunciou.
  void ocultar(Conversa c, MensagemChat m) {
    c.mensagens.remove(m);
    notifyListeners();
  }

  /// RN-100: aprovar cobra o restante e conclui.
  void aprovarEntrega(Conversa c) {
    final e = c.entrega;
    if (e == null || e.situacao != SituacaoEntrega.aguardando) return;
    e.situacao = SituacaoEntrega.aprovada;
    notifyListeners();
  }

  /// RN-101: depois da 1ª entrega, o cliente pode pedir um ajuste.
  void pedirAjuste(Conversa c, String texto) {
    final e = c.entrega;
    if (e == null || e.ultima || e.situacao != SituacaoEntrega.aguardando) {
      return;
    }
    e
      ..situacao = SituacaoEntrega.ajustePedido
      ..ajuste = texto.trim();
    c.mensagens.add(MensagemChat(texto: texto.trim(), minha: true));
    notifyListeners();
  }

  /// RN-104: depois da 2ª entrega, o cliente pode pedir reembolso; o
  /// restante fica guardado até o suporte decidir.
  void pedirReembolso(Conversa c, String motivo) {
    final e = c.entrega;
    if (e == null || !e.ultima || e.situacao != SituacaoEntrega.aguardando) {
      return;
    }
    e
      ..situacao = SituacaoEntrega.reembolsoEmAnalise
      ..motivo = motivo;
    notifyListeners();
  }

  /// RN-100: entregas sem resposta há 48 h são aprovadas sozinhas.
  /// Devolve se alguma mudou.
  bool aprovarSozinhas([DateTime? agora]) {
    final hoje = agora ?? clock.now();
    var mudou = false;
    for (final c in conversas) {
      final e = c.entrega;
      if (e == null || e.situacao != SituacaoEntrega.aguardando) continue;
      final ultima = c.mensagens.lastWhere(
        (m) => m.entrega != null,
        orElse: () => MensagemChat(),
      );
      final em = ultima.entregueEm;
      if (em != null && RegrasDistancia.aprovadaSozinha(em, hoje)) {
        e.situacao = SituacaoEntrega.aprovada;
        mudou = true;
      }
    }
    if (mudou) notifyListeners();
    return mudou;
  }

  /// RN-105: o prazo do valor (RN-89) acabou sem nenhuma entrega?
  bool semEntregaNoPrazo(Conversa c, [DateTime? agora]) {
    final e = c.entrega;
    return e != null &&
        e.enviadas == 0 &&
        e.situacao == SituacaoEntrega.semEntrega &&
        !e.esperandoMais &&
        RegrasValor.vencido(e.confirmadoEm, agora ?? clock.now());
  }

  /// RN-105: "Esperar mais".
  void esperarMais(Conversa c) {
    c.entrega?.esperandoMais = true;
    notifyListeners();
  }

  /// RN-105: "Pedir sinal de volta": vai para o suporte.
  void pedirSinalDeVolta(Conversa c) {
    final e = c.entrega;
    if (e == null || e.enviadas > 0) return;
    e.situacao = SituacaoEntrega.sinalDeVoltaPedido;
    notifyListeners();
  }

  /// RN-91: o cliente escolhe em quantas vezes paga.
  void escolherParcelas(Conversa c, int parcelas) {
    final v = c.valor;
    if (v == null) return;
    v.parcelas = parcelas.clamp(1, RegrasValor.maxParcelas);
    notifyListeners();
  }

  /// O cliente pede outro valor (total que ele quer pagar).
  void pedirOutroValor(Conversa c, double total) {
    final v = c.valor;
    if (v == null) return;
    v
      ..pedido = total
      ..situacao = SituacaoValor.pediuOutro;
    notifyListeners();
  }

  /// Resposta simulada do profissional: um novo valor no meio do caminho
  /// (a visita continua a mesma).
  void profissionalResponde(Conversa c) {
    final v = c.valor;
    if (v == null || v.situacao != SituacaoValor.pediuOutro) return;
    final meio = ((v.total + (v.pedido ?? v.total)) / 2 / 10).round() * 10.0;
    _novoValor(
      c,
      servico: (meio - v.visita).clamp(0, double.infinity).toDouble(),
      rodada: v.rodada + 1,
    );
    notifyListeners();
  }

  /// RN-229/RN-230: chega um valor novo da mesma pessoa: o anterior expira
  /// (linha cinza no lugar dele) e o novo entra depois das mensagens.
  void _novoValor(Conversa c, {required double servico, required int rodada}) {
    final v = c.valor!;
    c.valoresExpirados.add(
      ValorExpirado(total: v.total, em: clock.now(), ancora: v.ancora),
    );
    c.valor = ValorProposta(
      visita: v.visita,
      servico: servico,
      rodada: rodada,
      descricao: v.descricao,
      novo: v.novo,
      distancia: v.distancia,
      parcelas: v.parcelas,
      sinal: v.sinal,
      validade: v.validade,
      ancora: c.mensagens.length,
    );
  }

  /// RN-229: passou da validade sem confirmar: expira (nada é cobrado).
  /// Com o pagamento em andamento, vale a RN-223.
  void conferirValidade(Conversa c, {DateTime? agora}) {
    final v = c.valor;
    if (v == null || v.pagamento != null) return;
    if (v.situacao != SituacaoValor.aguardandoVoce &&
        v.situacao != SituacaoValor.pediuOutro) {
      return;
    }
    if ((agora ?? clock.now()).isBefore(v.valeAte)) return;
    v
      ..situacao = SituacaoValor.expirado
      ..expiradoEm = v.valeAte;
    notifyListeners();
  }

  /// RN-229: o pedido foi cancelado: o valor em aberto expira.
  void expirarPorCancelamento(Conversa c) {
    final v = c.valor;
    if (v == null ||
        v.situacao == SituacaoValor.confirmado ||
        v.situacao == SituacaoValor.expirado) {
      return;
    }
    v
      ..situacao = SituacaoValor.expirado
      ..expiradoEm = clock.now();
    notifyListeners();
  }

  /// RN-229: "Pedir de novo": avisa o profissional que o cliente quer um
  /// novo valor.
  void pedirValorDeNovo(Conversa c) {
    c.mensagens.add(
      MensagemChat.marcador(
        'Você pediu um novo valor ${c.feminino ? 'à' : 'ao'} ${c.primeiroNome}',
      ),
    );
    notifyListeners();
  }

  /// Protótipo: o profissional manda o valor de novo.
  void profissionalReenviaValor(Conversa c) {
    final v = c.valor;
    if (v == null || v.situacao != SituacaoValor.expirado) return;
    _novoValor(c, servico: v.servico, rodada: v.rodada);
    notifyListeners();
  }

  void marcarLida(Conversa c) {
    if (c.naoLidas == 0) return;
    c.naoLidas = 0;
    notifyListeners();
  }

  void enviar(Conversa c, MensagemChat m) {
    if (semInternet) m.envio = EnvioMensagem.falhou;
    c.mensagens.add(m);
    notifyListeners();
  }

  /// "Tentar de novo": envia se a internet voltou.
  void reenviar(MensagemChat m) {
    if (!semInternet) m.envio = EnvioMensagem.enviada;
    notifyListeners();
  }

  void definirSemInternet(bool valor) {
    semInternet = valor;
    notifyListeners();
  }

  void definirCobranca(bool valor) {
    cobrancaPendente = valor;
    notifyListeners();
  }

  /// Para a demo do estado vazio.
  void limpar() {
    conversas = [];
    cobrancaPendente = false;
    notifyListeners();
  }
}

/// Hora atual no formato 14:32.
String horaAgora() {
  final n = DateTime.now();
  return '${n.hour.toString().padLeft(2, '0')}:'
      '${n.minute.toString().padLeft(2, '0')}';
}

/// Instância única usada pelo app enquanto não há backend.
final conversas = ConversasRepo();
