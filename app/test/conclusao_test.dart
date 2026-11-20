import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/codigo_porta.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/prazos.dart';
import 'package:tatu/features/cliente/atividade/avaliar_page.dart';
import 'package:tatu/features/cliente/atividade/contestar_page.dart';
import 'package:tatu/features/cliente/atividade/pedido_andamento_page.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/shared/formatadores.dart';

/// Serviço em andamento (RN-169), vários profissionais (RN-170) e
/// conclusão confirmada pelo cliente (RN-31, RN-171).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

const _marcos = PedidoAndamento(
  servico: 'Eletricista',
  profissao: 'Eletricista',
  profissional: 'Marcos Dias',
  nota: '4,8',
  endereco: 'Rua das Flores, 120',
  valor: r'R$ 120,00',
  pagamento: 'Visa 4242',
  etapasFeitas: 1,
);

/// A Luiza (pedido de exemplo) chegou e digitou o código.
void _trabalhando() {
  pedidos
    ..chegou()
    ..codigoDigitado();
}

void main() {
  setUpAll(() => RegrasCodigo.sorteio = null);
  setUp(() {
    Prazos.aceleracao = 1;
    PedidosRepo.demoCodigo = false;
    PedidosRepo.demoConclusao = false;
    pedidos.restaurar();
  });
  tearDown(() {
    Prazos.aceleracao = 20;
    PedidosRepo.demoCodigo = true;
    PedidosRepo.demoConclusao = true;
    pedidos.restaurar();
  });

  testWidgets('RN-169: depois do código, "A Luiza está trabalhando"', (
    t,
  ) async {
    _trabalhando();
    await _abrir(t, const PedidoAndamentoPage());
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('A Luiza está trabalhando'), findsOneWidget);
    expect(find.text('Visa 4242 · cobrado quando você confirmar'), findsOneWidget);
    expect(find.text('Novo valor?'), findsOneWidget);
    expect(find.text('Cancelar pedido'), findsNothing);
    await t.pump(const Duration(minutes: 25));
    expect(find.text('25 min'), findsOneWidget);
    // Depois de 60 min, horas e minutos.
    await t.pump(const Duration(minutes: 40));
    expect(find.text('1 h 05 min'), findsOneWidget);
  });

  test('RN-169: tempo de serviço em min e depois em h e min', () {
    expect(duracaoTrabalho(0), '0 min');
    expect(duracaoTrabalho(59), '59 min');
    expect(duracaoTrabalho(60), '1 h');
    expect(duracaoTrabalho(65), '1 h 05 min');
    expect(duracaoTrabalho(135), '2 h 15 min');
  });

  test('RN-31: concluir não cobra antes do cliente confirmar', () {
    _trabalhando();
    pedidos.profissionalConcluiu();
    final p = pedidos.andamento!;
    expect(p.aguardandoConfirmacao, isTrue);
    // Nada foi para "Concluídos" (não cobrou).
    expect(pedidos.concluidos.where((c) => c.profissional == 'Luiza Souza'
        && c.dia != '04 nov'), isEmpty);
    expect(pedidos.avisos, contains('A Luiza concluiu o serviço'));
  });

  testWidgets('RN-31: "Sim, confirmar" cobra e abre a avaliação', (t) async {
    _trabalhando();
    final antes = pedidos.concluidos.length;
    await _abrir(t, const PedidoAndamentoPage());
    pedidos.profissionalConcluiu();
    await t.pumpAndSettle();
    expect(find.text('A Luiza concluiu o serviço'), findsOneWidget);
    expect(find.text('Está tudo certo?'), findsOneWidget);
    // RN-172: é uma tela, com a contagem das 2 horas.
    expect(find.text('Serviço concluído'), findsOneWidget);
    expect(find.textContaining('Confirmamos sozinho em'), findsOneWidget);
    await t.tap(find.text('Sim, confirmar'));
    await t.pumpAndSettle();
    expect(find.byType(AvaliarPage), findsOneWidget);
    expect(pedidos.concluidos, hasLength(antes + 1));
    expect(pedidos.andamentos, isEmpty);
    // RN-171: 24 h para contestar a partir da confirmação.
    expect(pedidos.concluidos.first.contestarAte, isNotNull);
  });

  testWidgets('RN-31: 2 horas sem resposta, confirma e cobra sozinho', (
    t,
  ) async {
    _trabalhando();
    final antes = pedidos.concluidos.length;
    await _abrir(t, const PedidoAndamentoPage());
    pedidos.profissionalConcluiu();
    await t.pumpAndSettle();
    expect(find.text('Sim, confirmar'), findsOneWidget);
    await t.pump(Prazos.confirmarConclusao);
    await t.pumpAndSettle();
    expect(pedidos.concluidos, hasLength(antes + 1));
    expect(pedidos.andamentos, isEmpty);
    expect(find.byType(AvaliarPage), findsOneWidget);
  });

  testWidgets('RN-31/RN-45: "Algo errado" retém o valor e contesta', (
    t,
  ) async {
    _trabalhando();
    final antes = pedidos.concluidos.length;
    await _abrir(t, const PedidoAndamentoPage());
    pedidos.profissionalConcluiu();
    await t.pumpAndSettle();
    await t.tap(find.text('Algo errado'));
    await t.pumpAndSettle();
    expect(find.byType(ContestarServicoPage), findsOneWidget);
    expect(pedidos.andamento?.valorRetido, isTrue);
    // Não cobrou, nem depois das 2 horas.
    await t.pump(Prazos.confirmarConclusao);
    expect(pedidos.concluidos, hasLength(antes));
  });

  testWidgets('RN-172: voltar mantém a confirmação na Home e na Atividade', (
    t,
  ) async {
    _trabalhando();
    pedidos.profissionalConcluiu();
    await _abrir(t, const HomeClientePage());
    // Faixa verde na Home.
    expect(find.text('Confirme o serviço da Luiza'), findsOneWidget);
    expect(find.textContaining('confirmamos sozinho em'), findsOneWidget);
    await t.tap(find.text('Confirme o serviço da Luiza'));
    await t.pumpAndSettle();
    expect(find.text('A Luiza concluiu o serviço'), findsOneWidget);
    // Voltar não descarta nada.
    await t.tap(find.byTooltip('Voltar').evaluate().isNotEmpty
        ? find.byTooltip('Voltar')
        : find.bySemanticsLabel('Voltar').first);
    await t.pumpAndSettle();
    expect(find.text('Confirme o serviço da Luiza'), findsOneWidget);
    expect(pedidos.andamento?.aguardandoConfirmacao, isTrue);
    // Card na Atividade abre a mesma tela.
    await t.tap(find.text('Atividade'));
    await t.pumpAndSettle();
    expect(find.text('Aguardando sua confirmação'), findsOneWidget);
    await t.tap(find.text('Aguardando sua confirmação'));
    await t.pumpAndSettle();
    expect(find.text('A Luiza concluiu o serviço'), findsOneWidget);    pedidos.restaurar(); // para o relógio das 2 horas
  });

  testWidgets('RN-169: faixa "está trabalhando" abre a tela do serviço', (
    t,
  ) async {
    _trabalhando();
    await _abrir(t, const HomeClientePage());
    expect(find.text('Luiza está trabalhando'), findsOneWidget);
    await t.tap(find.text('Luiza está trabalhando'));
    await t.pumpAndSettle();
    expect(find.text('A Luiza está trabalhando'), findsOneWidget);
  });

  testWidgets('RN-170: com 2 atendimentos, a faixa abre a Atividade', (
    t,
  ) async {
    _trabalhando();
    pedidos.aceitar(_marcos);
    await _abrir(t, const HomeClientePage());
    expect(find.text('2 profissionais com você'), findsOneWidget);
    expect(
      find.text('Marcos combinando · Luiza trabalhando'),
      findsOneWidget,
    );
    await t.tap(find.text('2 profissionais com você'));
    await t.pumpAndSettle();
    expect(find.text('Atividade'), findsWidgets);
    expect(find.text('Marcos Dias'), findsOneWidget);
    expect(find.text('Luiza Souza'), findsOneWidget);
  });
}
