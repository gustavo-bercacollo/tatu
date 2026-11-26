import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/features/cliente/atividade/atividade_page.dart';

/// C234/C235 · RN-207: card do retorno em Atividade → Em andamento.

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in ['400', '500', '600', '700']) {
    f.addFont(rootBundle.load('assets/fonts/Inter-$p.ttf'));
  }
  await f.load();
}

PedidoRetorno _rafael() => PedidoRetorno(
  servico: '#TT-47960',
  servicoNome: 'Eletricista',
  descricaoServico: 'tomada da sala',
  diaServico: '02 nov',
  profissional: 'Rafael Lima',
  profissionalFeminino: false,
  cliente: conta.nomeCompleto,
  clienteFeminina: true,
  valorServico: 220,
  descricao: 'A tomada parou de novo.',
  fotos: const [],
  pedidoEm: DateTime(2026, 11, 24, 10),
  retido: false,
);

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    conta.restaurar();
    pedidos.restaurar();
    planosFixos.restaurar();
    retornos
      ..restaurar()
      ..retornos.clear();
  });

  testWidgets('agendado e a caminho, com a mesma altura', (t) async {
    t.view.physicalSize = const Size(1179, 2556); // 393×852
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final r = retornos.pedir(_rafael())!;
    retornos.aceitar(
      r,
      DateTime(2026, 11, 27, 14),
      agora: DateTime(2026, 11, 24, 12),
    );
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const AtividadePage(aba: 0)),
    );
    await t.pumpAndSettle();
    final card = find
        .ancestor(of: find.text('Rafael Lima'), matching: find.byType(InkWell))
        .first;
    Finder dentro(String texto) =>
        find.descendant(of: card, matching: find.text(texto));

    // C253 · RN-207: agendado (subtítulo só com a profissão).
    expect(dentro('RL'), findsOneWidget);
    expect(dentro('Eletricista'), findsOneWidget);
    expect(dentro('Agendado'), findsOneWidget);
    expect(dentro('Retorno · sem custo'), findsOneWidget);
    expect(dentro('do serviço de ${r.diaServico}'), findsOneWidget);
    expect(dentro('Sexta, 27 nov · 14h'), findsOneWidget);
    expect(
      dentro('Código ${r.codigo} · passe para o Rafael na hora'),
      findsOneWidget,
    );
    final altura = t.getRect(card).height;

    // C235: a caminho.
    retornos.saiuParaRetorno(r, minutos: 8);
    await t.pumpAndSettle();
    expect(dentro('8 min'), findsOneWidget);
    expect(
      find.descendant(
        of: card,
        matching: find.textContaining(
          'Retorno · sem custo',
          findRichText: true,
        ),
      ),
      findsOneWidget,
    );
    for (final e in ['Agendado', 'A caminho', 'Retorno', 'Feito']) {
      expect(dentro(e), findsOneWidget, reason: e);
    }
    expect(dentro('Sexta, 27 nov · 14h'), findsNothing);
    expect(dentro('do serviço de ${r.diaServico}'), findsOneWidget);
    expect(t.getRect(card).height, altura);
  });
}
