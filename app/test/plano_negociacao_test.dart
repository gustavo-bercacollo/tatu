import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/cliente/plano_fixo/plano_fixo.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/plano_fixo/plano_fixo_profissional.dart';

/// RN-210: valor do plano fixo negociável, até 3 propostas pelo valor por
/// visita (RN-144, RN-148).

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

/// Plano mensal, sexta e sábado (8 visitas), entre a cliente logada e a
/// Luiza.
PlanoFixo _plano({String cliente = 'Ana Martins'}) => planosFixos.pedir(
  cliente: cliente,
  profissional: 'Luiza Souza',
  endereco: 'Rua das Flores, 120',
  frequencia: FrequenciaPlano.mensal,
  visitasPorSemana: 2,
  dias: const [5, 6],
  horario: '9:00',
)!;

/// Desce o chat até [texto] e um pouco mais (sai de baixo da barra).
Future<void> _descer(WidgetTester t, String texto) async {
  await t.scrollUntilVisible(
    find.text(texto),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await t.drag(find.byType(Scrollable).first, const Offset(0, -200));
  await t.pumpAndSettle();
}

/// [texto] dentro do card do plano (o chat também tem o do avulso).
Finder _noCard(String texto) => find.descendant(
  of: find.byType(CartaoPropostaPlano),
  matching: find.text(texto),
);

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    conta.restaurar();
    conversas.restaurar();
    pedidos.restaurar();
    planosFixos.restaurar();
  });

  group('Regras', () {
    test('3 propostas: profissional, cliente, último valor; recusar', () {
      final p = _plano();
      expect(p.estado(), EstadoPlano.aguardandoValor);
      // O cliente não pode pedir antes do 1º valor.
      expect(planosFixos.pedirOutroValor(p, 130), isFalse);

      expect(planosFixos.enviarValor(p, 150), isTrue);
      expect(p.negociacao.numero, 1);
      expect(p.estado(), EstadoPlano.valorEnviado);
      // Total sempre calculado: valor por visita × visitas do período.
      expect(p.valorDoPeriodo, 1200);

      expect(planosFixos.pedirOutroValor(p, 130), isTrue);
      expect(p.negociacao.numero, 2);
      expect(p.estado(), EstadoPlano.outroValorPedido);
      expect(p.valorDoPeriodo, 1040);
      final barra = p.barra(cliente: false)!;
      expect(barra.texto, 'Plano fixo · responda');
      expect(barra.direita, r'R$ 130/visita');
      expect(barra.laranja, isTrue);

      expect(planosFixos.enviarValor(p, 140), isTrue);
      expect(p.negociacao.numero, 3);
      expect(p.negociacao.clientePodeRecusar, isTrue);
      expect(p.negociacao.clientePodePedirOutro, isFalse);
      // Não existe 4ª proposta.
      expect(planosFixos.pedirOutroValor(p, 120), isFalse);

      planosFixos.recusarValor(p);
      expect(p.status, StatusPlano.cancelado);
      expect(p.semAcordo, isTrue);
      // Sem plano: dá para pedir de novo e os avulsos continuam.
      expect(planosFixos.planoCom('Luiza Souza'), isNull);
    });

    test('profissional aceita o valor do cliente → cliente confirma', () {
      final p = _plano();
      planosFixos
        ..enviarValor(p, 150)
        ..pedirOutroValor(p, 130);
      expect(planosFixos.aceitarValorDoCliente(p), isTrue);
      expect(p.negociacao.aceita, isTrue);
      expect(p.negociacao.numero, 2);
      planosFixos.confirmar(p, cartao: 'Visa 4242');
      expect(p.status, StatusPlano.ativo);
      expect(p.valorPorVisita, 130);
    });

    test('protótipo: aceita perto do pedido; senão meio-termo', () {
      final a = _plano();
      planosFixos
        ..enviarValor(a, 150)
        ..pedirOutroValor(a, 130)
        ..simularRespostaDoProfissional(a);
      expect(a.negociacao.valor, 140);
      expect(a.negociacao.ultimaProposta, isTrue);

      planosFixos.restaurar();
      final b = _plano();
      planosFixos
        ..enviarValor(b, 150)
        ..pedirOutroValor(b, 145)
        ..simularRespostaDoProfissional(b);
      expect(b.negociacao.aceita, isTrue);
    });

    test('RN-148: novo valor de um plano ativo usa a mesma negociação', () {
      final p = _plano();
      planosFixos
        ..enviarValor(p, 150)
        ..confirmar(p, cartao: 'Visa 4242')
        ..proporNovoValor(p, 180);
      expect(p.valorPorVisita, 150);
      expect(p.valorProposto, 180);
      expect(planosFixos.pedirOutroValor(p, 160), isTrue);
      expect(planosFixos.aceitarValorDoCliente(p), isTrue);
      planosFixos.aceitarNovoValor(p);
      expect(p.valorPorVisita, 160);
      expect(p.novoValor, isNull);

      // Recusar a última proposta mantém o valor de hoje.
      planosFixos
        ..proporNovoValor(p, 200)
        ..pedirOutroValor(p, 170)
        ..enviarValor(p, 190)
        ..recusarValor(p);
      expect(p.status, StatusPlano.ativo);
      expect(p.valorPorVisita, 160);
    });
  });

  group('Telas', () {
    testWidgets('C217/C218: pedir outro valor pelo card', (t) async {
      final p = _plano(cliente: conta.nomeCompleto);
      planosFixos.enviarValor(p, 150);
      await _abrir(
        t,
        ChatPage(
          conversa: conversas.conversas.first,
          resposta: const Duration(seconds: 1),
        ),
      );
      expect(find.text('Proposta 1 de 3'), findsOneWidget);
      expect(find.text(r'R$ 1.200 por mês'), findsOneWidget);
      // Barra do chat em laranja.
      expect(find.text('Plano fixo · confirme o valor'), findsOneWidget);
      await _descer(t, 'Confirmar plano');
      await t.tap(_noCard('Pedir outro valor'));
      await t.pumpAndSettle();

      expect(find.text('Quanto por visita?'), findsOneWidget);
      expect(find.text('Proposta 2 de 3'), findsOneWidget);
      expect(
        find.text(r'Ela pediu R$ 150 por visita (R$ 1.200 por mês).'),
        findsOneWidget,
      );
      await t.enterText(find.byType(TextField).last, '130');
      await t.pump();
      expect(find.text(r'8 visitas · R$ 1.040 por mês'), findsOneWidget);
      await t.tap(find.text('Enviar proposta'));
      await t.pumpAndSettle();
      expect(
        find.text(r'Você pediu R$ 130 por visita. Aguardando a Luiza.'),
        findsOneWidget,
      );

      // A Luiza manda o último valor (protótipo: meio-termo).
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(find.text('Luiza enviou a última proposta'), findsOneWidget);
      expect(find.text('Proposta 3 de 3 · última'), findsOneWidget);
      expect(_noCard('Pedir outro valor'), findsNothing);
    });

    testWidgets('C219: última proposta → Recusar → sem acordo', (t) async {
      final p = _plano(cliente: conta.nomeCompleto);
      planosFixos
        ..enviarValor(p, 150)
        ..pedirOutroValor(p, 130)
        ..enviarValor(p, 140);
      await _abrir(t, ChatPage(conversa: conversas.conversas.first));
      expect(
        find.text(
          'Sem acordo, o plano não começa. Serviços\n'
          'avulsos com a Luiza continuam valendo.',
        ),
        findsOneWidget,
      );
      await _descer(t, 'Recusar');
      await t.tap(find.text('Recusar'));
      await t.pumpAndSettle();
      expect(p.semAcordo, isTrue);
      expect(find.textContaining('Plano fixo sem acordo'), findsOneWidget);
    });

    testWidgets('P147: profissional aceita ou envia outro valor', (t) async {
      final p = _plano();
      planosFixos
        ..enviarValor(p, 150)
        ..pedirOutroValor(p, 130);
      await _abrir(t, const ChatProfissionalPage());
      expect(find.byType(CartaoOutroValorPlano), findsOneWidget);
      expect(find.text('Ana pediu outro valor'), findsOneWidget);
      expect(find.text('Plano fixo · responda'), findsOneWidget);
      expect(
        find.text(r'R$ 130 por visita · você pediu R$ 150'),
        findsOneWidget,
      );
      expect(
        find.text('Seu próximo valor será o último (3 de 3).'),
        findsOneWidget,
      );
      await _descer(t, 'Enviar outro valor');
      await t.tap(find.text(r'Aceitar R$ 130 por visita'));
      await t.pumpAndSettle();
      expect(p.negociacao.aceita, isTrue);
      expect(
        find.text(
          r'Você aceitou R$ 130 por visita. Aguardando a Ana confirmar.',
        ),
        findsOneWidget,
      );
    });
  });
}
