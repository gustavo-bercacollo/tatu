import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/avaliacoes_de_clientes.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/prazos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/cliente/atividade/servico_finalizado_page.dart';
import 'package:tatu/features/profissional/chamado/toque_chamado.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';
import 'package:tatu/features/profissional/servico/conclusao_page.dart';

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(430, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

/// Home → Em andamento (para voltar à Home ao encerrar).
Future<void> _emAndamento(WidgetTester t) async {
  await _abrir(t, const HomeProfissionalPage());
  Navigator.of(t.element(find.byType(HomeProfissionalPage))).push(
    MaterialPageRoute(
      builder: (_) => EmAndamentoPage(inicio: DateTime(2026, 11, 10, 14, 32)),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  ToqueChamado.ativo = false;
  setUp(() {
    profissional.demo();
    navegacao.restaurar();
    atendimentoProfissional.restaurar();
  });

  testWidgets('RN-31/RN-171: concluir não cobra; espera a Ana confirmar', (
    t,
  ) async {
    ConclusaoServicoPage.clienteConfirmaEm = null;
    addTearDown(
      () => ConclusaoServicoPage.clienteConfirmaEm = const Duration(seconds: 6),
    );
    Prazos.aceleracao = 1;
    addTearDown(() => Prazos.aceleracao = 20);
    await _emAndamento(t);
    expect(find.text('Ao concluir, a Ana confirma e é cobrada.'),
        findsOneWidget);
    await t.tap(find.text('Concluir serviço'));
    await t.pumpAndSettle();
    // P57 · RN-40: foto obrigatória do serviço pronto.
    await t.tap(find.bySemanticsLabel('Tirar foto'));
    await t.pumpAndSettle();
    expect(find.text('Serviço concluído'), findsOneWidget);
    expect(find.text('Aguardando a Ana confirmar'), findsOneWidget);
    // Contagem das 2 horas (h:mm).
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && RegExp(r'^[12]:\d\d$').hasMatch(w.data ?? ''),
      ),
      findsOneWidget,
    );
    expect(find.text('Ficar online'), findsOneWidget);
    expect(profissional.visitas, [false]);
    // RN-31: 2 horas sem resposta, confirma sozinho.
    await t.pump(const Duration(hours: 2));
    await t.pump();
    expect(find.text('Ana confirmou'), findsOneWidget);
    expect(find.text(r'R$ 135,00'), findsOneWidget);
    expect(find.text('Avaliar a Ana'), findsOneWidget);
    // RN-41: o profissional avalia a cliente.
    await t.tap(find.text('Avaliar a Ana'));
    await t.pumpAndSettle();
    expect(find.text('Pagamento recebido'), findsOneWidget);
    expect(find.text('Como foi com a Ana?'), findsOneWidget);
    final enviar = find.widgetWithText(FilledButton, 'Enviar avaliação');
    expect(t.widget<FilledButton>(enviar).onPressed, isNull); // sem nota
    await t.tap(find.bySemanticsLabel(RegExp('5 estrela')).first);
    await t.tap(find.text('Pagou rápido'));
    await t.pump();
    await t.tap(enviar);
    await t.pumpAndSettle();
    final a = avaliacoesDeClientes.enviadas.single;
    expect(a.cliente, 'Ana Julia');
    expect(a.nota, 5);
    expect(a.elogios, ['Pagou rápido']);
    expect(find.text('Avaliação enviada'), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
  });

  testWidgets('RN-171: aguardando, já pode ficar online', (t) async {
    ConclusaoServicoPage.clienteConfirmaEm = null;
    addTearDown(
      () => ConclusaoServicoPage.clienteConfirmaEm = const Duration(seconds: 6),
    );
    await _emAndamento(t);
    await t.tap(find.text('Concluir serviço'));
    await t.pumpAndSettle();
    // P57 · RN-40: foto obrigatória do serviço pronto.
    await t.tap(find.bySemanticsLabel('Tirar foto'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ficar online'));
    await t.pumpAndSettle();
    expect(profissional.online, isTrue);
  });

  testWidgets('Só a visita: folha com aviso e registro no histórico',
      (t) async {
    await _emAndamento(t);
    await t.tap(find.text('Encerrar e cobrar só a visita'));
    await t.pumpAndSettle();
    expect(find.text('Encerrar e cobrar só a visita?'), findsOneWidget);
    expect(find.text('Muitas visitas sem serviço pausam sua conta.'),
        findsOneWidget);
    await t.tap(find.text('Voltar'));
    await t.pumpAndSettle();
    expect(profissional.visitas, isEmpty);

    await t.tap(find.text('Encerrar e cobrar só a visita'));
    await t.pumpAndSettle();
    await t.tap(find.text('Encerrar e cobrar R\$ 40'));
    await t.pumpAndSettle();
    expect(find.text('Visita cobrada'), findsOneWidget);
    expect(profissional.visitas, [true]);
    await t.pump(const Duration(seconds: 4));
  });

  testWidgets('Conta pausada: aviso vermelho e não fica online', (t) async {
    profissional.pausarParaDemo();
    await _abrir(t, const HomeProfissionalPage());
    expect(find.text('Conta pausada'), findsOneWidget);
    expect(
      find.text('5 das últimas 8 visitas terminaram sem serviço. '
          'Fale com o suporte para voltar.'),
      findsOneWidget,
    );
    await t.tap(find.text('Ficar online'));
    await t.pump();
    expect(profissional.online, isFalse);
    await t.tap(find.text('Falar com o suporte'));
    await t.pumpAndSettle();
    expect(find.text('Sobre o que é?'), findsOneWidget);
  });

  testWidgets('Cliente: serviço concluído e contestação', (t) async {
    retornos.restaurar();
    await _abrir(
      t,
      ServicoFinalizadoPage(pedido: PedidosRepo().concluidos.first),
    );
    expect(find.text('Serviço concluído'), findsOneWidget);
    expect(find.text('R\$ 190,00 cobrado no Visa 4242'), findsOneWidget);
    expect(find.text('nº 000482'), findsOneWidget);
    expect(find.text('Avaliar a Luiza'), findsOneWidget);
    await t.tap(find.text('Algo errado? Avise o Tatu'));
    await t.pumpAndSettle();
    expect(find.text('O que deu errado?'), findsOneWidget);
    await t.tap(find.text('Cobrou diferente do combinado'));
    await t.pump();
    await t.tap(find.text('Enviar'));
    await t.pumpAndSettle();
    // RN-45: fluxo único: vira o pedido de retorno e abre o chat.
    expect(find.text('Pedido de retorno'), findsOneWidget);
    final r = retornos.comProfissional('Luiza Souza')!;
    expect(r.motivo, 'Cobrou diferente do combinado');
    expect(r.situacao, SituacaoRetorno.aguardando);
  });

  testWidgets('Cliente: serviço não realizado cobra só a visita', (t) async {
    await _abrir(
      t,
      ServicoFinalizadoPage(
        pedido: PedidosRepo().concluidos.first,
        realizado: false,
      ),
    );
    expect(find.text('Serviço não realizado'), findsOneWidget);
    expect(find.text('Só a visita foi cobrada: R\$ 40,00'), findsOneWidget);
    expect(find.text('A Luiza encerrou sem fazer o serviço.'), findsOneWidget);
    expect(find.text('Os R\$ 150 do serviço não foram cobrados.'),
        findsOneWidget);
    expect(find.text('Chamar outro encanador'), findsOneWidget);
  });
}
