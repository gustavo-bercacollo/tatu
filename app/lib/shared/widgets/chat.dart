import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../contato_oculto.dart';
import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import 'avatar_iniciais.dart';
import 'dart:async';
import '../../data/ditado.dart';
import 'ditado.dart';

/// Esqueleto das telas de chat: topo, lista de mensagens e rodapé
/// (barra de mensagem e botões).
class TelaChat extends StatelessWidget {
  const TelaChat({
    super.key,
    required this.topo,
    required this.mensagens,
    required this.rodape,
    this.rodapeColado = false,
    this.sobre,
  });

  /// Por cima da conversa, abaixo do canto direito do topo (ex.: balão
  /// "Agora dá para ligar pelo Tatu", RN-140).
  final Widget? sobre;

  final Widget topo;
  final List<Widget> mensagens;
  final Widget rodape;

  /// Rodapé de largura total, sem margens.
  final bool rodapeColado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Stack(
              children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      TatuMedidas.topo,
                      TatuMedidas.margem,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        topo,
                        const SizedBox(height: TatuMedidas.entreSecoes),
                        Expanded(child: ListView(children: mensagens)),
                      ],
                    ),
                  ),
                ),
                if (rodapeColado)
                  rodape
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      TatuMedidas.entreItens,
                      TatuMedidas.margem,
                      TatuMedidas.entreItens,
                    ),
                    child: rodape,
                  ),
              ],
            ),
            if (sobre != null)
              Positioned(
                top: TatuMedidas.topo + 40,
                right: TatuMedidas.margem,
                child: sobre!,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Espaço antes de um balão: maior quando muda quem fala.
double espacoAntesDoBalao({
  required bool? anteriorMinha,
  required bool minha,
}) => anteriorMinha == null ? 0 : (anteriorMinha == minha ? 10 : 18);

/// Nota cinza centralizada no meio da conversa.
class NotaChat extends StatelessWidget {
  const NotaChat(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) =>
      Text(texto, textAlign: TextAlign.center, style: TatuTexto.nota);
}

/// Cartão cinza com o pedido no topo da conversa.
class CartaoPedidoChat extends StatelessWidget {
  const CartaoPedidoChat({
    super.key,
    required this.servico,
    required this.descricao,
    required this.lado,
    this.rotulo = 'Pedido',
  });

  /// "Pedido" (cliente) ou "Chamado" (profissional).
  final String rotulo;
  final String servico;
  final String descricao;

  /// Texto pequeno à direita (data ou rua).
  final String lado;

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
                  '$rotulo · $servico',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descricao,
                  overflow: TextOverflow.ellipsis,
                  style: TatuTexto.detalhe,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(lado, style: TatuTexto.nota),
        ],
      ),
    );
  }
}

/// Balão de mensagem: da pessoa (preto, à direita) ou do outro lado
/// (cinza, à esquerda). Pode ser uma foto e mostrar "Não enviada".
class BalaoChat extends StatelessWidget {
  const BalaoChat({
    super.key,
    this.texto,
    this.minha = false,
    this.foto = false,
    this.imagem,
    this.legenda,
    this.falhou = false,
    this.onTentarDeNovo,
    this.ocultarContato = true,
    this.outro,
  });

  /// RN-85: contatos em mensagens recebidas aparecem como "contato oculto".
  final bool ocultarContato;

  /// "a Luiza", para a nota embaixo do contato oculto.
  final String? outro;

  final String? texto;
  final bool minha;
  final bool foto;
  final Uint8List? imagem;

  /// Linha pequena embaixo (ex.: "Enviada · 14:32").
  final String? legenda;
  final bool falhou;
  final VoidCallback? onTentarDeNovo;

