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
import 'package:clock/clock.dart';

import '../../../data/arquivos_seguros.dart';
import '../../../data/regras_distancia.dart';
import '../../entrada/chat_encerrado.dart';
import '../../entrada/conta_suspensa_page.dart';
import '../chamar/procurando_page.dart';
import '../../entrada/denunciar_arquivo.dart';
import '../atividade/avaliar_page.dart';
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

void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text('$o: em breve')));

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
    });
  }

  Conversa get _c => widget.conversa;

  @override
  void dispose() {
    _timer?.cancel();
    _campo.dispose();
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
      pedidos
        ..abrir(p)
        ..entregaAprovada();
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvaliarPage(
          pedido: PedidoConcluido(
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

  List<Widget> _valor() {
    final v = _c.valor;
    if (v == null) return const [];
    // À distância, depois de confirmar, vale o marcador no chat.
    if (_c.distancia && v.situacao == SituacaoValor.confirmado) {
      return const [];
    }
    return [
      const SizedBox(height: TatuMedidas.entreSecoes),
      // RN-87: numa conversa que já teve serviço, é um valor novo.
      NotaChat(
        '${_c.primeiroNome} enviou ${v.novo ? 'um novo valor' : 'um valor'}',
      ),
      const SizedBox(height: TatuMedidas.entreItens),
      switch (v.situacao) {
        SituacaoValor.aguardandoVoce => CartaoValorRecebido(
          valor: v,
          nome: '${_c.artigo} ${_c.primeiroNome}',
          onConfirmar: () {
            conversas.confirmarValor(_c);
            // RN-76: começa o prazo do profissional para sair.
            if (pedidos.doProfissional(_c.nome) case final p?) {
              pedidos.abrir(p);
              // RN-103: à distância, o sinal é cobrado agora.
              pedidos.valorConfirmado(sinal: v.sinal);
              // RN-165: no local, vai direto para o acompanhamento.
              if (!_c.distancia) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PedidoAndamentoPage(),
                  ),
                );
              }
            }
            // RN-99/RN-100: à distância, protótipo: chega uma prévia e
            // depois a 1ª entrega.
            if (_c.distancia) {
              _timer?.cancel();
              _timer = Timer(widget.resposta * 2, () {
                conversas.receberPrevia(_c);
                _timer = Timer(
                  widget.resposta * 2,
                  () => conversas.receberEntrega(_c),
                );
              });
            }
          },
          onTrocar: _trocarPagamento,
          onParcelas: () => _parcelas(v),
          onPedirOutro: v.rodada < maxRodadasValor ? _pedirOutro : null,
        ),
        SituacaoValor.pediuOutro => CartaoValorPedido(
          valor: v,
          nome: '${_c.artigo} ${_c.primeiroNome}',
        ),
        SituacaoValor.confirmado => CartaoValorConfirmado(valor: v),
      },
    ];
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
    icone: TablerIcons.tool,
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
              texto: 'Ver perfil ${_c.artigo == 'a' ? 'da' : 'do'} '
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
        MaterialPageRoute(builder: (_) => PlanoFixoPage(plano: atual)),
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
  void _confirmarPlano(PlanoFixo p) {
    planosFixos.confirmar(
      p,
      cartao: pagamentos.padrao?.titulo ?? 'Visa final 4242',
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlanoFixoPage(plano: p)),
    );
  }

  /// Pedir outro valor: o profissional responde de novo (protótipo).
  void _outroValorPlano(PlanoFixo p) {
    planosFixos.pedirOutroValor(p);
    _timer?.cancel();
    _timer = Timer(widget.resposta, () => planosFixos.enviarValor(p, 140));
  }

  List<Widget> _planoNoChat() {
    final p = _plano;
    if (p == null || _c.encerrada) return const [];
    return [
      const SizedBox(height: 18),
      if (p.status == StatusPlano.pendente && p.valorPorVisita == null)
        NotaChat('Pedido de plano fixo enviado ${_c.artigo == 'a' ? 'à' : 'ao'} '
            '${_c.primeiroNome}.')
      else if (p.status == StatusPlano.pendente)
        CartaoPropostaPlano(
          plano: p,
          onConfirmar: () => _confirmarPlano(p),
          onOutroValor: () => _outroValorPlano(p),
          onTrocarCartao: () => _emBreve(context, 'Trocar cartão'),
        )
      else
        Center(
          child: GestureDetector(
            onTap: _tornarFixa,
            child: MarcadorChat(
              'Plano fixo · ${p.quando}',
            ),
          ),
        ),
    ];
  }

  /// RN-140: ligação pelo Tatu, sem mostrar o número.
  void _ligar() {
    if (!_c.podeLigar) return;
    conversas.verDicaLigar(_c);
    ligarPeloTatu(context, _c.nome);
  }

  /// Perfil do profissional (C14–C15) a partir do chat.
  void _verPerfil() {
    final p = filaEncontrados.firstWhere(
      (p) => p.nome == _c.nome,
      orElse: () => ProfissionalEncontrado(
        nome: _c.nome,
        profissao: _c.profissao,
        feminino: _c.feminino,
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
            child: const Text('Voltar para a conversa'),
          ),
        ),
      ),
    );
  }

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
        if (x.texto != null && !x.denunciada) '${x.minha ? 'Eu' : _c.primeiroNome}: ${x.texto}',
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
      listenable: Listenable.merge([conversas, pagamentos, planosFixos]),
      builder: (context, _) {
        final msgs = _c.mensagens;
        final ultimaFotoMinha = msgs.lastIndexWhere((m) => m.minha && m.foto);
        final algumaFalhou = msgs.any((m) => m.envio == EnvioMensagem.falhou);
        final fim = _c.encerramento;
        return TelaChat(
          // RN-132: encerrada pelo Tatu, o nome vira "Conta indisponível".
          topo: fim != null
              ? TopoContaIndisponivel(detalhe: _c.servico)
              : _Topo(conversa: _c, onMenu: _menu, onLigar: _ligar),
          // C104 · RN-140: o ligar acabou de ser liberado.
          sobre: _c.podeLigar && !_c.dicaLigarVista
              ? BalaoLigarLiberado(
                  onFechar: () => conversas.verDicaLigar(_c),
                )
              : null,
          rodapeColado: fim != null,
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
            for (final (i, m) in msgs.indexed)
              if (m.concluido != null)
                // RN-42: o serviço acabou, a conversa continua.
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: MarcoConcluido(m.concluido!),
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
            ] else ...[
              ..._planoNoChat(),
              ..._valor(),
              ..._semEntrega(),
            ],
          ],
          // RN-132: só leitura depois que o Tatu encerra.
          // RN-42: fora isso, a conversa nunca fecha.
          rodape: fim != null
              ? const RodapeConversaEncerrada()
              : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (conversas.semInternet || algumaFalhou) ...[
                const _SemInternet(),
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
  });

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
                        Text(conversa.profissao, style: TatuTexto.nota),
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
  return a.concluido != null || a.dia != null || a.arquivo != null;
}
