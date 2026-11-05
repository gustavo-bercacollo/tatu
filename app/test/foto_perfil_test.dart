import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/perfil.dart';
import 'package:tatu/features/cliente/perfil_page.dart';

Future<void> _abrirFolha(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: tatuTheme(),
      home: const PerfilClientePage(nome: 'Ana Martins'),
    ),
  );
  await t.tap(find.bySemanticsLabel(RegExp('^Foto do perfil')));
  await t.pumpAndSettle();
}

/// Espera o aviso do topo sumir (não deixa timer pendente).
Future<void> _fecharAviso(WidgetTester t) async {
  await t.pump(const Duration(seconds: 4));
  await t.pumpAndSettle();
}

void main() {
  setUp(perfil.restaurar);

  testWidgets('Escolher um avatar troca a foto e avisa', (t) async {
    await _abrirFolha(t);
    expect(find.text('Remover foto'), findsOneWidget);
    await t.tap(find.text('Escolher um avatar'));
    await t.pumpAndSettle();
    expect(find.text('Escolha um avatar'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Avatar 3'));
    await t.pump();
    await t.tap(find.text('Salvar avatar'));
    await t.pumpAndSettle();
    expect(perfil.avatar, avataresProntos[2]);
    expect(find.text('Foto atualizada'), findsOneWidget);
    await _fecharAviso(t);
    expect(find.text('Foto atualizada'), findsNothing);
  });

  testWidgets('Remover foto volta para as iniciais', (t) async {
    await _abrirFolha(t);
    await t.tap(find.text('Remover foto'));
    await t.pumpAndSettle();
    expect(perfil.temImagem, isFalse);
    expect(find.text('AM'), findsOneWidget);

    await t.tap(find.bySemanticsLabel(RegExp('^Foto do perfil')));
    await t.pumpAndSettle();
    expect(find.text('Remover foto'), findsNothing);
  });

  testWidgets('Câmera negada leva para escolher avatar', (t) async {
    perfil.cameraPermitida = false;
    await _abrirFolha(t);
    await t.tap(find.text('Tirar foto'));
    await t.pumpAndSettle();
    expect(find.text('Câmera desativada'), findsOneWidget);

    await t.tap(find.text('Escolher um avatar'));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('Avatar 2'));
    await t.tap(find.text('Salvar avatar'));
    await t.pumpAndSettle();
    expect(find.byType(PerfilClientePage), findsOneWidget);
    expect(find.text('Câmera desativada'), findsNothing);
    expect(perfil.avatar, avataresProntos[1]);
    expect(find.text('Foto atualizada'), findsOneWidget);
    await _fecharAviso(t);
  });

  testWidgets('Galeria → Ajustar foto → Usar foto', (t) async {
    final bytes = File('assets/avatares/avatar-2.png').readAsBytesSync();
    perfil.escolherImagem = (_) async => bytes;
    await _abrirFolha(t);
    await t.tap(find.text('Escolher da galeria'));
    await t.pumpAndSettle();
    expect(find.text('Ajustar foto'), findsOneWidget);

    // Decodifica a imagem (fora do relógio falso dos testes).
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await t.pump();
    await t.tap(find.text('Usar foto'));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await t.pumpAndSettle();

    expect(perfil.foto, isNotNull);
    expect(perfil.avatar, isNull);
    expect(find.text('Sua nova foto já aparece no app.'), findsOneWidget);
    await _fecharAviso(t);
  });
}
