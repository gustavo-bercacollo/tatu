import '../../../shared/widgets/selo_plano_fixo.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ajuda.dart';
import '../../../data/conversas.dart';
import '../../../data/pagamentos.dart';
import '../../../data/pedidos.dart';
import '../../../data/perfil.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/chat.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../ajuda/chat_suporte_page.dart';
import '../atividade/pedido_andamento_page.dart';
import '../foto/camera_desativada_page.dart';
import '../atividade/pedido_concluido_page.dart';
import '../pagamento/pagamento_page.dart';
import '../pagamento/pagar_pix_sheet.dart';

import 'package:clock/clock.dart';

import '../../../data/retorno.dart';
import '../../../data/retorno_acoes.dart';
import '../retorno/retorno_cliente.dart';

import '../../../data/arquivos_seguros.dart';
import '../../../data/regras_distancia.dart';
import '../../entrada/chat_encerrado.dart';
import '../../entrada/conta_suspensa_page.dart';
import '../chamar/procurando_page.dart';
import '../../entrada/denunciar_arquivo.dart';
import '../atividade/avaliar_page.dart';
import '../atividade/pedir_de_novo_sheet.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../abas.dart';
import 'cartao_valor.dart';
import 'denunciar_page.dart';
import 'entrega_distancia.dart';
import '../../../data/conta.dart';
import '../../../data/denuncias.dart';
import '../../../data/encontrados.dart';
import '../../entrada/denunciar_mensagem.dart';
import '../../entrada/perfil_publico_page.dart';
import '../../entrada/ligacao_page.dart';
import '../../../data/plano_fixo.dart';
import '../plano_fixo/plano_fixo.dart';
import '../../../shared/widgets/negociacao_plano.dart';

void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text('$o: em breve')));

/// RN-176: "Pedir de novo" com o profissional desta conversa (o último
/// serviço feito, ou o pedido da conversa).
void pedirDeNovoDaConversa(BuildContext context, Conversa c) {
  final feito = pedidos.concluidos
      .where((p) => p.profissional == c.nome && !p.cancelado)
      .firstOrNull;
  abrirPedirDeNovo(
    context,
    feito ??
        PedidoConcluido(
          servico: c.servico,
          profissao: c.profissao,
          profissional: c.nome,
          descricao: c.descricao,
          endereco: c.rua,
          pagamento: '',
          valor: '',
          dia: c.concluidoEm ?? '',
          hora: '',
          mes: '',
          online: c.online,
        ),
  );
}

/// Perfil do profissional desta conversa (C14–C15).
void verPerfilDaConversa(
  BuildContext context,
  Conversa c, {
  String voltar = 'Voltar para a conversa',
}) {
  final p = filaEncontrados.firstWhere(
    (p) => p.nome == c.nome,
    orElse: () => ProfissionalEncontrado(
      nome: c.nome,
      profissao: c.profissao,
      feminino: c.feminino,
      nota: '4,9',
      servicos: 120,
      chegaEm: '',
    ),
  );
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => PerfilPublicoPage(
        perfil: perfilDe(p),
        avatar: AvatarIniciais(nome: p.nome, tamanho: 96),
        rodape: FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(voltar),
        ),
      ),
    ),
  );
}

