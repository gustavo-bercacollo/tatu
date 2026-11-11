// Gera as imagens das telas do app para o fluxograma (docs/fluxo/app/).
// Uso (dentro de app/):
//   flutter test tool/capturas_test.dart --update-goldens
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/cadastro/dados_page.dart';
import 'package:tatu/features/profissional/cadastro/especialidades_page.dart';
import 'package:tatu/features/profissional/cadastro/pix_page.dart';
import 'package:tatu/features/profissional/cadastro/profissoes_page.dart';
import 'package:tatu/features/profissional/cadastro/resultado_page.dart';
import 'package:tatu/features/profissional/cadastro/servicos_page.dart';
import 'package:tatu/features/profissional/cadastro/verificacao_page.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';
import 'package:tatu/features/profissional/perfil/perfil_profissional_page.dart';
import 'package:tatu/features/profissional/perfil/previa_page.dart';
import 'package:tatu/features/profissional/perfil/regiao_page.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/ajuda.dart';
import 'package:tatu/data/avaliacoes.dart';
import 'package:tatu/data/chamado.dart';
import 'package:tatu/features/cliente/chamar/fora_da_area_page.dart';
import 'package:tatu/features/cliente/chamar/imprevisto_page.dart';
import 'package:tatu/features/cliente/chamar/localizacao_chamar_page.dart';
import 'package:tatu/features/cliente/chamar/ninguem_ativo_page.dart';
import 'package:tatu/features/cliente/chamar/procurando_page.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/cliente/mensagens/denunciar_page.dart';
import 'package:tatu/features/cliente/mensagens/mensagens_page.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/atividade/atividade_page.dart';
import 'package:tatu/features/cliente/atividade/avaliar_page.dart';
import 'package:tatu/features/cliente/atividade/recibo_page.dart';
import 'package:tatu/features/cliente/atividade/pedido_andamento_page.dart';
import 'package:tatu/features/cliente/atividade/pedido_cancelado_page.dart';
import 'package:tatu/features/cliente/atividade/pedido_concluido_page.dart';
import 'package:tatu/data/documentos.dart';
import 'package:tatu/features/cliente/privacidade/baixar_dados_page.dart';
import 'package:tatu/features/cliente/privacidade/documento_page.dart';
import 'package:tatu/features/cliente/privacidade/permissoes_page.dart';
import 'package:tatu/features/cliente/privacidade/privacidade_page.dart';
import 'package:tatu/features/cliente/privacidade/seus_dados_page.dart';
import 'package:tatu/features/cliente/ajuda/ajuda_page.dart';
import 'package:tatu/features/cliente/ajuda/artigo_page.dart';
import 'package:tatu/features/cliente/ajuda/assunto_page.dart';
import 'package:tatu/features/cliente/ajuda/busca_ajuda_page.dart';
import 'package:tatu/features/cliente/ajuda/chat_suporte_page.dart';
import 'package:tatu/features/cliente/ajuda/escolher_pedido_page.dart';
import 'package:tatu/features/cliente/ajuda/suporte_assunto_page.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/features/cliente/conta/dados_conta_page.dart';
import 'package:tatu/features/cliente/conta/editar_nome_page.dart';
import 'package:tatu/features/cliente/conta/excluir_bloqueado_page.dart';
import 'package:tatu/features/cliente/conta/excluir_conta_page.dart';
import 'package:tatu/features/cliente/conta/novo_celular_page.dart';
import 'package:tatu/features/cliente/conta/novo_email_page.dart';
import 'package:tatu/data/enderecos.dart';
import 'package:tatu/data/notificacoes.dart';
import 'package:tatu/data/perfil.dart';
import 'package:tatu/features/cliente/foto/ajustar_foto_page.dart';
import 'package:tatu/features/cliente/foto/camera_desativada_page.dart';
import 'package:tatu/features/cliente/foto/escolher_avatar_page.dart';
import 'package:tatu/features/cliente/notificacoes/notificacoes_page.dart';
import 'package:tatu/features/cliente/avaliacoes/avaliacao_page.dart';
import 'package:tatu/features/cliente/avaliacoes/minhas_avaliacoes_page.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/features/cliente/pagamento/cartao_page.dart';
import 'package:tatu/features/cliente/pagamento/novo_cartao_page.dart';
import 'package:tatu/features/cliente/pagamento/pagamento_page.dart';
import 'package:tatu/features/cliente/endereco/buscar_endereco_page.dart';
import 'package:tatu/features/cliente/endereco/confirmar_endereco_page.dart';
import 'package:tatu/features/cliente/endereco/editar_endereco_page.dart';
import 'package:tatu/features/cliente/endereco/enderecos_page.dart';
import 'package:tatu/features/cliente/endereco/localizacao_desativada_page.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/cliente/perfil_page.dart';
import 'package:tatu/features/entrada/boas_vindas_page.dart';
import 'package:tatu/features/profissional/cadastro/boas_vindas_profissional_page.dart';
import 'package:tatu/features/entrada/celular_page.dart';
import 'package:tatu/features/entrada/codigo_page.dart';
import 'package:tatu/features/entrada/email_page.dart';
import 'package:tatu/features/entrada/nome_page.dart';

