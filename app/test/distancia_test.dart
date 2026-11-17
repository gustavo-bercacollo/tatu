import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/enderecos.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/sugestao_servico.dart';
import 'package:tatu/data/seguranca.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/cliente/atividade/pedido_andamento_page.dart';
import 'package:tatu/features/cliente/chamar/encontrado_page.dart';
import 'package:tatu/features/cliente/chamar/procurando_page.dart';
import 'package:tatu/features/cliente/chamar/som_encontrado.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/entrada/seguranca.dart';
import 'package:tatu/features/profissional/cadastro/como_atende_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/chamado/novo_chamado_page.dart';
import 'package:tatu/features/profissional/chamado/toque_chamado.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';

/// Serviço à distância (RN-92 a RN-98).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in ['400', '500', '600', '700']) {
    f.addFont(rootBundle.load('assets/fonts/Inter-$p.ttf'));
  }
  await f.load();
}

void main() {
  SomEncontrado.ativo = false;
  ToqueChamado.ativo = false;
  setUpAll(_carregarInter);
  setUp(() {
    pedidos.restaurar();
    conversas.restaurar();
    pagamentos.restaurar();
    enderecos.restaurar();
    seguranca.restaurar();
    profissional.demo();
    atendimentoProfissional.restaurar();
    ProcurandoPage.aceitaEm = null;
  });
  tearDown(() => pedidos.restaurar());

  test('RN-92: a IA sugere entre os serviços à distância', () {
    const ia = SugestaoServicoMock();
    const d = 'preciso de um logo para a minha loja de bolos';
    expect(ia.sugerir(d, distancia: true), 'Designer');
    expect(servicosDistanciaHome.contains(ia.sugerir(d, distancia: true)), true);
    expect(ia.sugerir('o cano da pia está vazando'), 'Encanador');
  });

  testWidgets('RN-92/RN-93: Home "À distância"', (t) async {
    await _abrir(t, const HomeClientePage());
    // Padrão: No local.
    expect(find.text('Rua Bruno Lobo, 29'), findsOneWidget);
    expect(find.text('Profissionais ativos perto de você'), findsOneWidget);
    await t.tap(find.text('Encanador'));
    await t.pump();

    await t.tap(find.text('À distância'));
    await t.pump();
    expect(find.text('À distância · de qualquer lugar'), findsOneWidget);
    expect(find.text('Rua Bruno Lobo, 29'), findsNothing);
    for (final s in servicosDistanciaHome) {
      expect(find.text(s), findsOneWidget);
    }
    expect(find.text('Encanador'), findsNothing);
    expect(find.text('Profissionais online agora'), findsOneWidget);
    // A escolha do outro modo não vale aqui.
    expect(find.text('Escolha um serviço'), findsOneWidget);

    await t.enterText(
      find.byType(TextField),
      'preciso de um logo para a minha loja de bolos',
    );
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Chamar designer'), findsOneWidget);
  });

  testWidgets('RN-94: busca em ondas, sem raio', (t) async {
    await _abrir(
      t,
      const ProcurandoPage(
        servico: 'Designer',
        endereco: 'À distância',
        distancia: true,
      ),
    );
    await t.pump();
    expect(find.text('Procurando um designer'), findsOneWidget);
    expect(
      find.text(
        'Avisamos primeiro os mais bem avaliados\nque estão online agora.',
      ),
      findsOneWidget,
    );
    await t.pump(ProcurandoPage.expandeEm);
    expect(
      find.text('Agora avisamos todos os profissionais\nque estão online.'),
      findsOneWidget,
    );
    expect(find.text('Expandindo a busca para sua região…'), findsNothing);
    await t.pump(ProcurandoPage.desisteEm);
    await t.pumpAndSettle();
  });

  testWidgets('RN-93 a RN-96: encontrada, valor só de serviço, entrega', (
    t,
  ) async {
    await _abrir(
      t,
      const EncontradoPage(
        servico: 'Designer',
        endereco: 'À distância',
        distancia: true,
        animar: false,
      ),
    );
    expect(find.text('Encontramos uma designer'), findsOneWidget);
    expect(find.text('Marina Reis'), findsOneWidget);
    expect(find.text('Online agora'), findsOneWidget);
    expect(find.text('Responde em'), findsOneWidget);
    expect(find.text('Chega em'), findsNothing);
    expect(find.text('Estimativa para esse serviço'), findsOneWidget);
    expect(find.text(r'R$ 150 a R$ 600'), findsOneWidget);

    await t.tap(find.text('Aceitar Marina'));
    await t.pumpAndSettle();
    expect(find.byType(ChatPage), findsOneWidget);
    expect(pedidos.andamento?.distancia, isTrue);
    // RN-95: só o serviço.
    expect(find.text('Serviço · sem visita'), findsOneWidget);
    expect(find.text(r'R$ 250,00'), findsOneWidget);
    await t.ensureVisible(find.text('Confirmar valor'));
    await t.pumpAndSettle();
    await t.tap(find.text('Confirmar valor'));
    await t.pump();
    // RN-95: direto para Em andamento; RN-103: o sinal é cobrado agora.
    expect(pedidos.andamento?.situacao, 'Em andamento');
    expect(pedidos.andamento?.sinal, 75);
    expect(find.text(r'Valor confirmado · sinal de R$ 75 pago'), findsOneWidget);
    // RN-99/RN-100: chegam a prévia protegida e a 1ª entrega.
    await t.pump(const Duration(seconds: 4));
    await t.pump();
    expect(find.text('Prévia protegida'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
    await t.pump();
    expect(find.text('Entrega 1 de 2'), findsOneWidget);
  });

  testWidgets('RN-95/RN-98: pedido à distância sem escudo nem endereço', (
    t,
  ) async {
    pedidos.aceitar(
      const PedidoAndamento(
        servico: 'Designer',
        profissao: 'Designer',
        profissional: 'Marina Reis',
        nota: '4,9',
        endereco: 'À distância',
        valor: r'R$ 250,00',
        pagamento: 'Visa 4242',
        etapasFeitas: 3,
        distancia: true,
        sinal: 75,
      ),
    );
    await _abrir(t, const PedidoAndamentoPage());
    await t.pump();
    expect(find.byType(BotaoEscudo), findsNothing);
    expect(find.text('Atendimento'), findsOneWidget);
    expect(find.text('Endereço'), findsNothing);
    expect(find.text('Ligar'), findsNothing);
    // RN-103: sinal pago.
    expect(find.text('Valor combinado · sinal pago'), findsOneWidget);
    expect(find.text('Entrega aprovada'), findsOneWidget);
    expect(find.text('Sinal pago'), findsOneWidget);
    expect(find.text('A caminho'), findsNothing);
  });

  testWidgets('RN-93: novo chamado à distância', (t) async {
    await _abrir(
      t,
      const NovoChamadoPage(chamado: chamadoDistanciaExemplo),
    );
    expect(find.text('À distância'), findsOneWidget);
    expect(find.text('Sem visita'), findsOneWidget);
    expect(find.textContaining('km'), findsNothing);
  });

  testWidgets('RN-95: enviar valor à distância só tem Serviço', (t) async {
    await _abrir(
      t,
      const ChatProfissionalPage(chamado: chamadoDistanciaExemplo),
    );
    await t.pumpAndSettle();
    expect(find.text('À distância'), findsOneWidget);
    expect(find.text('Estou a caminho'), findsNothing);
    await t.tap(find.text('Enviar valor'));
    await t.pumpAndSettle();
    expect(find.text('À distância não tem visita.'), findsOneWidget);
    expect(find.text('Pedir sinal'), findsOneWidget);
    expect(find.text('Visita'), findsNothing);
    expect(find.text('Taxa do Tatu (10%)'), findsOneWidget);
  });

  testWidgets('RN-96/RN-98: em andamento à distância', (t) async {
    await _abrir(
      t,
      EmAndamentoPage(servico: servicoDistanciaExemplo, inicio: DateTime.now()),
    );
    expect(find.byType(BotaoEscudo), findsNothing);
    // RN-96: no lugar de "Concluir serviço", "Enviar entrega".
    expect(find.text('Enviar prévia protegida'), findsOneWidget);
    expect(find.text(r'Sinal R$ 75 · sai na 1ª entrega'), findsOneWidget);
    expect(find.text('Entregas: 0 de 2'), findsOneWidget);
    expect(find.text('Encerrar e cobrar só a visita'), findsNothing);
    expect(find.text('Concluir serviço'), findsNothing);
    expect(find.text('Enviar entrega'), findsOneWidget);
  });

  testWidgets('RN-97: como atende em cada profissão', (t) async {
    await _abrir(t, const ComoAtendePage(indice: 1, edicao: true));
    expect(find.text('Como você atende?'), findsOneWidget);
    expect(find.text('Profissão: Designer.\nVocê pode mudar depois no Perfil.'), findsOneWidget);
    await t.tap(find.text('Os dois'));
    await t.pump();
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(profissional.profissoes[1].modo, ModoAtendimento.ambos);
  });

  test('RN-97: profissão nova vem com o modo mais comum', () {
    expect(modoSugerido('Designer'), ModoAtendimento.distancia);
    expect(modoSugerido('Encanador'), ModoAtendimento.local);
  });

  testWidgets('RN-11/RN-93: Home online escolhe de quais profissões', (
    t,
  ) async {
    profissional.ficarOnline(true);
    await _abrir(
      t,
      const HomeProfissionalPage(chamadoEm: Duration(hours: 1)),
    );
    await t.pump();
    expect(find.text('RECEBER CHAMADOS DE'), findsOneWidget);
    expect(find.text('Buscando chamados de encanador e designer…'), findsOneWidget);
    expect(
      find.text('Designer: à distância, chamados de qualquer cidade.'),
      findsOneWidget,
    );
    await t.tap(find.text('Encanador'));
    await t.pump();
    expect(profissional.recebeNoLocal, isFalse);
    expect(profissional.recebeDistancia, isTrue);
    // Pelo menos uma continua ligada.
    await t.tap(find.text('Designer'));
    await t.pump();
    expect(profissional.chamadosDe, ['Designer']);
    profissional.ficarOnline(false);
    await t.pump();
  });
}
