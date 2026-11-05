import 'package:flutter/material.dart';

import '../../shared/widgets/cadastro_scaffold.dart';
import '../../shared/widgets/tatu_field.dart';
import 'codigo_page.dart';

/// E-mail no lugar do celular (cadastro ou entrar); o código vai por e-mail.
class EmailPage extends StatefulWidget {
  const EmailPage({super.key, this.entrar = false});

  /// Veio da tela Entrar (conta que já existe), não do cadastro.
  final bool entrar;

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final _controller = TextEditingController();

  bool get _valido =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_valido) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CodigoPage.email(
          destino: _controller.text.trim(),
          entrar: widget.entrar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Qual é o seu e-mail?',
      subtitulo: 'Vamos enviar um código para ele.\nSem senha para decorar.',
      botao: 'Continuar',
      onBotao: _valido ? _continuar : null,
      botaoSecundario: 'Usar celular',
      onSecundario: () => Navigator.of(context).maybePop(),
      children: [
        TatuField(
          label: 'E-mail',
          hintText: 'ana@email.com',
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _continuar(),
        ),
        const SizedBox(height: 14),
        const CadastroNota(
          'Depois pedimos seu celular, para o profissional falar com você.',
        ),
      ],
    );
  }
}
