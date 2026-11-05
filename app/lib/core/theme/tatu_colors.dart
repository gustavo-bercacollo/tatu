import 'package:flutter/material.dart';

/// Cores do Tatu (docs/guia-de-design.md, seção 2.1).
class TatuColors {
  TatuColors._();

  static const bg = Color(0xFFFFFFFF);
  static const surfaceGrouped = Color(0xFFF2F2F7);
  static const fill = Color(0x1A787880); // 10%: cartões de opção
  static const fillStrong = Color(0x29787880); // 16%
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF8E8E93);
  static const chevron = Color(0xFFC7C7CC);
  static const textDisabled = Color(0xFFB0B0B5);
  static const circle = Color(0xFFE4E4E7); // avatar e botões redondos
  static const tabBar = Color(0xFFF9F9F9);
  static const tabBarLine = Color(0xFFD9D9DC);
  static const action = Color(0xFF1C1C1E);
  static const onAction = Color(0xFFFFFFFF);
  static const online = Color(0xFF34C759);
  static const verified = Color(0xFF007AFF);
  static const warning = Color(0xFFFF9F0A); // também as estrelas
  static const warningSoft = Color(0xFFFFF1DB); // fundo do ícone de atenção
  static const warningTexto = Color(0xFFA85F00); // ícone/texto de atenção
  static const trilho = Color(0xFFE5E5EA); // fundo de seletor e de barras
  static const danger = Color(0xFFFF3B30);

  /// Fundo de erro e do botão de remover.
  static const dangerSoft = Color(0xFFFFE5E5);
  static const hairline = Color(0x4A3C3C43);
  static const scrim = Color(0x61000000);

  /// Editor de foto (tela escura).
  static const editorFundo = Color(0xFF2C2C2E);
  static const editorSombra = Color(0xBF2C2C2E); // fora do círculo
  static const sombra = Color(0x2E000000); // sombra de avisos flutuantes
  static const editorTrilho = Color(0xFF48484A);
}
