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
import 'cartao_valor.dart';
import 'denunciar_page.dart';

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

  Conversa get _c => widget.conversa;

  @override
  void dispose() {
    _timer?.cancel();
    _campo.dispose();
    super.dispose();
  }

  void _trocarPagamento() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const PagamentoPage()));

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

  List<Widget> _valor() {
    final v = _c.valor;
    if (v == null || _c.encerrada) return const [];
    return [
      const SizedBox(height: TatuMedidas.entreSecoes),
      NotaChat('${_c.primeiroNome} enviou um valor'),
      const SizedBox(height: TatuMedidas.entreItens),
      switch (v.situacao) {
        SituacaoValor.aguardandoVoce => CartaoValorRecebido(
          valor: v,
          onConfirmar: () {
            conversas.confirmarValor(_c);
            // RN-76: começa o prazo do profissional para sair.
            if (pedidos.andamento?.profissional == _c.nome) {
              pedidos.valorConfirmado();
            }
          },
          onTrocar: _trocarPagamento,
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

  Future<void> _anexar() async {
    final origem = await mostrarFolha<OrigemFoto>(
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
        ],
      ),
    );
    if (origem == null || !mounted) return;
    try {
      final imagem = await perfil.pedirImagem(origem);
      if (imagem == null || !mounted) return;
      conversas.enviar(
        _c,
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
    if (_c.emAndamento && pedidos.andamento != null) {
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
        _emBreve(context, 'Ligar');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([conversas, pagamentos]),
      builder: (context, _) {
        final msgs = _c.mensagens;
        final ultimaFotoMinha = msgs.lastIndexWhere((m) => m.minha && m.foto);
        final algumaFalhou = msgs.any((m) => m.envio == EnvioMensagem.falhou);
        return TelaChat(
          topo: _Topo(conversa: _c, onMenu: _menu),
          mensagens: [
            CartaoPedidoChat(
              servico: _c.servico,
              descricao: _c.descricao,
              lado: _c.rua,
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            NotaChat(
              'Você aceitou ${_c.artigo} ${_c.primeiroNome}. '
              'Combinem os detalhes e o valor por aqui.',
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            for (final (i, m) in msgs.indexed)
              Padding(
                padding: EdgeInsets.only(
                  top: espacoAntesDoBalao(
                    anteriorMinha: i == 0 ? null : msgs[i - 1].minha,
                    minha: m.minha,
                  ),
                ),
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
            ..._valor(),
            if (_c.encerrada) ...[
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              NotaChat('Serviço concluído em ${_c.concluidoEm}'),
            ],
          ],
          rodapeColado: _c.encerrada,
          rodape: _c.encerrada
              ? const ConversaEncerrada()
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
                          'Pelo Tatu o serviço tem garantia. Chame '
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
  const _Topo({required this.conversa, required this.onMenu});

  final Conversa conversa;
  final VoidCallback onMenu;

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
        Semantics(
          button: true,
          label: 'Ligar',
          child: IconButton(
            onPressed: () => _emBreve(context, 'Ligar'),
            icon: const Icon(TablerIcons.phone, size: 22),
          ),
        ),
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
