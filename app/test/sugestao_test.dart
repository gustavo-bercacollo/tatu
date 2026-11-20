import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/arquivos_seguros.dart';
import 'package:tatu/data/perfil.dart';
import 'package:tatu/data/sugestoes_tatu.dart';
import 'package:tatu/features/cliente/perfil_page.dart';
import 'package:tatu/features/entrada/enviar_sugestao_page.dart';

/// RN-173: sugestão ao Tatu pelo Perfil.

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

const _pagina = EnviarSugestaoPage(conta: 'Ana', modo: ModoConta.cliente);

FilledButton _botao(WidgetTester t) =>
    t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Enviar sugestão'));

void main() {
  setUp(() {
    sugestoesTatu.restaurar();
    segurancaConteudo.restaurar();
    perfil.restaurar();
    perfil.escolherImagem = (_) async => Uint8List.fromList([1, 2, 3]);
    EnviarSugestaoPage.arquivoDoPrint = const ArquivoEnviado('print.jpg');
  });

  test('sem tipo ou sem texto não envia; 501 caracteres bloqueia', () {
    expect(SugestoesTatuRepo.conferir(null, 'oi'), ErroSugestao.semTipo);
    expect(
      SugestoesTatuRepo.conferir(TipoSugestao.ideia, '   '),
      ErroSugestao.semTexto,
    );
    expect(
      SugestoesTatuRepo.conferir(TipoSugestao.ideia, 'a' * 501),
      ErroSugestao.textoLongo,
    );
    expect(SugestoesTatuRepo.conferir(TipoSugestao.ideia, 'a' * 500), isNull);
    expect(
      sugestoesTatu.enviar(
        conta: 'Ana',
        modo: ModoConta.cliente,
        tipo: TipoSugestao.ideia,
        texto: 'a' * 501,
      ),
      ErroSugestao.textoLongo,
    );
    expect(sugestoesTatu.fila, isEmpty);
  });

  test('grava conta, modo, tipo, texto, versão e aparelho', () {
    sugestoesTatu.enviar(
      conta: 'Luiza Souza',
      modo: ModoConta.profissional,
      tipo: TipoSugestao.algoNaoFunciona,
      texto: '  O mapa travou.  ',
    );
    final s = sugestoesTatu.fila.single;
    expect(s.conta, 'Luiza Souza');
    expect(s.modo, ModoConta.profissional);
    expect(s.tipo, TipoSugestao.algoNaoFunciona);
    expect(s.texto, 'O mapa travou.');
    expect(s.versao, RegrasSugestaoTatu.versaoApp);
    expect(s.aparelho, isNotEmpty);
  });

  testWidgets('Perfil → Enviar sugestão → Obrigado!', (t) async {
    await _abrir(t, const PerfilClientePage());
    await t.scrollUntilVisible(
      find.text('Enviar sugestão'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text('Enviar sugestão'));
    await t.pumpAndSettle();
    expect(find.text('Sugira algo ao Tatu'), findsOneWidget);
    // Sem tipo e sem texto: não envia.
    expect(_botao(t).onPressed, isNull);
    await t.tap(find.text('Ideia'));
    await t.pump();
    expect(_botao(t).onPressed, isNull);
    await t.enterText(find.byType(TextField), 'Salvar um profissional favorito');
    await t.pump();
    expect(find.text('31/500'), findsOneWidget);
    expect(_botao(t).onPressed, isNotNull);
    await t.tap(find.text('Enviar sugestão'));
    await t.pumpAndSettle();
    expect(find.text('Obrigado!'), findsOneWidget);
    expect(sugestoesTatu.fila.single.modo, ModoConta.cliente);
    await t.tap(find.text('Voltar ao perfil'));
    await t.pumpAndSettle();
    expect(find.text('Enviar sugestão'), findsOneWidget);
  });

  testWidgets('mais de 500 caracteres não entra no campo', (t) async {
    await _abrir(t, _pagina);
    await t.tap(find.text('Outro'));
    await t.enterText(find.byType(TextField), 'a' * 501);
    await t.pump();
    expect(find.text('500/500'), findsOneWidget);
  });

  testWidgets('RN-120: o print passa pela verificação', (t) async {
    await _abrir(t, _pagina);
    // Print aprovado.
    await t.tap(find.bySemanticsLabel('Anexar print'));
    await t.pumpAndSettle();
    await t.tap(find.text('Escolher da galeria'));
    await t.pumpAndSettle();
    expect(find.text('Print anexado'), findsOneWidget);
    await t.tap(find.text('Remover'));
    await t.pump();
    // Print barrado pela moderação.
    EnviarSugestaoPage.arquivoDoPrint = const ArquivoEnviado('virus.jpg');
    await t.tap(find.bySemanticsLabel('Anexar print'));
    await t.pumpAndSettle();
    await t.tap(find.text('Tirar foto'));
    await t.pumpAndSettle();
    expect(find.text('Esta imagem foi bloqueada.'), findsOneWidget);
    expect(find.text('Anexar print (opcional)'), findsOneWidget);
  });
}
