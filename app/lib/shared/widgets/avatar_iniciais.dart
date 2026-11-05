import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';

/// Iniciais de um nome (até duas), ex.: "Ana Martins" → "AM".
String iniciaisDe(String nome) => nome
    .trim()
    .split(RegExp(r'\s+'))
    .take(2)
    .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
    .join();

/// Avatar redondo cinza com as iniciais (o app não usa fotos).
class AvatarIniciais extends StatelessWidget {
  const AvatarIniciais({super.key, required this.nome, this.tamanho = 36});

  final String nome;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: TatuColors.circle,
        shape: BoxShape.circle,
      ),
      child: Text(
        iniciaisDe(nome),
        style: TextStyle(fontSize: tamanho * 0.34, fontWeight: FontWeight.w600),
      ),
    );
  }
}
