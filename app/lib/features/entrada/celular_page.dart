import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tatu_colors.dart';
import '../../shared/widgets/back_circle_button.dart';
import '../../shared/widgets/tatu_field.dart';

/// Cadastro · celular: pede o número para enviar o código por SMS.
class CelularPage extends StatefulWidget {
  const CelularPage({super.key});

  @override
  State<CelularPage> createState() => _CelularPageState();
}

class _CelularPageState extends State<CelularPage> {
  final _controller = TextEditingController();

  // Celular com DDD: 11 dígitos.
  bool get _valido =>
      _controller.text.replaceAll(RegExp(r'\D'), '').length == 11;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_valido) return;
    // A tela do código SMS ainda não existe.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Código por SMS: em breve')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackCircleButton(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 50),
                          const Text(
                            'Qual é o seu celular?',
                            style: TextStyle(
                              fontSize: 30,
                              height: 36 / 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Vamos enviar um código por SMS.\nSem senha para decorar.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 22 / 16,
                              color: TatuColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                          const SizedBox(height: 14),
                          const Text(
                            'Usamos o número só para entrar e avisar sobre seus pedidos.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              color: TatuColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _valido ? _continuar : null,
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
