import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/avaliacoes.dart';
import 'package:tatu/features/cliente/perfil_page.dart';

Future<void> _abrirAvaliacoes(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilClientePage()),
  );
  await t.tap(find.text('Minhas avaliações'));
  await t.pumpAndSettle();
}

void main() {
  setUp(avaliacoes.restaurar);

  testWidgets('Recebidas: média, total, recentes com nome abreviado', (
    t,
  ) async {
    await _abrirAvaliacoes(t);
    expect(find.text('4,8'), findsOneWidget);
    expect(find.text('23 avaliações'), findsOneWidget);
    expect(find.text('O que dizem de você'), findsOneWidget);
    expect(find.text('Marcos D.'), findsOneWidget);
  });

  testWidgets('Enviadas: nomes completos', (t) async {
    await _abrirAvaliacoes(t);
    await t.tap(find.text('Enviadas'));
    await t.pump();
    expect(find.text('AVALIAÇÕES QUE VOCÊ DEU'), findsOneWidget);
    expect(find.text('Rafael Lima'), findsOneWidget);
    expect(find.text('Bom serviço, atrasou um pouco.'), findsOneWidget);
  });

  testWidgets('Detalhe: comentário completo, serviço e contestar', (t) async {
    await _abrirAvaliacoes(t);
    await t.tap(find.text('Marcos D.'));
    await t.pumpAndSettle();
    expect(find.text('Avaliação'), findsOneWidget);
    expect(find.text('Eletricista · 02 nov, 14:32'), findsOneWidget);
    expect(find.text('Serviço: vazamento na pia'), findsOneWidget);
    expect(find.text('Contestar avaliação'), findsOneWidget);
  });

  testWidgets('Sem avaliações: estado vazio e "Pedir um serviço"', (t) async {
    avaliacoes.limpar();
    await _abrirAvaliacoes(t);
    expect(find.text('Nenhuma avaliação ainda'), findsOneWidget);
    await t.tap(find.text('Pedir um serviço'));
    await t.pumpAndSettle();
    expect(find.text('Minhas avaliações'), findsOneWidget); // voltou ao Perfil
  });
}
