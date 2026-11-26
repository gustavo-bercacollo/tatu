import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/encontrados.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/selos.dart';
import 'package:tatu/features/cliente/chamar/encontrado_page.dart';
import 'package:tatu/features/cliente/chamar/som_encontrado.dart';
import 'package:tatu/features/entrada/perfil_publico_page.dart';
import 'package:tatu/features/profissional/perfil/seus_selos_page.dart';
import 'package:tatu/shared/widgets/avatar_iniciais.dart';

/// Selos de confiança do profissional (RN-217 a RN-220).

final _agora = DateTime(2026, 11, 26, 10);

Future<void> _abrir(WidgetTester t, Widget tela, {bool assentar = true}) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
  if (assentar) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
  }
}

/// [n] serviços, um por dia a partir de ontem.
List<ServicoParaSelo> _servicos(
  int n, {
  bool agendado = false,
  int foraDoHorario = 0,
  int clientes = 1,
  int voltaram = 0,
  bool contra = false,
}) => [
  for (var i = 0; i < n; i++)
    ServicoParaSelo(
      cliente: 'c${i % clientes}',
      em: _agora.subtract(Duration(days: 1 + i)),
      agendado: agendado,
      noHorario: i >= foraDoHorario,
      clienteVoltou: i % clientes < voltaram,
      retornoContra: contra && i == 0,
    ),
];

Set<Selo> _calcular(List<ServicoParaSelo> s, {bool ativa = true}) =>
    calcularSelos(servicos: s, verificado: true, ativa: ativa, agora: _agora);

void main() {
  SomEncontrado.ativo = false;
  setUp(() {
    profissional
      ..restaurar()
      ..demo();
    pedidos.restaurar();
    reiniciarFila();
  });

  group('RN-217/RN-218: cálculo', () {
    test('Pontual: 95% dos últimos 20 agendados', () {
      expect(
        _calcular(_servicos(20, agendado: true, foraDoHorario: 1)),
        contains(Selo.pontual),
      );
      expect(
        _calcular(_servicos(20, agendado: true, foraDoHorario: 2)),
        isNot(contains(Selo.pontual)),
      );
      // Menos de 20 agendados: ainda não dá para dizer.
      expect(
        _calcular(_servicos(19, agendado: true)),
        isNot(contains(Selo.pontual)),
      );
      // Chamado imediato não conta.
      expect(_calcular(_servicos(30)), isNot(contains(Selo.pontual)));
    });

    test('Resolve de primeira: 20 serviços e nenhum retorno contra', () {
      expect(_calcular(_servicos(20)), contains(Selo.resolveDePrimeira));
      expect(_calcular(_servicos(19)), isNot(contains(Selo.resolveDePrimeira)));
      expect(
        _calcular(_servicos(20, contra: true)),
        isNot(contains(Selo.resolveDePrimeira)),
      );
    });

    test('Clientes voltam: 30% com no mínimo 10 clientes', () {
      expect(
        _calcular(_servicos(10, clientes: 10, voltaram: 3)),
        contains(Selo.clientesVoltam),
      );
      expect(
        _calcular(_servicos(10, clientes: 10, voltaram: 2)),
        isNot(contains(Selo.clientesVoltam)),
      );
      expect(
        _calcular(_servicos(9, clientes: 9, voltaram: 9)),
        isNot(contains(Selo.clientesVoltam)),
      );
    });

    test('janela de 90 dias e clientes ligados não contam', () {
      final velhos = [
        for (final s in _servicos(20))
          ServicoParaSelo(
            cliente: s.cliente,
            em: s.em.subtract(RegrasSelos.janela),
          ),
      ];
      expect(_calcular(velhos), isNot(contains(Selo.resolveDePrimeira)));
      final ligados = [
        for (final s in _servicos(20))
          ServicoParaSelo(cliente: s.cliente, em: s.em, clienteLigado: true),
      ];
      expect(_calcular(ligados), isNot(contains(Selo.resolveDePrimeira)));
    });

    test('conta pausada ou suspensa perde todos', () {
      expect(_calcular(_servicos(20), ativa: false), isEmpty);
    });

    test('demo: Verificado, Pontual e Clientes voltam', () {
      expect(profissional.selos, {
        Selo.verificado,
        Selo.pontual,
        Selo.clientesVoltam,
      });
      profissional.pausarParaDemo();
      expect(profissional.selos, isEmpty);
    });
  });

  group('RN-219: onde aparecem', () {
    testWidgets('C166: perfil com a seção SELOS', (t) async {
      await _abrir(
        t,
        PerfilPublicoPage(
          perfil: perfilDe(filaEncontrados.first),
          avatar: const AvatarIniciais(nome: 'Luiza Souza'),
          rodape: const SizedBox.shrink(),
        ),
      );
      expect(find.text('SELOS'), findsOneWidget);
      for (final s in [
        Selo.verificado,
        Selo.pontual,
        Selo.resolveDePrimeira,
        Selo.clientesVoltam,
      ]) {
        expect(find.text(s.nome), findsWidgets);
        expect(find.text(s.frase), findsOneWidget);
      }
    });

    testWidgets('card de quem aceitou: selos pequenos embaixo do nome', (
      t,
    ) async {
      pedidos.limpar();
      await _abrir(
        t,
        const EncontradoPage(servico: 'Encanador', endereco: 'Rua A, 1'),
        assentar: false,
      );
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('Luiza Souza'), findsOneWidget);
      expect(
        find.text('Pontual · Resolve de primeira · Clientes voltam'),
        findsOneWidget,
      );
    });

    testWidgets('P85: Seus selos, sem progresso', (t) async {
      await _abrir(t, const SeusSelosPage());
      expect(find.text('Seus selos'), findsOneWidget);
      expect(find.text('Você tem'), findsNWidgets(3));
      expect(find.text('Ainda não'), findsOneWidget);
      expect(find.text(Selo.pontual.comoFunciona), findsOneWidget);
      expect(
        find.text('Selos não mudam quem recebe chamados.'),
        findsOneWidget,
      );
      expect(find.textContaining('faltam'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      // Conta pausada: todos "Ainda não".
      profissional.pausarParaDemo();
      await t.pumpAndSettle();
      expect(find.text('Você tem'), findsNothing);
    });
  });
}
