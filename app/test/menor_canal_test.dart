import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/documentos_legais.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/consulta_cpf.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/cliente/mensagens/mensagens_page.dart';
import 'package:tatu/features/cliente/pagamento/novo_cartao_page.dart';
import 'package:tatu/features/entrada/canal_tatu_page.dart';
import 'package:tatu/features/entrada/dados_cliente_page.dart';
import 'package:tatu/features/entrada/menor_de_idade_page.dart';
import 'package:tatu/features/profissional/cadastro/dados_page.dart';
import 'package:tatu/features/profissional/mensagens/mensagens_profissional_page.dart';

/// Menor de idade (RN-110 a RN-112, RN-114) e canal do Tatu (RN-115 a
/// RN-118).

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

const _cpfMenor = '52998224725';
const _cpfAdulto = '12345678909';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // RN-150: os documentos já lidos (o cadastro registra as versões).
    await documentosLegais.carregarTodos();
  });
  setUpAll(_carregarInter);
  setUp(() {
    consultaCpf = ConsultaCpfMock(demora: Duration.zero);
    conta.restaurar();
    conversas.restaurar();
    conversasProfissional.restaurar();
    pagamentos.restaurar();
    profissional.restaurar();
    canalTatu.restaurar();
  });

  group('RN-110: idade mínima de 18 anos', () {
    final hoje = DateTime(2026, 11, 17);

    test('17 anos e 364 dias bloqueia', () {
      final nascimento = DateTime(2008, 11, 18);
      expect(RegrasIdade.idade(nascimento, hoje), 17);
      expect(RegrasIdade.maiorDeIdade(nascimento, hoje), isFalse);
    });

    test('18 anos exatos entra', () {
      final nascimento = DateTime(2008, 11, 17);
      expect(RegrasIdade.idade(nascimento, hoje), 18);
      expect(RegrasIdade.maiorDeIdade(nascimento, hoje), isTrue);
    });

    test('a idade mínima é uma constante', () {
      expect(RegrasIdade.idadeMinima, 18);
    });

    test('RN-111: a consulta do CPF devolve a data de nascimento', () async {
      final mock = ConsultaCpfMock(demora: Duration.zero)
        ..fixos[_cpfAdulto] = DateTime(2008, 11, 18);
      consultaCpf = mock;
      expect(await consultaCpf.nascimento('123.456.789-09'), DateTime(2008, 11, 18));
      expect(await cpfDeMaior(_cpfMenor), isFalse);
    });
  });

  testWidgets('RN-110/RN-111: cliente menor não entra e a conta não nasce', (
    t,
  ) async {
    await _abrir(t, const DadosClientePage());
    expect(find.text('Seus dados'), findsOneWidget);
    await t.enterText(find.byType(TextField).first, 'Pedro Martins');
    await t.enterText(find.byType(TextField).last, _cpfMenor);
    await t.pump();
    await t.tap(find.bySemanticsLabel(RegExp('^Li e concordo')).first);
    await t.pump();
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(find.byType(MenorDeIdadePage), findsOneWidget);
    expect(find.text('O Tatu é para maiores\nde 18 anos'), findsOneWidget);
    expect(conta.cpf, isNull);
    expect(conta.nome, 'Ana'); // nada foi salvo
  });

  testWidgets('RN-115/RN-116: conta nova tem o Tatu fixado com 1 mensagem', (
    t,
  ) async {
    await _abrir(t, const DadosClientePage());
    await t.enterText(find.byType(TextField).first, 'Bia Souza');
    await t.enterText(find.byType(TextField).last, _cpfAdulto);
    await t.pump();
    await t.tap(find.bySemanticsLabel(RegExp('^Li e concordo')).first);
    await t.pump();
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(conta.nomeCompleto, 'Bia Souza');
    expect(conta.cpf, _cpfAdulto);
    final c = canalTatu.cliente;
    expect(c.mensagens, hasLength(1));
    expect(c.mensagens.single.resumo, 'Oi, Bia! Boas-vindas ao Tatu.');
    expect(c.mensagens.single.cartao?.botao, 'Ver dicas');
    expect(c.naoLidas, 1);

    // Primeiro acesso: Mensagens mostra só o Tatu, fixado.
    conversas.limpar();
    await t.pumpWidget(const SizedBox());
    await _abrir(t, const MensagensPage());
    expect(find.text('Tatu'), findsOneWidget);
    expect(find.text('· Fixada'), findsOneWidget);
    expect(find.text('Oi, Bia! Boas-vindas ao Tatu.'), findsOneWidget);
  });

  testWidgets('RN-112: profissional menor vê o mesmo bloqueio no passo 1', (
    t,
  ) async {
    await _abrir(t, const DadosProfissionalPage());
    final campos = find.byType(TextField);
    await t.enterText(campos.at(0), 'Pedro Vilela');
    await t.enterText(campos.at(1), _cpfMenor);
    await t.enterText(campos.at(2), '11977776666');
    await t.pump();
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(find.byType(MenorDeIdadePage), findsOneWidget);
    expect(profissional.cpf, isEmpty);
  });

  testWidgets('RN-111: titular do cartão também precisa ter 18 anos', (
    t,
  ) async {
    await _abrir(t, NovoCartaoPage(agora: DateTime(2026, 11, 5)));
    final campos = find.byType(TextField);
    await t.enterText(campos.at(0), '5555555555554444');
    await t.enterText(campos.at(1), '0828');
    await t.enterText(campos.at(2), '123');
    await t.enterText(campos.at(3), 'Pedro Martins');
    await t.enterText(campos.at(4), _cpfMenor);
    await t.pump();
    await t.tap(find.text('Salvar cartão'));
    await t.pumpAndSettle();
    expect(
      find.text('O titular do cartão precisa ter 18 anos ou mais.'),
      findsOneWidget,
    );
    expect(pagamentos.cartoes, hasLength(2));
  });

  testWidgets('RN-117/RN-118: só o Tatu envia; "Ver dicas" abre Em breve', (
    t,
  ) async {
    canalTatu.cliente.comecar(boasVindasCliente('Ana'));
    await _abrir(
      t,
      CanalTatuPage(
        canal: canalTatu.cliente,
        onDestino: abrirDestinoTatuCliente,
      ),
    );
    await t.pump();
    expect(find.text('Canal oficial'), findsOneWidget);
    expect(find.text('Só o Tatu envia mensagens neste canal.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(canalTatu.cliente.naoLidas, 0);
    await t.tap(find.text('Ver dicas'));
    await t.pumpAndSettle();
    expect(find.byType(DicasTatuPage), findsOneWidget);
    expect(find.text('Em breve'), findsOneWidget);
    expect(find.text('Avisamos pelo chat do Tatu quando abrir.'), findsOneWidget);
  });

  testWidgets('RN-117: novidade chega e a anterior fica resumida', (t) async {
    await _abrir(
      t,
      CanalTatuPage(
        canal: canalTatu.cliente,
        onDestino: abrirDestinoTatuCliente,
      ),
    );
    await t.pump();
    expect(find.text('+ 2 mensagens'), findsOneWidget);
    expect(find.text('Novidade'), findsOneWidget);
    expect(find.text('Ver como funciona'), findsOneWidget);
    await t.tap(find.text('+ 2 mensagens'));
    await t.pump();
    expect(find.text('Ver dicas'), findsOneWidget);
  });

  testWidgets('RN-115: profissional também tem o Tatu fixado', (t) async {
    conversasProfissional.limpar();
    canalTatu.profissional.comecar(boasVindasProfissional('Luiza'));
    await _abrir(t, const MensagensProfissionalPage());
    expect(find.text('Tatu'), findsOneWidget);
    expect(find.text('Oi, Luiza! Boas-vindas ao Tatu.'), findsOneWidget);
    expect(canalTatu.profissional.mensagens, hasLength(1));
  });

  test('RN-117: mensagens do Tatu chegam como dados (JSON)', () {
    final m = MensagemTatu.fromJson({
      'id': 'novidade-x',
      'em': '2026-11-17T10:02:00',
      'resumo': 'Novidade: pagamento com Pix',
      'titulo': 'Novidade',
      'destaque': 'Agora tem Pix',
      'texto': 'Pague na hora, sem taxa.',
      'link': {'texto': 'Ver como funciona', 'destino': DestinoTatu.dicas},
    });
    expect(m.titulo, 'Novidade');
    expect(m.link?.destino, DestinoTatu.dicas);
    expect(m.baloes, 1);
    final c = CanalTatu()..comecar(boasVindasCliente('Ana'));
    c.receber(m);
    c.receber(m); // a mesma não entra duas vezes
    expect(c.mensagens, hasLength(2));
    expect(c.naoLidas, 2);
  });
}
