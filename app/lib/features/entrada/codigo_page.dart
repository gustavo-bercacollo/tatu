import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../shared/widgets/cadastro_scaffold.dart';
import '../cliente/home_page.dart';
import 'nome_page.dart';

/// Cadastro · código de 6 dígitos, enviado por SMS ou por e-mail.
class CodigoPage extends StatefulWidget {
  /// Código por SMS. [destino] é o número formatado, ex.: (11) 98888-7777.
  const CodigoPage({
    super.key,
    required this.destino,
    this.entrar = false,
    this.botao = 'Continuar',
    this.onConfirmado,
  }) : porEmail = false;

  /// Código por e-mail. [destino] é o e-mail informado.
  const CodigoPage.email({
    super.key,
    required this.destino,
    this.entrar = false,
    this.botao = 'Continuar',
    this.onConfirmado,
  }) : porEmail = true;

  final String destino;
  final bool porEmail;

  /// Veio da tela Entrar (conta que já existe), não do cadastro.
  final bool entrar;

  /// Texto do botão (ex.: "Confirmar" ao trocar celular ou e-mail).
  final String botao;

  /// Fora do cadastro (trocar celular/e-mail): o que fazer com o código
  /// confirmado, em vez de seguir para o Nome ou a Home.
  final void Function(BuildContext context)? onConfirmado;

  @override
  State<CodigoPage> createState() => _CodigoPageState();
}

class _CodigoPageState extends State<CodigoPage> {
  static const _tamanho = 6;
  static const _espera = 60;

  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _segundos = _espera;

  bool get _completo => _controller.text.length == _tamanho;

  @override
  void initState() {
    super.initState();
    _iniciarContagem();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _iniciarContagem() {
    _timer?.cancel();
    setState(() => _segundos = _espera);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundos <= 1) t.cancel();
      setState(() => _segundos--);
    });
  }

  void _reenviar() {
    // Sem backend ainda: só reinicia a contagem.
    _iniciarContagem();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Código reenviado')));
  }

  void _continuar() {
    if (!_completo) return;
    // Sem backend ainda: qualquer código de 6 dígitos é aceito.
    if (widget.onConfirmado != null) {
      widget.onConfirmado!(context);
      return;
    }
    if (widget.entrar) {
      // Conta que já existe: vai direto para a Home (nome de exemplo).
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeClientePage()),
        (_) => false,
      );
      return;
    }
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const NomePage()));
  }

  String get _tempo =>
      '${_segundos ~/ 60}:${(_segundos % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Digite o código',
      subtitulo: widget.porEmail
          ? 'Enviamos um e-mail para\n${widget.destino}'
          : 'Enviamos um SMS para\n+55 ${widget.destino}',
      botao: widget.botao,
      onBotao: _completo ? _continuar : null,
      children: [
        const SizedBox(height: 18),
        _CaixasCodigo(
          controller: _controller,
          focus: _focus,
          tamanho: _tamanho,
          onChanged: () => setState(() {}),
          onCompleto: _continuar,
        ),
        const SizedBox(height: 22),
        Align(
          alignment: Alignment.centerLeft,
          child: _segundos > 0
              ? Text(
                  'Reenviar código em $_tempo',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: TatuColors.textSecondary,
                  ),
                )
              : _Link('Reenviar código', onTap: _reenviar),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: _Link(
            widget.porEmail ? 'Trocar e-mail' : 'Trocar número',
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        if (widget.porEmail) ...[
          const SizedBox(height: 12),
          const Text(
            'Não chegou? Veja a caixa de spam.',
            style: TextStyle(fontSize: 13, color: TatuColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Seis caixinhas; um campo invisível por trás recebe o teclado.
class _CaixasCodigo extends StatelessWidget {
  const _CaixasCodigo({
    required this.controller,
    required this.focus,
    required this.tamanho,
    required this.onChanged,
    required this.onCompleto,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final int tamanho;
  final VoidCallback onChanged;
  final VoidCallback onCompleto;

  @override
  Widget build(BuildContext context) {
    final texto = controller.text;
    return SizedBox(
      height: 58,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focus,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(tamanho),
                ],
                onChanged: (_) => onChanged(),
                onSubmitted: (_) => onCompleto(),
                decoration: const InputDecoration.collapsed(hintText: ''),
              ),
            ),
          ),
          IgnorePointer(
            child: ListenableBuilder(
              listenable: focus,
              builder: (context, _) => LayoutBuilder(
                builder: (context, c) {
                  const gap = 10.0;
                  final largura = ((c.maxWidth - gap * (tamanho - 1)) / tamanho)
                      .clamp(0.0, 48.0);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < tamanho; i++) ...[
                        if (i > 0) const SizedBox(width: gap),
                        _Caixa(
                          largura: largura,
                          digito: i < texto.length ? texto[i] : '',
                          atual: focus.hasFocus && i == texto.length,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Caixa extends StatelessWidget {
  const _Caixa({
    required this.largura,
    required this.digito,
    required this.atual,
  });

  final double largura;
  final String digito;
  final bool atual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largura,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCodigo),
        border: Border.all(
          color: atual ? TatuColors.textPrimary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Text(
        digito,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link(this.texto, {required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: TatuColors.verified,
          ),
        ),
      ),
    );
  }
}
