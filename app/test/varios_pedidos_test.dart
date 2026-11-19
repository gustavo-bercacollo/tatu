import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/home_page.dart';

/// RN-90: o cliente pode ter vários profissionais ao mesmo tempo; todos
/// ficam em "Em andamento".

PedidoAndamento _pedido(String servico, String profissao, String nome) =>
    PedidoAndamento(
      servico: servico,
      profissao: profissao,
      profissional: nome,
      nota: '4,8',
      endereco: 'Rua das Flores, 120',
      valor: '',
      pagamento: '',
      etapasFeitas: 1,
      descricao: servico,
    );

Future<void> _abrirAtividade(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
  );
  await t.tap(find.text('Atividade'));
  await t.pumpAndSettle();
}

void main() {
  setUp(pedidos.restaurar);
  tearDown(pedidos.restaurar);

  test('aceitar outro profissional não tira o anterior', () {
    expect(pedidos.andamentos, hasLength(1));
    pedidos.aceitar(_pedido('Eletricista', 'Eletricista', 'Rafael Lima'));
    pedidos.aceitar(_pedido('Pintor', 'Pintor', 'Marcos Dias'));
    expect(
      pedidos.andamentos.map((p) => p.profissional),
      ['Marcos Dias', 'Rafael Lima', 'Luiza Souza'],
    );
    // A busca do eletricista acabou: alguém aceitou.
    expect(pedidos.buscas, isEmpty);

    // Abrir um não tira os outros.
    pedidos.abrir(pedidos.doProfissional('Luiza Souza')!);
    expect(pedidos.andamento?.profissional, 'Luiza Souza');
    expect(pedidos.andamentos, hasLength(3));

    // Cancelar o aberto deixa os outros.
    pedidos.cancelarAndamento();
    expect(pedidos.andamentos, hasLength(2));
    expect(pedidos.doProfissional('Luiza Souza'), isNull);
  });

  test('cada pedido sem ninguém tem a sua busca', () {
    pedidos.buscarEmSegundoPlano(
      BuscaSegundoPlano(servico: 'Pintor', endereco: 'Rua das Flores, 120'),
    );
    expect(pedidos.buscas.map((b) => b.servico), ['Pintor', 'Eletricista']);
    // "Tentar de novo" na mesma busca não duplica.
    pedidos.buscarEmSegundoPlano(
      BuscaSegundoPlano(servico: 'Pintor', endereco: 'Rua das Flores, 120'),
    );
    expect(pedidos.buscas, hasLength(2));
    pedidos.cancelarBusca(pedidos.buscas.last);
    expect(pedidos.buscas.single.servico, 'Pintor');
  });

  testWidgets('Atividade mostra todos os pedidos e buscas', (t) async {
    pedidos.aceitar(_pedido('Eletricista', 'Eletricista', 'Rafael Lima'));
    pedidos.buscarEmSegundoPlano(
      BuscaSegundoPlano(
        servico: 'Pintor',
        endereco: 'Rua das Flores, 120',
        descricao: 'parede da sala',
      ),
    );
    await _abrirAtividade(t);
    expect(find.text('Rafael Lima'), findsOneWidget);
    expect(find.text('Luiza Souza'), findsOneWidget);
    expect(find.text('parede da sala'), findsOneWidget);

    // Tocar no da Luiza abre o pedido dela.
    await t.tap(find.text('Luiza Souza'));
    await t.pumpAndSettle();
    expect(pedidos.andamento?.profissional, 'Luiza Souza');
    expect(find.textContaining('Chega em'), findsOneWidget);
  });
}
