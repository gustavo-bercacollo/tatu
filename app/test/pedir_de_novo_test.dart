import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/cliente/atividade/pedido_concluido_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/chamado/novo_chamado_page.dart';
import 'package:tatu/features/profissional/chamado/toque_chamado.dart';

/// "Pedir de novo" × mensagem no chat depois do serviço (RN-175 a RN-182).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
  await t.pumpAndSettle();
}

Conversa _de(String nome) =>
    conversas.conversas.firstWhere((c) => c.nome == nome);

Finder get _lista => find
    .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
    .first;

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in ['400', '500', '600', '700']) {
    f.addFont(rootBundle.load('assets/fonts/Inter-$p.ttf'));
  }
  await f.load();
}

void main() {
  setUpAll(_carregarInter);
  ToqueChamado.ativo = false;
  setUp(() {
    conversas.restaurar();
    conversasProfissional.restaurar();
    pagamentos.restaurar();
    pedidos.restaurar();
    profissional.demo();
    atendimentoProfissional.restaurar();
  });

  testWidgets('RN-180: chat de serviço concluído mostra "Pedir de novo"', (
    t,
  ) async {
    await _abrir(t, ChatPage(conversa: _de('Marcos Dias')));
    expect(find.text('Precisa de um novo serviço?'), findsOneWidget);
    await t.tap(find.text('Pedir de novo'));
    await t.pumpAndSettle();
    // RN-176: já preenchido; offline, só "Chamar qualquer".
    expect(find.text('Pintor · Parede da sala'), findsOneWidget);
    expect(find.text('Offline agora'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Chamar qualquer pintor'),
      findsOneWidget,
    );
  });

  testWidgets('RN-176: "Pedir de novo" no detalhe do concluído', (t) async {
    await _abrir(t, PedidoConcluidoPage(pedido: pedidos.concluidos.first));
    await t.tap(find.text('Pedir de novo'));
    await t.pumpAndSettle();
    expect(find.text('Encanador · Vazamento na pia'), findsOneWidget);
    expect(find.text('Chamar a Luiza'), findsNWidgets(2));
  });

  testWidgets('RN-180: com valor em aberto não mostra a dica', (t) async {
    await _abrir(t, ChatPage(conversa: _de('Rafael Lima')));
    expect(find.text('Precisa de um novo serviço?'), findsNothing);
  });

  testWidgets('RN-181: novo valor confirmado vira serviço na Atividade', (
    t,
  ) async {
    final antes = pedidos.andamentos.length;
    await _abrir(t, ChatPage(conversa: _de('Rafael Lima')));
    await t.scrollUntilVisible(find.text('Confirmar valor'), 200,
        scrollable: _lista);
    await t.drag(_lista, const Offset(0, -400));
    await t.pumpAndSettle();
    expect(find.text('Novo serviço · troca do quadro de luz'), findsOneWidget);
    await t.tap(find.text('Confirmar valor'));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('Ele aparece na sua Atividade.'),
      200,
      scrollable: _lista,
    );
    expect(
      find.text('Novo serviço iniciado pelo chat · R\$ 1.200,00'),
      findsOneWidget,
    );
    expect(_de('Rafael Lima').emAndamento, isTrue);
    expect(pedidos.andamentos.length, antes + 1);
    expect(pedidos.doProfissional('Rafael Lima')?.descricao,
        'troca do quadro de luz');
  });

  test('RN-179: aceito pela mesma pessoa, a conversa ganha "Novo pedido"', () {
    final c = conversas.comecar(
      nome: 'Marcos Dias',
      profissao: 'Pintor',
      feminino: false,
      servico: 'Pintor',
      rua: 'Rua das Flores, 120',
      descricao: 'Parede da sala',
    );
    expect(c, same(_de('Marcos Dias')));
    expect(c.emAndamento, isTrue);
    expect(
      c.mensagens.any(
        (m) => m.divisor == 'Novo pedido · ${diaMes(clock.now())} · Parede da sala',
      ),
      isTrue,
    );
    // RN-179: segue o fluxo normal: o valor chega para confirmar.
    expect(c.valor?.situacao, SituacaoValor.aguardandoVoce);
    expect(c.valor?.novo, isFalse);
    expect(conversas.conversas.first, same(c));
  });

  testWidgets('RN-178: novo chamado de "Pedir de novo"', (t) async {
    await _abrir(t, const NovoChamadoPage(chamado: chamadoPediuDeNovo));
    expect(find.text('Pediu você de novo · atendeu a Ana em 12 nov'),
        findsOneWidget);
    expect(find.text('Só para você por 2 min. Depois vai para outros.'),
        findsOneWidget);
    // RN-177: 2 minutos para aceitar.
    expect(find.text('2:00'), findsOneWidget);
    await t.pump(const Duration(seconds: 39));
    expect(find.text('1:21'), findsOneWidget);
    await t.tap(find.text('Recusar'));
    await t.pumpAndSettle();
  });

  testWidgets('Chamado normal não tem a etiqueta', (t) async {
    await _abrir(t, const NovoChamadoPage());
    expect(find.textContaining('Pediu você de novo'), findsNothing);
    expect(find.text('30s'), findsOneWidget);
    await t.tap(find.text('Recusar'));
    await t.pumpAndSettle();
  });

  testWidgets('RN-179: chat do profissional mostra o divisor', (t) async {
    await _abrir(t, const ChatProfissionalPage(chamado: chamadoPediuDeNovo));
    expect(find.text('Serviço concluído · R\$ 190,00 · 12 nov'), findsOneWidget);
    expect(
      find.text(
        'Novo pedido · ${diaMes(clock.now())} · Chuveiro pingando sem parar',
      ),
      findsOneWidget,
    );
    expect(find.text('Oi, Ana! Aceitei, já te mando o valor.'), findsOneWidget);
  });

  testWidgets('RN-181: profissional envia novo valor e espera confirmar', (
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
    await t.tap(find.text('Enviar novo valor'));
    await t.pumpAndSettle();
    expect(find.text('O que vai ser feito'), findsOneWidget);
    expect(find.text('Valor 1 de 3'), findsNothing);
    await t.enterText(find.byType(TextField).last, '150');
    await t.pump();
    // Sem dizer o que é, não envia.
    final enviar = find.widgetWithText(FilledButton, 'Enviar para Júlia');
    expect(t.widget<FilledButton>(enviar).onPressed, isNull);
    await t.enterText(
      find.widgetWithText(TextField, 'Ex.: troca de registro'),
      'troca de registro',
    );
    await t.pump();
    await t.tap(enviar);
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('Só vira serviço quando a Júlia confirmar.'),
      200,
      scrollable: _lista,
    );
    expect(find.text('Novo valor'), findsOneWidget);
    expect(find.text('Aguardando a Júlia confirmar'), findsOneWidget);
    expect(find.text('Só vira serviço quando a Júlia confirmar.'),
        findsOneWidget);
    expect(atendimentoProfissional.ativo, isFalse);

    // Protótipo: a cliente confirma.
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('Novo serviço iniciado pelo chat · R\$ 150,00'),
      200,
      scrollable: _lista,
    );
    expect(atendimentoProfissional.ativo, isTrue);
  });
}
