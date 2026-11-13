import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/seguranca.dart';
import 'package:tatu/features/cliente/preferencias_cliente_page.dart';
import 'package:tatu/features/profissional/cadastro/verificacao_page.dart';

void main() {
  CameraVerificacaoPage.cameraAoVivo = false;
  setUp(() {
    seguranca.restaurar();
    profissional.restaurar();
  });

  testWidgets('Cliente verifica a identidade para preferir mulheres', (
    t,
  ) async {
    t.view.physicalSize = const Size(1179, 2556); // 393×852
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final bytes = File('assets/avatares/avatar-2.png').readAsBytesSync();
    profissional.tirarFoto = ({required bool frontal}) async => bytes;
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const PreferenciasClientePage()),
    );
    seguranca.definirIdentidade(Identidade.mulher);
    await t.pump();
    await t.tap(find.byType(CupertinoSwitch));
    await t.pumpAndSettle();
    expect(find.text('Verifique sua identidade'), findsOneWidget);
    expect(seguranca.preferirMulheres, isFalse);

    await t.tap(find.text('Começar'));
    await t.pumpAndSettle();
    expect(find.text('Frente do documento'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Tirar foto'));
    await t.pumpAndSettle();
    await t.tap(find.text('Usar esta foto'));
    await t.pumpAndSettle();
    expect(find.text('Agora uma selfie'), findsOneWidget);
    expect(find.text('Olhe para a câmera e pisque'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Tirar foto'));
    await t.pumpAndSettle();
    await t.tap(find.text('Usar esta foto'));
    await t.pumpAndSettle();

    expect(find.text('Identidade verificada'), findsOneWidget);
    expect(seguranca.preferirMulheres, isTrue);
    await t.tap(find.text('Concluir'));
    await t.pumpAndSettle();
    expect(find.text('Preferências de atendimento'), findsOneWidget);
    // Da próxima vez liga direto, sem pedir de novo.
    await t.tap(find.byType(CupertinoSwitch));
    await t.pump();
    expect(seguranca.preferirMulheres, isFalse);
    await t.tap(find.byType(CupertinoSwitch));
    await t.pumpAndSettle();
    expect(seguranca.preferirMulheres, isTrue);
    expect(find.text('Verifique sua identidade'), findsNothing);
  });
}
