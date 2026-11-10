import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conta.dart';
import '../../../shared/widgets/campo_celular.dart';
import '../../../shared/widgets/folha.dart';
import '../../entrada/codigo_page.dart';

/// Folha "Confirme seu celular" (quem se cadastrou pelo e-mail): manda o
/// código por SMS e guarda o número. Devolve `true` se confirmou.
Future<bool?> confirmarCelular(BuildContext context) =>
    mostrarFolha<bool>(context, builder: (_) => const _FolhaCelular());

class _FolhaCelular extends StatefulWidget {
  const _FolhaCelular();

  @override
  State<_FolhaCelular> createState() => _FolhaCelularState();
}

class _FolhaCelularState extends State<_FolhaCelular> {
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
    final ok = await nav.push<bool>(
      MaterialPageRoute(
        builder: (_) => CodigoPage(
          destino: _controller.text,
          botao: 'Confirmar',
          onConfirmado: (ctx) => Navigator.of(ctx).pop(true),
        ),
      ),
    );
    if (ok != true) return;
    conta.definirCelular(_controller.text);
    nav.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margemCadastro,
            10,
            TatuMedidas.margemCadastro,
            TatuMedidas.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AlcaFolha(),
              const SizedBox(height: TatuMedidas.entreSecoes),
              const Text(
                'Confirme seu celular',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'O profissional pode precisar falar com você.\nSó pedimos uma vez.',
                style: TatuTexto.corpo,
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              CampoCelular(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _enviar(),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              FilledButton(
                onPressed: _valido ? _enviar : null,
                child: const Text('Enviar código'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
