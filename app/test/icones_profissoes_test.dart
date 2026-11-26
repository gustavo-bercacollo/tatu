import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_colors.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/icones_profissoes.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/shared/widgets/icone_profissao.dart';
import 'package:tatu/shared/widgets/tatu_chip.dart';

/// Ícones das profissões (RN-227).

/// O arquivo existe de verdade (nunca ícone quebrado).
bool _existe(String caminho) => File(caminho).existsSync();

void main() {
  test('cada profissão do catálogo tem ícone próprio, e o arquivo existe', () {
    for (final p in catalogoServicos.todas) {
      expect(iconesProfissoes.temProprio(p.nome), isTrue, reason: p.nome);
      expect(_existe(iconesProfissoes.de(p.nome)), isTrue, reason: p.nome);
    }
  });

  test('nomes da Home, feminino e sinônimo', () {
    String arquivo(String n) => iconesProfissoes.de(n).split('/').last;
    expect(arquivo('Montador'), 'montador-de-moveis.svg');
    expect(arquivo('Designer'), 'designer-grafico.svg');
    expect(arquivo('Professor'), 'professor-particular.svg');
    expect(arquivo('Encanadora'), 'encanador.svg');
    expect(arquivo('bombeiro hidráulico'), 'encanador.svg');
    expect(arquivo('Psicóloga'), arquivo('Psicólogo'));
    // Profissões diferentes não dividem o mesmo ícone.
    final arquivos = {
      for (final p in catalogoServicos.todas) iconesProfissoes.de(p.nome),
    };
    expect(arquivos.length, catalogoServicos.todas.length);
  });

  test('sem ícone próprio: segmento; sem segmento: crachá', () {
    // Mapa sem o Encanador: cai no ícone de "Casa e reformas".
    final so = IconesProfissoes()
      ..ler('''
{"profissoes": {"Pintor": {"arquivo": "pintor.svg", "segmento": "Casa e reformas"}},
 "segmentos": {"Casa e reformas": "seg-casa.svg"},
 "sem_segmento": "generico-cracha.svg",
 "botao_outros": "outros.svg",
 "apelidos_na_home": {}}''');
    expect(so.de('Encanador'), endsWith('seg-casa.svg'));
    expect(so.de('Domador de dragões'), endsWith('generico-cracha.svg'));
    expect(_existe(iconesProfissoes.de('Domador de dragões')), isTrue);
    expect(iconesProfissoes.outros, endsWith('outros.svg'));
    expect(_existe(iconesProfissoes.outros), isTrue);
  });

  testWidgets('Home: ícone nas pílulas (branco quando selecionada) e no '
      '"Outros"', (t) async {
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
    );
    await t.pumpAndSettle();
    Finder iconeDa(String chip) => find.descendant(
      of: find.widgetWithText(TatuChip, chip),
      matching: find.byType(IconeProfissao),
    );
    expect(iconeDa('Encanador'), findsOneWidget);
    expect(iconeDa('Outros'), findsOneWidget);
    // A cor do texto da pílula.
    expect(
      t.widget<IconeProfissao>(iconeDa('Pintor')).cor,
      TatuColors.textPrimary,
    );
    await t.tap(find.text('Pintor'));
    await t.pump();
    expect(
      t.widget<IconeProfissao>(iconeDa('Pintor')).cor,
      TatuColors.onAction,
    );

    // "Outros": cada linha com o quadrado de 52 px.
    await t.tap(find.text('Outros'));
    await t.pumpAndSettle();
    expect(find.byType(IconeProfissaoQuadrado), findsWidgets);
    final q = t.getSize(find.byType(IconeProfissaoQuadrado).first);
    expect(q, const Size(52, 52));
    expect(find.byType(SvgPicture), findsWidgets);
  });
}
