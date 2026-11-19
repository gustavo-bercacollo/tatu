import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';
import 'package:tatu/features/profissional/servico/rota.dart';

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

void main() {
  final abertos = <Uri>[];
  setUp(() {
    navegacao.restaurar();
    abertos.clear();
    abrirLink = (u) async {
      abertos.add(u);
      return true;
    };
  });

  testWidgets('A caminho → Quase lá → Cheguei → código → Em serviço', (
    t,
  ) async {
    await _abrir(t, const ACaminhoPage());
    expect(find.text('A caminho da Ana'), findsOneWidget);
    expect(find.text('Chegada em 6 min · 1,2 km'), findsOneWidget);
    expect(find.text('Rua Bruno Lobo, 29'), findsOneWidget);
    // Longe: "Cheguei" ainda não funciona.
    await t.tap(find.text('Cheguei'));
    await t.pump();
    expect(find.text('Aguardando a Ana'), findsNothing);
    await t.pump(const Duration(seconds: 6));
    expect(find.text('Quase lá'), findsOneWidget);
    expect(find.text('Você chegou perto da Ana'), findsOneWidget);
    await t.tap(find.text('Cheguei'));
    await t.pump();
    // RN-39: pede o código; sem botão de começar.
    expect(find.text('Peça o código para a Ana'), findsOneWidget);
    expect(find.text('Iniciar serviço'), findsNothing);
    // RN-80: a espera continua contando.
    await t.tap(find.text('A Ana não está? Ver tempo de espera'));
    await t.pump();
    expect(find.text('Aguardando a Ana'), findsOneWidget);
    expect(find.textContaining('ela foi avisada'), findsOneWidget);
    await t.tap(find.text('Digitar o código'));
    await t.pump();
    for (final d in ['4', '8', '2', '1']) {
      await t.tap(find.text(d).last);
      await t.pump();
    }
    await t.pumpAndSettle();
    expect(find.text('Em serviço'), findsOneWidget);
  });

  testWidgets('Abrir rota: escolhe o app, "Usar sempre" guarda', (t) async {
    await _abrir(t, const ACaminhoPage(chegaEm: Duration(hours: 1)));
    await t.tap(find.text('Abrir rota'));
    await t.pumpAndSettle();
    expect(find.text('Abrir rota com'), findsOneWidget);
    await t.tap(find.byType(CupertinoSwitch));
    await t.pump();
    await t.tap(find.text('Google Maps'));
    await t.pumpAndSettle();
    expect(abertos.single.host, 'www.google.com');
    expect(navegacao.preferido, AppNavegacao.google);
    // Da próxima vez vai direto.
    await t.tap(find.text('Abrir rota'));
    await t.pumpAndSettle();
    expect(find.text('Abrir rota com'), findsNothing);
    expect(abertos, hasLength(2));
  });

  testWidgets('Waze não instalado: abrir no Google Maps ou baixar', (t) async {
    await _abrir(t, const ACaminhoPage(chegaEm: Duration(hours: 1)));
    await t.tap(find.text('Abrir rota'));
    await t.pumpAndSettle();
    await t.tap(find.text('Waze'));
    await t.pumpAndSettle();
    expect(find.text('Waze não está instalado'), findsOneWidget);
    await t.tap(find.text('Baixar o Waze'));
    await t.pumpAndSettle();
    expect(abertos.single.host, 'play.google.com');
  });

  testWidgets('Copiar endereço', (t) async {
    await _abrir(t, const ACaminhoPage(chegaEm: Duration(hours: 1)));
    await t.tap(find.text('Abrir rota'));
    await t.pumpAndSettle();
    await t.tap(find.text('Copiar endereço'));
    await t.pumpAndSettle();
    expect(find.text('Endereço copiado'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
  });

  testWidgets('Localização desligada: pede para ativar', (t) async {
    navegacao.ativarLocalizacao(false);
    await _abrir(t, const ACaminhoPage(chegaEm: Duration(seconds: 1)));
    await t.pumpAndSettle();
    expect(find.text('Ative sua localização'), findsOneWidget);
    await t.tap(find.text('Agora não'));
    await t.pumpAndSettle();
    // Sem localização, "Cheguei" não libera.
    expect(find.text('Quase lá'), findsNothing);
    expect(find.text('Ativar localização'), findsOneWidget);
    await t.tap(find.text('Ativar localização'));
    await t.pumpAndSettle();
    await t.tap(find.text('Abrir Ajustes'));
    await t.pumpAndSettle();
    expect(navegacao.localizacaoAtiva, isTrue);
    expect(find.text('Quase lá'), findsOneWidget);
  });

  testWidgets('App de navegação: marca o escolhido', (t) async {
    await _abrir(t, const AppNavegacaoPage());
    await t.tap(find.text('Waze'));
    await t.pump();
    expect(navegacao.preferido, AppNavegacao.waze);
  });
}
