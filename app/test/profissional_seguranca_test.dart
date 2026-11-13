import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/cliente/atividade/pedido_andamento_page.dart';
import 'package:tatu/data/seguranca.dart';
import 'package:tatu/features/profissional/perfil/preferencias_atendimento_page.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';
import 'package:tatu/features/profissional/servico/rota.dart';
import 'package:tatu/features/entrada/seguranca.dart';

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

final _inicio = DateTime(2026, 11, 12, 14, 32);

void main() {
  final ligacoes = <Uri>[];
  setUp(() {
    seguranca.restaurar();
    ligacoes.clear();
    abrirLink = (u) async {
      ligacoes.add(u);
      return true;
    };
  });

  testWidgets('Escudo abre Segurança; alerta silencioso deixa o topo vermelho', (
    t,
  ) async {
    await _abrir(t, EmAndamentoPage(inicio: _inicio));
    expect(find.text('Iniciado às 14:32'), findsOneWidget);
    expect(find.text('Em serviço'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Segurança'));
    await t.pumpAndSettle();
    expect(find.text('Ligar 180'), findsOneWidget);
    await t.tap(find.text('Alerta silencioso'));
    await t.pumpAndSettle();
    expect(seguranca.alertaAtivo, isTrue);
    expect(find.text('Alerta ativo · 2 contatos'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
  });

  testWidgets('Segurar o escudo 3 s dispara o alerta', (t) async {
    await _abrir(t, EmAndamentoPage(inicio: _inicio));
    final g = await t.startGesture(
      t.getCenter(find.bySemanticsLabel('Segurança')),
    );
    await t.pump(const Duration(seconds: 3));
    await g.up();
    await t.pumpAndSettle();
    expect(seguranca.alertaAtivo, isTrue);
    expect(find.text('Ligar 180'), findsNothing); // não abriu a folha
    await t.pump(const Duration(seconds: 4));
  });

  testWidgets('Ligar 190: mostra o que ler e liga', (t) async {
    await _abrir(t, EmAndamentoPage(inicio: _inicio));
    await t.tap(find.bySemanticsLabel('Segurança'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ligar 190'));
    await t.pumpAndSettle();
    expect(find.text('LEIA PARA O ATENDENTE'), findsOneWidget);
    expect(find.text('Pedido nº TT-48213'), findsOneWidget);
    expect(seguranca.alertaAtivo, isTrue);
    await t.tap(find.text('Ligar 190 agora'));
    await t.pump();
    expect(ligacoes.single.toString(), 'tel:190');
  });

  testWidgets('Sair agora → Você saiu → Contar o que aconteceu', (t) async {
    await _abrir(t, EmAndamentoPage(inicio: _inicio));
    await t.tap(find.bySemanticsLabel('Segurança'));
    await t.pumpAndSettle();
    await t.tap(find.text('Sair agora'));
    await t.pumpAndSettle();
    expect(find.text('Sair do atendimento agora?'), findsOneWidget);
    expect(find.text('A cliente é bloqueada para você.'), findsOneWidget);
    await t.tap(find.widgetWithText(FilledButton, 'Sair agora'));
    await t.pumpAndSettle();
    expect(find.text('Você saiu do atendimento'), findsOneWidget);
    await t.tap(find.text('Preciso de ajuda · ligar 190'));
    await t.pumpAndSettle();
    expect(find.text('Ligar 190 agora'), findsOneWidget);
  });

  testWidgets('Contatos de confiança: remover e compartilhar', (t) async {
    await _abrir(t, const ContatosConfiancaPage());
    expect(find.text('Mariana Souza · irmã'), findsOneWidget);
    await t.tap(find.byTooltip('Opções de João Vieira'));
    await t.pumpAndSettle();
    await t.tap(find.text('Remover João'));
    await t.pumpAndSettle();
    expect(seguranca.contatos, hasLength(1));
    await t.tap(find.byType(CupertinoSwitch));
    await t.pump();
    expect(seguranca.compartilharTudo, isFalse);
  });

  testWidgets('Preferências: só mulheres aparece para profissional mulher', (
    t,
  ) async {
    profissional.restaurar();
    await _abrir(t, const PreferenciasAtendimentoPage());
    expect(find.text('Atender só clientes mulheres'), findsNothing);
    profissional.demo();
    await t.pump();
    expect(find.text('Atender só clientes mulheres'), findsOneWidget);
    await t.tap(find.byType(CupertinoSwitch).first);
    await t.pump();
    expect(seguranca.soMulheres, isTrue);
    await t.tap(find.byType(CupertinoSwitch).last);
    await t.pump();
    expect(seguranca.soVerificados, isTrue);
  });

  testWidgets('Cliente: escudo no pedido, 190 e sair agora', (t) async {
    pedidos.restaurar();
    await _abrir(t, const PedidoAndamentoPage());
    await t.tap(find.bySemanticsLabel('Segurança'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ligar 190'));
    await t.pumpAndSettle();
    expect(find.text('Profissional'), findsOneWidget);
    expect(find.text('Luiza Souza'), findsOneWidget);
    await t.tap(find.text('Voltar'));
    await t.pumpAndSettle();
    expect(find.text('Alerta ativo · 2 contatos'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Segurança'));
    await t.pumpAndSettle();
    await t.tap(find.text('Sair agora'));
    await t.pumpAndSettle();
    expect(find.text('A profissional é bloqueada para você.'), findsOneWidget);
    expect(find.text('Nada é cobrado por sair.'), findsOneWidget);
    await t.tap(find.widgetWithText(FilledButton, 'Sair agora'));
    await t.pumpAndSettle();
    expect(find.text('Você saiu do atendimento'), findsOneWidget);
    expect(pedidos.andamento, isNull);
  });
}
