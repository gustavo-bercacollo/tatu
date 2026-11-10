import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/ajuda.dart';
import '../../../data/conta.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/chat.dart';
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
    return TelaChat(
      topo: const _Topo(),
      mensagens: [
        if (p != null) ...[
          CartaoPedidoChat(
            servico: p.servico,
            descricao: p.descricao,
            lado: p.quando,
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
        ],
        const NotaChat('Você está falando com o suporte do Tatu.'),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        for (final (i, m) in _mensagens.indexed)
          Padding(
            padding: EdgeInsets.only(
              top: espacoAntesDoBalao(
                anteriorMinha: i == 0 ? null : _mensagens[i - 1].minha,
                minha: m.minha,
              ),
            ),
            child: BalaoChat(texto: m.texto, minha: m.minha),
          ),
      ],
      rodape: BarraMensagem(
        controller: _campo,
        onEnviar: _enviar,
        onCamera: () => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Enviar foto: em breve')),
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
