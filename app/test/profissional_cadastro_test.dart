import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/cadastro/dados_page.dart';
import 'package:tatu/features/profissional/cadastro/pix_page.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';
import 'package:tatu/features/profissional/perfil/perfil_profissional_page.dart';

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(430, 1100);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

Future<void> _tocar(WidgetTester t, String texto) async {
  await t.ensureVisible(find.text(texto).last);
  await t.tap(find.text(texto).last);
  await t.pumpAndSettle();
}

void main() {
  setUp(profissional.restaurar);

  testWidgets('Cadastro completo: dados → serviços → Pix → verificação', (
    t,
  ) async {
    await _abrir(t, const DadosProfissionalPage());
    final campos = find.byType(TextField);
    await t.enterText(campos.at(0), 'Luiza Vilela');
    await t.enterText(campos.at(1), '11111111111'); // CPF inválido
    await t.pump();
    expect(find.text('CPF inválido. Confira os números.'), findsOneWidget);
    await t.enterText(campos.at(1), '12345678909');
    await t.enterText(campos.at(2), '11977776666');
    await t.pump();
    await _tocar(t, 'Continuar');

    // Código por SMS.
    await t.enterText(find.byType(TextField).last, '482719');
    await t.pump();
    await _tocar(t, 'Continuar');

    // Passo 2: dois serviços, especialidades de cada um.
    expect(find.text('Quais serviços você faz?'), findsOneWidget);
    await t.tap(find.text('Encanador'));
    await t.tap(find.text('Eletricista'));
    await t.pump();
    expect(find.text('2 selecionados'), findsOneWidget);
    await _tocar(t, 'Continuar');
    expect(find.text('Encanador · 1 de 2'), findsOneWidget);
    for (final e in ['Reparos', 'Instalações', 'Esgoto', 'Vazamentos']) {
      await t.tap(find.text(e));
    }
    await t.pump();
    expect(find.text('3 de 3 escolhidas'), findsOneWidget);
    await _tocar(t, 'Próximo: Eletricista');
    await t.tap(find.text('Quadro de luz'));
    await t.pump();
    await _tocar(t, 'Continuar');
    expect(find.text('Suas profissões'), findsOneWidget);
    expect(find.text('Reparos · Instalações · Esgoto'), findsOneWidget);
    expect(find.text('2 de 3 profissões'), findsOneWidget);
    await _tocar(t, 'Continuar');

    // Passo 3: Pix no CPF.
    expect(find.text('Onde você quer receber?'), findsOneWidget);
    expect(find.text('•••.456.789-••'), findsOneWidget);
    await t.tap(find.text('Salvar e continuar'));
    await t.pump();
    expect(find.text('Confirmando sua chave…'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 1600));
    expect(find.text('Chave salva'), findsOneWidget);
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();

    // Passo 4: documento (sozinho) e selfie.
    expect(find.text('Vamos confirmar que é você'), findsOneWidget);
    await _tocar(t, 'Começar');
    expect(find.text('Frente do documento'), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    expect(find.text('Verso do documento'), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('Tirar foto'));
    await t.pumpAndSettle();
    expect(find.text('Recebemos seus dados'), findsOneWidget);
    expect(profissional.verificacao, Verificacao.emAnalise);
    expect(profissional.pixTipo, TipoPix.cpf);
    expect(profissional.profissoes.length, 2);

    // Ativar avisos → aprovação simulada.
    await t.tap(find.text('Ativar avisos'));
    await t.pump(const Duration(seconds: 4));
    await t.pumpAndSettle();
    expect(find.text('Cadastro aprovado!'), findsOneWidget);
    await _tocar(t, 'Começar');
    expect(find.text('Pronta para começar?'), findsNothing);
    expect(find.text('Pronto para começar?'), findsOneWidget);
    await _tocar(t, 'Entendi');
    expect(find.text('Você está offline'), findsOneWidget);
  });

  testWidgets('Pix: chave em nome de outra pessoa e fazer depois', (t) async {
    profissional.salvarDados(
      nome: 'Luiza Vilela',
      cpf: '12345678909',
      celular: '11977776666',
    );
    await _abrir(t, const PixPage());
    await t.tap(find.text('Celular'));
    await t.pump();
    await t.enterText(find.byType(TextField), '11988887777');
    await t.pump();
    await t.tap(find.text('Salvar e continuar'));
    await t.pump(const Duration(seconds: 2));
    expect(find.textContaining('no nome de outra pessoa'), findsOneWidget);

    await _tocar(t, 'Fazer isso depois');
    expect(find.text('Deixar para depois?'), findsOneWidget);
    await _tocar(t, 'Fazer depois');
    expect(find.text('Vamos confirmar que é você'), findsOneWidget);
    expect(profissional.temPix, isFalse);
  });

  testWidgets('Home: sem Pix mostra o lembrete; fica online e offline', (
    t,
  ) async {
    profissional.demo(comPix: false);
    await _abrir(t, const HomeProfissionalPage());
    expect(find.text('Cadastre onde receber'), findsOneWidget);
    await _tocar(t, 'Ficar online');
    expect(find.text('Você está online'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    await _tocar(t, 'Ficar offline');
    expect(find.text('Você está offline'), findsOneWidget);
  });

  testWidgets('Perfil: trocar para cliente estando online pergunta antes', (
    t,
  ) async {
    profissional
      ..demo()
      ..ficarOnline(true);
    await _abrir(t, const PerfilProfissionalPage());
    await _tocar(t, 'Trocar para modo cliente');
    expect(find.text('Ficar offline e trocar?'), findsOneWidget);
    await _tocar(t, 'Continuar online');
    expect(profissional.online, isTrue);
    await _tocar(t, 'Região de atendimento');
    expect(find.text('10 km'), findsOneWidget);
    await _tocar(t, 'Salvar');
    expect(find.text('Região salva'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
  });
}
