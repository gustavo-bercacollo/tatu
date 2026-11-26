import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/plano_fixo.dart' show diaMes;
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/data/retorno_acoes.dart';
import 'package:tatu/features/cliente/atividade/pedido_concluido_page.dart';
import 'package:tatu/features/profissional/atividade/ganhos_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';

/// Algo errado e retorno (RN-40, RN-45 a RN-49, RN-107, RN-108,
/// RN-183 a RN-196).

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

PedidoRetorno _pedido({
  String servico = '#TT-1',
  String profissional = 'Luiza Vilela',
  DateTime? em,
  double valor = 150,
}) => PedidoRetorno(
  servico: servico,
  servicoNome: 'Encanador',
  descricaoServico: 'Vazamento na pia',
  diaServico: '04 nov',
  profissional: profissional,
  profissionalFeminino: true,
  cliente: 'Ana Martins',
  clienteFeminina: true,
  valorServico: valor,
  descricao: 'A pia voltou a vazar no mesmo cano.',
  fotos: [FotoProva(tiradaEm: em ?? DateTime(2026, 11, 24))],
  pedidoEm: em ?? DateTime(2026, 11, 24, 21),
  retido: false,
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
    pagamentos.restaurar();
    conta.restaurar();
    canalTatu.restaurar();
    profissional
      ..restaurar()
      ..demo();
  });

  group('RN-183: prazo de retorno', () {
    test('vem da coluna Retorno do catálogo (30 ou 90 dias)', () {
      expect(catalogoServicos.porNome('Encanador')!.retornoDias, 90);
      expect(catalogoServicos.porNome('Diarista')!.retornoDias, 30);
      expect(RegrasRetorno.prazoDias('Diarista'), 30);
      // Na dúvida, 90.
      expect(RegrasRetorno.prazoDias('Profissão que não existe'), 90);
    });

    test('conta da conclusão; o cliente vê só a data', () {
      final ate = RegrasRetorno.retornoAte(
        'Encanador',
        DateTime(2026, 11, 4, 15),
      );
      expect(ate, DateTime(2027, 2, 2, 15));
      expect(diaMes(ate), '2 fev');
    });

    test('RN-45: 24 horas de pagamento protegido', () {
      final c = DateTime(2026, 11, 24, 14, 20);
      expect(RegrasRetorno.protegidoAgora(c, DateTime(2026, 11, 25, 14)), isTrue);
      expect(
        RegrasRetorno.protegidoAgora(c, DateTime(2026, 11, 25, 14, 21)),
        isFalse,
      );
    });
  });

  group('RN-184 a RN-189: pedido e resposta', () {
    test('um pedido por serviço', () {
      expect(retornos.pedir(_pedido()), isNotNull);
      expect(retornos.pedir(_pedido()), isNull);
    });

    test('aceitar marca em até 7 dias; recusar exige motivo', () {
      final hoje = DateTime(2026, 11, 24);
      final r = retornos.pedir(_pedido())!;
      expect(
        retornos.aceitar(r, hoje.add(const Duration(days: 8)), agora: hoje),
        isFalse,
      );
      expect(retornos.recusar(r, '  '), isFalse);
      expect(
        retornos.aceitar(r, DateTime(2026, 11, 28, 14), agora: hoje),
        isTrue,
      );
      expect(r.situacao, SituacaoRetorno.aceito);
      // RN-187: começa com o código na porta.
      expect(retornos.digitarCodigo(r, '0000'), r.codigo == '0000');
      expect(retornos.digitarCodigo(r, r.codigo), r.codigo != '0000');
      expect(r.situacao, SituacaoRetorno.feito);
    });

    test('RN-188: sem resposta em 48 h, resolve sozinho e conta falta', () {
      final r = retornos.pedir(_pedido(em: DateTime(2026, 11, 20)))!;
      final faltas = <String>[];
      retornos.conferirPrazos(
        agora: DateTime(2026, 11, 22, 1),
        presos: (_) => 150,
        falta: faltas.add,
      );
      expect(r.situacao, SituacaoRetorno.resolvidoAutomatico);
      expect(r.falha, FalhaProfissional.naoRespondeu);
      expect(r.resolucao, ResolucaoAutomatica.devolucao);
      expect(faltas, ['Luiza Vilela']);
    });

    test('RN-188: sem saldo preso, o Tatu paga outro profissional', () {
      expect(
        RegrasRetorno.resolucao(valorServico: 150, presos: 40),
        ResolucaoAutomatica.outroProfissional,
      );
      expect(
        RegrasRetorno.resolucao(valorServico: 150, presos: 150),
        ResolucaoAutomatica.devolucao,
      );
    });

    test('RN-188: marcado e não veio (sem código) resolve sozinho', () {
      final r = retornos.pedir(_pedido())!;
      retornos.aceitar(r, DateTime(2026, 11, 28, 14), agora: DateTime(2026, 11, 24));
      retornos.conferirPrazos(agora: DateTime(2026, 11, 28, 17));
      expect(r.falha, FalhaProfissional.naoVeio);
    });

    test('RN-187: sem "Resolveu?" em 48 h, resolvido', () {
      final r = retornos.pedir(_pedido())!;
      retornos.aceitar(r, DateTime(2026, 11, 28, 14), agora: DateTime(2026, 11, 24));
      retornos.feito(r, agora: DateTime(2026, 11, 28, 15));
      retornos.conferirPrazos(agora: DateTime(2026, 11, 30, 16));
      expect(r.situacao, SituacaoRetorno.encerrado);
    });

    test('RN-189: recusa sem escolha em 7 dias encerra', () {
      final r = retornos.pedir(_pedido())!;
      retornos.recusar(r, 'Mau uso depois do serviço', agora: DateTime(2026, 11, 24));
      retornos.conferirPrazos(agora: DateTime(2026, 12, 2));
      expect(r.situacao, SituacaoRetorno.encerrado);
    });

    test('RN-187: cliente ausente: dado como cumprido', () {
      final r = retornos.pedir(_pedido())!;
      retornos.aceitar(r, DateTime(2026, 11, 28, 14), agora: DateTime(2026, 11, 24));
      retornos.clienteAusente(r);
      expect(r.situacao, SituacaoRetorno.cumpridoAusente);
      expect(r.aberto, isFalse);
    });
  });

  group('RN-190 a RN-193: mediação, dinheiro e abuso', () {
    test('uma mediação por serviço', () {
      final r = retornos.pedir(_pedido())!;
      retornos.recusar(r, 'Não é o mesmo problema');
      expect(retornos.mediar(r, MotivoMediacao.contestouRecusa), isTrue);
      retornos.decidir(r, DecisaoMediacao.devolver50);
      expect(retornos.mediar(r, MotivoMediacao.continuouProblema), isFalse);
    });

    test('RN-192: só o serviço volta; o Tatu devolve a comissão', () {
      final d = RegrasRetorno.devolucao(150);
      expect(d.total, 150);
      expect(d.doTatu, closeTo(15, 0.001));
      expect(d.doProfissional, closeTo(135, 0.001));
      expect(RegrasRetorno.devolucao(150, fracao: 0.5).total, 75);
    });

    test('RN-193: 3 faltas em 90 dias pausam a conta', () {
      final hoje = DateTime(2026, 11, 24);
      final f = [
        hoje.subtract(const Duration(days: 80)),
        hoje.subtract(const Duration(days: 10)),
      ];
      expect(RegrasRetorno.pausaPorFaltas(f, hoje), isFalse);
      expect(RegrasRetorno.pausaPorFaltas([...f, hoje], hoje), isTrue);
      expect(
        RegrasRetorno.pausaPorFaltas([
          hoje.subtract(const Duration(days: 120)),
          ...f,
        ], hoje),
        isFalse,
      );
    });

    test('RN-193: 3 "não procede" em 6 meses tiram o retorno mediado', () {
      final hoje = DateTime(2026, 11, 24);
      final d = [
        hoje.subtract(const Duration(days: 100)),
        hoje.subtract(const Duration(days: 40)),
        hoje.subtract(const Duration(days: 2)),
      ];
      final ate = RegrasRetorno.semRetornoMediadoAte(d, hoje);
      expect(ate, d.last.add(RegrasRetorno.semRetornoMediado));
      expect(RegrasRetorno.semRetornoMediadoAte(d.take(2).toList(), hoje), isNull);
    });

    test('RN-191: prazo de 3 dias úteis pula o fim de semana', () {
      // Sexta, 27 nov → quarta, 2 dez.
      expect(
        RegrasRetorno.prazoMediacao(DateTime(2026, 11, 27)),
        DateTime(2026, 12, 2),
      );
    });

    test('decisão: falta na recusa derrubada e mensagem no canal', () {
      final r = retornos.pedir(_pedido())!;
      retornos.recusar(r, 'Não é o mesmo problema');
      retornos.mediar(r, MotivoMediacao.contestouRecusa);
      final antes = canalTatu.cliente.mensagens.length;
      decidirRetorno(r, DecisaoMediacao.devolver100);
      expect(r.situacao, SituacaoRetorno.encerrado);
      expect(profissional.faltasRetorno, hasLength(1));
      expect(canalTatu.cliente.mensagens, hasLength(antes + 1));
      expect(canalTatu.cliente.mensagens.last.decisao!.titulo,
          'Devolvemos R\$ 150,00');
      final pro = canalTatu.profissional.mensagens.last;
      expect(pro.decisao!.titulo, 'Devolução de R\$ 150,00');
      expect(pro.decisao!.rodape, 'A recusa sem motivo contou 1 falta');
    });

    test('"não procede" conta para o cliente, não para o profissional', () {
      final r = retornos.pedir(_pedido())!;
      retornos.feito(r);
      retornos.resolveu(r, false);
      decidirRetorno(r, DecisaoMediacao.naoProcede);
      expect(retornos.naoProcedeCliente, hasLength(1));
      expect(profissional.faltasRetorno, isEmpty);
    });

    test('RN-192: sem saldo vira dívida no CPF e bloqueia chamados', () {
      final r = retornos.pedir(_pedido(valor: 900))!;
      retornos.recusar(r, 'Não consigo ir até lá');
      retornos.mediar(r, MotivoMediacao.contestouRecusa);
      decidirRetorno(r, DecisaoMediacao.devolver100);
      expect(profissional.comDivida, isTrue);
      expect(profissional.pausada, isTrue);
      expect(retornos.cpfComDivida(profissional.cpf), isTrue);
    });
  });

  test('RN-194: pacote de provas guardado ao confirmar a conclusão', () {
    retornos.fotoServicoPronto = FotoProva(tiradaEm: clock.now());
    pedidos.codigoDigitado();
    pedidos.profissionalConcluiu();
    final feito = pedidos.confirmarConclusao()!;
    final p = retornos.provas[feito.numero]!;
    expect(p.codigoPorta, isNotNull);
    expect(p.fotos, hasLength(1));
    expect(p.chat, isNotEmpty);
  });

  testWidgets('C224 · RN-183: depois de 24 h, "O problema voltou?"', (t) async {
    await _abrir(t, PedidoConcluidoPage(pedido: pedidos.concluidos.first));
    expect(find.text('O problema voltou?'), findsOneWidget);
    expect(find.text('Peça um retorno sem custo até 02 fev.'), findsOneWidget);
    await t.tap(find.text('O problema voltou?'));
    await t.pumpAndSettle();
    expect(find.text('O que voltou a dar problema?'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'A pia voltou a vazar.');
    await t.pump();
    await t.tap(find.bySemanticsLabel('Tirar foto'));
    await t.pumpAndSettle();
    // RN-184: a câmera do app (sem galeria).
    expect(find.text('Foto do problema'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Tirar foto'));
    await t.pumpAndSettle();
    // RN-213: passo 2 de 2: até 3 horários.
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(find.text('2 de 2'), findsOneWidget);
    expect(find.text('Quando você pode receber a Luiza?'), findsOneWidget);
    await t.tap(find.bySemanticsLabel(RegExp(r'^Amanhã à tarde')));
    await t.pump();
    expect(find.text('1 de 3 · Amanhã à tarde'), findsOneWidget);
    await t.tap(find.text('Pedir retorno'));
    await t.pumpAndSettle();
    final r = retornos.doServico('#TT-48213')!;
    expect(r.horarios, hasLength(1));
    expect(r.fotos, hasLength(1));
    expect(r.retido, isFalse);
    await t.scrollUntilVisible(find.text('Pedido de retorno'), 200,
        scrollable: _lista);
    // C250 · RN-231: card único, pílula "Aguardando" e até quando ela responde.
    expect(find.text('Aguardando'), findsOneWidget);
    expect(find.textContaining('A Luiza responde até'), findsOneWidget);
    expect(find.textContaining('Você pode:'), findsOneWidget);
  });

  testWidgets('C223 · RN-45: nas primeiras 24 h, "Pagamento protegido"', (
    t,
  ) async {
    final agora = clock.now();
    final p = PedidoConcluido(
      servico: 'Encanador',
      profissao: 'Encanadora',
      profissional: 'Luiza Souza',
      descricao: 'Vazamento na pia',
      endereco: 'Rua das Flores, 120',
      pagamento: 'Visa 4242',
      valor: r'R$ 150,00',
      dia: 'hoje',
      hora: '14:20',
      mes: 'Novembro',
      numero: '#TT-9',
      concluidoEm: agora,
    );
    await _abrir(t, PedidoConcluidoPage(pedido: p));
    expect(find.text('Pagamento protegido por 24h'), findsOneWidget);
    await t.tap(find.text('Pagamento protegido por 24h'));
    await t.pumpAndSettle();
    expect(find.text('O que deu errado?'), findsOneWidget);
    expect(
      find.textContaining('Primeiro a Luiza pode voltar, sem custo.'),
      findsOneWidget,
    );
    await t.tap(find.text('Enviar'));
    await t.pumpAndSettle();
    // RN-46: pedido nas primeiras 24 horas: valor retido.
    expect(retornos.doServico('#TT-9')!.retido, isTrue);
  });

  testWidgets('P152 a P154: profissional recusa só com motivo e aceita', (
    t,
  ) async {
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
      find.textContaining('Sem custo e sem taxa'),
      200,
      scrollable: _lista,
    );
    expect(find.text('Aceitar retorno'), findsOneWidget);
    expect(find.textContaining('Responda até'), findsOneWidget);
    expect(find.text('É outro problema · enviar valor'), findsOneWidget);
    await t.ensureVisible(find.text('Recusar'));
    await t.tap(find.text('Recusar'));
    await t.pumpAndSettle();
    expect(find.text('Por que vai recusar?'), findsOneWidget);
    final recusar = find.widgetWithText(FilledButton, 'Recusar retorno');
    expect(t.widget<FilledButton>(recusar).onPressed, isNull);
    Navigator.of(t.element(recusar)).pop();
    await t.pumpAndSettle();

    await t.tap(find.text('Aceitar retorno'));
    await t.pumpAndSettle();
    // P157 · RN-213: escolhe uma das opções do cliente e a hora.
    expect(find.text('Quando você vai?'), findsOneWidget);
    await t.tap(find.text('9h'));
    await t.pump();
    await t.tap(find.textContaining('Aceitar · '));
    await t.pumpAndSettle();
    final r = retornos.doCliente('Júlia Costa')!;
    expect(r.situacao, SituacaoRetorno.aceito);
    await t.scrollUntilVisible(find.text('Retorno aceito · sem custo'), 200,
        scrollable: _lista);
    expect(find.textContaining('peça o código à Júlia'), findsOneWidget);
  });

  testWidgets('P158 · RN-185: Ganhos mostra o repasse preso', (t) async {
    await _abrir(t, const GanhosPage());
    expect(find.text('R\$ 120,00 presos'), findsOneWidget);
    expect(
      find.text('Retorno da Júlia aberto · solta ao resolver'),
      findsOneWidget,
    );
  });
}
