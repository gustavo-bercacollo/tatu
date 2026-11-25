import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/cliente/plano_fixo/plano_fixo.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/plano_fixo/plano_fixo_profissional.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/data/profissional.dart';

/// Plano fixo (RN-144 a RN-149): regras de dados.

const _luiza = 'Luiza Souza';
const _casa = 'Rua das Flores, 120';

/// Terça, 10 nov 2026.
final _inicio = DateTime(2026, 11, 10);

PlanoFixo _plano({
  FrequenciaPlano f = FrequenciaPlano.mensal,
  int porSemana = 1,
  List<int> dias = const [2],
}) {
  final p = planosFixos.pedir(
    cliente: 'Ana Martins',
    profissional: _luiza,
    endereco: _casa,
    frequencia: f,
    visitasPorSemana: porSemana,
    dias: dias,
    horario: '9:00',
    agora: _inicio,
  )!;
  planosFixos
    ..enviarValor(p, 150)
    ..confirmar(p, cartao: 'Visa 4242', inicio: _inicio);
  return p;
}

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

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    conversas.restaurar();
    planosFixos.restaurar();
    canalTatu.restaurar();
    profissional.restaurar();
  });

  group('RN-144: pedido, valor uma vez e aceite', () {
    test('fluxo até ativo', () {
      final p = planosFixos.pedir(
        cliente: 'Ana Martins',
        profissional: _luiza,
        endereco: _casa,
        frequencia: FrequenciaPlano.mensal,
        visitasPorSemana: 1,
        dias: const [2],
        horario: '9:00',
        agora: _inicio,
      )!;
      expect(p.status, StatusPlano.pendente);
      expect(planosFixos.enviarValor(p, 150), isTrue);
      // O valor vai uma vez só.
      expect(planosFixos.enviarValor(p, 200), isFalse);
      expect(p.valorPorVisita, 150);
      planosFixos.confirmar(p, cartao: 'Visa 4242', inicio: _inicio);
      expect(p.status, StatusPlano.ativo);
      expect(p.visitas, hasLength(4));
      expect(p.valorDoPeriodo, 600);
      expect(p.quando, 'toda terça, 9h');
    });
  });

  group('RN-145: até 2 visitas por semana', () {
    test('3 vezes por semana nem vira pedido', () {
      expect(
        planosFixos.pedir(
          cliente: 'Ana',
          profissional: _luiza,
          endereco: _casa,
          frequencia: FrequenciaPlano.semanal,
          visitasPorSemana: 3,
          dias: const [1, 3, 5],
          horario: '9:00',
        ),
        isNull,
      );
      expect(RegrasPlanoFixo.maxVisitasSemana, 2);
    });

    test('3ª visita na semana bloqueada por pedido avulso', () {
      _plano(f: FrequenciaPlano.semanal, porSemana: 2, dias: const [2, 4]);
      // Plano já tem 2 nesta semana: o avulso seria a 3ª.
      expect(planosFixos.visitasNaSemana(_luiza, _casa, _inicio), 2);
      expect(planosFixos.pedirAvulso(_luiza, _casa, _inicio), isFalse);
      // Outra semana ou outro endereço não contam.
      expect(
        planosFixos.pedirAvulso(_luiza, 'Rua Bruno Lobo, 29', _inicio),
        isTrue,
      );
    });

    test('avulsos da semana impedem plano que passaria do limite', () {
      expect(planosFixos.pedirAvulso(_luiza, _casa, _inicio), isTrue);
      expect(
        planosFixos.pedir(
          cliente: 'Ana',
          profissional: _luiza,
          endereco: _casa,
          frequencia: FrequenciaPlano.semanal,
          visitasPorSemana: 2,
          dias: const [2, 4],
          horario: '9:00',
          agora: _inicio,
        ),
        isNull,
      );
      // 1 avulso + plano de 1 vez = 2: pode.
      expect(
        planosFixos.pedir(
          cliente: 'Ana',
          profissional: _luiza,
          endereco: _casa,
          frequencia: FrequenciaPlano.semanal,
          visitasPorSemana: 1,
          dias: const [4],
          horario: '9:00',
          agora: _inicio,
        ),
        isNotNull,
      );
    });

    test('plano de 1 vez + 1 avulso: o 2º avulso é bloqueado', () {
      _plano(f: FrequenciaPlano.semanal);
      expect(planosFixos.pedirAvulso(_luiza, _casa, _inicio), isTrue);
      expect(planosFixos.pedirAvulso(_luiza, _casa, _inicio), isFalse);
    });
  });

  group('RN-146/RN-147: cobrança', () {
    test('cobra só as visitas feitas, com a comissão normal', () {
      final p = _plano();
      planosFixos
        ..visitaFeita(p.visitas[0])
        ..visitaFeita(p.visitas[1]);
      final c = planosFixos.fecharPeriodo(p)!;
      expect(c.visitasFeitas, 2);
      expect(c.total, 300);
      expect(c.comissao, 300 * taxaTatu);
      expect(c.repasse, 300 - 300 * taxaTatu);
      // Novo período agendado.
      expect(p.visitas, hasLength(4));
      expect(p.feitas, 0);
    });

    test('"não vou" não cobra, não pune e avisa o cliente', () {
      final p = _plano();
      final antes = canalTatu.cliente.mensagens.length;
      planosFixos
        ..visitaFeita(p.visitas[0])
        ..naoVou(p, p.visitas[1]);
      expect(profissional.abandonos, isEmpty);
      final aviso = canalTatu.cliente.mensagens.last;
      expect(canalTatu.cliente.mensagens, hasLength(antes + 1));
      expect(aviso.texto, contains('A Luiza avisou que não vem na terça'));
      expect(aviso.texto, contains('Essa visita não será cobrada.'));
      expect(aviso.texto, contains('A próxima é terça'));
      final c = planosFixos.fecharPeriodo(p)!;
      expect(c.visitasFeitas, 1);
      expect(c.total, 150);
    });

    test('faltar sem avisar é abandono (RN-76 a RN-79) e não cobra', () {
      final p = _plano();
      planosFixos.faltou(p.visitas[0]);
      expect(profissional.abandonos, hasLength(1));
      expect(planosFixos.fecharPeriodo(p)!.total, 0);
    });
  });

  group('RN-148: pausar, cancelar e mudar valor', () {
    test('pausar e cancelar valem do próximo período', () {
      final p = _plano();
      planosFixos.pausar(p);
      expect(p.status, StatusPlano.ativo);
      planosFixos.fecharPeriodo(p);
      expect(p.status, StatusPlano.pausado);
      expect(p.visitas, isEmpty);

      final q = _plano(dias: const [4]);
      planosFixos.cancelar(q);
      expect(q.status, StatusPlano.ativo);
      planosFixos.fecharPeriodo(q);
      expect(q.status, StatusPlano.cancelado);
    });

    test('mudar valor = nova proposta + aceite', () {
      final p = _plano();
      planosFixos.proporNovoValor(p, 180);
      expect(p.valorPorVisita, 150);
      planosFixos.aceitarNovoValor(p);
      expect(p.valorPorVisita, 180);
    });
  });

  group('Telas', () {
    testWidgets('cliente: tornar fixa → valor → confirmar → plano ativo', (
      t,
    ) async {
      final c = conversas.conversas.first;
      await _abrir(
        t,
        ChatPage(conversa: c, resposta: const Duration(seconds: 1)),
      );
      await t.tap(find.bySemanticsLabel(RegExp('^Opções da conversa')));
      await t.pumpAndSettle();
      await t.tap(find.text('Tornar Luiza fixa'));
      await t.pumpAndSettle();
      expect(
        find.text('Pelo Tatu, a mesma profissional vem até 2 vezes por semana.'),
        findsOneWidget,
      );
      await t.tap(find.text('Pedir valor à Luiza'));
      await t.pumpAndSettle();
      expect(find.text('Pedido de plano fixo enviado à Luiza.'), findsOneWidget);
      await t.pump(const Duration(seconds: 1));
      await t.pump();
      expect(find.text('Luiza enviou o valor do plano'), findsOneWidget);
      expect(find.text('R\$ 600 por mês'), findsOneWidget);
      // RN-210: "Proposta 1 de 3" e "Pedir outro valor" dentro do card.
      expect(find.text('Proposta 1 de 3'), findsOneWidget);
      await t.scrollUntilVisible(
        find.text('Pedir outro valor'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.ancestor(
          of: find.text('Pedir outro valor'),
          matching: find.byType(CartaoPropostaPlano),
        ),
        findsOneWidget,
      );
      // Tira o botão de baixo da barra de mensagem.
      await t.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await t.pumpAndSettle();
      await t.tap(find.text('Confirmar plano'));
      await t.pumpAndSettle();
      expect(find.byType(PlanoFixoPage), findsOneWidget);
      final p = planosFixos.planoCom('Luiza Souza')!;
      expect(p.status, StatusPlano.ativo);
      expect(p.aceitouTermosEm, isNotNull);
    });

    testWidgets('limite: mostra o aviso e não cria o plano', (t) async {
      // Já há 2 avulsos com a Luiza nesta semana no mesmo endereço.
      final c = conversas.conversas.first;
      final hoje = DateTime.now();
      planosFixos
        ..pedirAvulso('Luiza Souza', c.rua, hoje)
        ..pedirAvulso('Luiza Souza', c.rua, hoje);
      await _abrir(t, ChatPage(conversa: c));
      await t.tap(find.bySemanticsLabel(RegExp('^Opções da conversa')));
      await t.pumpAndSettle();
      await t.tap(find.text('Tornar Luiza fixa'));
      await t.pumpAndSettle();
      await t.tap(find.text('Pedir valor à Luiza'));
      await t.pumpAndSettle();
      expect(find.text('Até 2 visitas por semana'), findsOneWidget);
      expect(find.text(RegrasPlanoFixo.avisoLimite), findsOneWidget);
      expect(planosFixos.planoCom('Luiza Souza'), isNull);
    });

    testWidgets('profissional: envia o valor do plano uma vez', (t) async {
      final p = planosFixos.pedir(
        cliente: chamadoExemplo.cliente,
        profissional: 'Luiza Souza',
        endereco: _casa,
        frequencia: FrequenciaPlano.mensal,
        visitasPorSemana: 1,
        dias: const [2],
        horario: '9:00',
      )!;
      await _abrir(t, const ChatProfissionalPage());
      expect(find.text('Ana quer você fixa'), findsOneWidget);
      await t.tap(find.text('Enviar valor do plano'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).last, '150');
      await t.pump();
      expect(find.text('R\$ 540,00'), findsOneWidget);
      await t.tap(find.text('Enviar para Ana'));
      await t.pumpAndSettle();
      expect(p.valorPorVisita, 150);
      expect(find.textContaining('Valor do plano enviado'), findsOneWidget);
      expect(find.text('Enviar valor do plano'), findsNothing);
    });

    testWidgets('profissional: "Não vou nesta semana" avisa e não cobra', (
      t,
    ) async {
      final p = _plano();
      await _abrir(t, PlanoFixoProfissionalPage(plano: p));
      await t.tap(find.text('Não vou nesta semana'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Não vou nesta semana'));
      await t.pumpAndSettle();
      expect(p.visitas.first.situacao, SituacaoVisita.naoVai);
      expect(profissional.abandonos, isEmpty);
      expect(
        canalTatu.cliente.mensagens.last.texto,
        contains('não vem na terça'),
      );
    });
  });
}
