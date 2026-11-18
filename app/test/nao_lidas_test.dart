import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/icone_app/icone_app.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/nao_lidas.dart';
import 'package:tatu/data/notificacoes.dart';
import 'package:tatu/features/cliente/abas.dart';
import 'package:tatu/features/cliente/mensagens/mensagens_page.dart';
import 'package:tatu/features/profissional/abas.dart';
import 'package:tatu/shared/widgets/abas_cliente.dart';

/// Contador de mensagens não lidas (RN-155).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
  await t.pump();
}

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in ['400', '500', '600', '700']) {
    f.addFont(rootBundle.load('assets/fonts/Inter-$p.ttf'));
  }
  await f.load();
}

/// Tela com só a barra de abas do cliente.
const _barraCliente = Scaffold(
  bottomNavigationBar: AbasDoCliente(ativa: AbaCliente.inicio),
);

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    conversas.restaurar();
    conversasProfissional.restaurar();
    canalTatu.restaurar();
    notificacoes.restaurar();
    IconeDoApp.valor = 0;
  });

  test('regras: rótulo e leitura', () {
    expect(NaoLidas.rotulo(0), isNull);
    expect(NaoLidas.rotulo(3), '3');
    expect(NaoLidas.rotulo(9), '9');
    expect(NaoLidas.rotulo(12), '9+');
    expect(NaoLidas.leitura(3), 'Mensagens, 3 não lidas');
    expect(NaoLidas.leitura(1), 'Mensagens, 1 não lida');
    expect(NaoLidas.leitura(0), 'Mensagens');
  });

  test('soma todas as conversas e o Tatu', () {
    // Demo: Luiza 2 + Tatu 1.
    expect(NaoLidas.total(LadoMensagens.cliente), 3);
    // Demo do profissional: Ana 1 + Carlos 2 + Tatu 1.
    expect(NaoLidas.total(LadoMensagens.profissional), 4);
  });

  testWidgets('conta nova começa com 1 (boas-vindas do Tatu)', (t) async {
    conversas.limpar();
    canalTatu.cliente.comecar(boasVindasCliente('Bia'));
    await _abrir(t, _barraCliente);
    expect(NaoLidas.total(LadoMensagens.cliente), 1);
    expect(find.text('1'), findsOneWidget);
    expect(find.bySemanticsLabel('Mensagens, 1 não lida'), findsOneWidget);
    expect(IconeDoApp.valor, 1);
  });

  testWidgets('12 não lidas mostra "9+" e lê o número todo', (t) async {
    conversas.conversas.first.naoLidas = 11;
    await _abrir(t, _barraCliente);
    expect(find.text('9+'), findsOneWidget);
    expect(find.bySemanticsLabel('Mensagens, 12 não lidas'), findsOneWidget);
    expect(IconeDoApp.valor, 12);
  });

  testWidgets('abrir uma conversa diminui o contador na hora', (t) async {
    await _abrir(t, const MensagensPage());
    expect(find.bySemanticsLabel('Mensagens, 3 não lidas'), findsOneWidget);
    await t.tap(find.text('Luiza Souza'));
    await t.pumpAndSettle();
    expect(NaoLidas.total(LadoMensagens.cliente), 1);
    // Volta para Mensagens: só o Tatu.
    await t.tap(find.bySemanticsLabel('Voltar'));
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('Mensagens, 1 não lida'), findsOneWidget);
    // Abriu o canal do Tatu: some.
    await t.tap(find.text('Tatu').first);
    await t.pumpAndSettle();
    expect(NaoLidas.total(LadoMensagens.cliente), 0);
  });

  testWidgets('sem não lidas não mostra nada', (t) async {
    for (final c in conversas.conversas) {
      c.naoLidas = 0;
    }
    canalTatu.cliente.naoLidas = 0;
    await _abrir(t, _barraCliente);
    expect(find.byType(ContadorVermelho), findsNothing);
    expect(find.bySemanticsLabel('Mensagens'), findsOneWidget);
    expect(IconeDoApp.valor, 0);
  });

  testWidgets('ícone do app só com notificações permitidas', (t) async {
    notificacoes.negarNoCelular();
    await _abrir(t, _barraCliente);
    expect(find.byType(ContadorVermelho), findsOneWidget);
    expect(IconeDoApp.valor, 0);
  });

  testWidgets('profissional também tem o contador', (t) async {
    await _abrir(
      t,
      const Scaffold(
        bottomNavigationBar: AbasDoProfissional(ativa: AbaCliente.inicio),
      ),
    );
    expect(find.text('4'), findsOneWidget);
    expect(find.bySemanticsLabel('Mensagens, 4 não lidas'), findsOneWidget);
  });
}