  /// O texto com cada contato trocado pela pílula "contato oculto".
  TextSpan _textoComContato(List<TrechoContato> oculto) {
    final t = texto ?? '';
    if (oculto.isEmpty) return TextSpan(text: t);
    final partes = <InlineSpan>[];
    var i = 0;
    for (final c in oculto) {
      if (c.inicio > i) partes.add(TextSpan(text: t.substring(i, c.inicio)));
      partes.add(
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _PilulaOculta(),
        ),
      );
      i = c.fim;
    }
    if (i < t.length) partes.add(TextSpan(text: t.substring(i)));
    return TextSpan(children: partes);
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final raio = BorderRadius.circular(TatuMedidas.raioOpcao);
    // RN-85: só nas mensagens recebidas (as minhas nunca saem com contato).
    final oculto = !minha && !foto && ocultarContato && texto != null
        ? acharContatos(texto!)
        : const <TrechoContato>[];
    final Widget balao = foto
        ? ClipRRect(
            borderRadius: raio,
            child: Container(
              width: largura * 0.46,
              height: largura * 0.33,
              color: TatuColors.fillStrong,
              child: imagem == null
                  ? const Icon(
                      TablerIcons.photo,
                      size: 36,
                      color: TatuColors.textSecondary,
                    )
                  : Image.memory(imagem!, fit: BoxFit.cover),
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: largura * 0.86),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: minha ? TatuColors.action : TatuColors.fill,
                borderRadius: raio,
              ),
              child: Text.rich(
                _textoComContato(oculto),
                style: TextStyle(
                  fontSize: 17,
                  height: 1.3,
                  color: minha ? TatuColors.onAction : TatuColors.textPrimary,
                ),
              ),
            ),
          );
    return Column(
      crossAxisAlignment: minha
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: minha
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (falhou) ...[
              const Icon(
                TablerIcons.alert_circle_filled,
                size: 22,
                color: TatuColors.danger,
                semanticLabel: 'Não enviada',
              ),
              const SizedBox(width: 8),
            ],
            Flexible(child: balao),
          ],
        ),
        if (falhou)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: GestureDetector(
              onTap: onTentarDeNovo,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Não enviada · Tentar de novo',
                style: TatuTexto.nota.copyWith(color: TatuColors.danger),
              ),
            ),
          )
        else if (legenda != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(legenda!, style: TatuTexto.nota),
          ),
        if (oculto.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: TatuMedidas.entreItens + 4),
            child: _NotaContatoOculto(outro: outro),
          ),
      ],
    );
  }
}

