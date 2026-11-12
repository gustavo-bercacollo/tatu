import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/perfil/perfil_profissional_page.dart';

void main() {
  testWidgets('Ajuda do profissional: artigo, atalho e suporte', (t) async {
    t.view.physicalSize = const Size(430, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    profissional.demo();
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const PerfilProfissionalPage()),
    );
    await t.scrollUntilVisible(find.text('Ajuda'), 200);
    await t.ensureVisible(find.text('Ajuda'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ajuda'));
    await t.pumpAndSettle();
    expect(find.text('Chamados e clientes'), findsOneWidget);
    expect(find.text('Ganhos e Pix'), findsOneWidget);

    // Pergunta frequente com texto.
    await t.tap(find.text('Quando recebo meu dinheiro?'));
    await t.pumpAndSettle();
    expect(find.text('Pago pelo app'), findsOneWidget);
    await t.tap(find.text('Falar com o suporte'));
    await t.pumpAndSettle();
    expect(find.text('Um chamado recente'), findsOneWidget);
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(find.text('Qual chamado?'), findsOneWidget);
    expect(find.text('Júlia Costa · R\$ 90'), findsOneWidget);
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(find.text('Oi, Luiza! Sou o Rafael, do suporte.'), findsOneWidget);
    expect(find.text('Chamado · Ana Martins'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'O Pix não caiu.');
    await t.pump();
    await t.tap(find.bySemanticsLabel('Enviar mensagem'));
    await t.pump();
    await t.pump(const Duration(seconds: 3));
    expect(find.text('Vou verificar o repasse, um instante.'), findsOneWidget);
  });

  testWidgets('Ver meus ganhos abre a tela de Ganhos', (t) async {
    t.view.physicalSize = const Size(430, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    profissional.demo();
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const PerfilProfissionalPage()),
    );
    await t.scrollUntilVisible(find.text('Ajuda'), 200);
    await t.ensureVisible(find.text('Ajuda'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ajuda'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ganhos e Pix'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ver meus ganhos'));
    await t.pumpAndSettle();
    expect(find.text('Total da semana'), findsOneWidget);
  });
}
