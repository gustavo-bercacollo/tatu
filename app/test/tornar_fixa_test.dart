import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/features/cliente/atividade/atividade_page.dart';
import 'package:tatu/features/cliente/mensagens/mensagens_page.dart';

/// "Tornar fixa" mais fácil de achar (RN-144, RN-208, RN-209).

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

PedidoConcluido _diarista() => PedidoConcluido(
  servico: 'Diarista',
  profissao: 'Diarista',
  profissional: 'Júlia Costa',
  descricao: 'Limpeza da casa',
  endereco: 'Rua das Flores, 120',
  pagamento: 'Visa 4242',
  valor: r'R$ 150,00',
  dia: '18 nov',
  hora: '09:00',
  mes: 'Novembro',
  numero: '#TT-9001',
  concluidoEm: DateTime(2026, 11, 18, 12),
);

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    conta.restaurar();
    conversas.restaurar();
    pedidos.restaurar();
    planosFixos.restaurar();
  });

  test('catálogo: coluna Fixo (diarista sim, encanador não)', () {
    expect(catalogoServicos.encontrar('Diarista')!.fixo, isTrue);
    expect(catalogoServicos.encontrar('Encanador')!.fixo, isFalse);
  });

  testWidgets('C215 · RN-209: "Tornar fixa" só em profissão Fixo: Sim', (
    t,
  ) async {
    pedidos.concluidos = [_diarista(), ...pedidos.concluidos];
    await _abrir(t, const AtividadePage(aba: 1));
    // Júlia (diarista) tem o botão; Luiza (encanadora) não.
    expect(find.text('Tornar fixa'), findsOneWidget);
    await t.tap(find.text('Tornar fixa'));
    await t.pumpAndSettle();
    expect(find.text('Tornar Júlia fixa'), findsOneWidget);
  });

  testWidgets('RN-209: com plano já existente, o botão some', (t) async {
    pedidos.concluidos = [_diarista(), ...pedidos.concluidos];
    planosFixos.pedir(
      cliente: conta.nomeCompleto,
      profissional: 'Júlia Costa',
      endereco: 'Rua das Flores, 120',
      frequencia: FrequenciaPlano.semanal,
      visitasPorSemana: 1,
      dias: const [2],
      horario: '9:00',
      profissao: 'Diarista',
    );
    await _abrir(t, const AtividadePage(aba: 1));
    expect(find.text('Tornar fixa'), findsNothing);
  });

  testWidgets('C214 · RN-208: segurar a conversa abre o menu', (t) async {
    await _abrir(t, const MensagensPage());
    await t.longPress(find.text('Marcos Dias'));
    await t.pumpAndSettle();
    expect(find.text('Ver perfil do Marcos'), findsOneWidget);
    expect(find.text('Tornar Marcos fixo'), findsOneWidget);
    expect(find.text('Pedir de novo'), findsOneWidget);
    // Abre a mesma tela de escolha do plano.
    await t.tap(find.text('Tornar Marcos fixo'));
    await t.pumpAndSettle();
    expect(find.text('Tornar Marcos fixa'), findsOneWidget);
  });

  testWidgets('RN-208: com plano, o item vira "Ver plano fixo"', (t) async {
    final p = planosFixos.pedir(
      cliente: conta.nomeCompleto,
      profissional: 'Marcos Dias',
      endereco: 'Rua das Flores',
      frequencia: FrequenciaPlano.semanal,
      visitasPorSemana: 1,
      dias: const [2],
      horario: '9:00',
      profissao: 'Pintor',
      feminino: false,
    )!;
    planosFixos
      ..enviarValor(p, 150)
      ..confirmar(p, cartao: 'Visa 4242');
    await _abrir(t, const MensagensPage());
    await t.longPress(find.text('Marcos Dias'));
    await t.pumpAndSettle();
    expect(find.text('Ver plano fixo'), findsOneWidget);
    expect(find.text('Tornar Marcos fixo'), findsNothing);
  });

  testWidgets('RN-144: "Pedir de novo" oferece tornar fixa', (t) async {
    await _abrir(t, const AtividadePage(aba: 1));
    await t.tap(find.text('Pedir de novo').first);
    await t.pumpAndSettle();
    // Terceira opção (borda só ao tocar); o botão passa a tornar fixa.
    expect(find.text('Precisa toda semana?'), findsOneWidget);
    expect(find.text('Tornar a Luiza fixa'), findsOneWidget);
    await t.tap(find.text('Precisa toda semana?'));
    await t.pumpAndSettle();
    expect(find.text('Tornar a Luiza fixa'), findsNWidgets(2));
    await t.tap(find.widgetWithText(FilledButton, 'Tornar a Luiza fixa'));
    await t.pumpAndSettle();
    // Abre a mesma tela de escolha do plano.
    expect(find.text('Tornar Luiza fixa'), findsOneWidget);
  });

  testWidgets('RN-144: com plano, o "Pedir de novo" não oferece', (t) async {
    planosFixos.pedir(
      cliente: conta.nomeCompleto,
      profissional: 'Luiza Souza',
      endereco: 'Rua das Flores, 120',
      frequencia: FrequenciaPlano.semanal,
      visitasPorSemana: 1,
      dias: const [2],
      horario: '9:00',
    );
    await _abrir(t, const AtividadePage(aba: 1));
    await t.tap(find.text('Pedir de novo').first);
    await t.pumpAndSettle();
    expect(find.textContaining('Precisa toda semana?'), findsNothing);
  });
}
