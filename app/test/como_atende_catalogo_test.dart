import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/cadastro/como_atende_page.dart';
import 'package:tatu/features/profissional/cadastro/especialidades_page.dart';

/// RN-97: "Como você atende?" só quando o catálogo permite mais de um modo.

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
  await t.pumpAndSettle();
}

void main() {
  setUp(profissional.restaurar);

  test('a decisão vem da coluna "Atende" do catálogo', () {
    expect(catalogoServicos.porNome('Encanador')!.atende, AtendeCatalogo.local);
    expect(modoUnico('Encanador'), ModoAtendimento.local);
    expect(modoUnico('Programador'), ModoAtendimento.distancia);
    expect(modoUnico('Advogado'), isNull);
    expect(modosPermitidos('Advogado'), ModoAtendimento.values);
    expect(modosPermitidos('Psicólogo'), [ModoAtendimento.distancia]);
  });

  test('ao adicionar, o modo único já fica salvo; inválido é recusado', () {
    profissional.definirProfissoes(const [
      ProfissaoEscolhida('Programador', ['Sites']),
      ProfissaoEscolhida('Encanador', ['Vazamentos']),
    ]);
    expect(profissional.profissoes.first.modo, ModoAtendimento.distancia);
    expect(profissional.profissoes.last.modo, ModoAtendimento.local);
    profissional.adicionarProfissao(const ProfissaoEscolhida('Tradutor'));
    expect(profissional.profissoes.last.modo, ModoAtendimento.distancia);
    // Encanador não atende à distância: não muda.
    profissional.definirModo('Encanador', ModoAtendimento.distancia);
    expect(profissional.profissoes[1].modo, ModoAtendimento.local);
  });

  testWidgets('L/D: a pergunta mostra os três modos', (t) async {
    profissional.definirProfissoes(const [
      ProfissaoEscolhida('Advogado', ['Contratos']),
    ]);
    await _abrir(t, const ComoAtendePage(indice: 0, edicao: true));
    expect(find.text('No local'), findsOneWidget);
    expect(find.text('À distância'), findsOneWidget);
    expect(find.text('Os dois'), findsOneWidget);
  });

  testWidgets('Perfil: profissão D não oferece o modo no local', (t) async {
    profissional.definirProfissoes(const [
      ProfissaoEscolhida('Programador', ['Sites']),
    ]);
    await _abrir(t, const ComoAtendePage(indice: 0, edicao: true));
    expect(find.text('No local'), findsNothing);
    expect(find.text('Os dois'), findsNothing);
    expect(find.text('À distância'), findsOneWidget);
  });

  test('os atalhos da tela de serviços acham a profissão no catálogo', () {
    // "Montador", "Ar-condicionado", "Jardinagem" e "Limpeza" são
    // sinônimos no catálogo; todos são só no local (L).
    for (final nome in profissoesPrincipais) {
      expect(catalogoServicos.encontrar(nome), isNotNull, reason: nome);
      expect(modoUnico(nome), ModoAtendimento.local, reason: nome);
    }
    expect(catalogoServicos.encontrar('Montador')!.nome, 'Montador de móveis');
    expect(catalogoServicos.encontrar('Limpeza')!.nome, 'Diarista');
    expect(catalogoServicos.encontrar('Encanadora')!.nome, 'Encanador');
    expect(catalogoServicos.encontrar('Profissão inventada'), isNull);
  });

  test('toda profissão L ou D do catálogo pula a pergunta', () {
    for (final p in catalogoServicos.todas) {
      final esperado = switch (p.atende) {
        AtendeCatalogo.local => ModoAtendimento.local,
        AtendeCatalogo.distancia => ModoAtendimento.distancia,
        AtendeCatalogo.ambos => null,
      };
      expect(modoUnico(p.nome), esperado, reason: p.nome);
    }
  });

  Future<void> adicionarESalvar(WidgetTester t, String nome) async {
    profissional.definirProfissoes(const [
      ProfissaoEscolhida('Encanador', ['Vazamentos']),
    ]);
    profissional.adicionarProfissao(ProfissaoEscolhida(nome, const ['Outra']));
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: tatuTheme(),
        home: Builder(
          builder: (ctx) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => EspecialidadesPage(
                    indice: profissional.profissoes.length - 1,
                    edicao: true,
                    nova: true,
                  ),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await t.pumpAndSettle();
  }

  testWidgets('"Adicionar outra": Montador (L) não pergunta', (t) async {
    await adicionarESalvar(t, 'Montador');
    expect(find.text('Como você atende?'), findsNothing);
    expect(profissional.profissoes.last.modo, ModoAtendimento.local);
  });

  testWidgets('"Adicionar outra": Advogado (L/D) pergunta', (t) async {
    await adicionarESalvar(t, 'Advogado');
    expect(find.text('Como você atende?'), findsOneWidget);
    expect(find.text('Os dois'), findsOneWidget);
  });
}
