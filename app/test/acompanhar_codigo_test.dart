import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/codigo_porta.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/prazos.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/cliente/atividade/pedido_andamento_page.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';

/// Acompanhar o profissional (RN-165, RN-166) e código para iniciar
/// (RN-39, RN-167).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

Future<void> _digitar(WidgetTester t, String codigo) async {
  for (final d in codigo.split('')) {
    await t.tap(find.text(d).last);
    await t.pump();
  }
}

const _combinado = PedidoAndamento(
  servico: 'Encanador',
  profissao: 'Encanadora',
  profissional: 'Luiza Souza',
  nota: '4,9',
  endereco: 'Rua das Flores, 120',
  valor: r'R$ 190,00',
  pagamento: 'Visa 4242',
  etapasFeitas: 1,
);

void main() {
  setUpAll(() => RegrasCodigo.sorteio = null);
  setUp(() {
    Prazos.aceleracao = 1;
    PedidosRepo.demoCodigo = false;
    navegacao.restaurar();
    pedidos.restaurar();
    atendimentoProfissional.restaurar();
  });
  tearDown(() {
    Prazos.aceleracao = 20;
    PedidosRepo.demoCodigo = true;
    pedidos.restaurar();
  });

  group('Profissional: código para iniciar', () {
    testWidgets('RN-39: código certo inicia o serviço sozinho', (t) async {
      await _abrir(t, const ACaminhoPage(perto: true));
      await t.tap(find.text('Cheguei'));
      await t.pump();
      expect(find.text('Peça o código para a Ana'), findsOneWidget);
      expect(find.text('Digitou, o serviço começa sozinho.'), findsOneWidget);
      expect(find.text('O código está no app da Ana.'), findsOneWidget);
      expect(find.text('Iniciar serviço'), findsNothing);

      await _digitar(t, '4821');
      await t.pumpAndSettle();
      expect(find.text('Em serviço'), findsOneWidget);
      expect(atendimentoProfissional.etapa, EtapaAtendimento.emServico);
    });

    testWidgets('RN-167: 3 erros bloqueiam e oferecem o suporte', (t) async {
      await _abrir(t, const ACaminhoPage(perto: true));
      await t.tap(find.text('Cheguei'));
      await t.pump();

      await _digitar(t, '4831');
      expect(
        find.text('Código incorreto. Confira com a Ana · restam 2 tentativas.'),
        findsOneWidget,
      );
      await _digitar(t, '1111');
      expect(
        find.text('Código incorreto. Confira com a Ana · resta 1 tentativa.'),
        findsOneWidget,
      );
      await _digitar(t, '2222');
      expect(find.text('Falar com o suporte'), findsOneWidget);
      expect(find.textContaining('estão bloqueadas'), findsOneWidget);
      // Sem teclado: não dá para tentar de novo, nem com o código certo.
      expect(find.text('5'), findsNothing);
      expect(atendimentoProfissional.codigo!.bloqueado, isTrue);
      expect(
        atendimentoProfissional.digitarCodigo('4821'),
        ResultadoCodigo.bloqueado,
      );
      expect(atendimentoProfissional.etapa, EtapaAtendimento.noLocal);
      // RN-80: a espera continua acessível.
      expect(find.text('A Ana não está? Ver tempo de espera'), findsOneWidget);
    });

    test('RN-95: à distância não tem código', () {
      atendimentoProfissional.irAteCliente(servicoDistanciaExemplo);
      expect(atendimentoProfissional.codigo, isNull);
      expect(atendimentoProfissional.enviarPosicao(), isFalse);
    });
  });

  group('RN-166: localização do profissional', () {
    test('para de ser enviada depois do código', () {
      final a = atendimentoProfissional;
      // Antes do "Estou a caminho": nada.
      expect(a.enviarPosicao(), isFalse);
      a.irAteCliente(servicoExemplo);
      expect(a.enviarPosicao(), isTrue);
      a.chegou();
      expect(a.enviarPosicao(), isTrue);
      expect(a.digitarCodigo('4821'), ResultadoCodigo.certo);
      expect(a.etapa, EtapaAtendimento.emServico);
      expect(a.enviarPosicao(), isFalse);
      expect(a.posicoesEnviadas, 2);
    });

    test('para com "Cliente não apareceu"', () {
      final a = atendimentoProfissional
        ..irAteCliente(servicoExemplo)
        ..chegou();
      expect(a.enviarPosicao(), isTrue);
      a.encerrar();
      expect(a.enviarPosicao(), isFalse);
    });

    test('o cliente só vê a posição até o código', () {
      expect(pedidos.andamento!.mostraLocalizacao, isTrue);
      pedidos.chegou();
      expect(pedidos.andamento!.mostraLocalizacao, isTrue);
      pedidos.codigoDigitado();
      expect(pedidos.andamento!.mostraLocalizacao, isFalse);
      expect(pedidos.andamento!.acompanhar(), isNull);
    });
  });

  group('Cliente: acompanhar', () {
    testWidgets('RN-165: vai sair já → a caminho → chegando → chegou', (
      t,
    ) async {
      pedidos.aceitar(_combinado);
      pedidos.valorConfirmado();
      await _abrir(t, const PedidoAndamentoPage());
      expect(find.text('A Luiza vai sair já'), findsOneWidget);
      expect(
        find.text('Ela tem até 10 min para sair · faltam 10 min'),
        findsOneWidget,
      );
      expect(find.text('Rua das Flores, 120'), findsOneWidget);
      expect(find.text(r'R$ 190,00'), findsOneWidget);
      expect(find.bySemanticsLabel('Ligar'), findsOneWidget);
      await t.pump(const Duration(minutes: 3));
      expect(find.textContaining('faltam 7 min'), findsOneWidget);

      pedidos.saiu();
      await t.pump();
      expect(find.text('Chega em 12 min'), findsOneWidget);
      expect(find.textContaining('A caminho · 2,3 km'), findsOneWidget);
      // Ainda sem código na tela.
      expect(find.text('4 8 2 1'), findsNothing);

      // RN-165: menos de 2 min: aviso no celular e código na tela.
      await t.pump(const Duration(minutes: 10, seconds: 30));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('A Luiza está chegando'), findsOneWidget);
      expect(find.text('4 8 2 1'), findsOneWidget);
      expect(
        find.text('Só diga o código pessoalmente, nunca por mensagem.'),
        findsOneWidget,
      );
      expect(pedidos.avisos, ['A Luiza está chegando']);

      pedidos.chegou();
      await t.pump();
      expect(find.text('A Luiza chegou'), findsOneWidget);
      expect(
        find.text('Passe o código para ela começar o serviço'),
        findsOneWidget,
      );
      // RN-39: digitou, o serviço começa e o mapa sai.
      pedidos.codigoDigitado();
      await t.pump();
      expect(find.text('A Luiza chegou'), findsNothing);
      expect(find.text('Pedido'), findsOneWidget);
    });

    testWidgets('RN-78: o atraso aparece no mapa', (t) async {
      await _abrir(t, const PedidoAndamentoPage());
      await t.pump(const Duration(minutes: 24, seconds: 1));
      await t.pump();
      expect(find.text('A Luiza está atrasada'), findsOneWidget);
      expect(find.text('Chamar outro encanador'), findsOneWidget);
      await t.tap(find.text('Continuar esperando'));
      await t.pump();
      expect(find.text('A Luiza está atrasada'), findsNothing);
      pedidos.restaurar();
    });

    testWidgets('RN-165: faixa na Home abre o mapa', (t) async {
      await _abrir(t, const HomeClientePage());
      expect(find.text('Luiza chega em 12 min'), findsOneWidget);
      expect(
        find.text('Encanadora · a caminho · ver no mapa'),
        findsOneWidget,
      );
      expect(find.text('Do que você precisa?'), findsNothing);
      await t.tap(find.text('Luiza chega em 12 min'));
      await t.pumpAndSettle();
      expect(find.text('Chega em 12 min'), findsOneWidget);
    });
  });
}
