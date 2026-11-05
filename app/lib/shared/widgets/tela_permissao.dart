import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../core/theme/tatu_theme.dart';
import 'back_circle_button.dart';

/// Tela de permissão negada (localização, câmera…): ícone num círculo,
/// título, explicação, "Abrir Ajustes" e uma alternativa.
class TelaPermissao extends StatelessWidget {
  const TelaPermissao({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    required this.alternativa,
    required this.onAlternativa,
  });

  final Widget icone;
  final String titulo;
  final String texto;
  final String alternativa;
  final VoidCallback onAlternativa;

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
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: TatuColors.fill,
                        shape: BoxShape.circle,
                      ),
                      child: icone,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    texto,
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
                    onPressed: onAlternativa,
                    child: Text(alternativa),
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

/// Ícone cinza da tela de permissão (44 px), com risco vermelho opcional.
class IconePermissao extends StatelessWidget {
  const IconePermissao(this.icone, {super.key, this.riscado = false});

  final IconData icone;
  final bool riscado;

  @override
  Widget build(BuildContext context) {
    final i = Icon(icone, size: 44, color: TatuColors.textSecondary);
    if (!riscado) return i;
    return SizedBox(
      width: 66,
      height: 76,
      child: CustomPaint(
        foregroundPainter: _Risco(),
        child: Center(child: i),
      ),
    );
  }
}

class _Risco extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      Paint()
        ..color = TatuColors.danger
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_Risco oldDelegate) => false;
}
