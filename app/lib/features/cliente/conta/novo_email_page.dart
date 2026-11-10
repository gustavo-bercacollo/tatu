import 'package:flutter/material.dart';

import '../../../data/conta.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../entrada/codigo_page.dart';

/// Seu e-mail: troca o e-mail, confirma o código e devolve o e-mail novo
/// (ou null se desistir).
class NovoEmailPage extends StatefulWidget {
  const NovoEmailPage({super.key});

  @override
  State<NovoEmailPage> createState() => _NovoEmailPageState();
}

class _NovoEmailPageState extends State<NovoEmailPage> {
  late final _controller = TextEditingController(text: conta.email ?? '');

  bool get _valido => emailValido(_controller.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_valido) return;
    final nav = Navigator.of(context);
    final email = _controller.text.trim();
    final confirmado = await nav.push<bool>(
      MaterialPageRoute(
        builder: (_) => CodigoPage.email(
          destino: email,
          botao: 'Confirmar',
          onConfirmado: (ctx) => Navigator.of(ctx).pop(true),
        ),
      ),
    );
    if (confirmado == true) nav.pop(email);
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Seu e-mail',
      subtitulo: 'Usamos para recuperar sua conta\ne enviar seus recibos.',
      botao: 'Enviar código',
      onBotao: _valido ? _enviar : null,
      children: [
        TatuField(
          label: 'E-mail',
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _enviar(),
        ),
        const SizedBox(height: 6),
        const CadastroNota('Vamos enviar um código para confirmar.'),
      ],
    );
  }
}
