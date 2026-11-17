import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/arquivos_seguros.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/filtro_palavras.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/entrada/conta_suspensa_page.dart';
import 'package:tatu/features/profissional/chamado/escolher_entrega.dart';

/// Arquivos seguros (RN-119 a RN-127).

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

void main() {
  late ModeracaoArquivoMock mod;
  setUpAll(_carregarInter);
  setUp(() {
    mod = ModeracaoArquivoMock();
    moderacao = mod;
    verificaLink = VerificaLinkMock();
    segurancaConteudo.restaurar();
    conversas.restaurar();
    pagamentos.restaurar();
  });

  test('RN-119: tipos do chat; .apk no chat bloqueia', () async {
    expect(RegrasArquivo.permitidoNoChat('foto.jpg'), isTrue);
    expect(RegrasArquivo.permitidoNoChat('video.mp4'), isTrue);
    expect(RegrasArquivo.permitidoNoChat('orcamento.pdf'), isTrue);
    for (final n in ['app.apk', 'setup.exe', 'rodar.bat', 'script.sh']) {
      expect(RegrasArquivo.permitidoNoChat(n), isFalse, reason: n);
      expect(
        await segurancaConteudo.enviarNoChat(ArquivoEnviado(n)),
        ResultadoEnvio.tipoNaoPermitido,
      );
    }
    expect(RegrasArquivo.limiteEntregaMb, greaterThan(RegrasArquivo.limiteChatMb));
  });

  test('RN-125: .apk na entrega de Programador passa e na de Designer não', () async {
    const apk = ArquivoEnviado('app-padaria.apk', mb: 32);
    expect(ehTecnologia('Programador'), isTrue);
    expect(ehTecnologia('Designer'), isFalse);
    expect(
      await segurancaConteudo.enviarEntrega(
        apk,
        tecnologia: ehTecnologia('Programador'),
      ),
      ResultadoEnvio.entregue,
    );
    expect(
      await segurancaConteudo.enviarEntrega(
        apk,
        tecnologia: ehTecnologia('Designer'),
      ),
      ResultadoEnvio.tipoNaoPermitido,
    );
    // Link do site vale para qualquer profissão.
    expect(
      await segurancaConteudo.enviarLink('padariadaana.com.br'),
      ResultadoEnvio.entregue,
    );
  });

  test('RN-122: abuso infantil suspende a conta e não apaga a prova', () async {
    mod.marcados['foto.jpg'] = ResultadoModeracao.abusoInfantil;
    final r = await segurancaConteudo.enviarNoChat(
      const ArquivoEnviado('foto.jpg'),
    );
    expect(r, ResultadoEnvio.contaSuspensa);
    expect(segurancaConteudo.suspensa, isTrue);
    expect(segurancaConteudo.provas, hasLength(1));
    expect(segurancaConteudo.provas.single.arquivo, 'foto.jpg');
    expect(segurancaConteudo.registros, hasLength(1));
    // Área protegida: a lista de provas não pode ser apagada.
    expect(() => segurancaConteudo.provas.clear(), throwsUnsupportedError);
    expect(
      () => segurancaConteudo.provas.removeAt(0),
      throwsUnsupportedError,
    );
    expect(segurancaConteudo.provas, hasLength(1));
  });

  test('RN-122/RN-126: nudez repetida e vírus na entrega banem', () async {
    expect(
      await segurancaConteudo.enviarNoChat(const ArquivoEnviado('nudez1.jpg')),
      ResultadoEnvio.barrado,
    );
    expect(segurancaConteudo.banida, isFalse);
    expect(
      await segurancaConteudo.enviarNoChat(const ArquivoEnviado('nudez2.jpg')),
      ResultadoEnvio.contaBanida,
    );
    segurancaConteudo.restaurar();
    expect(
      await segurancaConteudo.enviarNoChat(const ArquivoEnviado('virus.pdf')),
      ResultadoEnvio.barrado,
    );
    expect(segurancaConteudo.banida, isFalse);
    expect(
      await segurancaConteudo.enviarEntrega(
        const ArquivoEnviado('virus.zip'),
        tecnologia: false,
      ),
      ResultadoEnvio.contaBanida,
    );
    // RN-126: link perigoso é barrado.
    expect(
      await segurancaConteudo.enviarLink('https://site-perigoso.com/app'),
      ResultadoEnvio.barrado,
    );
  });

  test('RN-127: prévia só imagem, vídeo ou PDF', () {
    expect(RegrasArquivo.permitidoNaPrevia('logo.png'), isTrue);
    expect(RegrasArquivo.permitidoNaPrevia('demo.mp4'), isTrue);
    expect(RegrasArquivo.permitidoNaPrevia('app.apk'), isFalse);
    expect(RegrasArquivo.permitidoNaPrevia('site.zip'), isFalse);
  });

  test('RN-124: filtro de palavras', () {
    expect(FiltroPalavras.barrada('Vendo pack de fotos'), isNotNull);
    expect(FiltroPalavras.barrada('troca de fotos, chama no privado'), isNotNull);
    expect(FiltroPalavras.barrada('o cano da pia está vazando'), isNull);
    expect(FiltroPalavras.barrada('preciso empacotar a mudança'), isNull);
    FiltroPalavras.lista = [...FiltroPalavras.lista, 'palavra teste'];
    expect(FiltroPalavras.barrada('uma palavra teste aqui'), isNotNull);
  });

  testWidgets('RN-124: link no chat não envia', (t) async {
    final c = conversas.emAndamento.first;
    final antes = c.mensagens.length;
    await _abrir(t, ChatPage(conversa: c));
    await t.enterText(find.byType(TextField), 'olha www.meusite.com.br');
    await t.pump();
    expect(find.text('Links não são permitidos no chat.'), findsOneWidget);
    expect(find.text('Envie o arquivo direto aqui.'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Enviar mensagem'));
    await t.testTextInput.receiveAction(TextInputAction.send);
    await t.pump();
    expect(c.mensagens, hasLength(antes));
  });

  testWidgets('RN-123: segurar o arquivo denuncia e ele some do chat', (
    t,
  ) async {
    final c = conversas.emAndamento.first;
    c.mensagens.add(
      MensagemChat(arquivo: 'fotos.pdf', arquivoDetalhe: 'PDF · 2 MB'),
    );
    await _abrir(t, ChatPage(conversa: c));
    await t.longPress(find.text('fotos.pdf'));
    await t.pumpAndSettle();
    expect(find.text('Denunciar arquivo'), findsOneWidget);
    await t.tap(find.text('Envolve menor de idade'));
    await t.pump();
    await t.tap(find.text('Enviar denúncia'));
    await t.pumpAndSettle();
    expect(find.text('fotos.pdf'), findsNothing);
    expect(segurancaConteudo.denuncias, hasLength(1));
    expect(segurancaConteudo.denuncias.single.motivo, 'Envolve menor de idade');
    expect(segurancaConteudo.denuncias.single.prioridadeMaxima, isTrue);
  });

  testWidgets('RN-125: na entrega do Designer, programa não passa', (t) async {
    EntregaEscolhida? escolha;
    await _abrir(
      t,
      Builder(
        builder: (ctx) => Center(
          child: TextButton(
            onPressed: () async => escolha = await escolherEntrega(
              ctx,
              numero: 1,
              cliente: 'Ana',
              tecnologia: ehTecnologia('Designer'),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    expect(find.text('Entrega 1 de 2'), findsOneWidget);
    expect(find.text('Verificamos o link antes de chegar à Ana.\nNo chat, links não são permitidos.'), findsOneWidget);
    await t.tap(find.text('Arquivo'));
    await t.pump();
    await t.tap(find.text('app-padaria.apk'));
    await t.pump();
    expect(
      find.text('Programa e código só em profissões de tecnologia.'),
      findsOneWidget,
    );
    await t.tap(find.widgetWithText(FilledButton, 'Enviar entrega'));
    await t.pump();
    expect(escolha, isNull);
    await t.tap(find.text('entrega-final.zip'));
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, 'Enviar entrega'));
    await t.pumpAndSettle();
    expect(escolha?.arquivo?.nome, 'entrega-final.zip');
  });

  testWidgets('RN-126: executável no cliente: só baixa, com aviso', (t) async {
    final c = conversas.comecar(
      nome: 'Diego Rocha',
      profissao: 'Programador',
      feminino: false,
      servico: 'Programador',
      rua: 'À distância',
      distancia: true,
    );
    conversas.confirmarValor(c);
    conversas.receberEntrega(
      c,
      arquivo: 'app-padaria.apk',
      detalhe: 'APK · 32 MB · sem vírus',
      em: clock.now(),
    );
    await _abrir(t, ChatPage(conversa: c));
    expect(
      find.text('Arquivo executável · abra só se você pediu'),
      findsOneWidget,
    );
    expect(
      find.text('O Tatu não abre nem roda este arquivo. Só baixa.'),
      findsOneWidget,
    );
  });

  testWidgets('RN-122: tela de conta suspensa não diz o motivo', (t) async {
    await _abrir(t, const ContaSuspensaPage());
    expect(find.text('Conta suspensa'), findsOneWidget);
    expect(
      find.text('Sua conta foi suspensa por\nnão seguir as regras do Tatu.'),
      findsOneWidget,
    );
    expect(find.text('Ler as regras do Tatu'), findsOneWidget);
    expect(find.text('Falar com o suporte'), findsOneWidget);
    expect(find.textContaining('abuso'), findsNothing);
  });

  testWidgets('RN-124: pedido com palavra barrada não chama', (t) async {
    await _abrir(t, const HomeClientePage());
    await t.enterText(find.byType(TextField), 'vendo pack de fotos do cano');
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Encanador'));
    await t.pump();
    await t.tap(find.text('Chamar encanador'));
    await t.pump();
    expect(find.text(FiltroPalavras.aviso), findsOneWidget);
  });
}
