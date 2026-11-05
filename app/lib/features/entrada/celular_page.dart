import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tatu_colors.dart';
import '../../shared/widgets/cadastro_scaffold.dart';
import '../../shared/widgets/tatu_field.dart';
import 'codigo_page.dart';
import 'email_page.dart';

/// Celular para receber o código por SMS: no cadastro ou para entrar.
class CelularPage extends StatefulWidget {
  /// Cadastro: "Qual é o seu celular?".
  const CelularPage({super.key}) : entrar = false;

  /// Entrar numa conta que já existe.
  const CelularPage.entrar({super.key}) : entrar = true;

  final bool entrar;

  @override
  State<CelularPage> createState() => _CelularPageState();
}

class _CelularPageState extends State<CelularPage> {
  final _controller = TextEditingController();
  final _criarConta = TapGestureRecognizer();

  // Celular com DDD: 11 dígitos.
  bool get _valido =>
      _controller.text.replaceAll(RegExp(r'\D'), '').length == 11;

  @override
  void initState() {
    super.initState();
    _criarConta.onTap = () => Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const CelularPage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _criarConta.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_valido) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CodigoPage(destino: _controller.text, entrar: widget.entrar),
      ),
    );
  }

  // Volta do e-mail com "Usar celular" é um pop; daqui para o e-mail é push.
  void _usarEmail() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => EmailPage(entrar: widget.entrar)));

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: widget.entrar ? 'Entrar' : 'Qual é o seu celular?',
      subtitulo: widget.entrar
          ? 'Digite o celular do seu cadastro.\nEnviamos um código por SMS.'
          : 'Vamos enviar um código por SMS.\nSem senha para decorar.',
      botao: 'Continuar',
      onBotao: _valido ? _continuar : null,
      botaoSecundario: 'Usar e-mail',
      onSecundario: _usarEmail,
      children: [
        Row(
          children: [
            Container(
              width: 86,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TatuColors.fill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'BR +55',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TatuField(
                label: 'Celular',
                hintText: '(11) 98888-7777',
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  _CelularFormatter(),
                ],
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _continuar(),
              ),
            ),
          ],
        ),
        if (widget.entrar) ...[
          const SizedBox(height: 26),
          Text.rich(
            TextSpan(
              text: 'Não tem conta? ',
              children: [
                TextSpan(
                  text: 'Criar conta',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TatuColors.verified,
                  ),
                  recognizer: _criarConta,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: TatuColors.textSecondary,
            ),
          ),
        ] else ...[
          const SizedBox(height: 14),
          const CadastroNota(
            'Usamos o número só para entrar e avisar sobre seus pedidos.',
          ),
        ],
      ],
    );
  }
}

/// Formata os dígitos como (11) 98888-7777 enquanto a pessoa digita.
class _CelularFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = newValue.text;
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 0) b.write('(');
      if (i == 2) b.write(') ');
      if (i == 7) b.write('-');
      b.write(d[i]);
    }
    final texto = b.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