Future<void> _carregarFontes() async {
  final inter = FontLoader('Inter');
  for (final w in [400, 500, 600, 700]) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();

  final cache = Directory(
    '${Platform.environment['LOCALAPPDATA']}/Pub/Cache/hosted/pub.dev',
  );
  final pacote = cache.listSync().whereType<Directory>().lastWhere(
    (d) => d.path.contains('flutter_tabler_icons-'),
  );
  final tabler = File('${pacote.path}/assets/fonts/tabler-icons.ttf');
  await (FontLoader('packages/flutter_tabler_icons/tabler-icons')
        ..addFont(Future.value(ByteData.sublistView(tabler.readAsBytesSync()))))
      .load();
}

Future<void> _capturar(
  WidgetTester tester,
  String nome,
  Widget tela, {
  Future<void> Function()? preparar,
}) async {
  tester.view.physicalSize = const Size(786, 1704); // 393×852 @2x
  tester.view.devicePixelRatio = 2;
  enderecos.restaurar();
  pagamentos.restaurar();
  avaliacoes.restaurar();
  notificacoes.restaurar();
  perfil.restaurar();
  conta.restaurar();
  pedidos.restaurar();
  conversas.restaurar();
  chamado.restaurar();
  profissional.restaurar();
  await tester.pumpWidget(
    MaterialApp(
      theme: tatuTheme(),
      debugShowCheckedModeBanner: false,
      home: tela,
    ),
  );
  await tester.pump();
  if (preparar != null) await preparar();
  await tester.pump(const Duration(milliseconds: 600)); // fim das animações
  // Carrega de verdade as imagens (avatares) antes de capturar.
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
  // A tela inteira do app (inclui folhas abertas por cima da página).
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/fluxo/app/$nome.png'),
  );
  await tester.pumpWidget(const SizedBox()); // encerra timers da tela
}

