import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/demo_plano_fixo.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/features/cliente/atividade/atividade_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/cliente/mensagens/mensagens_page.dart';
import 'package:tatu/features/cliente/plano_fixo/plano_fixo.dart';
import 'package:tatu/features/profissional/atividade/atividade_profissional_page.dart';
import 'package:tatu/features/profissional/mensagens/mensagens_profissional_page.dart';

/// Identificação do plano fixo (RN-200 a RN-205).

/// Terça, 24 nov 2026, 8h (a visita do plano da demo é hoje às 9h).
final _terca = DateTime(2026, 11, 24, 8);

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in ['400', '500', '600', '700']) {
    f.addFont(rootBundle.load('assets/fonts/Inter-$p.ttf'));
  }
  await f.load();
}

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
  await t.pumpAndSettle();
}

PlanoFixo _plano() => planosFixos.pedir(
  cliente: 'Ana Martins',
  profissional: 'Júlia Costa',
  endereco: 'Rua A',
  frequencia: FrequenciaPlano.mensal,
  visitasPorSemana: 1,
  dias: const [2],
  horario: '9:00',
  profissao: 'Diarista',
  agora: _terca,
)!;

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    planosFixos.restaurar();
    conversas.restaurar();
    conversasProfissional.restaurar();
    pedidos.restaurar();
    pagamentos.restaurar();
    conta.restaurar();
    retornos.restaurar();
    profissional
      ..restaurar()
      ..demo();
  });

  group('RN-205: estados (selo · barra)', () {
    test('aguardando e valor enviado: sem selo; laranja só para o cliente', () {
      withClock(Clock.fixed(_terca), () {
        final p = _plano();
        expect(p.estado(), EstadoPlano.aguardandoValor);
        expect(p.selo(), isNull);
        expect(
          p.barra(cliente: true)!.texto,
          'Plano fixo · aguardando o valor da Júlia',
        );
        planosFixos.enviarValor(p, 150);
        expect(p.estado(), EstadoPlano.valorEnviado);
        final b = p.barra(cliente: true)!;
        expect(b.texto, 'Plano fixo · confirme o valor');
        expect(b.direita, r'R$ 150/visita');
        expect(b.laranja, isTrue);
        final pro = p.barra(cliente: false)!;
        expect(pro.texto, 'Plano fixo · aguardando a Ana confirmar');
        expect(pro.laranja, isFalse);
      });
    });

    test('ativo, sem visita na semana, pausado, cancelado e encerrado', () {
      withClock(Clock.fixed(_terca), () {
        final p = _plano();
        planosFixos
          ..enviarValor(p, 150)
          ..confirmar(p, cartao: 'Visa 4242', inicio: _terca);
        expect(p.estado(), EstadoPlano.ativo);
        expect(p.selo(), 'Plano fixo');
        expect(p.barra(cliente: true)!.texto, 'Plano fixo · toda terça, 9h');
        expect(p.barra(cliente: true)!.direita, 'Próxima: 24 nov');

        // "Não vou nesta semana": sem visita na semana.
        planosFixos.naoVou(p, p.visitas.first);
        expect(p.estado(), EstadoPlano.semVisitaNaSemana);
        expect(p.selo(), 'Plano fixo');
        expect(p.barra(cliente: true)!.texto, 'Sem visita nesta semana');
        expect(p.barra(cliente: true)!.direita, 'Próxima: 1 dez');

        planosFixos.cancelar(p);
        expect(p.estado(), EstadoPlano.cancelado);
        expect(p.selo(), startsWith('Plano até '));
        expect(p.barra(cliente: true)!.texto, startsWith('Plano termina em '));

        planosFixos.fecharPeriodo(p);
        expect(p.estado(), EstadoPlano.encerrado);
        expect(p.selo(), isNull);
        expect(p.barra(cliente: true), isNull);
        expect(p.encerradoEm, isNotNull);
      });
    });

    test('pausado: "Plano pausado", apagado', () {
      withClock(Clock.fixed(_terca), () {
        final p = _plano();
        planosFixos
          ..enviarValor(p, 150)
          ..confirmar(p, cartao: 'Visa 4242', inicio: _terca);
        p.status = StatusPlano.pausado;
        expect(p.selo(), 'Plano pausado');
        expect(p.seloApagado, isTrue);
        expect(
          p.barra(cliente: true)!.texto,
          'Plano pausado · volta quando quiser',
        );
      });
    });
  });

  testWidgets('RN-201: selo nas Mensagens do cliente', (t) async {
    await withClock(Clock.fixed(_terca), () async {
      sementeDemoPlanoFixo();
      await _abrir(t, const MensagensPage());
      expect(find.text('Júlia Costa'), findsOneWidget);
      expect(find.text('Plano fixo'), findsOneWidget);
    });
  });

  testWidgets('RN-202/RN-203: chat com subtítulo, barra e visita feita', (
    t,
  ) async {
    await withClock(Clock.fixed(_terca), () async {
      sementeDemoPlanoFixo();
      final c = conversas.conversas.firstWhere((c) => c.nome == 'Júlia Costa');
      await _abrir(t, ChatPage(conversa: c));
      expect(find.text('Diarista · Plano fixo'), findsOneWidget);
      expect(
        find.text('Plano fixo · toda terça, 9h'),
        findsOneWidget,
      );
      expect(find.text('Próxima: 24 nov'), findsOneWidget);
      expect(
        find.text('Visita do plano · 17 nov · feita'),
        findsOneWidget,
      );
    });
  });

  testWidgets('RN-201/RN-203: Atividade do cliente (visita e cobrança)', (
    t,
  ) async {
    await withClock(Clock.fixed(_terca), () async {
      sementeDemoPlanoFixo();
      await _abrir(t, const AtividadePage());
      expect(find.text('Diarista · Júlia'), findsOneWidget);
      expect(find.text('Plano fixo · visita 2 de 4'), findsOneWidget);
      await t.tap(find.text('Concluídos'));
      await t.pumpAndSettle();
      expect(find.text('Plano fixo · 4 visitas'), findsOneWidget);
      expect(find.text('R\$ 600,00'), findsOneWidget);
    });
  });

  testWidgets('RN-201/RN-204: profissional (Mensagens e Atividade)', (
    t,
  ) async {
    await withClock(Clock.fixed(_terca), () async {
      sementeDemoPlanoFixo();
      await _abrir(t, const MensagensProfissionalPage());
      expect(find.text('Plano pausado'), findsOneWidget);
      await _abrir(t, const AtividadeProfissionalPage(aba: 0));
      expect(find.text('PRÓXIMAS VISITAS DO PLANO'), findsOneWidget);
      expect(find.text('Roberto Alves · Diarista'), findsOneWidget);
      expect(find.text('Pausado'), findsOneWidget);
    });
  });

  testWidgets('C216 · RN-202: "Mensagem" na tela do plano abre o chat', (
    t,
  ) async {
    await withClock(Clock.fixed(_terca), () async {
      sementeDemoPlanoFixo();
      final p = planosFixos.ultimoCom(profissional: 'Júlia Costa')!;
      await _abrir(t, PlanoFixoPage(plano: p));
      expect(find.text('Mensagem'), findsOneWidget);
      await t.tap(find.text('Mensagem'));
      await t.pumpAndSettle();
      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.text('Diarista · Plano fixo'), findsOneWidget);
    });
  });

  testWidgets('RN-202: aberta pelo chat, "Mensagem" só volta', (t) async {
    await withClock(Clock.fixed(_terca), () async {
      sementeDemoPlanoFixo();
      final c = conversas.conversas.firstWhere((c) => c.nome == 'Júlia Costa');
      await _abrir(t, ChatPage(conversa: c));
      await t.tap(find.text('Plano fixo · toda terça, 9h'));
      await t.pumpAndSettle();
      expect(find.byType(PlanoFixoPage), findsOneWidget);
      await t.tap(find.text('Mensagem'));
      await t.pumpAndSettle();
      expect(find.byType(PlanoFixoPage), findsNothing);
      expect(find.byType(ChatPage), findsOneWidget);
    });
  });
}
