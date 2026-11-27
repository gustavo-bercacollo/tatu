import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/data/retorno_acoes.dart';
import 'package:tatu/features/cliente/atividade/atividade_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/cliente/retorno/retorno_cliente.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';

/// Agendar o retorno (RN-186, RN-213 a RN-215).

/// Quarta, 25 nov 2026, 9h41 (como nas telas).
final _agora = DateTime(2026, 11, 25, 9, 41);

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

DateTime _dia(int mais) =>
    DateTime(_agora.year, _agora.month, _agora.day + mais);

/// Pedido da Ana à Luiza Souza (lado do cliente da demo).
PedidoRetorno _pedido({List<OpcaoHorario>? horarios, bool urgente = false}) =>
    PedidoRetorno(
      servico: '#TT-77',
      servicoNome: 'Encanador',
      descricaoServico: 'Vazamento na pia',
      diaServico: '04 nov',
      profissional: 'Luiza Souza',
      profissionalFeminino: true,
      cliente: conta.nomeCompleto,
      clienteFeminina: true,
      valorServico: 150,
      descricao: 'A pia voltou a vazar no mesmo cano.',
      fotos: [FotoProva(tiradaEm: _agora)],
      pedidoEm: _agora,
      retido: false,
      horarios:
          horarios ??
          [
            OpcaoHorario(_dia(2), PeriodoDia.manha),
            OpcaoHorario(_dia(3), PeriodoDia.tarde),
          ],
      urgente: urgente,
    );

