import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/encontrados.dart';
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

    // Abrir um não tira os outros nem muda a ordem.
    pedidos.abrir(pedidos.doProfissional('Rafael Lima')!);
    expect(pedidos.andamento?.profissional, 'Rafael Lima');
    expect(
      pedidos.andamentos.map((p) => p.profissional),
      ['Marcos Dias', 'Rafael Lima', 'Luiza Souza'],
    );

    // Cancelar o aberto deixa os outros.
    pedidos.cancelarAndamento();
    expect(pedidos.andamentos, hasLength(2));
    expect(pedidos.doProfissional('Rafael Lima'), isNull);
  });

  test('a mesma profissional aceitando de novo é outro pedido', () {
    pedidos.limpar();
    pedidos.aceitar(_pedido('Encanador', 'Encanadora', 'Luiza Souza'));
    pedidos.aceitar(_pedido('Eletricista', 'Encanadora', 'Luiza Souza'));
    pedidos.aceitar(_pedido('Pintor', 'Encanadora', 'Luiza Souza'));
    expect(
      pedidos.andamentos.map((p) => p.servico),
      ['Pintor', 'Eletricista', 'Encanador'],
    );
    // Abrir um não perde nenhum nem muda a ordem (pilha: o mais novo em
    // cima).
    pedidos.abrir(pedidos.andamentos.last);
    expect(pedidos.andamento?.servico, 'Encanador');
    expect(
      pedidos.andamentos.map((p) => p.servico),
      ['Pintor', 'Eletricista', 'Encanador'],
    );
  });

  test('cada chamada começa a fila em outra pessoa', () {
    reiniciarFila();
    final fila = filaPara(soMulheres: false);
    final nomes = [
      for (var i = 0; i < 3; i++) fila[inicioDaFila() % fila.length].nome,
    ];
    expect(nomes.toSet(), hasLength(3));
    // Pula quem já está atendendo.
    reiniciarFila();
    final i = inicioDaFila(ocupados: {fila.first.nome});
    expect(fila[i % fila.length].nome, isNot(fila.first.nome));
    reiniciarFila();
  });

  test('cada profissional tem a sua conversa; nenhuma some', () {
    conversas.restaurar();
    final antes = conversas.conversas.length;
    final a = conversas.comecar(
      nome: 'Carlos Pereira',
      profissao: 'Eletricista',
      feminino: false,
      servico: 'Eletricista',
      rua: 'Rua A, 1',
    );
    conversas.enviar(a, MensagemChat(texto: 'Pode vir agora?', minha: true));
    conversas.comecar(
      nome: 'Fernanda Lima',
      profissao: 'Pintora',
      feminino: true,
      servico: 'Pintor',
      rua: 'Rua A, 1',
    );
    expect(conversas.conversas, hasLength(antes + 2));
    // A mesma pessoa de novo: continua a conversa, com a mensagem.
    final de = conversas.comecar(
      nome: 'Carlos Pereira',
      profissao: 'Eletricista',
      feminino: false,
      servico: 'Encanador',
      rua: 'Rua A, 1',
    );
    expect(identical(de, a), isTrue);
    expect(de.mensagens.map((m) => m.texto), contains('Pode vir agora?'));
    expect(conversas.conversas, hasLength(antes + 2));
    conversas.restaurar();
  });

  test('cada pedido sem ninguém tem a sua busca', () {
    pedidos.buscarEmSegundoPlano(
      BuscaSegundoPlano(servico: 'Pintor', endereco: 'Rua das Flores, 120'),
    );
    expect(pedidos.buscas.map((b) => b.servico), ['Pintor', 'Eletricista']);
    // Outro pedido do mesmo serviço é outra busca.
    pedidos.buscarEmSegundoPlano(
      BuscaSegundoPlano(servico: 'Pintor', endereco: 'Rua das Flores, 120'),
    );
    expect(pedidos.buscas, hasLength(3));
    pedidos.cancelarBusca(pedidos.buscas.last);
    expect(pedidos.buscas.map((b) => b.servico), ['Pintor', 'Pintor']);
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
