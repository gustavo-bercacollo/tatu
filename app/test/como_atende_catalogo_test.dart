import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/cadastro/como_atende_page.dart';

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
}
