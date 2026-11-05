import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_texto.dart';

/// Estado vazio: ícone num círculo, título, texto e botão principal embaixo.
/// Usar como `corpo` de [TelaInterna]; o botão vai no `rodape`.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
  });

  final IconData icone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: TatuColors.fill,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 38, color: TatuColors.textSecondary),
          ),
        ),
        const SizedBox(height: 26),
        Text(titulo, textAlign: TextAlign.center, style: TatuTexto.tituloFolha),
        const SizedBox(height: 10),
        Text(texto, textAlign: TextAlign.center, style: TatuTexto.corpo),
        const Spacer(flex: 2),
      ],
    );
  }
}