/// Pílula cinza com cadeado no lugar de um contato (RN-85).
class _PilulaOculta extends StatelessWidget {
  const _PilulaOculta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            TablerIcons.lock,
            size: 15,
            color: TatuColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'contato oculto',
            style: TatuTexto.corpo.copyWith(
              fontWeight: FontWeight.w600,
              color: TatuColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão cinza embaixo de uma mensagem com contato oculto (RN-85).
class _NotaContatoOculto extends StatelessWidget {
  const _NotaContatoOculto({this.outro});

  final String? outro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        children: [
          const Icon(
            TablerIcons.shield_check,
            size: 22,
            color: TatuColors.textSecondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Telefones e redes ficam ocultos.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  // RN-107: a garantia do Tatu é de 24 horas por serviço.
                  outro == null
                      ? 'Chame de novo pelo app, com garantia de 24h.'
                      : 'Chame $outro de novo pelo app, com garantia de 24h.',
                  style: TatuTexto.nota,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso amarelo acima do campo quando há contato no texto (RN-85).
class _AvisoContato extends StatelessWidget {
  const _AvisoContato({
    required this.titulo,
    required this.texto,
    this.icone = TablerIcons.lock,
  });

  final String titulo;
  final String texto;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.warningSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 22,
            color: TatuColors.warningTexto,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TatuColors.warningTexto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: TatuTexto.nota.copyWith(
                    color: TatuColors.warningTexto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra embaixo do chat: câmera e campo "Mensagem". Com
/// [bloquearContato], telefone, e-mail, endereço, @ e links não são
/// enviados: a borda fica preta e aparece o aviso amarelo (RN-85).
class BarraMensagem extends StatefulWidget {
  const BarraMensagem({
    super.key,
    required this.controller,
    required this.onEnviar,
    required this.onCamera,
    this.bloquearContato = true,
    this.porQue = 'Pelo Tatu o serviço tem garantia de 24h.',
  });

  final TextEditingController controller;
  final VoidCallback onEnviar;
  final VoidCallback onCamera;
  final bool bloquearContato;

  /// Explicação no aviso (muda entre cliente e profissional).
  final String porQue;

  @override
  State<BarraMensagem> createState() => _BarraMensagemState();
}

class _BarraMensagemState extends State<BarraMensagem> {
  /// RN-138: ouvindo agora (o texto aparece no próprio campo).
  bool _ouvindo = false;

  /// RN-138: o texto do campo veio do ditado; a pessoa confere e envia.
  bool _ditado = false;
  int _segundos = 0;
  Timer? _relogio;
  StreamSubscription<String>? _fala;

  TextEditingController get _campo => widget.controller;

  @override
  void initState() {
    super.initState();
    _campo.addListener(_mudou);
  }

  @override
  void dispose() {
    _campo.removeListener(_mudou);
    _relogio?.cancel();
    _fala?.cancel();
    if (_ouvindo) ditado.parar();
    super.dispose();
  }

  /// Enviou ou apagou: o aviso de ditado some.
  void _mudou() {
    if (_ditado && !_ouvindo && _campo.text.isEmpty) {
      setState(() => _ditado = false);
    }
  }

  Future<void> _ditar() async {
    // Permissão do microfone só no primeiro toque.
    if (!await ditado.permitir()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Permita o microfone nas configurações para ditar.'),
          ),
        );
      return;
    }
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _ouvindo = true;
      _ditado = true;
      _segundos = 0;
    });
    _relogio = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _segundos++),
    );
    _fala = ditado.ouvir().listen((t) => _campo.text = t);
  }

  /// Parar: o texto fica no campo para conferir e enviar como texto.
  Future<void> _parar() async {
    _relogio?.cancel();
    unawaited(_fala?.cancel());
    await ditado.parar();
    if (!mounted) return;
    setState(() {
      _ouvindo = false;
      _ditado = _campo.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _campo,
      builder: (context, _) {
        final contato = widget.bloquearContato
            ? contatoNoTexto(_campo.text)
            : null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (contato != null) ...[
              _AvisoContato(
                titulo: contato.aviso,
                icone: contato == TipoContato.link
                    ? TablerIcons.alert_triangle
                    : TablerIcons.lock,
                texto: switch (contato) {
                  // RN-28: o endereço vai sozinho depois do valor.
                  TipoContato.endereco =>
                    'O endereço vai pelo app depois que o valor é '
                        'confirmado.',
                  // RN-124: arquivo vai direto pelo chat (link, só entrega).
                  TipoContato.link => 'Envie o arquivo direto aqui.',
                  _ => widget.porQue,
                },
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
            ],
            _linha(context, bloqueado: contato != null),
          ],
        );
      },
    );
  }

  Widget _botao({
    required String rotulo,
    required Color fundo,
    required Widget icone,
    VoidCallback? onTap,
    double tamanho = 36,
  }) => Semantics(
    button: true,
    label: rotulo,
    excludeSemantics: true,
    child: Material(
      color: fundo,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: tamanho,
          height: tamanho,
          child: Center(child: icone),
        ),
      ),
    ),
  );

  Widget _linha(BuildContext context, {required bool bloqueado}) {
    void enviar() {
      if (!bloqueado) widget.onEnviar();
    }

    final temTexto = _campo.text.trim().isNotEmpty;
    // Campo alto quando há ditado (rótulo + texto), como nos desenhos.
    final alto = _ouvindo || _ditado;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _botao(
          rotulo: 'Enviar foto',
          fundo: TatuColors.fill,
          icone: const Icon(TablerIcons.camera, size: 20),
          onTap: widget.onCamera,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: TatuMedidas.alturaChip,
            ),
            padding: alto
                ? const EdgeInsets.fromLTRB(16, 10, 16, 10)
                : const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: bloqueado ? TatuColors.bg : TatuColors.fill,
              borderRadius: BorderRadius.circular(TatuMedidas.alturaChip / 2),
              border: _ouvindo
                  ? Border.all(color: TatuColors.danger, width: 1.5)
                  : bloqueado
                  ? Border.all(color: TatuColors.action, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_ouvindo) ...[
                  RotuloOuvindo(
                    'Ouvindo · ${tempoDitado(_segundos)}',
                    pequeno: true,
                  ),
                  const SizedBox(height: 4),
                ],
                TextField(
                  controller: _campo,
                  readOnly: _ouvindo,
                  onSubmitted: (_) => enviar(),
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: alto ? 4 : 1,
                  cursorColor: TatuColors.textPrimary,
                  style: TextStyle(
                    fontSize: alto ? 15 : 17,
                    color: _ouvindo
                        ? TatuColors.textSecondary
                        : TatuColors.textPrimary,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: _ouvindo ? 'Pode falar…' : 'Mensagem',
                    hintStyle: const TextStyle(
                      fontSize: 17,
                      color: TatuColors.textSecondary,
                    ),
                  ),
                ),
                // RN-138: confere antes de enviar; vai como texto.
                if (_ditado && !_ouvindo) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Ditado · confira antes de enviar',
                    style: TatuTexto.legenda,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_ouvindo)
          _botao(
            rotulo: 'Parar ditado',
            fundo: TatuColors.danger,
            tamanho: 40,
            icone: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: TatuColors.onAction,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            onTap: _parar,
          )
        else if (temTexto || bloqueado)
          // Enviar (como no WhatsApp): preto quando há texto que pode ir.
          _botao(
            rotulo: 'Enviar mensagem',
            fundo: temTexto && !bloqueado ? TatuColors.action : TatuColors.fill,
            tamanho: alto ? 40 : 36,
            icone: Icon(
              TablerIcons.send,
              size: 18,
              color: temTexto && !bloqueado
                  ? TatuColors.onAction
                  : TatuColors.textSecondary,
            ),
            onTap: temTexto && !bloqueado ? enviar : null,
          )
        else
          // RN-138: campo vazio mostra o microfone ("Ditar").
          _botao(
            rotulo: 'Ditar',
            fundo: TatuColors.fill,
            icone: const Icon(TablerIcons.microphone, size: 20),
            onTap: _ditar,
          ),
      ],
    );
  }
}

