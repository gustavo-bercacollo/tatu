import 'package:flutter/material.dart';

import 'tatu_colors.dart';

/// Estilos de texto padrão do Tatu (medidos nos desenhos). Usar estes em vez
/// de tamanhos soltos nas telas.
class TatuTexto {
  TatuTexto._();

  /// Título de folha e de estado vazio.
  static const tituloFolha = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  /// Texto explicativo de folhas e estados vazios (centralizado).
  static const corpo = TextStyle(
    fontSize: 15,
    height: 1.4,
    color: TatuColors.textSecondary,
  );

  /// Linha cinza de detalhe (ex.: "Vence 08/28", "Oi, Ana", "4,8 · 23 pedidos").
  static const detalhe = TextStyle(
    fontSize: 15,
    color: TatuColors.textSecondary,
  );

  /// Avisos e dicas pequenas (cadeado, "Toque para editar"…).
  static const nota = TextStyle(
    fontSize: 13,
    height: 1.35,
    color: TatuColors.textSecondary,
  );

  /// Título de seção em maiúsculas (ex.: SALVOS, CONTA).
  static const secao = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: TatuColors.textSecondary,
  );
}
