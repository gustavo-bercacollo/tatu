import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/recibo.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/data/retorno_acoes.dart';
import 'package:tatu/features/cliente/atividade/recibo_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';

/// Ajustes legais do retorno (RN-191, RN-192, RN-197 a RN-199).

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
  String profissional = 'Luiza Vilela',
  String cliente = 'Ana Martins',
}) => PedidoRetorno(
  servico: '#TT-7',
  servicoNome: 'Encanador',
  descricaoServico: 'Vazamento na pia',
  diaServico: '04 nov',
  profissional: profissional,
  profissionalFeminino: true,
  cliente: cliente,
  clienteFeminina: true,
  valorServico: 150,
  descricao: 'A pia voltou a vazar.',
  fotos: [FotoProva(tiradaEm: DateTime.now())],
  pedidoEm: DateTime.now().subtract(const Duration(hours: 49)),
  retido: false,
);

Finder get _lista => find
    .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
    .first;

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    retornos.restaurar();
    retornos.retornos.clear();
    pedidos.restaurar();
    conversas.restaurar();
    pagamentos.restaurar();
    conta.restaurar();
    canalTatu.restaurar();
    recibos.restaurar();
    profissional
      ..restaurar()
      ..demo();
  });

  group('RN-197: termo de garantia no recibo', () {
    test('mesmo bloco no PDF e no e-mail', () {
      final p = pedidos.concluidos.first;
      expect(garantiaDe(p).linhaRetorno,
          'Retorno sem custo até 02 fev (90 dias)');
      final pdf = recibos.gerarPdf(p);
      expect(pdf, containsAll([
        'Garantia',
        'Retorno sem custo até 02 fev (90 dias)',
        'Como pedir: Atividade → serviço → Algo errado?',
        'Seus direitos pelo Código do Consumidor continuam.',
      ]));
      recibos.enviarEmail(p, 'ana@exemplo.com');
      expect(recibos.emails.single.$2, pdf);
    });

    testWidgets('C144: bloco "Garantia" e link para a seção 11', (t) async {
      await _abrir(t, ReciboPage(pedido: pedidos.concluidos.first));
      expect(find.text('Garantia'), findsOneWidget);
      expect(
        find.text('Retorno sem custo até 02 fev (90 dias)'),
        findsOneWidget,
      );
      expect(find.text('Ver termo de garantia'), findsOneWidget);
      await t.ensureVisible(find.text('Ver termo de garantia'));
      await t.tap(find.text('Ver termo de garantia'));
      await t.pumpAndSettle();
      expect(find.textContaining('11. Algo errado, retorno e garantia'),
          findsWidgets);
    });
  });

  group('RN-198: pedir revisão de decisão automática', () {
    test('vale por 7 dias e uma vez por decisão', () {
      final em = DateTime(2026, 11, 20);
      expect(
        retornos.pedirRevisao(
          decisao: DecisaoAutomatica.falta,
          quem: 'Luiza Vilela',
          decididoEm: em,
          servico: '#TT-7',
          agora: DateTime(2026, 11, 28),
        ),
        isNull,
      );
      final p = retornos.pedirRevisao(
        decisao: DecisaoAutomatica.falta,
        quem: 'Luiza Vilela',
        decididoEm: em,
        servico: '#TT-7',
        agora: DateTime(2026, 11, 26), // quinta
      )!;
      // 3 dias úteis: sexta, segunda e terça, 1º dez.
      expect(p.respostaAte, DateTime(2026, 12, 1));
      expect(
        retornos.pedirRevisao(
          decisao: DecisaoAutomatica.falta,
          quem: 'Luiza Vilela',
          decididoEm: em,
          servico: '#TT-7',
          agora: DateTime(2026, 11, 26),
        ),
        isNull,
      );
    });

    test('quais decisões são automáticas (a da mediação não é)', () {
      final r = _pedido();
      retornos.pedir(r);
      retornos.clienteAusente(r);
      expect(r.decisaoAutomatica, DecisaoAutomatica.cumpridoAusente);
      final m = _pedido()..situacao = SituacaoRetorno.emMediacao;
      m.mediacaoDesde = DateTime.now();
      retornos.decidir(m, DecisaoMediacao.devolver100);
      expect(m.decisaoAutomatica, isNull);
    });

    test('P157: resolvido sozinho chega ao profissional pelo canal', () {
      retornos.pedir(_pedido());
      conferirPrazosRetorno();
      final m = canalTatu.profissional.mensagens.last;
      expect(m.decisao!.automatica, isTrue);
      expect(m.decisao!.titulo, 'Devolução de R\$ 150,00');
      expect(m.decisao!.rodape, '1 falta registrada');
      expect(m.texto, contains('não respondeu em 48 horas'));
      expect(m.textoDepois, contains('Peça revisão em até 7 dias'));
    });

    testWidgets('C231: "Não foi isso? Pedir revisão" no cumprido', (t) async {
      final r = _pedido(profissional: 'Luiza Souza');
      retornos.pedir(r);
      retornos.aceitar(r, DateTime.now().add(const Duration(days: 1)));
      retornos.clienteAusente(r);
      final c = conversas.conversas.firstWhere((c) => c.nome == 'Luiza Souza');
      await _abrir(t, ChatPage(conversa: c));
      await t.scrollUntilVisible(
        find.text('Não foi isso? Pedir revisão'),
        200,
        scrollable: _lista,
      );
      expect(find.text('Você não estava no retorno'), findsOneWidget);
      await t.drag(_lista, const Offset(0, -300));
      await t.pumpAndSettle();
      await t.tap(find.text('Não foi isso? Pedir revisão'));
      await t.pumpAndSettle();
      expect(retornos.revisoes.single.decisao, DecisaoAutomatica.cumpridoAusente);
      expect(find.textContaining('Revisão pedida'), findsOneWidget);
    });
  });

  test('RN-199: fotos apagadas depois do prazo de guarda', () {
    final velha = FotoProva(
      tiradaEm: DateTime.now().subtract(
        RegrasRetorno.guardaFotos + const Duration(days: 1),
      ),
    );
    final nova = FotoProva(tiradaEm: DateTime.now());
    final r = _pedido();
    r.fotos
      ..clear()
      ..addAll([velha, nova]);
    retornos.pedir(r);
    retornos.apagarFotosAntigas();
    expect(r.fotos, [nova]);
    expect(RegrasRetorno.guardaFotos.inDays ~/ 365, 5);
  });

  test('RN-192: a dívida é da conta no Tatu', () {
    profissional.registrarDivida(50);
    expect(profissional.comDivida, isTrue);
    expect(retornos.cpfComDivida(profissional.cpf), isTrue);
  });
}
