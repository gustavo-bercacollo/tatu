import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/fotos_trabalho.dart';
import 'package:tatu/data/perfil.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/perfil/perfil_profissional_page.dart';

Future<void> _abrir(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  profissional.demo();
  fotosTrabalho.restaurar();
  final bytes = File('assets/avatares/avatar-2.png').readAsBytesSync();
  perfil.escolherImagem = (_) async => bytes;
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilProfissionalPage()),
  );
  await t.tap(find.text('Fotos de trabalhos'));
  await t.pumpAndSettle();
}

void main() {
  tearDown(perfil.restaurar);

  testWidgets('Fotos: adicionar com legenda, em análise e aprovada', (t) async {
    await _abrir(t);
    expect(find.text('3 DE 12 FOTOS'), findsOneWidget);
    await t.tap(find.text('Adicionar'));
    await t.pumpAndSettle();
    await t.tap(find.text('Escolher da galeria'));
    await t.pumpAndSettle();
    expect(find.text('Nova foto'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'Torneira');
    await t.tap(find.text('Salvar foto'));
    await t.pumpAndSettle();
    expect(find.text('Foto adicionada'), findsOneWidget);
    expect(find.text('4 DE 12 FOTOS'), findsOneWidget);
    expect(find.text('Em análise'), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
    expect(find.text('Em análise'), findsNothing);
  });

  testWidgets('Fotos: remover e estado vazio', (t) async {
    await _abrir(t);
    for (var i = 0; i < 3; i++) {
      await t.tap(find.bySemanticsLabel('Remover foto').first);
      await t.pumpAndSettle();
      expect(find.text('Remover esta foto?'), findsOneWidget);
      await t.tap(find.text('Remover'));
      await t.pumpAndSettle();
    }
    expect(find.text('Mostre seu trabalho'), findsOneWidget);
    expect(find.text('Adicionar fotos'), findsOneWidget);
  });

  testWidgets('Fotos: recusada → enviar outra', (t) async {
    await _abrir(t);
    final f = fotosTrabalho.fotos.first;
    fotosTrabalho.recusar(f, 'Aparece o rosto de uma pessoa.');
    await t.pump();
    expect(find.text('Recusada'), findsOneWidget);
    await t.tap(find.text('Troca de chuveiro'));
    await t.pumpAndSettle();
    expect(find.text('Foto recusada'), findsOneWidget);
    await t.tap(find.text('Enviar outra foto'));
    await t.pumpAndSettle();
    await t.tap(find.text('Tirar foto'));
    await t.pumpAndSettle();
    await t.tap(find.text('Salvar foto'));
    await t.pumpAndSettle();
    expect(find.text('Recusada'), findsNothing);
    expect(fotosTrabalho.fotos.length, 3);
    await t.pump(const Duration(seconds: 5));
  });

  test('Reordenar move a foto', () {
    fotosTrabalho.restaurar();
    fotosTrabalho.mover(0, 2);
    expect(fotosTrabalho.fotos.last.legenda, 'Troca de chuveiro');
  });
}
