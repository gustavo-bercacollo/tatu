import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ajuda.dart';
import '../../../data/conta.dart';
import '../../../shared/widgets/back_circle_button.dart';
import 'ajuda_page.dart';

/// Chat com o suporte do Tatu. Com [pedido], mostra o pedido no topo.
/// Versão simulada: o atendente responde sozinho à primeira mensagem.
class ChatSuportePage extends StatefulWidget {
  const ChatSuportePage({super.key, this.pedido});

  final PedidoRecente? pedido;

  @override
  State<ChatSuportePage> createState() => _ChatSuportePageState();
}

class _Mensagem {
  const _Mensagem(this.texto, {this.minha = false});

  final String texto;
  final bool minha;
}

class _ChatSuportePageState extends State<ChatSuportePage> {
  final _campo = TextEditingController();
  final _rolagem = ScrollController();
  Timer? _resposta;
  late final List<_Mensagem> _mensagens = [
    _Mensagem('Oi, ${conta.nome}! Sou o Rafael, do suporte.'),
    _Mensagem(
      widget.pedido == null
          ? 'Como posso ajudar?'
          : 'Vi seu pedido com a ${widget.pedido!.profissional}. Como ajudo?',
    ),
  ];

  @override
  void dispose() {
    _resposta?.cancel();
    _campo.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _campo.text.trim();
    if (texto.isEmpty) return;
    final primeira = !_mensagens.any((m) => m.minha);
    setState(() => _mensagens.add(_Mensagem(texto, minha: true)));
    _campo.clear();
    if (primeira) {
      _resposta = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(
          () => _mensagens.add(const _Mensagem('Já estou vendo, um instante.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.entreItens,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Topo(),
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  Expanded(
                    child: ListView(
                      controller: _rolagem,
                      children: [
                        if (p != null) ...[
                          _CartaoPedido(pedido: p),
                          const SizedBox(height: TatuMedidas.entreSecoes),
                        ],
                        const Text(
                          'Você está falando com o suporte do Tatu.',
                          textAlign: TextAlign.center,
                          style: TatuTexto.nota,
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        for (final (i, m) in _mensagens.indexed)
                          Padding(
                            padding: EdgeInsets.only(
                              top: i == 0
                                  ? 0
                                  : m.minha != _mensagens[i - 1].minha
                                  ? 18
                                  : 10,
                            ),
                            child: _Balao(mensagem: m),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  _BarraMensagem(controller: _campo, onEnviar: _enviar),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Topo extends StatelessWidget {
  const _Topo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BackCircleButton(),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconeSuporte(tamanho: 32),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suporte Tatu',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Rafael · online',
                    style: TextStyle(fontSize: 13, color: TatuColors.online),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 36), // equilibra o botão de voltar
      ],
    );
  }
}

class _CartaoPedido extends StatelessWidget {
  const _CartaoPedido({required this.pedido});

  final PedidoRecente pedido;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido · ${pedido.servico}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(pedido.descricao, style: TatuTexto.detalhe),
              ],
            ),
          ),
          Text(pedido.quando, style: TatuTexto.nota),
        ],
      ),
    );
  }
}

class _Balao extends StatelessWidget {
  const _Balao({required this.mensagem});

  final _Mensagem mensagem;

  @override
  Widget build(BuildContext context) {
    final minha = mensagem.minha;
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: minha ? TatuColors.action : TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          ),
          child: Text(
            mensagem.texto,
            style: TextStyle(
              fontSize: 17,
              height: 1.3,
              color: minha ? TatuColors.onAction : TatuColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarraMensagem extends StatelessWidget {
  const _BarraMensagem({required this.controller, required this.onEnviar});

  final TextEditingController controller;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Enviar foto',
          child: Material(
            color: TatuColors.fill,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Enviar foto: em breve')),
                ),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(TablerIcons.camera, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: TatuMedidas.alturaChip,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const ShapeDecoration(
              color: TatuColors.fill,
              shape: StadiumBorder(),
            ),
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onEnviar(),
              textInputAction: TextInputAction.send,
              cursorColor: TatuColors.textPrimary,
              style: const TextStyle(fontSize: 17),
              decoration: const InputDecoration.collapsed(
                hintText: 'Mensagem',
                hintStyle: TextStyle(
                  fontSize: 17,
                  color: TatuColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
