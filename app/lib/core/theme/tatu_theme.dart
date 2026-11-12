import 'package:flutter/material.dart';

import 'tatu_colors.dart';
import 'tatu_medidas.dart';

/// Botão secundário: cinza claro com texto preto (ex.: "Usar e-mail").
ButtonStyle tatuBotaoSecundario() => FilledButton.styleFrom(
  backgroundColor: TatuColors.fill,
  foregroundColor: TatuColors.textPrimary,
);

/// Botão de ação destrutiva: vermelho claro com texto vermelho.
ButtonStyle tatuBotaoPerigo() => FilledButton.styleFrom(
  backgroundColor: TatuColors.dangerSoft,
  foregroundColor: TatuColors.danger,
);

/// Botão vermelho cheio (emergência: ligar 190, sair agora).
ButtonStyle tatuBotaoVermelho() => FilledButton.styleFrom(
  backgroundColor: TatuColors.danger,
  foregroundColor: TatuColors.onAction,
);

ThemeData tatuTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: TatuColors.bg,
  colorScheme: const ColorScheme.light(
    primary: TatuColors.action,
    onPrimary: TatuColors.onAction,
    surface: TatuColors.bg,
    onSurface: TatuColors.textPrimary,
    error: TatuColors.danger,
  ),
  splashFactory: NoSplash.splashFactory,
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: TatuColors.action,
      foregroundColor: TatuColors.onAction,
      disabledBackgroundColor: TatuColors.fill,
      disabledForegroundColor: TatuColors.textDisabled,
    ),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    color: TatuColors.hairline,
  ),
);

/// Botão com contorno cinza (ex.: "Adicionar outra profissão").
ButtonStyle tatuBotaoContorno() => OutlinedButton.styleFrom(
  foregroundColor: TatuColors.textPrimary,
  minimumSize: const Size.fromHeight(TatuMedidas.alturaBotao),
  side: const BorderSide(color: TatuColors.chevron),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
  ),
  textStyle: const TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
);
