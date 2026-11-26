import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/atividade/atividade_page.dart';
import 'package:tatu/features/profissional/atividade/atividade_profissional_page.dart';
import 'package:tatu/shared/widgets/abas_deslizantes.dart';
import 'package:tatu/shared/widgets/segmento.dart';

/// Trocar de aba deslizando o dedo (Atividade do cliente e do
/// profissional), sem perder os botões das abas.

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
  await t.pumpAndSettle();
}

/// Duas listas longas: "A 0…A 39" e "B 0…B 39".
Widget _duasListas() => Scaffold(
  body: AbasDeslizantes(
    opcoes: const ['Em andamento', 'Concluídos'],
    paginas: [
      for (final l in ['A', 'B'])
        ListView(
          children: [
            for (var i = 0; i < 40; i++)
              SizedBox(height: 60, child: Text('$l $i')),
          ],
        ),
    ],
  ),
);

double _posicao(WidgetTester t) =>
    t.widget<Segmento>(find.byType(Segmento)).posicao!;

/// Meio da tela, longe da borda esquerda.
const _meio = Offset(250, 400);

void main() {
  setUp(pedidos.restaurar);

  testWidgets('deslizar para a esquerda vai para Concluídos e volta', (
    t,
  ) async {
    await _abrir(t, _duasListas());
    expect(find.text('A 0'), findsOneWidget);
    await t.dragFrom(_meio, const Offset(-250, 0));
    await t.pumpAndSettle();
    expect(find.text('B 0'), findsOneWidget);
    expect(find.text('A 0'), findsNothing);
    expect(_posicao(t), 1);
    await t.dragFrom(_meio, const Offset(250, 0));
    await t.pumpAndSettle();
    expect(find.text('A 0'), findsOneWidget);
  });

  testWidgets('a marcação branca acompanha o dedo no arraste', (t) async {
    await _abrir(t, _duasListas());
    final g = await t.startGesture(_meio);
    await g.moveBy(const Offset(-40, 0));
    await g.moveBy(const Offset(-80, 0));
    await t.pump();
    final p = _posicao(t);
    expect(p, greaterThan(0));
    expect(p, lessThan(1));
    // Menos da metade, devagar: volta para a aba atual.
    await g.up();
    await t.pumpAndSettle();
    expect(_posicao(t), 0);
    expect(find.text('A 0'), findsOneWidget);
  });

  testWidgets('arraste curto e rápido também troca', (t) async {
    await _abrir(t, _duasListas());
    await t.flingFrom(_meio, const Offset(-90, 0), 1500);
    await t.pumpAndSettle();
    expect(_posicao(t), 1);
  });

  testWidgets('movimento diagonal rola a lista e não troca de aba', (t) async {
    await _abrir(t, _duasListas());
    await t.dragFrom(_meio, const Offset(-60, -300));
    await t.pumpAndSettle();
    expect(_posicao(t), 0);
    // A lista rolou.
    expect(find.text('A 0'), findsNothing);
  });

  testWidgets('não começa na borda esquerda (gesto de voltar)', (t) async {
    await _abrir(t, _duasListas());
    await t.dragFrom(const Offset(8, 400), const Offset(300, 0));
    await t.pumpAndSettle();
    expect(_posicao(t), 0);
    await t.tap(find.text('Concluídos'));
    await t.pumpAndSettle();
    await t.dragFrom(const Offset(8, 400), const Offset(300, 0));
    await t.pumpAndSettle();
    expect(_posicao(t), 1);
  });

  testWidgets('cada aba guarda a própria rolagem', (t) async {
    await _abrir(t, _duasListas());
    await t.drag(find.text('A 3'), const Offset(0, -600));
    await t.pumpAndSettle();
    expect(find.text('A 0'), findsNothing);
    await t.tap(find.text('Concluídos'));
    await t.pump();
    // Tocar na aba troca na hora, como antes.
    expect(find.text('B 0'), findsOneWidget);
    await t.tap(find.text('Em andamento'));
    await t.pump();
    expect(find.text('A 0'), findsNothing);
    expect(find.text('A 12'), findsOneWidget);
  });

  testWidgets('Atividade do cliente: desliza para Concluídos', (t) async {
    await _abrir(t, const AtividadePage());
    expect(find.text('Pedir de novo'), findsNothing);
    await t.dragFrom(_meio, const Offset(-250, 0));
    await t.pumpAndSettle();
    expect(find.text('Pedir de novo'), findsWidgets);
  });

  testWidgets('Atividade do profissional: desliza para Concluídos', (t) async {
    await _abrir(t, const AtividadeProfissionalPage());
    expect(find.text('Nenhum serviço agora'), findsOneWidget);
    await t.dragFrom(_meio, const Offset(-250, 0));
    await t.pumpAndSettle();
    expect(find.text('Nenhum serviço agora'), findsNothing);
    expect(_posicao(t), 1);
  });
}
