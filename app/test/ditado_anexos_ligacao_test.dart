import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/anexos.dart';
import 'package:tatu/data/arquivos_seguros.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/ditado.dart';
import 'package:tatu/data/ligacao.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/entrada/ligacao_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/chamado/novo_chamado_page.dart';

/// Ditado (RN-137, RN-138), anexos na descrição (RN-139) e ligação
/// (RN-140).

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

/// Fala o ditado de exemplo até o fim.
Future<void> _falar(WidgetTester t) async {
  for (var i = 0; i < 20; i++) {
    await t.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  late DitadoMock mock;
  late LigacaoMock tel;
  setUpAll(_carregarInter);
  setUp(() {
    conversas.restaurar();
    segurancaConteudo.restaurar();
    moderacao = ModeracaoArquivoMock();
    seletorArquivo = SeletorArquivoMock();
    ditado = mock = DitadoMock(
      frase: 'Pode vir agora, o registro fica embaixo da pia.',
      passo: const Duration(milliseconds: 10),
    );
    ligacao = tel = LigacaoMock();
  });

  group('RN-140: ligação só durante o atendimento', () {
    test('regra: do valor confirmado até a conclusão', () {
      expect(
        RegrasLigacao.disponivel(valorConfirmado: false, concluido: false),
        isFalse,
      );
      expect(
        RegrasLigacao.disponivel(valorConfirmado: true, concluido: false),
        isTrue,
      );
      expect(
        RegrasLigacao.disponivel(valorConfirmado: true, concluido: true),
        isFalse,
      );
    });

    testWidgets('indisponível antes da confirmação e depois da conclusão', (
      t,
    ) async {
      final c = conversas.conversas.first;
      await _abrir(t, ChatPage(conversa: c));
      // Antes de confirmar: sem telefone no topo nem no menu.
      expect(find.bySemanticsLabel('Ligar pelo Tatu'), findsNothing);
      await t.tap(find.bySemanticsLabel(RegExp('^Opções da conversa')));
      await t.pumpAndSettle();
      expect(find.textContaining('Ligar'), findsNothing);
      await t.tapAt(const Offset(10, 10));
      await t.pumpAndSettle();

      // Confirmou: aparece o telefone e o balão.
      conversas.confirmarValor(c);
      await t.pump();
      expect(find.bySemanticsLabel('Ligar pelo Tatu'), findsOneWidget);
      expect(find.text('Agora dá para ligar pelo Tatu.'), findsOneWidget);

      // A ligação mostra só o nome, nunca o número.
      await t.tap(find.bySemanticsLabel('Ligar pelo Tatu'));
      await t.pumpAndSettle();
      expect(find.byType(LigacaoPage), findsOneWidget);
      expect(find.text('Luiza Souza'), findsOneWidget);
      expect(find.text('Seu número não aparece'), findsOneWidget);
      expect(tel.chamadas, ['Luiza Souza']);
      await t.tap(find.bySemanticsLabel('Desligar'));
      await t.pumpAndSettle();
      expect(find.text('Agora dá para ligar pelo Tatu.'), findsNothing);

      // Concluiu: o telefone some.
      conversas.concluirServico(c);
      await t.pump();
      expect(find.bySemanticsLabel('Ligar pelo Tatu'), findsNothing);
      expect(c.podeLigar, isFalse);
    });

    testWidgets('profissional: sem telefone antes do valor combinado', (
      t,
    ) async {
      await _abrir(t, const ChatProfissionalPage());
      expect(find.bySemanticsLabel('Ligar pelo Tatu'), findsNothing);
    });
  });

  group('RN-139: anexos na descrição', () {
    test('6º anexo bloqueado', () async {
      final a = AnexosPedido();
      for (var i = 1; i <= RegrasAnexo.maxPorPedido; i++) {
        expect(
          await a.adicionar(ArquivoEnviado('foto$i.jpg')),
          ResultadoAnexo.anexado,
        );
      }
      expect(a.cheio, isTrue);
      expect(
        await a.adicionar(const ArquivoEnviado('foto6.jpg')),
        ResultadoAnexo.limite,
      );
      expect(a.itens, hasLength(RegrasAnexo.maxPorPedido));
    });

    test('.apk bloqueado; vírus barrado (RN-119/RN-120)', () async {
      final a = AnexosPedido();
      expect(
        await a.adicionar(const ArquivoEnviado('app.apk')),
        ResultadoAnexo.tipoNaoPermitido,
      );
      expect(
        await a.adicionar(const ArquivoEnviado('virus.pdf')),
        ResultadoAnexo.barrado,
      );
      expect(a.itens, isEmpty);
    });

    testWidgets('.apk pelo clipe não vira anexo', (t) async {
      seletorArquivo = SeletorArquivoMock(const ArquivoEnviado('app.apk'));
      await _abrir(t, const HomeClientePage());
      await t.tap(find.bySemanticsLabel('Anexar'));
      await t.pumpAndSettle();
      await t.tap(find.text('Arquivo (PDF, documento)'));
      await t.pumpAndSettle();
      expect(find.text('Vão só fotos, vídeos curtos e PDF.'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Arquivo ')), findsNothing);
    });

    testWidgets('PDF vira miniatura com o tipo', (t) async {
      await _abrir(t, const HomeClientePage());
      await t.tap(find.bySemanticsLabel('Anexar'));
      await t.pumpAndSettle();
      await t.tap(find.text('Arquivo (PDF, documento)'));
      await t.pumpAndSettle();
      expect(find.text('PDF'), findsOneWidget);
    });

    testWidgets('o profissional vê os anexos no Novo chamado', (t) async {
      await _abrir(
        t,
        const NovoChamadoPage(
          chamado: ChamadoNovo(
            anexos: [AnexoPedido('foto.jpg'), AnexoPedido('orcamento.pdf')],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Foto anexada'), findsOneWidget);
      expect(find.bySemanticsLabel('Arquivo PDF'), findsOneWidget);
    });
  });

  group('RN-137/RN-138: ditado', () {
    testWidgets('chat: ditado não gera áudio, vai como texto', (t) async {
      final c = conversas.conversas.first;
      final antes = c.mensagens.length;
      await _abrir(t, ChatPage(conversa: c));
      await t.tap(find.bySemanticsLabel('Ditar'));
      await t.pump();
      expect(find.textContaining('Ouvindo'), findsOneWidget);
      await _falar(t);
      await t.tap(find.bySemanticsLabel('Parar ditado'));
      await t.pumpAndSettle();
      expect(find.text('Ditado · confira antes de enviar'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Enviar mensagem'));
      await t.pumpAndSettle();

      expect(c.mensagens, hasLength(antes + 1));
      final m = c.mensagens.last;
      expect(m.texto, mock.frase);
      expect(m.minha, isTrue);
      // Nada além do texto: nem foto, nem arquivo, nem áudio.
      expect(m.foto, isFalse);
      expect(m.arquivo, isNull);
      expect(m.especial, isFalse);
      expect(find.text('Ditado · confira antes de enviar'), findsNothing);
    });

    testWidgets('permissão do microfone só no primeiro toque', (t) async {
      await _abrir(t, ChatPage(conversa: conversas.conversas.first));
      for (var i = 0; i < 2; i++) {
        await t.tap(find.bySemanticsLabel('Ditar'));
        await t.pump();
        await t.tap(find.bySemanticsLabel('Parar ditado'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), '');
        await t.pump();
      }
      expect(mock.perguntas, 1);
    });

    testWidgets('microfone negado: avisa e não ouve', (t) async {
      mock.permitido = false;
      await _abrir(t, ChatPage(conversa: conversas.conversas.first));
      await t.tap(find.bySemanticsLabel('Ditar'));
      await t.pump();
      expect(find.textContaining('Ouvindo'), findsNothing);
      expect(
        find.text('Permita o microfone nas configurações para ditar.'),
        findsOneWidget,
      );
    });

    testWidgets('Home: texto vai para a descrição e sugere o serviço', (
      t,
    ) async {
      mock.frase = 'Minha pia da cozinha tá vazando embaixo.';
      await _abrir(t, const HomeClientePage());
      await t.tap(find.bySemanticsLabel('Ditar'));
      await t.pump();
      expect(find.textContaining('Gravando'), findsOneWidget);
      await _falar(t);
      await t.tap(find.bySemanticsLabel('Usar o texto'));
      await t.pumpAndSettle();
      expect(find.text('Minha pia da cozinha tá vazando embaixo.'), findsOneWidget);
      expect(find.text('Transcrito do áudio · confira'), findsOneWidget);
      expect(find.text('Chamar encanador'), findsOneWidget);
      // Editou: já conferiu.
      await t.enterText(find.byType(TextField), 'Pia vazando embaixo.');
      await t.pump();
      expect(find.text('Transcrito do áudio · confira'), findsNothing);
    });
  });
}
