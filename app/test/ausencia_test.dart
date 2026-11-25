import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/prazos.dart';
import 'package:tatu/features/cliente/atividade/pedido_andamento_page.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';

/// Cliente que não aparece (RN-80 a RN-82).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in [
    'assets/fonts/Inter-400.ttf',
    'assets/fonts/Inter-500.ttf',
    'assets/fonts/Inter-600.ttf',
    'assets/fonts/Inter-700.ttf',
  ]) {
    f.addFont(rootBundle.load(p));
  }
  await f.load();
}

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    Prazos.aceleracao = 1;
    navegacao.restaurar();
    pedidos.restaurar();
    conta.restaurar();
    PedidosRepo.demoCodigo = false;
    PedidosRepo.demoConclusao = false;
  });
  tearDown(() {
    Prazos.aceleracao = 20;
    PedidosRepo.demoCodigo = true;
    PedidosRepo.demoConclusao = true;
    pedidos.restaurar(); // para os relógios
  });

  testWidgets('Profissional: espera 10 min e encerra recebendo a visita', (
    t,
  ) async {
    await _abrir(t, const ACaminhoPage(perto: true));
    await t.tap(find.text('Cheguei'));
    await t.pump();
    // RN-80: a espera conta enquanto o código não é digitado.
    await t.tap(find.text('A Ana não está? Ver tempo de espera'));
    await t.pump();
    // RN-80: contador de 10 min; "Cliente não apareceu" desativado.
    expect(find.text('Aguardando a Ana'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Libera depois de 10 min de espera.'), findsOneWidget);
    await t.tap(find.text('Cliente não apareceu'));
    await t.pump();
    expect(find.text('A Ana não apareceu?'), findsNothing);

    await t.pump(const Duration(minutes: 2, seconds: 18));
    expect(find.text('7:42'), findsOneWidget);
    await t.pump(const Duration(minutes: 8));
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('A espera acabou.'), findsOneWidget);

    // RN-81: confirma e encerra cobrando só a visita.
    await t.tap(find.text('Cliente não apareceu'));
    await t.pumpAndSettle();
    expect(find.text('A Ana não apareceu?'), findsOneWidget);
    expect(find.text('Esperar mais'), findsOneWidget);
    await t.tap(find.text('Esperar mais'));
    await t.pumpAndSettle();
    expect(find.text('Aguardando a Ana'), findsOneWidget);
    await t.tap(find.text('Cliente não apareceu'));
    await t.pumpAndSettle();
    await t.tap(find.text('Encerrar e receber a visita'));
    await t.pump();
    expect(find.text('Visita recebida'), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
  });

  testWidgets('Cliente: chegou, passa o código; o serviço começa sozinho', (
    t,
  ) async {
    pedidos.chegou();
    await _abrir(t, const PedidoAndamentoPage());
    await t.pump();
    expect(find.text('A Luiza chegou'), findsOneWidget);
    expect(find.text('Diga este código à Luiza'), findsOneWidget);
    expect(find.text('4 8 2 1'), findsOneWidget);
    expect(
      find.text('Quando ela digitar, o serviço começa sozinho.'),
      findsOneWidget,
    );
    // RN-39: quem digita é a profissional.
    pedidos.codigoDigitado();
    await t.pump();
    expect(find.text('A Luiza chegou'), findsNothing);
    expect(pedidos.andamento?.etapasFeitas, 4);
  });

  testWidgets('Cliente ausente: visita cobrada e conta a ausência', (t) async {
    pedidos.chegou();
    await _abrir(t, const PedidoAndamentoPage());
    await t.pumpAndSettle();
    await t.pump(Prazos.esperaCliente);
    await t.pumpAndSettle();
    expect(find.text('Você não estava no local'), findsOneWidget);
    expect(find.text('A visita foi cobrada: R\$ 40,00'), findsOneWidget);
    expect(find.text('A Luiza esperou 10 minutos na porta.'), findsOneWidget);
    expect(find.text('Algo errado? Avise o Tatu'), findsOneWidget);
    expect(pedidos.andamento, isNull);
    expect(conta.ausenciasRecentes, 1);
    expect(conta.pausadaPorAusencias, isFalse);
  });

  testWidgets('Atrasada: quem continua esperando vê a profissional chegar', (
    t,
  ) async {
    pedidos.esperarAtrasado();
    await _abrir(t, const PedidoAndamentoPage());
    await t.pump(const Duration(minutes: 3));
    await t.pumpAndSettle();
    expect(find.text('A Luiza chegou'), findsOneWidget);
    pedidos.restaurar(); // para o relógio da espera
  });

  testWidgets('3 ausências em 30 dias pausam a conta (RN-82)', (t) async {
    conta.pausarPorAusenciasParaDemo();
    await _abrir(t, const HomeClientePage());
    expect(find.text('Conta pausada'), findsOneWidget);
    expect(find.text('3 ausências em 30 dias.'), findsOneWidget);
    expect(
      find.text('Fale com o suporte para voltar a pedir.'),
      findsOneWidget,
    );
    await t.enterText(find.byType(TextField), 'o cano da pia está vazando');
    await t.pump(const Duration(milliseconds: 600));
    final b = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Chamar profissional'),
    );
    expect(b.onPressed, isNull);
  });
}