/// RN-42: faixa verde "Serviço concluído · R$ 190,00 · 04 nov" no meio
/// da conversa, que continua aberta depois dela.
class MarcoConcluido extends StatelessWidget {
  const MarcoConcluido(this.texto, {super.key, this.nota = true});

  final String texto;

  /// Mostra embaixo "A conversa continua aberta…".
  final bool nota;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TatuColors.onlineSoft,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          ),
          child: Row(
            children: [
              const Icon(
                TablerIcons.check,
                size: 20,
                color: TatuColors.onlineTexto,
              ),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.onlineTexto,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (nota) ...[
          const SizedBox(height: TatuMedidas.entreItens),
          const NotaChat(
            'A conversa continua aberta. Precisou de novo, é só chamar por '
            'aqui.',
          ),
        ],
      ],
    );
  }
}

/// Pílula preta sobre uma linha fina, no meio da conversa: começa um
/// atendimento novo. RN-179: "Novo pedido · 24 nov · Vazamento no
/// banheiro". RN-181: "Novo serviço iniciado pelo chat · R$ 150,00", com
/// [nota] embaixo ("Ele aparece na sua Atividade.").
class DivisorChat extends StatelessWidget {
  const DivisorChat(this.texto, {super.key, this.nota});

  final String texto;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const Divider(height: 1, color: TatuColors.trilho),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const ShapeDecoration(
                color: TatuColors.action,
                shape: StadiumBorder(),
              ),
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: TatuTexto.nota.copyWith(
                  color: TatuColors.onAction,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (nota != null) ...[
          const SizedBox(height: 8),
          NotaChat(nota!),
        ],
      ],
    );
  }
}

/// RN-180: dica acima do campo de mensagem, no chat de um serviço
/// concluído: mensagem é só conversa; serviço novo é "Pedir de novo".
class DicaPedirDeNovo extends StatelessWidget {
  const DicaPedirDeNovo({super.key, required this.onPedir});

  final VoidCallback onPedir;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
      ),
      child: Row(
        children: [
          const Icon(
            TablerIcons.refresh,
            size: 18,
            color: TatuColors.textSecondary,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Precisa de um novo serviço?', style: TatuTexto.detalhe),
          ),
          TextButton(
            onPressed: onPedir,
            style: TextButton.styleFrom(
              foregroundColor: TatuColors.verified,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Pedir de novo'),
          ),
        ],
      ),
    );
  }
}

/// Separador de dia no meio da conversa ("12 nov").
class SeparadorDia extends StatelessWidget {
  const SeparadorDia(this.dia, {super.key});

  final String dia;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      dia,
      textAlign: TextAlign.center,
      style: TatuTexto.nota.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

/// Pílula cinza centralizada no meio da conversa ("Valor confirmado ·
/// sinal de R$ 75 pago", "Entrega 1 de 2 · ajuste pedido").
class MarcadorChat extends StatelessWidget {
  const MarcadorChat(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const ShapeDecoration(
        color: TatuColors.fill,
        shape: StadiumBorder(),
      ),
      child: Text(texto, textAlign: TextAlign.center, style: TatuTexto.nota),
    ),
  );
}

