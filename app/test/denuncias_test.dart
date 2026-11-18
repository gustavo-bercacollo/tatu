import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/arquivos_seguros.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/denuncias.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/cliente/mensagens/denunciar_page.dart';
import 'package:tatu/features/entrada/perfil_publico_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';

/// Denúncias (RN-133 a RN-135).

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

const _assedio = 'Manda uma foto sua, linda.';

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    denuncias.restaurar();
    conversas.restaurar();
    pedidos.restaurar();
    conta.restaurar();
    profissional.restaurar();
    atendimentoProfissional.restaurar();
    segurancaConteudo.restaurar();
  });

  group('RN-134: denunciar mensagem', () {
    testWidgets('esconde só para quem denunciou e manda o contexto', (
      t,
    ) async {
      final c = conversas.conversas.first;
      final m = MensagemChat(texto: _assedio);
      c.mensagens.add(m);
      await _abrir(t, ChatPage(conversa: c));
      await t.longPress(find.text(_assedio));
      await t.pumpAndSettle();
      expect(find.text('Copiar'), findsOneWidget);
      await t.tap(find.text('Denunciar mensagem'));
      await t.pumpAndSettle();
      expect(find.text('Não mostramos a denúncia para a Luiza.'), findsOneWidget);
      await t.tap(find.text('Assédio ou ofensa'));
      await t.pump();
      await t.tap(find.widgetWithText(FilledButton, 'Denunciar mensagem'));
      await t.pumpAndSettle();

      // Quem denunciou não vê mais a mensagem…
      expect(find.text(_assedio), findsNothing);
      expect(find.text('Mensagem denunciada · em análise'), findsOneWidget);
      // …mas ela não é apagada (a outra pessoa continua vendo).
      expect(c.mensagens, contains(m));
      expect(m.texto, _assedio);
      // A conversa continua (só "Assédio ou discriminação" bloqueia).
      expect(c.encerrada, isFalse);

      final d = denuncias.fila.single;
      expect(d.tipo, TipoDenuncia.mensagem);
      expect(d.motivo, 'Assédio ou ofensa');
      expect(d.mensagem, _assedio);
      expect(d.denunciado, 'Luiza Souza');
      expect(d.contexto, contains('Luiza: Chego em 12 min.'));
      expect(d.contexto.last, 'Luiza: $_assedio');
    });

    testWidgets('profissional também; só esconde do lado dele', (t) async {
      await _abrir(
        t,
        const ChatProfissionalPage(
          mensagens: [
            ('Oi! A pia não para de vazar.', false),
            ('Posso ir agora. Já te mando o valor.', true),
            ('Faz por 50 ou te dou nota 1.', false),
          ],
        ),
      );
      await t.longPress(find.text('Faz por 50 ou te dou nota 1.'));
      await t.pumpAndSettle();
      await t.tap(find.text('Denunciar mensagem'));
      await t.pumpAndSettle();
      await t.tap(find.text('Ameaça ou chantagem'));
      await t.pump();
      await t.tap(find.widgetWithText(FilledButton, 'Denunciar mensagem'));
      await t.pumpAndSettle();
      expect(find.text('Faz por 50 ou te dou nota 1.'), findsNothing);
      expect(find.text('Mensagem denunciada · em análise'), findsOneWidget);
      expect(denuncias.fila.single.contexto, hasLength(3));
    });

    testWidgets('Copiar copia e não denuncia', (t) async {
      final c = conversas.conversas.first;
      await _abrir(t, ChatPage(conversa: c));
      await t.longPress(find.text('Chego em 12 min.'));
      await t.pumpAndSettle();
      await t.tap(find.text('Copiar'));
      await t.pumpAndSettle();
      expect(denuncias.fila, isEmpty);
      expect(find.text('Chego em 12 min.'), findsOneWidget);
    });

    testWidgets('a própria mensagem não abre o menu', (t) async {
      await _abrir(t, ChatPage(conversa: conversas.conversas.first));
      await t.longPress(find.text('Ótimo, pode vir agora?'));
      await t.pumpAndSettle();
      expect(find.text('Denunciar mensagem'), findsNothing);
    });
  });

  group('RN-133/RN-56: denunciar pessoa', () {
    test('assédio bloqueia os dois', () {
      denuncias.denunciarPessoa(
        denunciante: 'Ana Martins',
        denunciado: 'Luiza Souza',
        motivo: 'Assédio ou discriminação',
      );
      expect(denuncias.bloqueados('Ana Martins', 'Luiza Souza'), isTrue);
      expect(denuncias.bloqueados('Luiza Souza', 'Ana Martins'), isTrue);
    });

    test('outros motivos não bloqueiam', () {
      for (final m in motivosDenunciaPessoa.where(
        (m) => m != 'Assédio ou discriminação',
      )) {
        denuncias.denunciarPessoa(
          denunciante: 'Ana',
          denunciado: 'Luiza',
          motivo: m,
        );
      }
      expect(denuncias.bloqueados('Ana', 'Luiza'), isFalse);
    });

    testWidgets('cliente denuncia assédio: bloqueia e encerra a conversa', (
      t,
    ) async {
      final c = conversas.conversas.first;
      await _abrir(t, DenunciarPage(conversa: c));
      expect(find.textContaining('Não mostramos a denúncia para ela.'), findsOneWidget);
      await t.tap(find.text('Assédio ou discriminação'));
      await t.enterText(find.byType(TextField), 'Me mandou mensagens ofensivas.');
      await t.pump();
      await t.tap(find.text('Enviar denúncia'));
      await t.pumpAndSettle();
      expect(find.text('Denúncia enviada'), findsOneWidget);
      final d = denuncias.fila.single;
      expect(d.texto, 'Me mandou mensagens ofensivas.');
      expect(denuncias.bloqueados(conta.nomeCompleto, 'Luiza Souza'), isTrue);
      // RN-56: o acusado fica suspenso enquanto o suporte analisa (RN-129).
      expect(c.encerrada, isTrue);
    });

    testWidgets('profissional denuncia assédio: bloqueia e encerra', (
      t,
    ) async {
      atendimentoProfissional
        ..aceitar(chamadoExemplo)
        ..irAteCliente(const ServicoAceito());
      await _abrir(t, const ChatProfissionalPage());
      await t.tap(find.bySemanticsLabel(RegExp('^Opções da conversa')));
      await t.pumpAndSettle();
      await t.tap(find.text('Denunciar cliente'));
      await t.pumpAndSettle();
      await t.tap(find.text('Assédio ou discriminação'));
      await t.pump();
      await t.tap(find.text('Enviar denúncia'));
      await t.pumpAndSettle();
      expect(
        denuncias.bloqueados(profissional.nome, chamadoExemplo.cliente),
        isTrue,
      );
      expect(
        atendimentoProfissional.encerrados.containsKey(chamadoExemplo.cliente),
        isTrue,
      );
      await t.tap(find.text('Voltar para a conversa'));
      await t.pumpAndSettle();
      expect(find.text('Esta conversa foi encerrada.'), findsOneWidget);
    });
  });

  group('RN-135: fila do suporte e contadores', () {
    test('fila única, arquivo na frente', () {
      denuncias.denunciarPessoa(
        denunciante: 'Ana',
        denunciado: 'Luiza',
        motivo: 'Perfil falso',
      );
      segurancaConteudo.denunciar('fotos.pdf', 'Envolve menor de idade');
      final fila = denuncias.fila;
      expect(fila, hasLength(2));
      expect(fila.first.tipo, TipoDenuncia.arquivo);
      expect(fila.first.prioridadeMaxima, isTrue);
      expect(fila.last.motivo, 'Perfil falso');
    });

    test('confirmadas contam para o denunciado; falsas para quem denunciou', () {
      final a = denuncias.denunciarPessoa(
        denunciante: 'Ana',
        denunciado: 'Luiza',
        motivo: 'Golpe ou pagamento por fora',
      );
      final b = denuncias.denunciarPessoa(
        denunciante: 'Ana',
        denunciado: 'Luiza',
        motivo: 'Perfil falso',
      );
      final c = denuncias.denunciarPessoa(
        denunciante: 'Ana',
        denunciado: 'Luiza',
        motivo: 'Outro motivo',
      );
      denuncias
        ..analisar(a, AnaliseDenuncia.confirmada)
        ..analisar(b, AnaliseDenuncia.falsa)
        ..analisar(c, AnaliseDenuncia.naoConfirmada)
        // Analisar de novo não conta duas vezes.
        ..analisar(a, AnaliseDenuncia.confirmada);
      expect(denuncias.confirmadas, {'Luiza': 1});
      expect(denuncias.falsas, {'Ana': 1});
    });
  });

  testWidgets('Menu do chat tem "Ver perfil" e abre o perfil', (t) async {
    await _abrir(t, ChatPage(conversa: conversas.conversas.first));
    await t.tap(find.bySemanticsLabel(RegExp('^Opções da conversa')));
    await t.pumpAndSettle();
    await t.tap(find.text('Ver perfil'));
    await t.pumpAndSettle();
    expect(find.byType(PerfilPublicoPage), findsOneWidget);
    await t.tap(find.text('Voltar para a conversa'));
    await t.pumpAndSettle();
    expect(find.byType(ChatPage), findsOneWidget);
  });
}
