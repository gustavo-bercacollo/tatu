// Gera as imagens das telas do app para o fluxograma (docs/fluxo/app/).
// Uso (dentro de app/):
//   flutter test tool/capturas_test.dart --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/entrada/boas_vindas_page.dart';
import 'package:tatu/features/entrada/celular_page.dart';
import 'package:tatu/features/entrada/codigo_page.dart';
import 'package:tatu/features/entrada/email_page.dart';
import 'package:tatu/features/entrada/nome_page.dart';

Future<void> _carregarFontes() async {
  final inter = FontLoader('Inter');
  for (final w in [400, 500, 600, 700]) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();

  final cache = Directory(
    '${Platform.environment['LOCALAPPDATA']}/Pub/Cache/hosted/pub.dev',
  );
  final pacote = cache.listSync().whereType<Directory>().lastWhere(
    (d) => d.path.contains('flutter_tabler_icons-'),
  );
  final tabler = File('${pacote.path}/assets/fonts/tabler-icons.ttf');
  await (FontLoader('packages/flutter_tabler_icons/tabler-icons')
        ..addFont(Future.value(ByteData.sublistView(tabler.readAsBytesSync()))))
      .load();
}

Future<void> _capturar(
  WidgetTester tester,
  String nome,
  Widget tela, {
  Future<void> Function()? preparar,
}) async {
  tester.view.physicalSize = const Size(786, 1704); // 393×852 @2x
  tester.view.devicePixelRatio = 2;
  await tester.pumpWidget(
    MaterialApp(
      theme: tatuTheme(),
      debugShowCheckedModeBanner: false,
      home: tela,
    ),
  );
  await tester.pump();
  if (preparar != null) await preparar();
  await tester.pump(const Duration(milliseconds: 600)); // fim das animações
  await expectLater(
    find.byWidget(tela),
    matchesGoldenFile('../../docs/fluxo/app/$nome.png'),
  );
  await tester.pumpWidget(const SizedBox()); // encerra timers da tela
}

void main() {
  setUpAll(_carregarFontes);

  testWidgets('boas-vindas', (t) async {
    await _capturar(t, 'boas-vindas', const BoasVindasPage());
  });

  testWidgets('celular', (t) async {
    await _capturar(
      t,
      'celular',
      const CelularPage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), '11988887777');
        await t.pump();
      },
    );
  });

  testWidgets('codigo', (t) async {
    await _capturar(
      t,
      'codigo',
      const CodigoPage(destino: '(11) 98888-7777'),
      preparar: () async {
        await t.enterText(find.byType(TextField), '4827');
        await t.pump(const Duration(seconds: 18));
      },
    );
  });

  testWidgets('entrar', (t) async {
    await _capturar(
      t,
      'entrar',
      const CelularPage.entrar(),
      preparar: () async {
        await t.enterText(find.byType(TextField), '11988887777');
        await t.pump();
      },
    );
  });

  testWidgets('email', (t) async {
    await _capturar(
      t,
      'email',
      const EmailPage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), 'ana@email.com');
        await t.pump();
      },
    );
  });

  testWidgets('codigo-email', (t) async {
    await _capturar(
      t,
      'codigo-email',
      const CodigoPage.email(destino: 'ana@email.com'),
      preparar: () async {
        await t.enterText(find.byType(TextField), '4827');
        await t.pump(const Duration(seconds: 18));
      },
    );
  });

  testWidgets('home-vazia', (t) async {
    await _capturar(
      t,
      'home-vazia',
      const HomeClientePage(nome: 'Ana Martins'),
    );
  });

  testWidgets('home-ia', (t) async {
    await _capturar(
      t,
      'home-ia',
      const HomeClientePage(nome: 'Ana Martins'),
      preparar: () async {
        await t.enterText(
          find.byType(TextField),
          'o cano da pia da cozinha está vazando e a água não para',
        );
        await t.pump(const Duration(milliseconds: 600));
      },
    );
  });

  testWidgets('nome', (t) async {
    await _capturar(
      t,
      'nome',
      const NomePage(),
      preparar: () async {
        await t.enterText(find.byType(TextField).first, 'Ana');
        await t.enterText(find.byType(TextField).last, 'Martins');
        await t.pump();
      },
    );
  });
}