void main() {
  setUpAll(_carregarFontes);

  testWidgets('boas-vindas', (t) async {
    await _capturar(t, 'boas-vindas', const BoasVindasPage());
  });

  testWidgets('pro-boas-vindas', (t) async {
    await _capturar(t, 'pro-boas-vindas', const BoasVindasProfissionalPage());
  });

  testWidgets('celular', (t) async {
    await _capturar(
      t,
      'celular',
      const CelularPage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), '11988887777');
        await t.pump();
        await t.pump();
      },
    );
  });

  testWidgets('codigo', (t) async {
    await _capturar(
      t,
      'codigo',
      const CodigoPage(destino: '(11) 98888-7777'),
      preparar: () async {
        await t.enterText(find.byType(TextField), '4827');
        await t.pump(const Duration(seconds: 18));
      },
    );
  });

  testWidgets('entrar', (t) async {
    await _capturar(
      t,
      'entrar',
      const CelularPage.entrar(),
      preparar: () async {
        await t.enterText(find.byType(TextField), '11988887777');
        await t.pump();
        await t.pump();
      },
    );
  });

  testWidgets('email', (t) async {
    await _capturar(
      t,
      'email',
      const EmailPage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), 'ana@email.com');
        await t.pump();
      },
    );
  });

  testWidgets('codigo-email', (t) async {
    await _capturar(
      t,
      'codigo-email',
      const CodigoPage.email(destino: 'ana@email.com'),
      preparar: () async {
        await t.enterText(find.byType(TextField), '4827');
        await t.pump(const Duration(seconds: 18));
      },
    );
  });

  testWidgets('endereco-folha', (t) async {
    await _capturar(
      t,
      'endereco-folha',
      const HomeClientePage(),
      preparar: () async {
        await t.tap(find.text('Rua Bruno Lobo, 29'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('endereco-busca', (t) async {
    await _capturar(
      t,
      'endereco-busca',
      const BuscarEnderecoPage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), 'Rua Bruno Lo');
        await t.pump();
      },
    );
  });

  testWidgets('endereco-mapa', (t) async {
    await _capturar(
      t,
      'endereco-mapa',
      const ConfirmarEnderecoPage(resultado: EnderecosRepo.localAtual),
    );
  });

  testWidgets('localizacao-desativada', (t) async {
    await _capturar(
      t,
      'localizacao-desativada',
      const LocalizacaoDesativadaPage(),
    );
  });

  testWidgets('enderecos', (t) async {
    await _capturar(t, 'enderecos', const EnderecosPage());
  });

  testWidgets('enderecos-vazio', (t) async {
    await _capturar(
      t,
      'enderecos-vazio',
      const EnderecosPage(),
      preparar: () async {
        for (final e in enderecos.salvos) {
          enderecos.excluir(e.id);
        }
        await t.pump();
      },
    );
  });

  testWidgets('editar-endereco', (t) async {
    final casa = EnderecosRepo().salvos.first;
    await _capturar(
      t,
      'editar-endereco',
      EditarEnderecoPage(endereco: casa),
      preparar: () async {
        // Foco sem toque (o toque desenharia a alça de seleção do texto).
        t
            .state<EditableTextState>(find.byType(EditableText).at(2))
            .requestKeyboard();
        await t.pump();
      },
    );
  });

  testWidgets('pagamento', (t) async {
    await _capturar(t, 'pagamento', const PagamentoPage());
  });

  testWidgets('pagamento-vazio', (t) async {
    await _capturar(
      t,
      'pagamento-vazio',
      const PagamentoPage(),
      preparar: () async {
        for (final c in pagamentos.cartoes) {
          pagamentos.remover(c);
        }
        await t.pump();
      },
    );
  });

  Future<void> preencherCartao(WidgetTester t, String numero) async {
    final campos = find.byType(TextField);
    await t.enterText(campos.at(0), numero);
    await t.enterText(campos.at(1), '0828');
    await t.enterText(campos.at(2), '123');
    await t.enterText(campos.at(3), 'ANA MARTINS');
    await t.enterText(campos.at(4), '12345678900');
    await t.pump();
  }

  testWidgets('novo-cartao', (t) async {
    await _capturar(
      t,
      'novo-cartao',
      NovoCartaoPage(agora: DateTime(2026, 11, 5)),
      preparar: () async {
        await preencherCartao(t, '4242424242424242');
        t
            .state<EditableTextState>(find.byType(EditableText).at(0))
            .requestKeyboard();
        await t.pump();
      },
    );
  });

  testWidgets('novo-cartao-recusado', (t) async {
    await _capturar(
      t,
      'novo-cartao-recusado',
      NovoCartaoPage(agora: DateTime(2026, 11, 5)),
      preparar: () async {
        await preencherCartao(t, '4000000000000002');
        await t.tap(find.text('Salvar cartão'));
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  testWidgets('cartao', (t) async {
    await _capturar(
      t,
      'cartao',
      CartaoPage(cartao: PagamentosRepo().cartoes.first),
    );
  });

  testWidgets('cartao-remover', (t) async {
    await _capturar(
      t,
      'cartao-remover',
      CartaoPage(cartao: PagamentosRepo().cartoes.first),
      preparar: () async {
        await t.tap(find.text('Remover cartão'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('avaliacoes-recebidas', (t) async {
    await _capturar(t, 'avaliacoes-recebidas', const MinhasAvaliacoesPage());
  });

  testWidgets('avaliacoes-enviadas', (t) async {
    await _capturar(
      t,
      'avaliacoes-enviadas',
      const MinhasAvaliacoesPage(aba: 1),
    );
  });

  testWidgets('avaliacoes-vazio', (t) async {
    await _capturar(
      t,
      'avaliacoes-vazio',
      const MinhasAvaliacoesPage(),
      preparar: () async {
        avaliacoes.limpar();
        await t.pump();
      },
    );
  });

  testWidgets('avaliacao-detalhe', (t) async {
    await _capturar(
      t,
      'avaliacao-detalhe',
      AvaliacaoPage(avaliacao: AvaliacoesRepo().recebidas.first),
    );
  });

  testWidgets('notificacoes', (t) async {
    await _capturar(t, 'notificacoes', const NotificacoesPage());
  });

  testWidgets('notificacoes-desativadas', (t) async {
    await _capturar(
      t,
      'notificacoes-desativadas',
      const NotificacoesPage(),
      preparar: () async {
        notificacoes.negarNoCelular();
        await t.pump();
      },
    );
  });

  testWidgets('notificacoes-desligar', (t) async {
    await _capturar(
      t,
      'notificacoes-desligar',
      const NotificacoesPage(),
      preparar: () async {
        await t.tap(find.byType(CupertinoSwitch).first);
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('perfil-cliente', (t) async {
    await _capturar(t, 'perfil-cliente', const PerfilClientePage());
  });

  testWidgets('foto-perfil', (t) async {
    await _capturar(
      t,
      'foto-perfil',
      const PerfilClientePage(),
      preparar: () async {
        await t.tap(find.bySemanticsLabel(RegExp('^Foto do perfil')));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('escolher-avatar', (t) async {
    await _capturar(t, 'escolher-avatar', const EscolherAvatarPage());
  });

  testWidgets('ajustar-foto', (t) async {
    final bytes = File('assets/avatares/avatar-1.png').readAsBytesSync();
    await _capturar(
      t,
      'ajustar-foto',
      AjustarFotoPage(imagem: bytes),
      preparar: () async {
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await t.pump();
      },
    );
  });

  testWidgets('foto-atualizada', (t) async {
    await _capturar(
      t,
      'foto-atualizada',
      const PerfilClientePage(),
      preparar: () async {
        await t.tap(find.bySemanticsLabel(RegExp('^Foto do perfil')));
        await t.pumpAndSettle();
        await t.tap(find.text('Escolher um avatar'));
        await t.pumpAndSettle();
        await t.tap(find.text('Salvar avatar'));
        await t.pump(const Duration(milliseconds: 600));
      },
    );
  });

  testWidgets('camera-desativada', (t) async {
    await _capturar(t, 'camera-desativada', const CameraDesativadaPage());
  });

  testWidgets('dados-conta', (t) async {
    await _capturar(t, 'dados-conta', const DadosContaPage());
  });

  testWidgets('editar-nome', (t) async {
    await _capturar(t, 'editar-nome', const EditarNomePage());
  });

  testWidgets('novo-celular', (t) async {
    await _capturar(
      t,
      'novo-celular',
      const NovoCelularPage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), '11977776666');
        await t.pump();
      },
    );
  });

  testWidgets('codigo-celular', (t) async {
    await _capturar(
      t,
      'codigo-celular',
      const NovoCelularPage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), '11977776666');
        await t.pump();
        await t.tap(find.text('Enviar código'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), '4827');
        await t.pump(const Duration(seconds: 18));
      },
    );
  });

  testWidgets('novo-email', (t) async {
    await _capturar(t, 'novo-email', const NovoEmailPage());
  });

  testWidgets('celular-atualizado', (t) async {
    await _capturar(
      t,
      'celular-atualizado',
      const DadosContaPage(),
      preparar: () async {
        await t.tap(find.text('+55 (11) 98888-7777'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), '11977776666');
        await t.pump();
        await t.tap(find.text('Enviar código'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), '482719');
        await t.pump();
        if (find.text('Confirmar').evaluate().isNotEmpty) {
          await t.tap(find.text('Confirmar'));
        }
        await t.pump(const Duration(milliseconds: 600));
        await t.pump(const Duration(milliseconds: 600));
      },
    );
  });

  testWidgets('excluir-conta', (t) async {
    await _capturar(t, 'excluir-conta', const ExcluirContaPage());
  });

  testWidgets('excluir-confirmar', (t) async {
    await _capturar(
      t,
      'excluir-confirmar',
      const DadosContaPage(),
      preparar: () async {
        await t.tap(find.text('Excluir conta'));
        await t.pumpAndSettle();
        await t.tap(find.text('Excluir minha conta'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('excluir-bloqueado', (t) async {
    await _capturar(t, 'excluir-bloqueado', const ExcluirBloqueadoPage());
  });

  testWidgets('ajuda', (t) async {
    await _capturar(t, 'ajuda', const AjudaPage());
  });

  testWidgets('ajuda-assunto', (t) async {
    await _capturar(t, 'ajuda-assunto', AssuntoPage(assunto: assuntosAjuda[1]));
  });

  testWidgets('ajuda-artigo', (t) async {
    await _capturar(
      t,
      'ajuda-artigo',
      const ArtigoPage(artigo: artigoPagamento),
    );
  });

  testWidgets('ajuda-busca', (t) async {
    await _capturar(t, 'ajuda-busca', const BuscaAjudaPage(termo: 'pix'));
  });

  testWidgets('ajuda-busca-vazia', (t) async {
    await _capturar(
      t,
      'ajuda-busca-vazia',
      const BuscaAjudaPage(termo: 'reembolso de cripto'),
    );
  });

  testWidgets('suporte-assunto', (t) async {
    await _capturar(t, 'suporte-assunto', const SuporteAssuntoPage());
  });

  testWidgets('suporte-pedido', (t) async {
    await _capturar(t, 'suporte-pedido', const EscolherPedidoPage());
  });

  testWidgets('chat-suporte', (t) async {
    await _capturar(
      t,
      'chat-suporte',
      ChatSuportePage(pedido: pedidosRecentes.first),
      preparar: () async {
        await t.enterText(
          find.byType(TextField),
          'Cobraram duas vezes no cartão.',
        );
        await t.testTextInput.receiveAction(TextInputAction.send);
        await t.pump(const Duration(seconds: 2));
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  testWidgets('privacidade', (t) async {
    await _capturar(t, 'privacidade', const PrivacidadePage());
  });

  testWidgets('termos-de-uso', (t) async {
    await _capturar(
      t,
      'termos-de-uso',
      const DocumentoPage(documento: termosDeUso),
    );
  });

  testWidgets('politica-privacidade', (t) async {
    await _capturar(
      t,
      'politica-privacidade',
      const DocumentoPage(
        documento: politicaDePrivacidade,
        linkSeusDados: true,
      ),
    );
  });

  testWidgets('permissoes', (t) async {
    await _capturar(
      t,
      'permissoes',
      const PermissoesPage(),
      preparar: () async {
        perfil.definirPermissoes(fotos: false); // como no desenho
        await t.pump();
      },
    );
  });

  testWidgets('seus-dados', (t) async {
    await _capturar(t, 'seus-dados', const SeusDadosPage());
  });

  testWidgets('baixar-dados', (t) async {
    await _capturar(t, 'baixar-dados', const BaixarDadosPage());
  });

  testWidgets('baixar-dados-enviado', (t) async {
    await _capturar(t, 'baixar-dados-enviado', const DadosPedidosPage());
  });

  testWidgets('atividade', (t) async {
    await _capturar(t, 'atividade', const AtividadePage());
  });

  testWidgets('atividade-concluidos', (t) async {
    await _capturar(t, 'atividade-concluidos', const AtividadePage(aba: 1));
  });

  testWidgets('atividade-vazio', (t) async {
    await _capturar(
      t,
      'atividade-vazio',
      const AtividadePage(),
      preparar: () async {
        pedidos.limpar();
        await t.pump();
      },
    );
  });

  testWidgets('atividade-concluidos-vazio', (t) async {
    await _capturar(
      t,
      'atividade-concluidos-vazio',
      const AtividadePage(aba: 1),
      preparar: () async {
        pedidos.limpar();
        await t.pump();
      },
    );
  });

  testWidgets('atividade-ninguem-aceitou', (t) async {
    await _capturar(
      t,
      'atividade-ninguem-aceitou',
      const AtividadePage(),
      preparar: () async {
        pedidos.cancelarAndamento();
        await t.pump();
      },
    );
  });

  testWidgets('pedido-andamento', (t) async {
    await _capturar(t, 'pedido-andamento', const PedidoAndamentoPage());
  });

  testWidgets('pedido-cancelar', (t) async {
    await _capturar(
      t,
      'pedido-cancelar',
      const PedidoAndamentoPage(),
      preparar: () async {
        await t.tap(find.text('Cancelar pedido'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pedido-cancelado', (t) async {
    await _capturar(
      t,
      'pedido-cancelado',
      const PedidoCanceladoPage(profissional: 'Luiza'),
    );
  });

  testWidgets('pedido-concluido', (t) async {
    await _capturar(
      t,
      'pedido-concluido',
      PedidoConcluidoPage(pedido: PedidosRepo().concluidos.first),
    );
  });

  testWidgets('mensagens', (t) async {
    await _capturar(
      t,
      'mensagens',
      const MensagensPage(),
      preparar: () async {
        conversas.definirCobranca(true);
        await t.pump();
      },
    );
  });

  testWidgets('mensagens-lista', (t) async {
    await _capturar(t, 'mensagens-lista', const MensagensPage());
  });

  testWidgets('mensagens-vazio', (t) async {
    await _capturar(
      t,
      'mensagens-vazio',
      const MensagensPage(),
      preparar: () async {
        conversas.limpar();
        await t.pump();
      },
    );
  });

  testWidgets('chat', (t) async {
    await _capturar(
      t,
      'chat',
      ChatPage(conversa: ConversasRepo().conversas.first),
    );
  });

  testWidgets('chat-anexar', (t) async {
    await _capturar(
      t,
      'chat-anexar',
      ChatPage(conversa: ConversasRepo().conversas.first),
      preparar: () async {
        await t.tap(find.bySemanticsLabel('Enviar foto'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('chat-foto', (t) async {
    final c = ConversasRepo().conversas.first
      ..mensagens.add(MensagemChat(minha: true, foto: true, hora: '14:32'));
    await _capturar(t, 'chat-foto', ChatPage(conversa: c));
  });

  testWidgets('chat-nao-enviada', (t) async {
    final c = ConversasRepo().conversas.first
      ..mensagens.add(
        MensagemChat(
          texto: 'Pode ser às 15h?',
          minha: true,
          envio: EnvioMensagem.falhou,
        ),
      );
    await _capturar(t, 'chat-nao-enviada', ChatPage(conversa: c));
  });

  testWidgets('chat-encerrado', (t) async {
    final l = ConversasRepo().conversas.first;
    final c = Conversa(
      nome: l.nome,
      profissao: l.profissao,
      feminino: l.feminino,
      servico: l.servico,
      descricao: l.descricao,
      rua: l.rua,
      quando: '04 nov',
      concluidoEm: '04 nov',
      mensagens: l.mensagens,
    );
    await _capturar(t, 'chat-encerrado', ChatPage(conversa: c));
  });

  testWidgets('chat-menu', (t) async {
    await _capturar(
      t,
      'chat-menu',
      ChatPage(conversa: ConversasRepo().conversas.first),
      preparar: () async {
        await t.tap(find.bySemanticsLabel(RegExp('^Opções da conversa')));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('chat-denunciar', (t) async {
    await _capturar(
      t,
      'chat-denunciar',
      DenunciarPage(conversa: ConversasRepo().conversas.first, motivo: 1),
    );
  });

  testWidgets('chat-denuncia-enviada', (t) async {
    await _capturar(t, 'chat-denuncia-enviada', const DenunciaEnviadaPage());
  });

  Future<void> descrever(WidgetTester t) async {
    await t.enterText(
      find.byType(TextField),
      'o cano da pia da cozinha está vazando e a água não para',
    );
    await t.pump(const Duration(milliseconds: 600));
  }

  testWidgets('home-fotos', (t) async {
    final bytes = File('assets/avatares/avatar-2.png').readAsBytesSync();
    await _capturar(
      t,
      'home-fotos',
      const HomeClientePage(),
      preparar: () async {
        perfil.escolherImagem = (_) async => bytes;
        await descrever(t);
        for (var i = 0; i < 2; i++) {
          await t.tap(find.bySemanticsLabel('Enviar foto'));
          await t.pumpAndSettle();
          await t.tap(find.text('Escolher da galeria'));
          await t.pumpAndSettle();
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  testWidgets('chamar-celular', (t) async {
    await _capturar(
      t,
      'chamar-celular',
      const HomeClientePage(),
      preparar: () async {
        conta.cadastrou(email: 'ana@email.com');
        await descrever(t);
        await t.tap(find.text('Chamar encanador'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).last, '11988887777');
        await t.pump();
      },
    );
  });

  testWidgets('chamar-ja-tem-pedido', (t) async {
    await _capturar(
      t,
      'chamar-ja-tem-pedido',
      const HomeClientePage(),
      preparar: () async {
        await descrever(t);
        FocusManager.instance.primaryFocus?.unfocus();
        await t.tap(find.text('Chamar encanador'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('chamar-localizacao', (t) async {
    await _capturar(t, 'chamar-localizacao', const LocalizacaoChamarPage());
  });

  testWidgets('chamar-fora-da-area', (t) async {
    await _capturar(t, 'chamar-fora-da-area', const ForaDaAreaPage());
  });

  testWidgets('chamar-imprevisto', (t) async {
    await _capturar(
      t,
      'chamar-imprevisto',
      ImprevistoPage(pedido: PedidosRepo().andamento!),
    );
  });

  testWidgets('chamar-outro', (t) async {
    final p = PedidosRepo().andamento!;
    await _capturar(
      t,
      'chamar-outro',
      ProcurandoPage(
        servico: p.servico,
        endereco: p.endereco,
        anterior: p,
        animar: false,
      ),
    );
  });

  testWidgets('procurando', (t) async {
    await _capturar(
      t,
      'procurando',
      const ProcurandoPage(
        servico: 'Encanador',
        endereco: 'Rua Bruno Lobo, 29',
        animar: false,
      ),
    );
  });

  testWidgets('procurando-expandindo', (t) async {
    await _capturar(
      t,
      'procurando-expandindo',
      const ProcurandoPage(
        servico: 'Encanador',
        endereco: 'Rua Bruno Lobo, 29',
        animar: false,
        fase: FaseBusca.expandindo,
      ),
    );
  });

  testWidgets('procurando-ninguem', (t) async {
    await _capturar(
      t,
      'procurando-ninguem',
      const NinguemAtivoPage(servico: 'Encanador'),
    );
  });

  Future<void> abrirOutros(WidgetTester t) async {
    await t.tap(find.text('Outros'));
    await t.pumpAndSettle();
  }

  testWidgets('outros-lista', (t) async {
    await _capturar(
      t,
      'outros-lista',
      const HomeClientePage(),
      preparar: () => abrirOutros(t),
    );
  });

  testWidgets('outros-busca', (t) async {
    await _capturar(
      t,
      'outros-busca',
      const HomeClientePage(),
      preparar: () async {
        await abrirOutros(t);
        await t.enterText(find.byType(TextField).last, 'desent');
        await t.pump();
      },
    );
  });

  testWidgets('outros-busca-vazia', (t) async {
    await _capturar(
      t,
      'outros-busca-vazia',
      const HomeClientePage(),
      preparar: () async {
        await abrirOutros(t);
        await t.enterText(find.byType(TextField).last, 'afinador de piano');
        await t.pump();
      },
    );
  });

  testWidgets('outros-escolhido', (t) async {
    await _capturar(
      t,
      'outros-escolhido',
      const HomeClientePage(),
      preparar: () async {
        await t.enterText(
          find.byType(TextField),
          'a fechadura da porta emperrou',
        );
        await t.pump(const Duration(milliseconds: 600));
        FocusManager.instance.primaryFocus?.unfocus();
        await abrirOutros(t);
        await t.tap(find.text('Chaveiro').last);
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('outros-nao-sei', (t) async {
    await _capturar(
      t,
      'outros-nao-sei',
      const HomeClientePage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), 'meu piano está desafinado');
        await t.pump(const Duration(milliseconds: 600));
        FocusManager.instance.primaryFocus?.unfocus();
        await abrirOutros(t);
        await t.tap(find.text('Não sei qual serviço'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('outros-nao-sei-sem-descricao', (t) async {
    await _capturar(
      t,
      'outros-nao-sei-sem-descricao',
      const HomeClientePage(),
      preparar: () async {
        await abrirOutros(t);
        await t.tap(find.text('Não sei qual serviço'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('avaliar', (t) async {
    await _capturar(
      t,
      'avaliar',
      AvaliarPage(pedido: PedidosRepo().concluidos.first),
      preparar: () async {
        await t.tap(find.bySemanticsLabel('4 estrelas'));
        await t.tap(find.text('Pontual'));
        await t.tap(find.text('Educada'));
        await t.pump();
      },
    );
  });

  testWidgets('sua-avaliacao', (t) async {
    await _capturar(
      t,
      'sua-avaliacao',
      SuaAvaliacaoPage(pedido: PedidosRepo().concluidos[1]),
    );
  });

  testWidgets('recibo', (t) async {
    await _capturar(
      t,
      'recibo',
      ReciboPage(pedido: PedidosRepo().concluidos.first),
    );
  });

  testWidgets('comprovante', (t) async {
    await _capturar(
      t,
      'comprovante',
      ReciboPage(pedido: PedidosRepo().concluidos[1]),
    );
  });

  testWidgets('pedir-de-novo', (t) async {
    await _capturar(
      t,
      'pedir-de-novo',
      const AtividadePage(aba: 1),
      preparar: () async {
        await t.tap(find.text('Pedir de novo').first);
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pedir-de-novo-offline', (t) async {
    await _capturar(
      t,
      'pedir-de-novo-offline',
      const AtividadePage(aba: 1),
      preparar: () async {
        await t.tap(find.text('Pedir de novo').at(1));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('chamando-mesmo', (t) async {
    await _capturar(
      t,
      'chamando-mesmo',
      const ProcurandoPage(
        servico: 'Encanador',
        endereco: 'Rua das Flores, 120',
        direto: 'Luiza',
        animar: false,
      ),
    );
  });

  testWidgets('home-vazia', (t) async {
    await _capturar(t, 'home-vazia', const HomeClientePage());
  });

  testWidgets('home-ia', (t) async {
    await _capturar(
      t,
      'home-ia',
      const HomeClientePage(),
      preparar: () async {
        await t.enterText(
          find.byType(TextField),
          'o cano da pia da cozinha está vazando e a água não para',
        );
        await t.pump(const Duration(milliseconds: 600));
      },
    );
  });

  testWidgets('nome', (t) async {
    await _capturar(
      t,
      'nome',
      const NomePage(),
      preparar: () async {
        await t.enterText(find.byType(TextField).first, 'Ana');
        await t.enterText(find.byType(TextField).last, 'Martins');
        await t.pump();
      },
    );
  });

  // ── Profissional ──────────────────────────────────────────────
  void cadastroEmCurso() {
    profissional.salvarDados(
      nome: 'Luiza Vilela',
      cpf: '12345678909',
      celular: '11977776666',
    );
    profissional.feminino = true;
  }

  testWidgets('pro-dados', (t) async {
    await _capturar(t, 'pro-dados', const DadosProfissionalPage());
  });

  testWidgets('pro-servicos', (t) async {
    await _capturar(
      t,
      'pro-servicos',
      const ServicosProfissionalPage(),
      preparar: () async {
        await t.tap(find.text('Encanador'));
        await t.tap(find.text('Eletricista'));
        await t.pump();
      },
    );
  });

  testWidgets('pro-outras', (t) async {
    await _capturar(
      t,
      'pro-outras',
      const ServicosProfissionalPage(),
      preparar: () async {
        await t.tap(find.text('Outros'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-especialidades', (t) async {
    await _capturar(
      t,
      'pro-especialidades',
      const SizedBox(),
      preparar: () async {
        profissional.definirProfissoes(const [
          ProfissaoEscolhida('Encanador'),
          ProfissaoEscolhida('Eletricista'),
        ]);
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const EspecialidadesPage(indice: 0),
          ),
        );
        await t.tap(find.text('Reparos'));
        await t.tap(find.text('Instalações'));
        await t.tap(find.text('Esgoto'));
        await t.pump();
      },
    );
  });

  testWidgets('pro-profissoes', (t) async {
    await _capturar(
      t,
      'pro-profissoes',
      const ProfissoesPage(),
      preparar: () async {
        profissional.definirProfissoes(const [
          ProfissaoEscolhida('Encanador', ['Reparos', 'Instalações', 'Esgoto']),
        ]);
        await t.pump();
      },
    );
  });

  testWidgets('pro-pix', (t) async {
    cadastroEmCurso();
    await _capturar(
      t,
      'pro-pix',
      const PixPage(),
      preparar: () async {
        cadastroEmCurso();
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const PixPage(),
          ),
        );
      },
    );
  });

  testWidgets('pro-pix-erro', (t) async {
    await _capturar(
      t,
      'pro-pix-erro',
      const SizedBox(),
      preparar: () async {
        cadastroEmCurso();
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const PixPage(),
          ),
        );
        await t.tap(find.text('Celular'));
        await t.pump();
        await t.enterText(find.byType(TextField), '11988887777');
        await t.pump();
        await t.tap(find.text('Salvar e continuar'));
        await t.pump(const Duration(seconds: 2));
      },
    );
  });

  testWidgets('pro-pix-confirmando', (t) async {
    await _capturar(
      t,
      'pro-pix-confirmando',
      const SizedBox(),
      preparar: () async {
        cadastroEmCurso();
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const PixPage(),
          ),
        );
        await t.tap(find.text('Salvar e continuar'));
        await t.pump(const Duration(milliseconds: 300));
      },
    );
  });

  testWidgets('pro-taxas', (t) async {
    await _capturar(
      t,
      'pro-taxas',
      const PixPage(),
      preparar: () async {
        await t.tap(find.text('Ver taxas do Tatu'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-pix-depois', (t) async {
    await _capturar(
      t,
      'pro-pix-depois',
      const PixPage(),
      preparar: () async {
        await t.tap(find.text('Fazer isso depois'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-verificacao', (t) async {
    await _capturar(t, 'pro-verificacao', const VerificacaoIntroPage());
  });

  testWidgets('pro-camera-documento', (t) async {
    await _capturar(
      t,
      'pro-camera-documento',
      const CameraVerificacaoPage(etapa: EtapaFoto.frente),
    );
  });

  testWidgets('pro-selfie', (t) async {
    await _capturar(
      t,
      'pro-selfie',
      const CameraVerificacaoPage(etapa: EtapaFoto.selfie),
    );
  });

  testWidgets('pro-em-analise', (t) async {
    await _capturar(
      t,
      'pro-em-analise',
      const SizedBox(),
      preparar: () async {
        profissional.demo(aprovada: false);
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const EmAnalisePage(),
          ),
        );
      },
    );
  });

  testWidgets('pro-refazer', (t) async {
    await _capturar(
      t,
      'pro-refazer',
      const SizedBox(),
      preparar: () async {
        profissional.demo(aprovada: false);
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const RefazerFotoPage(),
          ),
        );
      },
    );
  });

  testWidgets('pro-reprovado', (t) async {
    await _capturar(t, 'pro-reprovado', const ReprovadoPage());
  });

  Future<void> comDemo(
    WidgetTester t,
    String nome,
    Widget tela, {
    bool comPix = true,
    bool dica = false,
    Future<void> Function()? depois,
  }) => _capturar(
    t,
    nome,
    const SizedBox(),
    preparar: () async {
      profissional.demo(comPix: comPix);
      if (dica) profissional.dicaVista = false;
      await t.pumpWidget(
        MaterialApp(
          theme: tatuTheme(),
          debugShowCheckedModeBanner: false,
          home: tela,
        ),
      );
      if (depois != null) await depois();
    },
  );

  testWidgets('pro-aprovado', (t) async {
    await comDemo(t, 'pro-aprovado', const AprovadoPage());
  });

  testWidgets('pro-home-dica', (t) async {
    await comDemo(
      t,
      'pro-home-dica',
      const HomeProfissionalPage(),
      comPix: false,
      dica: true,
    );
  });

  testWidgets('pro-home-sem-pix', (t) async {
    await comDemo(
      t,
      'pro-home-sem-pix',
      const HomeProfissionalPage(),
      comPix: false,
    );
  });

  testWidgets('pro-home-offline', (t) async {
    await comDemo(t, 'pro-home-offline', const HomeProfissionalPage());
  });

  testWidgets('pro-home-online', (t) async {
    await comDemo(
      t,
      'pro-home-online',
      const HomeProfissionalPage(),
      depois: () async {
        await t.tap(find.text('Ficar online'));
        await t.pump();
      },
    );
  });

  testWidgets('pro-perfil', (t) async {
    await comDemo(t, 'pro-perfil', const PerfilProfissionalPage());
  });

  testWidgets('pro-trocar-online', (t) async {
    await comDemo(
      t,
      'pro-trocar-online',
      const PerfilProfissionalPage(),
      depois: () async {
        profissional.ficarOnline(true);
        await t.pump();
        await t.scrollUntilVisible(find.text('Trocar para modo cliente'), 200);
        await t.tap(find.text('Trocar para modo cliente'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-regiao', (t) async {
    await comDemo(t, 'pro-regiao', const RegiaoPage());
  });

  testWidgets('pro-previa', (t) async {
    await comDemo(t, 'pro-previa', const PreviaPage());
  });

  testWidgets('pro-previa-avaliacoes', (t) async {
    await comDemo(
      t,
      'pro-previa-avaliacoes',
      const PreviaPage(),
      depois: () async {
        await t.drag(find.byType(ListView).first, const Offset(0, -700));
        await t.pump();
      },
    );
  });

  testWidgets('pro-a-caminho', (t) async {
    await _capturar(
      t,
      'pro-a-caminho',
      const ACaminhoPage(chegaEm: Duration(hours: 1)),
    );
  });

  testWidgets('pro-chegou', (t) async {
    await _capturar(t, 'pro-chegou', const ACaminhoPage(chegou: true));
  });

  testWidgets('pro-em-andamento', (t) async {
    await _capturar(
      t,
      'pro-em-andamento',
      EmAndamentoPage(inicio: DateTime(2026, 11, 10, 14, 32)),
    );
  });
}