/// Chat com o profissional do pedido.
class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.conversa,
    this.resposta = const Duration(seconds: 2),
  });

  final Conversa conversa;

  /// Protótipo: quanto o profissional demora para responder a um pedido
  /// de outro valor.
  final Duration resposta;

  /// RN-180: dica "Precisa de um novo serviço? Pedir de novo" acima do
  /// campo. Desligada por enquanto (pedido do Gustavo, 25/11/2026); o
  /// "Pedir de novo" continua na Atividade e no detalhe do concluído.
  static bool dicaPedirDeNovo = false;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _campo = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // RN-100: entregas sem resposta há 48 h já foram aprovadas.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      conversas.aprovarSozinhas();
      // RN-155: abriu, leu; o contador da aba diminui na hora.
      conversas.marcarLida(_c);
      // RN-187/RN-188: confere os prazos do retorno e, se ele foi feito,
      // pergunta "Resolveu?".
      conferirPrazosRetorno();
      // RN-225: visita suspensa sem resolver no prazo não acontece.
      planosFixos.conferirSuspensas();
      // RN-223: o prazo para pagar pode ter vencido com o chat fechado.
      conversas.conferirPagamento(_c);
      _contarPrazoPagamento();
      final r = _retorno;
      if (r != null && r.situacao == SituacaoRetorno.feito && mounted) {
        perguntarResolveu(context, r);
      }
    });
  }

  Conversa get _c => widget.conversa;

  /// RN-184: o pedido de retorno com este profissional (nulo = nenhum).
  PedidoRetorno? get _retorno => retornos.comProfissional(_c.nome);

  @override
  void dispose() {
    _timer?.cancel();
    _campo.dispose();
    _prazoPagamento?.cancel();
    _timerValidade?.cancel();
    _rolagem.dispose();
    super.dispose();
  }

  /// RN-91: escolhe em quantas vezes paga.
  Future<void> _parcelas(ValorProposta v) async {
    final n = await escolherParcelas(
      context,
      total: v.total,
      atual: v.parcelas,
    );
    if (n != null && mounted) conversas.escolherParcelas(_c, n);
  }

  /// RN-222/RN-223: confirma reservando no cartão. Recusado, o card
  /// mostra "Cartão recusado" e o prazo para pagar começa a contar.
  void _confirmarValor(ValorProposta v, {bool pix = false}) {
    // RN-181: novo valor no chat de um serviço concluído.
    final peloChat = v.novo && !_c.emAndamento;
    if (!conversas.confirmarValor(_c, pix: pix)) return _contarPrazoPagamento();
    _prazoPagamento?.cancel();
    if (peloChat) return _novoServicoPeloChat(v);
    // RN-76: começa o prazo do profissional para sair.
    if (pedidos.doProfissional(_c.nome) case final p?) {
      pedidos.abrir(p);
      // RN-103: à distância, o sinal é cobrado agora.
      pedidos.valorConfirmado(sinal: v.sinal);
      // RN-165: no local, vai direto para o acompanhamento.
      if (!_c.distancia) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PedidoAndamentoPage()));
      }
    }
    // RN-99/RN-100: à distância, protótipo: chega uma prévia e depois a
    // 1ª entrega.
    if (_c.distancia) {
      _timer?.cancel();
      _timer = Timer(widget.resposta * 2, () {
        conversas.receberPrevia(_c);
        _timer = Timer(widget.resposta * 2, () => conversas.receberEntrega(_c));
      });
    }
  }

  Timer? _prazoPagamento;

  /// RN-223: sem pagamento no prazo, o valor expira (nada cobrado).
  void _contarPrazoPagamento() {
    final p = _c.valor?.pagamento;
    if (p == null || !p.pendente) return;
    _prazoPagamento?.cancel();
    final falta = p.prazo.difference(clock.now());
    _prazoPagamento = Timer(
      falta.isNegative ? Duration.zero : falta,
      () => conversas.conferirPagamento(_c),
    );
  }

  /// RN-223: "Usar outro cartão": escolhe o cartão e tenta de novo.
  Future<void> _outroCartao(ValorProposta v) async {
    final antes = pagamentos.padrao;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PagamentoPage()));
    if (!mounted) return;
    final agora = pagamentos.padrao;
    if (agora != null && agora.id != antes?.id) _confirmarValor(v);
  }

  /// C111 · RN-224: Pix pago confirma o valor; código vencido = mesma
  /// regra do cartão recusado.
  Future<void> _pagarComPix(ValorProposta v) async {
    conversas.gerarPix(_c);
    _contarPrazoPagamento();
    final p = v.pagamento;
    if (p == null) return;
    final pago = await pagarComPix(
      context,
      valor: v.total,
      nome: '${_c.artigo} ${_c.primeiroNome}',
      ate: p.pixAte ?? p.prazo,
    );
    if (!mounted) return;
    if (pago ?? false) {
      _confirmarValor(v, pix: true);
    } else {
      conversas.conferirPagamento(_c);
    }
  }

  void _trocarPagamento() =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PagamentoPage()));

  Future<void> _pedirOutro() async {
    final v = _c.valor;
    if (v == null) return;
    final total = await pedirOutroValor(
      context,
      nome: _c.primeiroNome,
      artigo: _c.artigo,
      rodada: v.rodada,
    );
    if (total == null || !mounted) return;
    conversas.pedirOutroValor(_c, total);
    _timer?.cancel();
    _timer = Timer(widget.resposta, () => conversas.profissionalResponde(_c));
  }

  /// RN-100/RN-101: cartão de cada entrega conforme a situação.
  Widget _entrega(MensagemChat m) {
    final e = _c.entrega;
    final v = _c.valor;
    final nome = _c.primeiroNome;
    final max = RegrasDistancia.maxEntregas;
    final ultimaEnviada = e != null && m.entrega == e.enviadas;
    final enviou = NotaChat('$nome enviou a entrega');
    if (e == null || v == null) return MarcadorChat('Entrega ${m.entrega}');
    if (!ultimaEnviada) {
      // Entrega anterior: virou ajuste.
      return MarcadorChat('Entrega ${m.entrega} de $max · ajuste pedido');
    }
    return switch (e.situacao) {
      SituacaoEntrega.ajustePedido => MarcadorChat(
        'Entrega ${m.entrega} de $max · ajuste pedido',
      ),
      SituacaoEntrega.aprovada => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          enviou,
          const SizedBox(height: TatuMedidas.entreItens + 4),
          CartaoEntregaAprovada(
            restante: v.restante,
            total: v.total,
            nome: nome,
            onAvaliar: _avaliar,
          ),
        ],
      ),
      SituacaoEntrega.reembolsoEmAnalise => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          enviou,
          const SizedBox(height: TatuMedidas.entreItens),
          MarcadorChat('Entrega ${m.entrega} de $max · reembolso pedido'),
          const SizedBox(height: TatuMedidas.entreSecoes),
          // RN-104: o restante fica guardado até o suporte decidir.
          CaixaEmAnalise(
            titulo: 'Reembolso em análise',
            texto:
                'Resposta em até ${RegrasDistancia.diasUteisSuporte} dias '
                'úteis.\n${v.sinal > 0 ? 'Nada foi cobrado além do sinal.' : 'Nada foi cobrado.'}',
          ),
        ],
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          enviou,
          const SizedBox(height: TatuMedidas.entreItens),
          CartaoEntregaRecebida(
            numero: m.entrega!,
            arquivo: m.arquivo ?? '',
            detalhe: m.arquivoDetalhe ?? '',
            link: m.link != null,
            restante: v.restante,
            onAprovar: _aprovar,
            onOutro: e.ultima ? _reembolso : _ajuste,
          ),
        ],
      ),
    };
  }

  /// RN-100: aprovar cobra o restante.
  void _aprovar() {
    conversas.aprovarEntrega(_c);
    if (pedidos.doProfissional(_c.nome) case final p?) {
      final v = _c.valor;
      // Pago: o pedido vai para "Concluídos".
      pedidos
        ..abrir(p)
        ..entregaAprovada(
          valor: v == null ? '' : reais(v.total),
          pagamento: pagamentos.padrao?.curto ?? 'Pix',
        );
    }
  }

  /// RN-101: depois da 1ª entrega, pede ajuste. Protótipo: a
  /// profissional responde e manda a 2ª entrega.
  Future<void> _ajuste() async {
    final texto = await pedirAjuste(
      context,
      nome: '${_c.artigo == 'a' ? 'A' : 'O'} ${_c.primeiroNome}',
    );
    if (texto == null || !mounted) return;
    conversas.pedirAjuste(_c, texto);
    _timer?.cancel();
    _timer = Timer(widget.resposta, () {
      conversas.enviar(
        _c,
        MensagemChat(texto: 'Ajustado! Vai a versão final.'),
      );
      conversas.receberEntrega(_c);
    });
  }

  /// RN-104: depois da 2ª entrega, pede reembolso ao suporte.
  Future<void> _reembolso() async {
    final v = _c.valor;
    if (v == null) return;
    final motivo = await pedirReembolso(
      context,
      restante: v.restante,
      sinal: v.sinal,
      nome: '${_c.artigo} ${_c.primeiroNome}',
    );
    if (motivo == null || !mounted) return;
    conversas.pedirReembolso(_c, motivo);
  }

  void _avaliar() {
    final v = _c.valor;
    // O pedido já concluído (pago) desta pessoa, se houver.
    final feito = pedidos.concluidos
        .where((p) => p.profissional == _c.nome && !p.cancelado)
        .firstOrNull;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvaliarPage(
          pedido:
              feito ??
              PedidoConcluido(
                servico: _c.servico,
                profissao: _c.profissao,
                profissional: _c.nome,
                descricao: _c.descricao,
                endereco: _c.rua,
                pagamento: pagamentos.padrao?.curto ?? 'Pix',
                valor: v == null ? '' : reais(v.total),
                dia: 'hoje',
                hora: '',
                mes: 'Novembro',
              ),
        ),
      ),
    );
  }

  /// RN-105: o prazo acabou sem entrega: pode pedir o sinal de volta.
  List<Widget> _semEntrega() {
    final e = _c.entrega;
    final v = _c.valor;
    if (e == null || v == null || v.sinal <= 0) return const [];
    if (e.situacao == SituacaoEntrega.sinalDeVoltaPedido) {
      return [
        const SizedBox(height: TatuMedidas.entreSecoes),
        CaixaEmAnalise(
          titulo: 'Sinal de volta em análise',
          texto:
              'Resposta em até ${RegrasDistancia.diasUteisSuporte} dias '
              'úteis. Sem entrega, o sinal volta para você.',
        ),
      ];
    }
    if (!conversas.semEntregaNoPrazo(_c)) return const [];
    return [
      const SizedBox(height: TatuMedidas.entreSecoes),
      CartaoSemEntrega(
        nome: '${_c.artigo == 'a' ? 'A' : 'O'} ${_c.primeiroNome}',
        sinal: v.sinal,
        onEsperar: () => conversas.esperarMais(_c),
        onPedirSinal: () => conversas.pedirSinalDeVolta(_c),
      ),
    ];
  }

  /// RN-230: o card do valor (para a barra "Valor pendente" saber se ele
  /// saiu da tela e para rolar até ele).
  final _chaveValor = GlobalKey();
  final _rolagem = ScrollController();

  /// RN-230: o card do valor pendente está fora da tela?
  bool _valorFora = false;

  bool _conferindo = false;

  void _conferirNoFimDoQuadro() {
    if (_conferindo) return;
    _conferindo = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _conferindo = false;
      if (mounted) _verValorFora();
    });
  }

  /// Mensagem nova (enviada ou recebida): a conversa desce até o fim.
  int? _qtdMensagens;

  void _descerSeChegouMensagem() {
    final n = _c.mensagens.length;
    final antes = _qtdMensagens;
    _qtdMensagens = n;
    if (antes == null || n <= antes || !_rolagem.hasClients) return;
    _rolagem.jumpTo(_rolagem.position.maxScrollExtent);
  }

  List<Widget> _valor() {
    final v = _c.valor;
    // RN-212: nenhum card de valor some depois de combinado (à distância
    // também; o marcador no chat continua).
    if (v == null) return const [];
    // C114 · RN-229: expirado, vira linha cinza com "Pedir de novo".
    if (v.situacao == SituacaoValor.expirado) {
      return [
        const SizedBox(height: 18),
        CartaoValorExpirado(
          nome: _c.nome,
          total: v.total,
          em: v.expiradoEm ?? v.valeAte,
          onPedirDeNovo: () => _pedirValorDeNovo(),
        ),
      ];
    }
    return [
      const SizedBox(height: TatuMedidas.entreSecoes),
      // RN-87: numa conversa que já teve serviço, é um valor novo.
      // C112 · RN-229: com a hora em que chegou.
      NotaChat(
        '${_c.primeiroNome} enviou ${v.novo ? 'um novo valor' : 'um valor'}'
        ' · ${horaMinuto(v.enviadoEm)}',
      ),
      const SizedBox(height: TatuMedidas.entreItens),
      KeyedSubtree(
        key: _chaveValor,
        child: switch (v.situacao) {
          SituacaoValor.aguardandoVoce => CartaoValorRecebido(
            valor: v,
            nome: '${_c.artigo} ${_c.primeiroNome}',
            onConfirmar: () => _confirmarValor(v),
            onOutroCartao: () => _outroCartao(v),
            onPix: () => _pagarComPix(v),
            onTrocar: _trocarPagamento,
            onParcelas: () => _parcelas(v),
            onPedirOutro: v.rodada < maxRodadasValor ? _pedirOutro : null,
            onRecusar: _recusar,
          ),
          SituacaoValor.pediuOutro => CartaoValorPedido(
            valor: v,
            nome: '${_c.artigo} ${_c.primeiroNome}',
          ),
          // RN-203: com plano fixo, o valor do chat é um serviço avulso.
          SituacaoValor.confirmado => CartaoValorConfirmado(
            valor: v,
            avulso: _barraPlano != null,
          ),
          SituacaoValor.expirado => const SizedBox.shrink(),
        },
      ),
      // RN-181: o novo valor confirmado no chat virou um serviço.
      if (v.novo && v.situacao == SituacaoValor.confirmado) ...[
        const SizedBox(height: TatuMedidas.entreSecoes),
        DivisorChat(
          'Novo serviço iniciado pelo chat · ${reais(v.total)}',
          nota: 'Ele aparece na sua Atividade.',
        ),
      ],
    ];
  }

  /// RN-229: "Pedir de novo": avisa o profissional; protótipo: ele manda
  /// o valor de novo.
  void _pedirValorDeNovo() {
    conversas.pedirValorDeNovo(_c);
    _timer?.cancel();
    _timer = Timer(widget.resposta, () {
      conversas.profissionalReenviaValor(_c);
      _contarValidade();
    });
  }

  Timer? _timerValidade;
  DateTime? _validadeContada;

  /// RN-229: quando passar da validade, o valor expira sozinho.
  void _contarValidade() {
    final v = _c.valor;
    if (v == null || v.situacao != SituacaoValor.aguardandoVoce) {
      _timerValidade?.cancel();
      _validadeContada = null;
      return;
    }
    if (_validadeContada == v.valeAte) return;
    _validadeContada = v.valeAte;
    _timerValidade?.cancel();
    final falta = v.valeAte.difference(clock.now());
    _timerValidade = Timer(
      falta.isNegative ? Duration.zero : falta,
      () => conversas.conferirValidade(_c),
    );
  }

  /// RN-230: o card fica depois de [n] mensagens; fixado na primeira vez
  /// que aparece.
  int _ancora(String chave) =>
      _c.ancoras.putIfAbsent(chave, () => _c.mensagens.length);

  /// RN-230: cards de valor, plano e retorno no lugar em que foram
  /// enviados (chave = antes de qual mensagem).
  Map<int, List<Widget>> _cartoesNoLugar() {
    final n = _c.mensagens.length;
    final m = <int, List<Widget>>{};
    void por(int ancora, List<Widget> ws) {
      if (ws.isEmpty) return;
      (m[ancora.clamp(0, n)] ??= []).addAll(ws);
    }

    // RN-183 a RN-191 / RN-231: o pedido de retorno e o que veio depois.
    if (_retorno case final r?) {
      por(
        _ancora('retorno:${r.servico}'),
        secaoRetornoCliente(context, r, endereco: _c.rua),
      );
      // RN-231: a aceitação vira um aviso pequeno no lugar em que veio.
      final m0 = r.marcadoPara;
      if (r.situacao == SituacaoRetorno.aceito && m0 != null) {
        por(_ancora('retorno-aceito:${r.servico}'), [
          const SizedBox(height: 18),
          NotaChat(
            '${r.oProfissional[0].toUpperCase()}${r.oProfissional.substring(1)}'
            ' aceitou · ${quandoCurto(m0)}',
          ),
        ]);
      }
    }
    por(_ancora('plano'), _planoNoChat());
    // RN-229: valores que expiraram porque veio outro.
    for (final e in _c.valoresExpirados) {
      por(e.ancora ?? n, [
        const SizedBox(height: 18),
        CartaoValorExpirado(nome: _c.nome, total: e.total, em: e.em),
      ]);
    }
    final v = _c.valor;
    if (v != null) por(v.ancora ??= n, _valor());
    return m;
  }

  /// RN-230: o valor pendente saiu da tela? (rolou para cima ou para
  /// baixo dele).
  void _verValorFora() {
    final v = _c.valor;
    final pendente = v != null && v.situacao == SituacaoValor.aguardandoVoce;
    var fora = false;
    if (pendente) {
      final ctx = _chaveValor.currentContext;
      final caixa = ctx?.findRenderObject() as RenderBox?;
      final vista = ctx == null ? null : Scrollable.maybeOf(ctx);
      final janela = vista?.context.findRenderObject() as RenderBox?;
      if (caixa == null || janela == null || !caixa.attached) {
        fora = _rolagem.hasClients;
      } else {
        final topo = janela.localToGlobal(Offset.zero).dy;
        final base = topo + janela.size.height;
        final y = caixa.localToGlobal(Offset.zero).dy;
        fora = y + caixa.size.height < topo + 8 || y > base - 8;
      }
    }
    if (fora != _valorFora && mounted) setState(() => _valorFora = fora);
  }

  /// RN-230: tocar na barra rola até o card.
  Future<void> _irAoValor() async {
    for (var i = 0; i < 20; i++) {
      final ctx = _chaveValor.currentContext;
      if (ctx != null) {
        // O contexto é lido de novo a cada volta (depois do quadro).
        await Scrollable.ensureVisible(
          // ignore: use_build_context_synchronously
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
        return;
      }
      if (!_rolagem.hasClients) return;
      final p = _rolagem.position;
      // O card está acima (a conversa subiu): sobe uma tela por vez.
      _rolagem.jumpTo(
        (p.pixels - p.viewportDimension).clamp(0, p.maxScrollExtent),
      );
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }
  }

  /// RN-181: confirmado o novo valor enviado no chat, vira um atendimento
  /// novo, com card na Atividade. O cliente continua no chat (o chat mostra
  /// "Novo serviço iniciado pelo chat").
  void _novoServicoPeloChat(ValorProposta v) {
    pedidos.aceitar(
      PedidoAndamento(
        servico: _c.servico,
        profissao: _c.profissao,
        profissional: _c.nome,
        nota: '4,9',
        endereco: _c.rua,
        valor: reais(v.total),
        pagamento: pagamentos.padrao?.curto ?? '',
        etapasFeitas: 2,
        descricao: v.descricao ?? _c.descricao,
        visita: v.visita,
        confirmadoEm: clock.now(),
      ),
    );
  }

  /// RN-300: "Recusar valor" no 3º valor: chamar outro ou cancelar.
  Future<void> _recusar() async {
    final ela = '${_c.artigo} ${_c.primeiroNome}';
    final chamarOutro = await perguntar(
      context,
      titulo: 'Recusar o valor?',
      texto:
          'A conversa com $ela termina e nada é cobrado. '
          'Você pode chamar outro profissional.',
      confirmar: 'Recusar e chamar outro',
      cancelar: 'Recusar e cancelar pedido',
      voltar: 'Voltar',
      iconeAviso: false,
    );
    if (chamarOutro == null || !mounted) return;
    // RN-301: sem custo; o pedido com ela sai e ela não volta.
    conversas.recusarValor(_c);
    final p = pedidos.semAcordo(_c.nome);
    if (chamarOutro) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcurandoPage(
            servico: _c.servico,
            endereco: p?.endereco ?? _c.rua,
            descricao: p?.descricao ?? _c.descricao,
            distancia: _c.distancia,
          ),
        ),
      );
      return;
    }
    // O aviso fica no overlay de cima, então continua depois de sair.
    mostrarAvisoTopo(
      context,
      titulo: 'Pedido cancelado',
      texto: 'Nada foi cobrado.',
    );
    irParaAba(context, AbaCliente.inicio);
  }

  /// RN-176/RN-180: "Pedir de novo" a partir do chat de um serviço
  /// concluído (serviço, descrição e endereço do último pedido).
  void _pedirDeNovo() => pedirDeNovoDaConversa(context, _c);

  /// RN-180: a dica aparece no chat de um serviço concluído, quando não
  /// há atendimento nem valor em aberto (mensagem é só conversa).
  bool get _mostraDicaPedirDeNovo =>
      ChatPage.dicaPedirDeNovo &&
      _c.concluida &&
      !_c.emAndamento &&
      !_c.encerrada &&
      (_c.valor == null || _c.valor!.situacao == SituacaoValor.confirmado);

  /// RN-202/RN-205: barra do plano para o cliente (nula = sem plano ou
  /// encerrado).
  BarraPlano? get _barraPlano => _planoVisivel?.barra(cliente: true);

  /// Topo do chat com a barra fixa do plano logo abaixo (RN-202).
  Widget _comBarraDoPlano(Widget topo) {
    final v = _c.valor;
    // C113 · RN-230: valor pendente fora da tela: barra laranja (embaixo
    // da barra do plano, quando houver as duas).
    final pendente =
        v != null && v.situacao == SituacaoValor.aguardandoVoce && _valorFora
        ? BarraPlano(
            'Valor pendente · ${reaisInteiros(v.total)}',
            direita: 'vale até ${horaMinuto(v.valeAte)}',
            laranja: true,
          )
        : null;
    final plano = _barraPlano;
    if (plano == null && pendente == null) return topo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        topo,
        if (plano != null) ...[
          const SizedBox(height: TatuMedidas.entreItens),
          BarraPlanoFixo(barra: plano, onTap: _abrirPlano),
        ],
        if (pendente != null) ...[
          const SizedBox(height: TatuMedidas.entreItens),
          BarraPlanoFixo(barra: pendente, onTap: _irAoValor),
        ],
      ],
    );
  }

  /// A barra abre a tela do plano (ou o pedido, enquanto pendente).
  void _abrirPlano() {
    final p = _planoVisivel;
    if (p == null) return;
    if (p.status == StatusPlano.pendente) {
      _tornarFixa();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlanoFixoPage(plano: p, doChat: true)),
    );
  }

  void _enviar() {
    final texto = _campo.text.trim();
    if (texto.isEmpty) return;
    conversas.enviar(_c, MensagemChat(texto: texto, minha: true));
    _campo.clear();
  }

  /// RN-119 a RN-122: o arquivo passa pela moderação antes de chegar.
  Future<void> _enviarArquivo(ArquivoEnviado a, MensagemChat m) async {
    final r = await segurancaConteudo.enviarNoChat(a);
    if (!mounted) return;
    switch (r) {
      case ResultadoEnvio.entregue:
        conversas.enviar(_c, m);
      case ResultadoEnvio.barrado:
        conversas.enviar(_c, MensagemChat(minha: true, bloqueada: true));
      case ResultadoEnvio.contaSuspensa || ResultadoEnvio.contaBanida:
        mostrarContaSuspensa(context);
      case ResultadoEnvio.tipoNaoPermitido || ResultadoEnvio.grandeDemais:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                r == ResultadoEnvio.grandeDemais
                    ? 'Arquivo grande demais para o chat '
                          '(até ${RegrasArquivo.limiteChatMb} MB).'
                    : 'No chat vão só fotos, vídeos curtos e PDF.',
              ),
            ),
          );
    }
  }

  /// RN-123: segurar o dedo sobre um arquivo recebido abre a denúncia.
  Future<void> _denunciar(MensagemChat m) async {
    final motivo = await denunciarArquivo(context);
    if (motivo == null || !mounted) return;
    segurancaConteudo.denunciar(m.arquivo ?? 'foto', motivo);
    conversas.ocultar(_c, m);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Denúncia enviada ao suporte.')),
      );
  }

  Future<void> _anexar() async {
    final origem = await mostrarFolha<Object>(
      context,
      builder: (ctx) => FolhaOpcoes(
        itens: [
          ItemLista(
            icone: TablerIcons.camera,
            texto: 'Tirar foto',
            seta: false,
            onTap: () => Navigator.of(ctx).pop(OrigemFoto.camera),
          ),
          ItemLista(
            icone: TablerIcons.photo,
            texto: 'Escolher da galeria',
            seta: false,
            onTap: () => Navigator.of(ctx).pop(OrigemFoto.galeria),
          ),
          // RN-119: documento (PDF). Protótipo: um PDF de exemplo.
          ItemLista(
            icone: TablerIcons.file_text,
            texto: 'Documento (PDF)',
            seta: false,
            onTap: () => Navigator.of(ctx).pop('documento'),
          ),
        ],
      ),
    );
    if (origem == null || !mounted) return;
    if (origem == 'documento') {
      const a = ArquivoEnviado('documento.pdf', mb: 1.2);
      return _enviarArquivo(
        a,
        MensagemChat(
          minha: true,
          arquivo: a.nome,
          arquivoDetalhe: a.detalhe,
          hora: horaAgora(),
        ),
      );
    }
    try {
      final imagem = await perfil.pedirImagem(origem as OrigemFoto);
      if (imagem == null || !mounted) return;
      await _enviarArquivo(
        const ArquivoEnviado('foto.jpg', mb: 2),
        MensagemChat(
          minha: true,
          foto: true,
          imagem: imagem,
          hora: horaAgora(),
        ),
      );
    } on CameraNegada {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CameraDesativadaPage(semAvatar: true),
        ),
      );
    }
  }

  PedidoRecente get _pedidoParaSuporte => PedidoRecente(
    servico: _c.servico,
    profissional: _c.primeiroNome,
    resumo: _c.descricao,
    descricao: _c.descricao,
    quando: _c.quando,
  );

  void _verPedido() {
    final nav = Navigator.of(context);
    final p = pedidos.doProfissional(_c.nome);
    if (_c.emAndamento && p != null) {
      pedidos.abrir(p);
      nav.push(MaterialPageRoute(builder: (_) => const PedidoAndamentoPage()));
      return;
    }
    final concluido = pedidos.concluidos
        .where((p) => p.profissional == _c.nome)
        .firstOrNull;
    if (concluido == null) return _emBreve(context, 'Ver pedido');
    nav.push(
      MaterialPageRoute(builder: (_) => PedidoConcluidoPage(pedido: concluido)),
    );
  }

  Future<void> _menu() async {
    final escolha = await mostrarFolha<int>(
      context,
      builder: (ctx) {
        void ir(int i) => Navigator.of(ctx).pop(i);
        return FolhaOpcoes(
          itens: [
            // RN-136: ver o perfil pelo nome e pela foto do topo.
            ItemLista(
              icone: TablerIcons.user,
              texto:
                  'Ver perfil ${_c.artigo == 'a' ? 'da' : 'do'} '
                  '${_c.primeiroNome}',
              seta: false,
              onTap: () => ir(4),
            ),
            // RN-144: tornar o profissional fixo (ou ver o plano).
            ItemLista(
              icone: TablerIcons.calendar_repeat,
              texto: _plano == null
                  ? 'Tornar ${_c.primeiroNome} fix${_c.artigo}'
                  : 'Ver plano fixo',
              seta: false,
              onTap: () => ir(5),
            ),
            // RN-140: ligar só existe durante o atendimento.
            if (_c.podeLigar)
              ItemLista(
                icone: TablerIcons.phone,
                texto: 'Ligar para ${_c.primeiroNome}',
                seta: false,
                onTap: () => ir(0),
              ),
            ItemLista(
              icone: TablerIcons.clock,
              texto: 'Ver pedido',
              seta: false,
              onTap: () => ir(1),
            ),
            ItemLista(
              icone: TablerIcons.help_circle,
              texto: 'Ajuda com o pedido',
              seta: false,
              onTap: () => ir(2),
            ),
            ItemLista(
              icone: TablerIcons.alert_triangle,
              texto: 'Denunciar',
              cor: TatuColors.danger,
              seta: false,
              onTap: () => ir(3),
            ),
          ],
        );
      },
    );
    if (escolha == null || !mounted) return;
    final nav = Navigator.of(context);
    switch (escolha) {
      case 0:
        _ligar();
      case 1:
        _verPedido();
      case 2:
        nav.push(
          MaterialPageRoute(
            builder: (_) => ChatSuportePage(pedido: _pedidoParaSuporte),
          ),
        );
      case 3:
        nav.push(
          MaterialPageRoute(builder: (_) => DenunciarPage(conversa: _c)),
        );
      case 4:
        _verPerfil();
      case 5:
        _tornarFixa();
    }
  }

  /// RN-144: plano fixo com este profissional (nulo = não tem).
  PlanoFixo? get _plano => planosFixos.planoCom(_c.nome);

  /// RN-144/RN-145: "Tornar [nome] fixa" → folha → o pedido vai para o
  /// chat do profissional, que responde com o valor por visita.
  Future<void> _tornarFixa() async {
    final atual = _plano;
    if (atual != null && atual.status != StatusPlano.pendente) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlanoFixoPage(plano: atual, doChat: true),
        ),
      );
      return;
    }
    if (atual != null) return;
    final e = await escolherPlano(
      context,
      nome: _c.primeiroNome,
      feminino: _c.feminino,
    );
    if (e == null || !mounted) return;
    final p = planosFixos.pedir(
      cliente: conta.nomeCompleto,
      profissional: _c.nome,
      endereco: _c.rua,
      frequencia: e.frequencia,
      visitasPorSemana: e.vezes,
      dias: e.dias,
      horario: e.horario,
      profissao: _c.profissao,
      feminino: _c.feminino,
    );
    // RN-145: passaria de 2 visitas na semana (com os avulsos).
    if (p == null) return mostrarLimiteSemana(context);
    // Protótipo: o profissional responde com o valor por visita.
    _timer?.cancel();
    _timer = Timer(widget.resposta, () => planosFixos.enviarValor(p, 150));
  }

  /// RN-144: o cliente confirma no cartão padrão e o plano fica ativo.
  /// RN-148: num plano ativo, confirma o novo valor.
  void _confirmarPlano(PlanoFixo p) {
    if (p.status == StatusPlano.ativo) {
      planosFixos.aceitarNovoValor(p);
      return;
    }
    planosFixos.confirmar(
      p,
      cartao: pagamentos.padrao?.titulo ?? 'Visa final 4242',
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlanoFixoPage(plano: p, doChat: true)),
    );
  }

  /// C218 · RN-210: o cliente diz quanto quer pagar por visita; a
  /// profissional aceita ou manda o último valor (protótipo).
  Future<void> _outroValorPlano(PlanoFixo p) async {
    final v = await pedirValorPorVisita(
      context,
      p,
      novoValor: p.status == StatusPlano.ativo,
    );
    if (v == null || !mounted) return;
    if (!planosFixos.pedirOutroValor(p, v)) return;
    _timer?.cancel();
    _timer = Timer(
      widget.resposta,
      () => planosFixos.simularRespostaDoProfissional(p),
    );
  }

  /// C219 · RN-210: recusa a última proposta. Sem acordo, o plano não
  /// começa (num plano ativo, fica o valor de hoje).
  void _recusarPlano(PlanoFixo p) => planosFixos.recusarValor(p);

  /// RN-202/RN-205: o plano com esta pessoa, mesmo encerrado.
  PlanoFixo? get _planoVisivel => planosFixos.ultimoCom(profissional: _c.nome);

  /// RN-203: visitas do plano já feitas viram divisores no chat.
  List<Widget> _visitasDoPlano() {
    final p = _planoVisivel;
    if (p == null || _c.encerrada) return const [];
    final feitas = [
      for (final v in p.visitas)
        if (v.situacao == SituacaoVisita.feita) v,
    ];
    if (feitas.isEmpty) return const [];
    return [
      for (final v in feitas) ...[
        const SizedBox(height: 18),
        DivisorChat('Visita do plano · ${diaMes(v.dia)} · feita'),
      ],
      // Espaço antes do 1º balão (ele não tem margem de cima).
      const SizedBox(height: 18),
    ];
  }

  /// C228 · RN-225: "Atualizar pagamento": escolhe o cartão e reserva de
  /// novo; dando certo, a visita volta e a profissional é avisada.
  Future<void> _atualizarPagamentoVisita(PlanoFixo p, VisitaPlano v) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PagamentoPage()));
    if (!mounted) return;
    if (planosFixos.atualizarPagamentoVisita(p, v)) {
      mostrarAvisoTopo(
        context,
        titulo: 'Visita confirmada',
        texto:
            '${_c.artigo == 'a' ? 'A' : 'O'} ${_c.primeiroNome} vai na '
            '${diaLongo(v.dia.weekday)}.',
      );
    }
  }

  /// RN-211: valor do último serviço avulso com a pessoa (economia).
  double? get _ultimoAvulso {
    final c = pedidos.concluidos
        .where((x) => x.profissional == _c.nome)
        .firstOrNull;
    return c == null ? null : lerReais(c.valor);
  }

  /// RN-210 a RN-212: a negociação do plano fica no chat (histórico,
  /// card da vez e, depois, o card confirmado ou o "sem acordo").
  List<Widget> _planoNoChat() {
    final p = _planoVisivel;
    if (p == null || _c.encerrada) return const [];
    // RN-148/RN-210: plano ativo com um novo valor em negociação.
    final novo = p.status == StatusPlano.ativo ? p.novoValor : null;
    final n = novo ?? p.negociacao;
    final encerrado = p.estado() == EstadoPlano.encerrado;
    if (n.propostas.isEmpty &&
        p.status != StatusPlano.pendente &&
        !encerrado &&
        p.visitaSuspensa == null) {
      return const [];
    }
    return [
      const SizedBox(height: 18),
      if (n.propostas.isNotEmpty)
        NegociacaoPlanoChat(
          plano: p,
          souCliente: true,
          novoValor: novo != null,
          ultimoAvulso: _ultimoAvulso,
          cartao: p.cartao ?? pagamentos.padrao?.titulo,
          onConfirmar: () => _confirmarPlano(p),
          onOutroValor: () => _outroValorPlano(p),
          onRecusar: () => _recusarPlano(p),
          onTrocarCartao: () => _emBreve(context, 'Trocar cartão'),
          onVerPlano: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlanoFixoPage(plano: p, doChat: true),
            ),
          ),
        )
      else if (!encerrado)
        NotaChat(
          'Pedido de plano fixo enviado ${_c.artigo == 'a' ? 'à' : 'ao'} '
          '${_c.primeiroNome}.',
        ),
      // RN-205: plano encerrado depois de ativo: o divisor embaixo.
      if (encerrado && !p.semAcordo) ...[
        if (n.propostas.isNotEmpty) const SizedBox(height: 18),
        MarcadorChat(
          'Plano fixo encerrado · ${diaMes(p.encerradoEm ?? clock.now())}',
        ),
      ],
      // C228 · RN-225: visita suspensa por pagamento.
      if (p.visitaSuspensa case final v?) ...[
        const SizedBox(height: 18),
        CartaoVisitaSuspensa(
          plano: p,
          visita: v,
          onAtualizar: () => _atualizarPagamentoVisita(p, v),
        ),
      ],
    ];
  }

  /// RN-140: ligação pelo Tatu, sem mostrar o número.
  void _ligar() {
    if (!_c.podeLigar) return;
    conversas.verDicaLigar(_c);
    ligarPeloTatu(context, _c.nome);
  }

  /// Perfil do profissional (C14–C15) a partir do chat.
  void _verPerfil() => verPerfilDaConversa(context, _c);

  /// Chave de cada balão, para o menu abrir no lugar dele (RN-134).
  final _chaves = <MensagemChat, GlobalKey>{};

  /// RN-134: segurar uma mensagem de texto do outro.
  Future<void> _segurar(MensagemChat m) async {
    final texto = m.texto ?? '';
    final motivo = await segurarMensagem(
      context,
      alvo: _chaves.putIfAbsent(m, GlobalKey.new),
      balao: BalaoChat(texto: texto, outro: '${_c.artigo} ${_c.primeiroNome}'),
      texto: texto,
      nome: _c.primeiroNome,
      feminino: _c.feminino,
    );
    if (motivo == null || !mounted) return;
    final textos = [
      for (final x in _c.mensagens)
        if (x.texto != null && !x.denunciada)
          '${x.minha ? 'Eu' : _c.primeiroNome}: ${x.texto}',
    ];
    final i = textos.indexOf('${_c.primeiroNome}: $texto');
    denuncias.denunciarMensagem(
      denunciante: conta.nomeCompleto,
      denunciado: _c.nome,
      motivo: motivo,
      mensagem: texto,
      contexto: RegrasDenuncia.contexto(textos, i < 0 ? 0 : i),
    );
    conversas.denunciarMensagem(m);
  }

  /// RN-130: "Chamar outro profissional" abre a busca com o mesmo pedido.
  void _chamarOutro() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProcurandoPage(
          servico: _c.servico,
          endereco: _c.rua,
          distancia: _c.distancia,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        conversas,
        pagamentos,
        planosFixos,
        retornos,
      ]),
      builder: (context, _) {
        final msgs = _c.mensagens;
        final ultimaFotoMinha = msgs.lastIndexWhere((m) => m.minha && m.foto);
        final algumaFalhou = msgs.any((m) => m.envio == EnvioMensagem.falhou);
        final fim = _c.encerramento;
        // RN-230: cards no lugar em que foram enviados.
        final antes = fim == null && !_c.semAcordo
            ? _cartoesNoLugar()
            : const <int, List<Widget>>{};
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _descerSeChegouMensagem();
          _verValorFora();
          // RN-229: conta a validade do valor que está na tela.
          conversas.conferirValidade(_c);
          _contarValidade();
        });
        return NotificationListener<ScrollNotification>(
          // A rolagem avisa no meio do layout: confere no fim do quadro.
          onNotification: (_) {
            _conferirNoFimDoQuadro();
            return false;
          },
          child: TelaChat(
            controle: _rolagem,
            // RN-132: encerrada pelo Tatu, o nome vira "Conta indisponível".
            topo: fim != null
                ? TopoContaIndisponivel(detalhe: _c.servico)
                : _comBarraDoPlano(
                    _Topo(
                      conversa: _c,
                      onMenu: _menu,
                      onLigar: _ligar,
                      // RN-202: "[profissão] · Plano fixo".
                      subtitulo: _barraPlano == null
                          ? null
                          : '${_c.profissao} · Plano fixo',
                    ),
                  ),
            // C104 · RN-140: o ligar acabou de ser liberado.
            sobre: _c.podeLigar && !_c.dicaLigarVista
                ? BalaoLigarLiberado(onFechar: () => conversas.verDicaLigar(_c))
                : null,
            rodapeColado: fim != null || _c.semAcordo,
            mensagens: [
              CartaoPedidoChat(
                servico: _c.servico,
                descricao: _c.descricao,
                lado: _c.rua,
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              if (fim == null)
                NotaChat(
                  'Você aceitou ${_c.artigo} ${_c.primeiroNome}. '
                  'Combinem os detalhes e o valor por aqui.',
                ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              ..._visitasDoPlano(),
              for (final (i, m) in msgs.indexed) ...[
                ...?antes[i],
                if (m.concluido != null)
                  // RN-42: o serviço acabou, a conversa continua.
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: MarcoConcluido(m.concluido!),
                  )
                else if (m.divisor != null)
                  // RN-179/RN-181: começa um atendimento novo na conversa.
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: DivisorChat(m.divisor!, nota: m.divisorNota),
                  )
                else if (m.dia != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: SeparadorDia(m.dia!),
                  )
                else if (m.bloqueada)
                  // RN-120: barrado; só quem enviou vê.
                  const Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: BalaoBloqueado(),
                  )
                else if (m.marcador != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: MarcadorChat(m.marcador!),
                  )
                else if (m.previaEm != null)
                  // RN-99: prévia protegida, só no app.
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: BalaoPrevia(
                      valida: RegrasDistancia.previaValida(
                        m.previaEm!,
                        clock.now(),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PreviaProtegidaPage(
                            de: _c.primeiroNome,
                            enviadaEm: m.previaEm!,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (m.entrega != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: GestureDetector(
                      onLongPress: () => _denunciar(m),
                      child: _entrega(m),
                    ),
                  )
                else if (m.arquivo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: GestureDetector(
                      onLongPress: m.minha ? null : () => _denunciar(m),
                      child: BalaoArquivo(
                        nome: m.arquivo!,
                        detalhe: m.arquivoDetalhe ?? '',
                        minha: m.minha,
                      ),
                    ),
                  )
                else if (m.denunciada)
                  // RN-134: só quem denunciou vê isso no lugar da mensagem.
                  const Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: MensagemDenunciada(),
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(
                      top: _primeiroDoBloco(msgs, i)
                          ? (i == 0 ? 0 : 18)
                          : espacoAntesDoBalao(
                              anteriorMinha: msgs[i - 1].minha,
                              minha: m.minha,
                            ),
                    ),
                    child: GestureDetector(
                      key: _chaves.putIfAbsent(m, GlobalKey.new),
                      // RN-123: foto recebida pode ser denunciada.
                      // RN-134: mensagem de texto do outro também.
                      onLongPress: m.minha || _c.encerrada
                          ? null
                          : m.foto
                          ? () => _denunciar(m)
                          : () => _segurar(m),
                      child: BalaoChat(
                        texto: m.texto,
                        minha: m.minha,
                        outro: '${_c.artigo} ${_c.primeiroNome}',
                        foto: m.foto,
                        imagem: m.imagem,
                        legenda: i == ultimaFotoMinha && m.hora != null
                            ? 'Enviada · ${m.hora}'
                            : null,
                        falhou: m.envio == EnvioMensagem.falhou,
                        onTentarDeNovo: () => conversas.reenviar(m),
                      ),
                    ),
                  ),
              ],
              if (fim != null) ...[
                // RN-130: o Tatu avisa e oferece outro profissional.
                const SizedBox(height: TatuMedidas.entreSecoes),
                CartaoTatuChat(
                  texto: fim.mensagem,
                  botao: fim.chamarOutro ? 'Chamar outro profissional' : null,
                  onBotao: _chamarOutro,
                ),
                if (fim.nota != null) ...[
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  NotaChat(fim.nota!),
                ],
              ] else if (_c.semAcordo) ...[
                // RN-301: só leitura depois da recusa do último valor.
                const SizedBox(height: TatuMedidas.entreSecoes),
                const MarcadorChat('Sem acordo de valor'),
              ] else ...[
                // RN-230: os cards enviados depois da última mensagem.
                ...?antes[msgs.length],
                ..._semEntrega(),
              ],
            ],
            // RN-132: só leitura depois que o Tatu encerra.
            // RN-42: fora isso, a conversa nunca fecha.
            rodape: fim != null || _c.semAcordo
                ? const RodapeConversaEncerrada()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (conversas.semInternet || algumaFalhou) ...[
                        const _SemInternet(),
                        const SizedBox(height: TatuMedidas.entreItens),
                      ],
                      if (_mostraDicaPedirDeNovo) ...[
                        DicaPedirDeNovo(onPedir: _pedirDeNovo),
                        const SizedBox(height: TatuMedidas.entreItens),
                      ],
                      // RN-85: contato não passa pelo chat.
                      BarraMensagem(
                        controller: _campo,
                        onEnviar: _enviar,
                        onCamera: _anexar,
                        porQue:
                            // RN-107: garantia de 24 horas por serviço.
                            'Pelo Tatu o serviço tem garantia de 24h. Chame '
                            '${_c.artigo} ${_c.primeiroNome} de novo pelo app.',
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _Topo extends StatelessWidget {
  const _Topo({
    required this.conversa,
    required this.onMenu,
    required this.onLigar,
    this.subtitulo,
  });

  /// RN-202: "Diarista · Plano fixo" (nulo = só a profissão).
  final String? subtitulo;

  final Conversa conversa;
  final VoidCallback onMenu;
  final VoidCallback onLigar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BackCircleButton(),
        Expanded(
          child: Semantics(
            button: true,
            label: 'Opções da conversa',
            child: GestureDetector(
              onTap: onMenu,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AvatarIniciais(nome: conversa.nome),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                conversa.primeiroNome,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              TablerIcons.circle_check_filled,
                              size: 18,
                              color: TatuColors.verified,
                              semanticLabel: 'Verificada',
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              TablerIcons.chevron_right,
                              size: 14,
                              color: TatuColors.textSecondary,
                            ),
                          ],
                        ),
                        Text(
                          subtitulo ?? conversa.profissao,
                          style: TatuTexto.nota,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // RN-140: o telefone só aparece com o valor confirmado e some
        // quando o serviço é concluído.
        if (conversa.podeLigar)
          BotaoLigar(onTap: onLigar)
        else
          const SizedBox(width: 48),
      ],
    );
  }
}

class _SemInternet extends StatelessWidget {
  const _SemInternet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: TatuColors.dangerSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: const Row(
        children: [
          Icon(TablerIcons.alert_triangle, size: 20, color: TatuColors.danger),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sem internet. Reconectando...',
              style: TextStyle(fontSize: 15, color: TatuColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

/// O balão vem logo depois de um marco, separador ou arquivo?
bool _primeiroDoBloco(List<MensagemChat> msgs, int i) {
  if (i == 0) return true;
  final a = msgs[i - 1];
  return a.concluido != null ||
      a.dia != null ||
      a.arquivo != null ||
      a.divisor != null;
}
