import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/core/protecao_tela.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/regras_distancia.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/cliente/mensagens/entrega_distancia.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';

/// Entrega à distância (RN-96, RN-99 a RN-106).

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

/// Conversa à distância com a Marina, valor de R$ 250 com sinal de R$ 75
/// já confirmado.
Conversa _marina({DateTime? confirmadoEm}) {
  final c = conversas.comecar(
    nome: 'Marina Reis',
    profissao: 'Designer',
    feminino: true,
    servico: 'Designer',
    rua: 'À distância',
    distancia: true,
  );
  conversas.confirmarValor(c);
  if (confirmadoEm != null) {
    c.entrega = EntregaDistancia(confirmadoEm: confirmadoEm);
  }
  return c;
}

Future<void> _rolar(WidgetTester t, Finder f) => t.scrollUntilVisible(
  f,
  300,
  scrollable: find
      .descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      )
      .first,
);

/// RN-125: na folha "Escolha como entregar", manda um link do site.
Future<void> _entregarLink(WidgetTester t) async {
  await t.enterText(find.byType(TextField).last, 'padariadaana.com.br');
  await t.pump();
  await t.tap(find.widgetWithText(FilledButton, 'Enviar entrega'));
  await t.pumpAndSettle();
}

void main() {
  ProtecaoTela.ativa = false;
  setUpAll(_carregarInter);
  setUp(() {
    conversas.restaurar();
    pagamentos.restaurar();
    profissional.demo();
    atendimentoProfissional.restaurar();
    ProtecaoTela.ligacoes = 0;
  });

  group('RegrasDistancia', () {
    test('RN-102: sinal de até 30%', () {
      expect(RegrasDistancia.sinalMaximo, 0.30);
      expect(RegrasDistancia.sinalDe(250), 75);
    });

    test('RN-99: prévia expira em 24 h', () {
      final em = DateTime(2026, 11, 17, 10);
      expect(
        RegrasDistancia.previaValida(em, em.add(const Duration(hours: 23))),
        isTrue,
      );
      expect(
        RegrasDistancia.previaValida(em, em.add(const Duration(hours: 24))),
        isFalse,
      );
    });

    test('RN-100: aprova sozinha em 48 h', () {
      final em = DateTime(2026, 11, 17, 10);
      expect(
        RegrasDistancia.aprovadaSozinha(em, em.add(const Duration(hours: 47))),
        isFalse,
      );
      expect(
        RegrasDistancia.aprovadaSozinha(em, em.add(const Duration(hours: 48))),
        isTrue,
      );
    });
  });

  group('Conversa à distância', () {
    test('RN-103: confirmar cobra o sinal e começa a entrega', () {
      final c = _marina();
      expect(c.valor?.sinal, 75);
      expect(c.valor?.restante, 175);
      expect(c.entrega?.situacao, SituacaoEntrega.semEntrega);
      expect(
        c.mensagens.last.marcador,
        r'Valor confirmado · sinal de R$ 75 pago',
      );
    });

    test('RN-101: no máximo 2 entregas; ajuste só na 1ª', () {
      final c = _marina();
      conversas.receberEntrega(c);
      expect(c.entrega?.enviadas, 1);
      conversas.pedirReembolso(c, 'Qualidade ruim'); // ainda não pode
      expect(c.entrega?.situacao, SituacaoEntrega.aguardando);
      conversas.pedirAjuste(c, 'Letras maiores');
      expect(c.entrega?.situacao, SituacaoEntrega.ajustePedido);
      conversas.receberEntrega(c);
      conversas.receberEntrega(c); // a 3ª não entra
      expect(c.entrega?.enviadas, RegrasDistancia.maxEntregas);
      conversas.pedirAjuste(c, 'De novo'); // depois da 2ª não pode
      expect(c.entrega?.situacao, SituacaoEntrega.aguardando);
      conversas.pedirReembolso(c, 'Qualidade ruim');
      expect(c.entrega?.situacao, SituacaoEntrega.reembolsoEmAnalise);
    });

    test('RN-100: sem resposta em 48 h, aprova sozinha', () {
      final c = _marina();
      final em = clock.now().subtract(const Duration(hours: 49));
      conversas.receberEntrega(c, em: em);
      expect(conversas.aprovarSozinhas(), isTrue);
      expect(c.entrega?.situacao, SituacaoEntrega.aprovada);
    });

    test('RN-105: prazo acabou sem entrega', () {
      final c = _marina(
        confirmadoEm: clock.now().subtract(const Duration(days: 8)),
      );
      expect(conversas.semEntregaNoPrazo(c), isTrue);
      conversas.esperarMais(c);
      expect(conversas.semEntregaNoPrazo(c), isFalse);
      conversas.pedirSinalDeVolta(c);
      expect(c.entrega?.situacao, SituacaoEntrega.sinalDeVoltaPedido);
    });
  });

  testWidgets('RN-102: o cliente vê sinal e restante antes de confirmar', (
    t,
  ) async {
    final c = conversas.comecar(
      nome: 'Marina Reis',
      profissao: 'Designer',
      feminino: true,
      servico: 'Designer',
      rua: 'À distância',
      distancia: true,
    );
    await _abrir(t, ChatPage(conversa: c));
    await _rolar(t, find.text('Confirmar valor'));
    expect(find.text('Sinal · cobrado agora'), findsOneWidget);
    expect(find.text(r'R$ 75,00'), findsOneWidget);
    expect(find.text('Restante · quando aprovar'), findsOneWidget);
    expect(find.text(r'R$ 175,00'), findsOneWidget);
    expect(find.text('O sinal paga o tempo da Marina.'), findsOneWidget);
  });

  testWidgets('RN-99: prévia abre protegida e expira', (t) async {
    final c = _marina();
    conversas.receberPrevia(c);
    conversas.receberPrevia(
      c,
      em: clock.now().subtract(const Duration(hours: 25)),
    );
    await _abrir(t, ChatPage(conversa: c));
    expect(find.text('Só para ver · expira em 24h'), findsOneWidget);
    expect(find.text('Vista · expirada'), findsOneWidget);
    await t.tap(find.text('Só para ver · expira em 24h'));
    await t.pumpAndSettle();
    expect(find.byType(PreviaProtegidaPage), findsOneWidget);
    expect(find.text('Prévia da Marina'), findsOneWidget);
    expect(find.text('Print e gravação de tela ficam pretos.'), findsOneWidget);
    expect(ProtecaoTela.ligacoes, 1);
    await t.tap(find.text('Voltar ao chat'));
    await t.pumpAndSettle();
    // A expirada não abre.
    await t.tap(find.text('Vista · expirada'));
    await t.pumpAndSettle();
    expect(find.byType(PreviaProtegidaPage), findsNothing);
  });

  testWidgets('RN-100/RN-101/RN-104: ajuste, 2ª entrega e reembolso', (
    t,
  ) async {
    final c = _marina();
    conversas.receberEntrega(c);
    await _abrir(t, ChatPage(conversa: c, resposta: const Duration(seconds: 1)));
    await _rolar(t, find.text('Aprovar'));
    expect(find.text('Entrega 1 de 2'), findsOneWidget);
    expect(find.text(r'Aprove para pagar o restante de R$ 175,00.'), findsOneWidget);
    expect(find.text('Sem resposta em 48h, a entrega é aprovada.'), findsOneWidget);

    await t.tap(find.text('Pedir ajuste'));
    await t.pumpAndSettle();
    expect(find.text('O que precisa mudar?'), findsOneWidget);
    expect(find.text('A Marina pode mandar mais 1 entrega.'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, 'Quero as letras maiores.');
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, 'Pedir ajuste').last);
    await t.pumpAndSettle();
    expect(find.text('Entrega 1 de 2 · ajuste pedido'), findsOneWidget);
    expect(find.text('Quero as letras maiores.'), findsOneWidget);

    // Protótipo: a profissional ajusta e manda a 2ª.
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    await _rolar(t, find.text('Reembolso'));
    expect(find.text('Entrega 2 de 2 · última'), findsOneWidget);
    expect(find.text('Última entrega. Não gostou? Peça reembolso.'), findsOneWidget);

    await t.tap(find.text('Reembolso'));
    await t.pumpAndSettle();
    expect(find.text('Pedir reembolso'), findsOneWidget);
    expect(
      find.text(
        'Os R\$ 175,00 ficam guardados até a decisão.\n'
        'O sinal de R\$ 75 fica com a Marina.',
      ),
      findsOneWidget,
    );
    await t.tap(find.text('Qualidade ruim'));
    await t.pump();
    await t.tap(find.text('Enviar para o suporte'));
    await t.pumpAndSettle();
    expect(c.entrega?.motivo, 'Qualidade ruim');
    expect(find.text('Reembolso em análise'), findsOneWidget);
    expect(find.text('Entrega 2 de 2 · reembolso pedido'), findsOneWidget);
  });

  testWidgets('RN-100: aprovar cobra o restante', (t) async {
    final c = _marina();
    conversas.receberEntrega(c);
    await _abrir(t, ChatPage(conversa: c));
    await _rolar(t, find.text('Aprovar'));
    await t.tap(find.text('Aprovar'));
    await t.pumpAndSettle();
    expect(find.text('Você aprovou a entrega'), findsOneWidget);
    expect(find.text(r'R$ 175,00 cobrados · total R$ 250,00'), findsOneWidget);
    expect(find.text('Avaliar Marina'), findsOneWidget);
  });

  testWidgets('Pago à distância: sai de Em andamento e vai para Concluídos', (
    t,
  ) async {
    pedidos.limpar();
    pedidos.aceitar(
      const PedidoAndamento(
        servico: 'Designer',
        profissao: 'Designer',
        profissional: 'Marina Reis',
        nota: '4,9',
        endereco: 'À distância',
        valor: '',
        pagamento: '',
        etapasFeitas: 3,
        distancia: true,
        sinal: 75,
      ),
    );
    final c = _marina();
    conversas.receberEntrega(c);
    await _abrir(t, ChatPage(conversa: c));
    await _rolar(t, find.text('Aprovar'));
    await t.tap(find.text('Aprovar'));
    await t.pumpAndSettle();
    expect(pedidos.andamentos, isEmpty);
    final feito = pedidos.concluidos.first;
    expect(feito.profissional, 'Marina Reis');
    expect(feito.valor, r'R$ 250,00');
    expect(feito.endereco, 'À distância');
    pedidos.restaurar();
  });

  testWidgets('RN-105: sem entrega no prazo, pede o sinal de volta', (
    t,
  ) async {
    final c = _marina(
      confirmadoEm: clock.now().subtract(const Duration(days: 8)),
    );
    await _abrir(t, ChatPage(conversa: c));
    await _rolar(t, find.text('Pedir sinal de volta'));
    expect(find.text('A Marina não enviou nada'), findsOneWidget);
    await t.tap(find.text('Pedir sinal de volta'));
    await t.pumpAndSettle();
    expect(find.text('Sinal de volta em análise'), findsOneWidget);
  });

  testWidgets('RN-99 a RN-103: profissional pede sinal e manda entregas', (
    t,
  ) async {
    await _abrir(
      t,
      const ChatProfissionalPage(
        chamado: chamadoDistanciaExemplo,
        resposta: Duration(seconds: 1),
      ),
    );
    await t.tap(find.text('Enviar valor'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '250');
    await t.pump();
    expect(find.text(r'R$ 75'), findsOneWidget);
    expect(find.textContaining('Até 30% do valor.'), findsOneWidget);
    await t.tap(find.byType(CupertinoSwitch));
    await t.pump();
    await t.tap(find.text('Enviar para Ana'));
    await t.pumpAndSettle();
    // A cliente propõe outro; aceita e fica combinado.
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    await t.ensureVisible(find.textContaining('Aceitar'));
    await t.tap(find.textContaining('Aceitar'));
    await t.pumpAndSettle();

    // P112: prévia ou entrega.
    await t.tap(find.bySemanticsLabel('Enviar foto'));
    await t.pumpAndSettle();
    expect(find.text('O que você vai mandar?'), findsOneWidget);
    expect(find.text('2 restantes'), findsOneWidget);
    await t.tap(find.text('Prévia protegida'));
    await t.pumpAndSettle();
    expect(atendimentoProfissional.previas, 1);

    await t.tap(find.bySemanticsLabel('Enviar foto'));
    await t.pumpAndSettle();
    await t.tap(find.text('Entrega'));
    await t.pumpAndSettle();
    await _entregarLink(t);
    expect(atendimentoProfissional.entregas, 1);
    expect(atendimentoProfissional.sinalLiberado, isTrue);
    expect(find.text('Entrega 1 de 2'), findsOneWidget);

    // Protótipo: a Ana pede ajuste.
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Enviar entrega 2'));
    expect(find.text('Ana pediu um ajuste'), findsOneWidget);
    expect(find.text('Entrega 1 de 2 enviada'), findsOneWidget);
    await t.tap(find.text('Enviar entrega 2'));
    await t.pumpAndSettle();
    await _entregarLink(t);
    expect(atendimentoProfissional.entregas, 2);
    expect(atendimentoProfissional.podeEntregar, isFalse);
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
  });

  testWidgets('RN-106: 3 sinais sem entrega em 30 dias pausam a conta', (
    t,
  ) async {
    profissional.registrarSinalSemEntrega();
    profissional.registrarSinalSemEntrega();
    expect(profissional.pausada, isFalse);
    profissional.registrarSinalSemEntrega();
    expect(profissional.pausadaPorSinais, isTrue);
    await _abrir(
      t,
      const HomeProfissionalPage(chamadoEm: Duration(hours: 1)),
    );
    expect(find.text('Conta pausada'), findsOneWidget);
    expect(find.text('3 sinais sem entrega em 30 dias.'), findsOneWidget);
    expect(find.textContaining('Sua conta volta sozinha em'), findsOneWidget);
  });
}
