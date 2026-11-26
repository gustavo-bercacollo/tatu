import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/aceites.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/consulta_cpf.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/documentos_legais.dart';
import 'package:tatu/data/profissional.dart' show taxaTatu;
import 'package:tatu/data/resumo_tatu.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/entrada/dados_cliente_page.dart';
import 'package:tatu/features/entrada/documentos_legais_page.dart';
import 'package:tatu/features/profissional/cadastro/aceite_page.dart';

/// Termos de Uso, Política de Privacidade e aceite (RN-150, RN-151).

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

/// Adulto válido (o mock da consulta de CPF diz que é maior).
const _cpf = '12345678909';

String _semMarcas(String s) => s.replaceAll('**', '').toLowerCase();

void main() {
  // Sem profissional a caminho: a Home mostra a saudação (RN-165).
  setUp(() => pedidos..restaurar()..cancelarAndamento());

  late DocumentoLegal termos, politica;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _carregarInter();
    await documentosLegais.carregarTodos();
    termos = documentosLegais.termos!;
    politica = documentosLegais.politica!;
    consultaCpf = ConsultaCpfMock(demora: Duration.zero);
  });
  setUp(() {
    documentosLegais
      ..definir(termos)
      ..definir(politica);
    aceites.restaurar();
    conta.restaurar();
    canalTatu.restaurar();
  });

  group('RN-150: documentos lidos do .md', () {
    test('Termos: versão, essencial, 23 seções e histórico', () {
      expect(termos.versao, '1.2');
      expect(termos.essencial, hasLength(7));
      expect(termos.numeradas, 23);
      expect(
        termos.secoes.map((s) => s.titulo),
        contains('8. Valor, pagamento e taxa'),
      );
      expect(termos.secoes.last.titulo, startsWith('Anexo I'));
      expect(termos.desta?.versao, '1.2');
    });

    test('Política: versão, essencial e seções', () {
      expect(politica.versao, '1.1');
      expect(politica.essencial, isNotEmpty);
      expect(politica.numeradas, 14);
    });

    test('o resumo do cadastro bate com "O essencial em 1 minuto"', () {
      for (final p in resumoCliente) {
        final item = _semMarcas(termos.essencial[p.item]);
        for (final c in p.chaves) {
          expect(item, contains(c.toLowerCase()), reason: p.texto);
        }
      }
      for (final p in resumoProfissional()) {
        final item = _semMarcas(termos.essencial[p.item]);
        for (final c in p.chaves) {
          expect(item, contains(c.toLowerCase()), reason: p.titulo);
        }
      }
      // A taxa vem da mesma constante da comissão.
      expect(
        resumoProfissional()[1].titulo,
        'Taxa de ${(taxaTatu * 100).round()}% por pagamento',
      );
    });
  });

  group('RN-150: aceite ativo', () {
    testWidgets('cliente: sem marcar não avança; aceite registrado', (t) async {
      final agora = DateTime(2026, 11, 20, 14, 32);
      await withClock(Clock.fixed(agora), () async {
        await _abrir(t, const DadosClientePage());
        await t.enterText(find.byType(TextField).first, 'Bia Souza');
        await t.enterText(find.byType(TextField).last, _cpf);
        await t.pump();
        FilledButton botao() =>
            t.widget(find.widgetWithText(FilledButton, 'Continuar'));
        expect(botao().onPressed, isNull);
        expect(find.textContaining('Ao continuar'), findsNothing);
        expect(find.text('O essencial do Tatu'), findsOneWidget);

        await t.tap(find.bySemanticsLabel(RegExp('^Li e concordo')).first);
        await t.pump();
        expect(botao().onPressed, isNotNull);
        await t.tap(find.text('Continuar'));
        await t.pumpAndSettle();
      });
      final a = aceites.ultimo(_cpf, TipoAceite.cliente)!;
      expect(a.versaoTermos, '1.2');
      expect(a.versaoPolitica, '1.1');
      expect(a.em, DateTime(2026, 11, 20, 14, 32));
      expect(a.conta, _cpf);
    });

    testWidgets('profissional: "Enviar para análise" só marcado', (t) async {
      var enviou = false;
      await _abrir(t, AceiteProfissionalPage(onEnviar: () => enviou = true));
      expect(find.text('Antes de enviar'), findsOneWidget);
      expect(find.text('Você é autônomo'), findsOneWidget);
      FilledButton botao() =>
          t.widget(find.widgetWithText(FilledButton, 'Enviar para análise'));
      expect(botao().onPressed, isNull);
      await t.tap(find.bySemanticsLabel(RegExp('^Li e concordo')).first);
      await t.pump();
      await t.tap(find.text('Enviar para análise'));
      await t.pumpAndSettle();
      expect(enviou, isTrue);
      final a = aceites.ultimo(contaDoAceite(), TipoAceite.profissional)!;
      expect(a.versaoTermos, '1.2');
    });
  });

  group('RN-151: versão nova', () {
    testWidgets('bloqueia ao abrir até "Concordo e continuar"', (t) async {
      documentosLegais.definir(
        versaoNovaDemo(termos, vigencia: DateTime(2026, 12, 3)),
      );
      // Abriu o app depois da data da versão nova.
      await withClock(Clock.fixed(DateTime(2026, 12, 5, 9)), () async {
      await _abrir(t, const HomeClientePage());
      await t.pumpAndSettle();
      expect(find.text('Atualizamos os Termos de uso'), findsOneWidget);
      expect(find.text('Plano fixo: até 2 visitas por semana.'), findsOneWidget);
      // Não dá para sair sem aceitar.
      final nav = t.state<NavigatorState>(find.byType(Navigator).first);
      await nav.maybePop();
      await t.pumpAndSettle();
      expect(find.text('Atualizamos os Termos de uso'), findsOneWidget);

      await t.tap(find.text('Concordo e continuar'));
      await t.pumpAndSettle();
      expect(find.byType(TermosAtualizadosPage), findsNothing);
      expect(find.text('Do que você precisa?'), findsOneWidget);
      final a = aceites.ultimo(contaDoAceite(), TipoAceite.cliente)!;
      expect(a.versaoTermos, '1.3');
      expect(a.versaoPolitica, '1.1');
      expect(a.em, DateTime(2026, 12, 5, 9));
      });
    });

    testWidgets('versão futura não bloqueia e é avisada no canal', (t) async {
      documentosLegais.definir(
        versaoNovaDemo(termos, vigencia: DateTime(2099, 1, 1)),
      );
      final antes = canalTatu.cliente.mensagens.length;
      await _abrir(t, const HomeClientePage());
      await t.pumpAndSettle();
      expect(find.byType(TermosAtualizadosPage), findsNothing);
      expect(canalTatu.cliente.mensagens, hasLength(antes + 1));
      expect(
        canalTatu.cliente.mensagens.last.resumo,
        'Atualizamos os Termos de uso',
      );
    });

    test('pedido em andamento segue a versão em que foi feito', () {
      final nova = versaoNovaDemo(termos, vigencia: DateTime(2026, 12, 3));
      expect(nova.versaoEm(DateTime(2026, 11, 25)), '1.2');
      expect(nova.versaoEm(DateTime(2026, 12, 4)), '1.3');
    });
  });

  testWidgets('falha ao ler: avisa e "Tentar de novo" carrega', (t) async {
    final fonte = _FonteQueFalha();
    documentosLegais
      ..restaurar()
      ..fonte = fonte;
    addTearDown(() {
      documentosLegais
        ..restaurar()
        ..definir(termos)
        ..definir(politica);
    });
    await _abrir(t, const DocumentoLegalPage(tipo: TipoDocumento.termos));
    await t.pumpAndSettle();
    expect(find.text('Não deu para abrir'), findsOneWidget);
    await t.tap(find.text('Tentar de novo'));
    await t.pumpAndSettle();
    expect(fonte.leituras, 2);
    expect(find.text('Não deu para abrir'), findsNothing);
    expect(find.text('O essencial em 1 minuto'), findsOneWidget);
    expect(fonte.leituras, 2);
  });
}

/// Falha na 1ª leitura (como antes de o Flutter iniciar) e depois lê.
class _FonteQueFalha implements FonteDocumentos {
  int leituras = 0;

  @override
  Future<String> ler(TipoDocumento tipo) async {
    leituras++;
    if (leituras == 1) throw StateError('ainda não iniciou');
    return '## O essencial em 1 minuto\n\n- Item.\n\n## 1. Seção\n\nTexto.';
  }
}
