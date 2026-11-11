import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/chat.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../servico/andamento_page.dart';
import 'enviar_valor_sheet.dart';

/// Respostas prontas do profissional.
const respostasRapidas = ['Estou a caminho', 'Posso hoje'];

/// P23 · Chat do profissional com o cliente: combinar detalhes e enviar
/// o valor. O endereço exato só aparece depois do valor confirmado.
class ChatProfissionalPage extends StatefulWidget {
  const ChatProfissionalPage({super.key, this.chamado = chamadoExemplo});

  final ChamadoNovo chamado;

  @override
  State<ChatProfissionalPage> createState() => _ChatProfissionalPageState();
}

class _ChatProfissionalPageState extends State<ChatProfissionalPage> {
  final _campo = TextEditingController();

  /// (texto, minha): conversa de exemplo.
  final _mensagens = <(String, bool)>[
    ('Oi! Vi o vazamento, posso hoje.', true),
    ('Ótimo, pode vir agora?', false),
    ('Chego em 12 min.', true),
  ];

  /// Valor enviado, esperando o cliente confirmar.
  double? _valorEnviado;
  bool _confirmado = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _campo.dispose();
    super.dispose();
  }

  /// Envia o valor; o cliente confirma (protótipo: sempre, em 2 s) e
  /// só então o endereço aparece, na tela "A caminho".
  Future<void> _enviarValor() async {
    final valor = await pedirValor(context, cliente: widget.chamado.cliente);
    if (valor == null || !mounted) return;
    setState(() {
      _valorEnviado = valor;
      _mensagens.add(('Valor do serviço: ${reais(valor)}', true));
    });
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _confirmado = true);
      _timer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ACaminhoPage(servico: ServicoAceito(valor: valor)),
          ),
        );
      });
    });
  }

  String get _notaValor {
    final nome = widget.chamado.cliente;
    if (_valorEnviado == null) return 'Combine o valor com a $nome';
    if (!_confirmado) return 'Aguardando a $nome confirmar o valor…';
    return '$nome confirmou ${reais(_valorEnviado!)}. Abrindo o endereço…';
  }

  void _emBreve(String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  void _enviar([String? pronto]) {
    final texto = (pronto ?? _campo.text).trim();
    if (texto.isEmpty) return;
    setState(() => _mensagens.add((texto, true)));
    if (pronto == null) _campo.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.chamado;
    final nota = c.notaCliente.toStringAsFixed(1).replaceAll('.', ',');
    return TelaChat(
      topo: Row(
        children: [
          const BackCircleButton(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarIniciais(nome: c.cliente),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      c.cliente,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('Cliente · $nota', style: TatuTexto.nota),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Ligar',
            child: IconButton(
              onPressed: () => _emBreve('Ligar'),
              icon: const Icon(TablerIcons.phone, size: 22),
            ),
          ),
        ],
      ),
      mensagens: [
        CartaoPedidoChat(
          servico: c.profissao,
          descricao: c.resumo,
          lado: c.bairro,
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        const NotaChat(
          'Você aceitou o chamado. Combinem os detalhes e o valor por aqui.',
        ),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        for (final (i, m) in _mensagens.indexed)
          Padding(
            padding: EdgeInsets.only(
              top: espacoAntesDoBalao(
                anteriorMinha: i == 0 ? null : _mensagens[i - 1].$2,
                minha: m.$2,
              ),
            ),
            child: BalaoChat(texto: m.$1, minha: m.$2),
          ),
        const SizedBox(height: TatuMedidas.entreSecoes + 8),
        NotaChat(_notaValor),
      ],
      rodape: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                for (final r in respostasRapidas)
                  TatuChip(label: r, onTap: () => _enviar(r)),
              ],
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          FilledButton(
            onPressed: _valorEnviado == null ? _enviarValor : null,
            child: Text(
              _valorEnviado == null ? 'Enviar valor' : 'Valor enviado',
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          BarraMensagem(
            controller: _campo,
            onEnviar: _enviar,
            onCamera: () => _emBreve('Enviar foto'),
          ),
        ],
      ),
    );
  }
}
