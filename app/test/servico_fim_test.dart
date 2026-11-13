import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/cliente/atividade/servico_finalizado_page.dart';
import 'package:tatu/features/profissional/chamado/toque_chamado.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';

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

  testWidgets('Concluir serviço cobra o cliente e volta à Home', (t) async {
    await _emAndamento(t);
    expect(find.text('Ao concluir, a Ana é cobrada automaticamente.'),
        findsOneWidget);
    await t.tap(find.text('Concluir serviço'));
    await t.pumpAndSettle();
    expect(find.text('Serviço concluído'), findsOneWidget);
    expect(find.text('Você está offline'), findsOneWidget);
    expect(profissional.visitas, [false]);
    await t.pump(const Duration(seconds: 4)); // aviso some
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
    await _abrir(
      t,
      ServicoFinalizadoPage(pedido: PedidosRepo().concluidos.first),
    );
    expect(find.text('Serviço concluído'), findsOneWidget);
    expect(find.text('R\$ 190,00 cobrado no Visa 4242'), findsOneWidget);
    expect(find.text('nº 000482'), findsOneWidget);
    expect(find.text('Avaliar a Luiza'), findsOneWidget);
    await t.tap(find.text('Algo errado? Avise em até 24h'));
    await t.pumpAndSettle();
    expect(find.text('O que deu errado?'), findsOneWidget);
    await t.tap(find.text('Cobrou diferente do combinado'));
    await t.pump();
    await t.tap(find.text('Enviar'));
    await t.pumpAndSettle();
    expect(find.text('Recebemos sua contestação'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
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
