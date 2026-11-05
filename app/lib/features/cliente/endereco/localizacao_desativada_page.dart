import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../shared/widgets/back_circle_button.dart';
import 'buscar_endereco_page.dart';

/// Localização desativada: sem permissão, oferece Ajustes ou digitar.
class LocalizacaoDesativadaPage extends StatelessWidget {
  const LocalizacaoDesativadaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackCircleButton(),
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: const BoxDecoration(
                        color: TatuColors.fill,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        TablerIcons.map_pin_off,
                        size: 44,
                        color: TatuColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Localização desativada',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sem ela não achamos você no mapa.\nAtive nos Ajustes ou digite o endereço.',
                    textAlign: TextAlign.center,
                    style: TatuTexto.corpo,
                  ),
                  const Spacer(flex: 2),
                  FilledButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Abrir Ajustes: em breve'),
                        ),
                      ),
                    child: const Text('Abrir Ajustes'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    style: tatuBotaoSecundario(),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const BuscarEnderecoPage(),
                      ),
                    ),
                    child: const Text('Digitar endereço'),
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
