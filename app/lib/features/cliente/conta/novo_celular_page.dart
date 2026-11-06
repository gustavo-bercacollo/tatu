import 'package:flutter/material.dart';

import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/campo_celular.dart';
import '../../entrada/codigo_page.dart';

/// Novo celular: digita o número, confirma o código por SMS e devolve os
/// dígitos do número novo (ou null se desistir).
class NovoCelularPage extends StatefulWidget {
  const NovoCelularPage({super.key});

  @override
  State<NovoCelularPage> createState() => _NovoCelularPageState();
}

class _NovoCelularPageState extends State<NovoCelularPage> {
  final _controller = TextEditingController();

  bool get _valido => CampoCelular.completo(_controller.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_valido) return;
    final nav = Navigator.of(context);
    final confirmado = await nav.push<bool>(
      MaterialPageRoute(
        builder: (_) => CodigoPage(
          destino: _controller.text,
          botao: 'Confirmar',
          onConfirmado: (ctx) => Navigator.of(ctx).pop(true),
        ),
      ),
    );
    if (confirmado == true) nav.pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Novo celular',
      subtitulo: 'Enviamos um código por SMS\npara confirmar o número.',
      botao: 'Enviar código',
      onBotao: _valido ? _enviar : null,
      children: [
        CampoCelular(
          controller: _controller,
          label: 'Novo celular',
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _enviar(),
        ),
        const SizedBox(height: 14),
        const CadastroNota(
          'Seu número atual continua valendo até você confirmar.',
        ),
      ],
    );
  }
}