Finder get _lista => find
    .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
    .first;

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    retornos.restaurar();
    pedidos.restaurar();
    conversas.restaurar();
    conversasProfissional.restaurar();
    conta.restaurar();
    canalTatu.restaurar();
    profissional
      ..restaurar()
      ..demo();
  });

  group('Regras', () {
    test('períodos, opções que já passaram e o prazo de 7 dias', () {
      expect(PeriodoDia.manha.horas, [8, 9, 10, 11]);
      expect(PeriodoDia.noite.faixa, '18h–21h');
      // 9h41: a manhã de hoje já começou; a tarde ainda não.
      expect(OpcaoHorario(_dia(0), PeriodoDia.manha).passou(_agora), isTrue);
      expect(OpcaoHorario(_dia(0), PeriodoDia.tarde).passou(_agora), isFalse);
      expect(RegrasRetorno.limiteMarcar(_agora), DateTime(2026, 12, 2, 23, 59));
      expect(
        textoOpcao(OpcaoHorario(_dia(2), PeriodoDia.manha), _agora),
        'Sexta de manhã',
      );
      expect(quandoCurto(DateTime(2026, 11, 27, 9)), 'sexta, 27 nov, 9h');
    });

    test('aceitar uma opção marca sem confirmação do cliente', () {
      final r = retornos.pedir(_pedido())!;
      final quando = r.horarios.first.as(9);
      expect(retornos.aceitar(r, quando, agora: _agora), isTrue);
      expect(r.situacao, SituacaoRetorno.aceito);
      expect(r.marcadoPara, quando);
      // Uma hora fora do prazo (7 dias depois do pedido) não vale.
      retornos.restaurar();
      final s = retornos.pedir(_pedido())!;
      expect(
        retornos.aceitar(s, DateTime(2026, 12, 3, 9), agora: _agora),
        isFalse,
      );
    });

    test('sugerir outro horário → o cliente confirma', () {
      final r = retornos.pedir(_pedido())!;
      final dom = DateTime(2026, 11, 29, 10);
      // Passou do prazo (7 dias depois do pedido): não vale.
      expect(
        retornos.sugerirHorario(r, DateTime(2026, 12, 3, 10), agora: _agora),
        isFalse,
      );
      expect(retornos.sugerirHorario(r, dom, agora: _agora), isTrue);
      expect(r.situacao, SituacaoRetorno.aceito);
      expect(r.semHorario, isTrue);
      expect(r.sugerido, dom);
      expect(retornos.confirmarSugerido(r), isTrue);
      expect(r.marcadoPara, dom);
      expect(r.sugerido, isNull);
    });

    test('"Escolher outro": novos horários e o profissional escolhe', () {
      final r = retornos.pedir(_pedido())!;
      retornos.sugerirHorario(r, DateTime(2026, 11, 29, 10), agora: _agora);
      final novo = OpcaoHorario(_dia(4), PeriodoDia.noite);
      expect(retornos.novosHorarios(r, [novo], urgente: true), isTrue);
      expect(r.sugerido, isNull);
      expect(r.urgente, isTrue);
      expect(retornos.aceitar(r, novo.as(19), agora: _agora), isTrue);
      expect(r.marcadoPara, novo.as(19));
    });

    test('sem horário até 7 dias depois do pedido, vale a RN-188', () {
      final r = retornos.pedir(_pedido())!;
      // Aceitou sem marcar nem sugerir horário.
      retornos.aceitar(r, null, agora: _agora);
      retornos.conferirPrazos(agora: DateTime(2026, 12, 2, 20));
      expect(r.situacao, SituacaoRetorno.aceito);
      retornos.conferirPrazos(agora: DateTime(2026, 12, 3, 8));
      expect(r.situacao, SituacaoRetorno.resolvidoAutomatico);
      expect(r.falha, FalhaProfissional.naoMarcou);
    });

    test(
      'RN-243: sugeriu e o cliente não respondeu: sem acordo, sem falta',
      () {
        final r = retornos.pedir(_pedido())!;
        retornos.sugerirHorario(r, DateTime(2026, 11, 29, 10), agora: _agora);
        retornos.conferirPrazos(agora: DateTime(2026, 12, 3, 8));
        expect(r.situacao, SituacaoRetorno.semAcordoHorario);
        expect(r.falha, isNull);
        expect(r.historicoHorarios, isNotEmpty);
      },
    );

    test('RN-243: 2 sugestões, 1 "Escolher outro" e "Não posso"', () {
      final r = retornos.pedir(_pedido())!;
      expect(
        retornos.sugerirHorario(r, DateTime(2026, 11, 28, 10), agora: _agora),
        isTrue,
      );
      expect(r.podeEscolherOutro, isTrue);
      expect(
        retornos.novosHorarios(r, [OpcaoHorario(_dia(4), PeriodoDia.tarde)]),
        isTrue,
      );
      expect(
        retornos.sugerirHorario(r, DateTime(2026, 11, 30, 10), agora: _agora),
        isTrue,
      );
      // Na 2ª sugestão: só "Confirmar horário" e "Não posso".
      expect(r.podeEscolherOutro, isFalse);
      expect(r.podeSugerir, isFalse);
      expect(
        retornos.novosHorarios(r, [OpcaoHorario(_dia(5), PeriodoDia.tarde)]),
        isFalse,
      );
      expect(retornos.naoPosso(r), isTrue);
      expect(r.situacao, SituacaoRetorno.semAcordoHorario);
      // "Pedir ajuda ao Tatu" vira o 4º caso de mediação (RN-190).
      expect(retornos.mediar(r, MotivoMediacao.semAcordoHorario), isTrue);
    });

    test('RN-186/RN-188: "Não consigo ir" resolve sozinho; falta na 2ª', () {
      final r = retornos.pedir(_pedido())!;
      var faltas = 0;
      retornos.recusar(
        r,
        motivoNaoConsigoIr,
        agora: _agora,
        falta: (_) => faltas++,
      );
      expect(r.situacao, SituacaoRetorno.resolvidoAutomatico);
      expect(r.falha, FalhaProfissional.naoConsegueIr);
      expect(r.contouFalta, isFalse);
      expect(faltas, 0);
      final r2 = retornos.pedir(
        PedidoRetorno(
          servico: '#TT-78',
          servicoNome: 'Encanador',
          descricaoServico: 'Torneira',
          diaServico: '05 nov',
          profissional: 'Luiza Souza',
          profissionalFeminino: true,
          cliente: conta.nomeCompleto,
          clienteFeminina: true,
          valorServico: 90,
          descricao: 'Pinga de novo.',
          fotos: [FotoProva(tiradaEm: _agora)],
          pedidoEm: _agora,
          retido: false,
        ),
      )!;
      retornos.recusar(
        r2,
        motivoNaoConsigoIr,
        agora: _agora.add(const Duration(days: 10)),
        falta: (_) => faltas++,
      );
      expect(r2.contouFalta, isTrue);
      expect(faltas, 1);
    });

    test('RN-235: suspenso resolve na hora; RN-191: refazer não refaz', () {
      final r = retornos.pedir(_pedido())!;
      final resolvidos = retornos.profissionalSuspenso('Luiza Souza');
      expect(resolvidos, [r]);
      expect(r.falha, FalhaProfissional.suspenso);
      final refazer = PedidoRetorno(
        servico: '#TT-79',
        servicoNome: 'Encanador',
        descricaoServico: 'Refazer',
        diaServico: '06 nov',
        profissional: 'Carlos Lima',
        profissionalFeminino: false,
        cliente: conta.nomeCompleto,
        clienteFeminina: true,
        valorServico: 150,
        descricao: 'Continua.',
        fotos: const [],
        pedidoEm: _agora,
        retido: false,
        deRefazer: true,
      );
      expect(
        refazer.decisoesPossiveis,
        isNot(contains(DecisaoMediacao.refazerComOutro)),
      );
    });

    test('remarcar: uma vez cada lado, até 12 horas antes', () {
      final r = retornos.pedir(_pedido())!;
      retornos.aceitar(r, DateTime(2026, 11, 27, 9), agora: _agora);
      // O cliente pede: dia e período; a profissional escolhe a hora.
      expect(
        retornos.pedirRemarcar(
          r,
          cliente: true,
          dia: _dia(5),
          periodo: PeriodoDia.manha,
          agora: _agora,
        ),
        isTrue,
      );
      expect(retornos.confirmarRemarcar(r, 13), isFalse); // fora da manhã
      expect(retornos.confirmarRemarcar(r, 10), isTrue);
      expect(r.marcadoPara, DateTime(2026, 11, 30, 10));
      // O cliente não remarca de novo.
      expect(retornos.podeRemarcar(r, cliente: true, agora: _agora), isFalse);
      // A profissional ainda pode, mas não a menos de 12 horas.
      expect(retornos.podeRemarcar(r, cliente: false, agora: _agora), isTrue);
      expect(
        retornos.podeRemarcar(
          r,
          cliente: false,
          agora: DateTime(2026, 11, 29, 23),
        ),
        isFalse,
      );
      // Novo dia fora do prazo do pedido: não.
      expect(
        retornos.pedirRemarcar(
          r,
          cliente: false,
          dia: DateTime(2026, 12, 3),
          periodo: PeriodoDia.manha,
          agora: _agora,
        ),
        isFalse,
      );
    });

    test('RN-215: lembretes na véspera e 1 hora antes, uma vez cada', () {
      final r = retornos.pedir(_pedido())!;
      final m = DateTime(2026, 11, 27, 9);
      retornos.aceitar(r, m, agora: _agora);
      expect(retornos.lembretesDevidos(r, agora: _agora), isEmpty);
      final vespera = m.subtract(const Duration(hours: 23));
      expect(retornos.lembretesDevidos(r, agora: vespera), [
        const Duration(hours: 24),
      ]);
      expect(retornos.lembretesDevidos(r, agora: vespera), isEmpty);
      final antes = m.subtract(const Duration(minutes: 50));
      expect(retornos.lembretesDevidos(r, agora: antes), [
        const Duration(hours: 1),
      ]);
    });

    test('RN-215: o lembrete chega pelo canal do Tatu do cliente', () {
      final r = retornos.pedir(_pedido())!;
      final m = DateTime(2026, 11, 27, 9);
      retornos.aceitar(r, m, agora: _agora);
      conferirPrazosRetorno(agora: m.subtract(const Duration(hours: 20)));
      expect(
        canalTatu.cliente.mensagens.where(
          (x) => x.resumo == 'Retorno amanhã com a Luiza',
        ),
        hasLength(1),
      );
    });
  });

  group('Telas', () {
    testWidgets('C239: grade com até 3 horários e "É urgente?"', (t) async {
      await withClock(Clock.fixed(_agora), () async {
        (List<OpcaoHorario>, bool)? volta;
        await _abrir(
          t,
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    volta = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EscolherHorariosRetornoPage(
                          nome: 'Luiza',
                          feminino: true,
                          contador: '2 de 2',
                        ),
                      ),
                    );
                  },
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        );
        await t.tap(find.text('abrir'));
        await t.pumpAndSettle();
        expect(find.text('2 de 2'), findsOneWidget);
        expect(find.text('Quando você pode receber a Luiza?'), findsOneWidget);
        expect(find.text('Hoje'), findsOneWidget);
        expect(find.text('Amanhã'), findsOneWidget);
        // A manhã de hoje já passou: apagada.
        expect(find.text('–'), findsOneWidget);
        final pedir = find.widgetWithText(FilledButton, 'Pedir retorno');
        expect(t.widget<FilledButton>(pedir).onPressed, isNull);

        for (final l in [
          'Sexta de manhã',
          'Sábado à tarde',
          'Domingo à noite',
          'Segunda de manhã',
        ]) {
          await t.tap(find.bySemanticsLabel(l));
          await t.pump();
        }
        // O 4º não entra.
        expect(
          find.text(
            '3 de 3 · Sexta de manhã · Sábado à tarde · Domingo à noite',
          ),
          findsOneWidget,
        );
        await t.tap(
          find.byWidgetPredicate((w) => w is Switch || w is CupertinoSwitch),
        );
        await t.pump();
        await t.tap(pedir);
        await t.pumpAndSettle();
        expect(volta!.$1, hasLength(3));
        expect(volta!.$2, isTrue);
      });
    });

    testWidgets('P157/P158: urgente, opções e sugerir outro horário', (
      t,
    ) async {
      // A Júlia (cliente da demo do profissional) pediu com urgência.
      final r = retornos.doCliente('Júlia Costa')!..urgente = true;
      final c = conversasProfissional.anteriores.first;
      await _abrir(
        t,
        ChatProfissionalPage(
          chamado: c.chamado,
          concluidoPor: c.concluidaPor,
          concluidoEm: c.concluidaEm,
          depois: c.depois,
          diaDepois: c.diaDepois,
        ),
      );
      await t.scrollUntilVisible(
        find.text('Aceitar retorno'),
        200,
        scrollable: _lista,
      );
      expect(find.text('Urgente · a Júlia pediu hoje, se der'), findsOneWidget);
      await t.ensureVisible(find.text('Aceitar retorno'));
      await t.tap(find.text('Aceitar retorno'));
      await t.pumpAndSettle();
      expect(find.text('Quando você vai?'), findsOneWidget);
      expect(find.text('A Júlia pode nestes horários:'), findsOneWidget);
      expect(find.text('Que horas?'), findsOneWidget);
      // Sem hora, o botão espera.
      expect(
        t
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Aceitar'))
            .onPressed,
        isNull,
      );
      await t.tap(find.text('Nenhum serve? Sugerir outro horário'));
      await t.pumpAndSettle();
      expect(find.text('Sugerir outro horário'), findsOneWidget);
      expect(
        find.text('A Júlia precisa confirmar o novo horário.'),
        findsOneWidget,
      );
      await t.tap(find.text('${_amanha().day}').first);
      await t.tap(find.text('10h'));
      await t.pump();
      await t.tap(find.textContaining('Enviar · '));
      await t.pumpAndSettle();
      expect(r.sugerido, isNotNull);
      expect(r.sugerido!.hour, 10);
      expect(r.semHorario, isTrue);
    });

    testWidgets('C241: o cliente confirma o horário sugerido', (t) async {
      final r = retornos.pedir(_pedido())!;
      final quando = DateTime.now().add(const Duration(days: 2));
      final dom = DateTime(quando.year, quando.month, quando.day, 10);
      // O pedido é de hoje (para o prazo de 7 dias valer).
      r.horarios.clear();
      retornos.aceitar(r, null);
      r.sugerido = dom;
      await _abrir(
        t,
        ChatPage(
          conversa: conversas.conversas.firstWhere(
            (c) => c.nome == 'Luiza Souza',
          ),
        ),
      );
      await t.scrollUntilVisible(
        find.text('Confirmar horário'),
        200,
        scrollable: _lista,
      );
      expect(find.text('Luiza sugeriu outro horário'), findsOneWidget);
      expect(find.text(quandoRetorno(dom)), findsOneWidget);
      expect(find.text('Escolher outro'), findsOneWidget);
      await t.drag(_lista, const Offset(0, -200));
      await t.pumpAndSettle();
      await t.tap(find.text('Confirmar horário'));
      await t.pumpAndSettle();
      expect(r.marcadoPara, dom);
    });

    testWidgets('C244: remarcar pelo chat aberto no card da Atividade', (
      t,
    ) async {
      final r = retornos.pedir(_pedido())!;
      final daqui3 = DateTime.now().add(const Duration(days: 3));
      retornos.aceitar(r, DateTime(daqui3.year, daqui3.month, daqui3.day, 14));
      // O prazo conta do pedido: hoje.
      await _abrir(t, const AtividadePage());
      // C253 · RN-207: o card da Atividade não tem "Remarcar"; abre o chat.
      expect(find.text('Remarcar'), findsNothing);
      await t.scrollUntilVisible(
        find.text('Retorno · sem custo'),
        200,
        scrollable: _lista,
      );
      await t.tap(find.text('Retorno · sem custo'));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(
        find.text('Remarcar'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await t.tap(find.text('Remarcar'));
      await t.pumpAndSettle();
      expect(find.text('Remarcar retorno'), findsOneWidget);
      expect(
        find.textContaining('Dá para remarcar uma vez, até 12 horas antes.'),
        findsOneWidget,
      );
      expect(find.text('A Luiza escolhe a hora e confirma.'), findsOneWidget);
      await t.tap(find.text('${_amanha().day}').first);
      await t.tap(find.text('Manhã'));
      await t.pump();
      await t.tap(find.text('Pedir para remarcar'));
      await t.pumpAndSettle();
      expect(r.remarcacao, isNotNull);
      expect(r.remarcouCliente, isTrue);
      expect(find.text('Remarcar'), findsNothing);
    });
  });
}

DateTime _amanha() => DateTime.now().add(const Duration(days: 1));