/// RN-99: balão da prévia protegida. Do profissional ([minha]) é preto;
/// para o cliente é cinza e abre ao tocar enquanto não expira.
class BalaoPrevia extends StatelessWidget {
  const BalaoPrevia({
    super.key,
    required this.valida,
    this.minha = false,
    this.vistaPor,
    this.onTap,
  });

  /// Ainda não expirou.
  final bool valida;
  final bool minha;

  /// "Ana": no balão do profissional, "Vista pela Ana · expirada".
  final String? vistaPor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final detalhe = minha
        ? (valida
              ? 'Enviada · expira em 24h'
              : 'Vista ${vistaPor == null ? '' : 'pela $vistaPor '}· expirada')
        : (valida ? 'Só para ver · expira em 24h' : 'Vista · expirada');
    final corTexto = minha ? TatuColors.onAction : TatuColors.textPrimary;
    return Column(
      crossAxisAlignment: minha
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: minha ? 0.7 : 0.64,
            child: Semantics(
              button: onTap != null && valida,
              label: 'Prévia protegida',
              child: GestureDetector(
                onTap: valida ? onTap : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: minha ? TatuColors.action : TatuColors.fill,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: minha
                              ? TatuColors.editorTrilho
                              : TatuColors.bg,
                          borderRadius: BorderRadius.circular(
                            TatuMedidas.raioCaixa,
                          ),
                        ),
                        child: Icon(TablerIcons.lock, size: 22, color: corTexto),
                      ),
                      const SizedBox(width: TatuMedidas.entreItens),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prévia protegida',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: corTexto,
                              ),
                            ),
                            Text(
                              detalhe,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TatuTexto.nota.copyWith(
                                color: minha
                                    ? TatuColors.avisoEscuroTexto
                                    : TatuColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!minha && valida) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Toque para ver',
              style: TatuTexto.nota.copyWith(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}

/// RN-96: arquivo enviado no chat (entrega à distância).
class BalaoArquivo extends StatelessWidget {
  const BalaoArquivo({
    super.key,
    required this.nome,
    required this.detalhe,
    this.minha = false,
  });

  final String nome;

  /// "PDF · 2,4 MB".
  final String detalhe;
  final bool minha;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.74,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TatuColors.bg,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
                ),
                child: const Icon(TablerIcons.file_text, size: 22),
              ),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(detalhe, style: TatuTexto.nota),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha da lista de Mensagens: avatar, nome, última mensagem, hora,
/// contador de não lidas e um selo opcional (ex.: "Proposta 2 de 3").
class LinhaConversa extends StatelessWidget {
  const LinhaConversa({
    super.key,
    required this.nome,
    required this.iniciais,
    required this.ultima,
    required this.quando,
    required this.onTap,
    this.naoLidas = 0,
    this.online = false,
    this.selo,
    this.avatar,
    this.titulo,
  });

  final String nome;

  /// Avatar próprio no lugar das iniciais (ex.: o "T" do Tatu).
  final Widget? avatar;

  /// Título próprio no lugar do [nome] (ex.: "Tatu ✓ · Fixada").
  final Widget? titulo;

  /// Nome usado para as iniciais do avatar.
  final String iniciais;
  final String ultima;
  final String quando;
  final int naoLidas;
  final bool online;
  final Widget? selo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final naoLida = naoLidas > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: TatuMedidas.margem),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                avatar ?? AvatarIniciais(nome: iniciais, tamanho: 48),
                if (online)
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: TatuColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: TatuColors.bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  14,
                  TatuMedidas.margem,
                  14,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: TatuColors.trilho, width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titulo ??
                              Text(
                                nome,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          const SizedBox(height: 2),
                          Text(
                            ultima,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TatuTexto.detalhe.copyWith(
                              color: naoLida
                                  ? TatuColors.textPrimary
                                  : TatuColors.textSecondary,
                            ),
                          ),
                          if (selo != null) ...[
                            const SizedBox(height: 6),
                            selo!,
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(quando, style: TatuTexto.nota),
                        const SizedBox(height: 6),
                        if (naoLida)
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: TatuColors.action,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$naoLidas',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: TatuColors.onAction,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
