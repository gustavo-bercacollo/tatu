// Gera as imagens das telas do app para o fluxograma (docs/fluxo/app/).
// Uso (dentro de app/):
//   flutter test tool/capturas_test.dart --update-goldens
import 'dart:io';

import 'package:tatu/data/sugestoes_tatu.dart' show ModoConta;
import 'package:tatu/features/entrada/enviar_sugestao_page.dart';
import 'package:tatu/features/profissional/servico/conclusao_page.dart';
import 'package:tatu/shared/widgets/avatar_iniciais.dart';
import 'package:tatu/features/entrada/perfil_publico_page.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/encontrados.dart';
import 'package:tatu/features/profissional/cadastro/registro_page.dart';
import 'package:tatu/data/profissoes_reguladas.dart';
import 'package:tatu/features/profissional/cadastro/aceite_page.dart';
import 'package:tatu/features/entrada/documentos_legais_page.dart';
import 'package:tatu/data/documentos_legais.dart';
import 'package:tatu/data/aceites.dart';
import 'package:tatu/features/profissional/plano_fixo/plano_fixo_profissional.dart';
import 'package:tatu/features/cliente/plano_fixo/plano_fixo.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/features/cliente/atividade/gorjeta.dart';
import 'package:tatu/features/entrada/ligacao_page.dart';
import 'package:tatu/data/ditado.dart';
import 'package:tatu/features/entrada/conta_suspensa_page.dart';
import 'package:tatu/data/consulta_cpf.dart';
import 'package:tatu/features/entrada/menor_de_idade_page.dart';
import 'package:tatu/features/entrada/canal_tatu_page.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/core/protecao_tela.dart';
import 'package:tatu/features/cliente/mensagens/entrega_distancia.dart';
import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/features/profissional/cadastro/como_atende_page.dart';
import 'package:tatu/features/profissional/chamado/toque_chamado.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/avaliacoes_profissional.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/data/prazos.dart';
import 'package:tatu/data/seguranca.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/data/notificacoes_profissional.dart';
import 'package:tatu/features/profissional/perfil/notificacoes_profissional_page.dart';
import 'package:tatu/features/profissional/perfil/dados_conta_profissional_page.dart';
import 'package:tatu/data/fotos_trabalho.dart';
import 'package:tatu/features/cliente/mensagens/denunciar_page.dart'
    show DenunciarPage, DenunciaEnviadaPage;
import 'package:tatu/features/profissional/mensagens/mensagens_profissional_page.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/perfil/fotos_trabalho_page.dart';
import 'package:tatu/features/profissional/atividade/atividade_profissional_page.dart';
import 'package:tatu/features/profissional/atividade/ganhos_page.dart';
import 'package:tatu/features/profissional/cadastro/dados_page.dart';
import 'package:tatu/features/profissional/chamado/ainda_vai.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/chamado/novo_chamado_page.dart';
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
import 'package:tatu/features/profissional/perfil/sobre_page.dart';
import 'package:tatu/data/sobre_ia.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';
import 'package:tatu/features/profissional/servico/rota.dart';
import 'package:tatu/features/entrada/seguranca.dart';
import 'package:tatu/features/profissional/perfil/preferencias_atendimento_page.dart';
import 'package:tatu/features/profissional/perfil/avaliacoes_profissional_page.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/ajuda.dart';
import 'package:tatu/data/avaliacoes.dart';
import 'package:tatu/data/chamado.dart';
import 'package:tatu/features/cliente/chamar/fora_da_area_page.dart';
import 'package:tatu/features/cliente/chamar/imprevisto_page.dart';
import 'package:tatu/features/cliente/chamar/localizacao_chamar_page.dart';
import 'package:tatu/features/cliente/chamar/ninguem_ativo_page.dart';
import 'package:tatu/features/cliente/chamar/encontrado_page.dart';
import 'package:tatu/features/cliente/chamar/procurando_page.dart';
import 'package:tatu/features/cliente/chamar/som_encontrado.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/cliente/mensagens/denunciar_page.dart';
import 'package:tatu/features/cliente/mensagens/mensagens_page.dart';
import 'package:tatu/data/codigo_porta.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/atividade/atividade_page.dart';
import 'package:tatu/features/cliente/atividade/avaliar_page.dart';
import 'package:tatu/features/cliente/atividade/contestar_page.dart';
import 'package:tatu/features/cliente/atividade/servico_finalizado_page.dart';
import 'package:tatu/features/cliente/atividade/recibo_page.dart';
import 'package:tatu/features/cliente/atividade/pedido_andamento_page.dart';
import 'package:tatu/features/cliente/atividade/na_porta_page.dart';
import 'package:tatu/features/cliente/preferencias_cliente_page.dart';
import 'package:tatu/features/cliente/verificar_identidade_page.dart';
import 'package:tatu/features/cliente/atividade/pedido_cancelado_page.dart';
import 'package:tatu/features/cliente/atividade/pedido_concluido_page.dart';
import 'package:tatu/features/cliente/privacidade/baixar_dados_page.dart';
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
import 'package:tatu/features/entrada/dados_cliente_page.dart';

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
  fotosTrabalho.restaurar();
  conversasProfissional.restaurar();
  notificacoesProfissional.restaurar();
  navegacao.restaurar();
  seguranca.restaurar();
  avaliacoesProfissional.restaurar();
  atendimentoProfissional.restaurar();
  canalTatu.restaurar();
  planosFixos.restaurar();
  // RN-165: a Home só mostra a faixa "chega em X min" nas capturas dela.
  if (tela is HomeClientePage &&
      !const {
        'home-profissional-a-caminho',
        'home-profissional-trabalhando',
        'home-varios-profissionais',
        'home-confirmar-servico',
        'chamar-ja-tem-pedido',
      }
          .contains(nome)) {
    pedidos.cancelarAndamento();
  }
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
  setUpAll(() async {
    await documentosLegais.carregarTodos();
    await profissoesReguladas.carregar();
    await catalogoServicos.carregar();
    demoConferencia = null;
    // RN-39: código do desenho e sem o profissional digitar sozinho.
    RegrasCodigo.sorteio = null;
    PedidosRepo.demoCodigo = false;
    // RN-31: sem conclusão nem confirmação automáticas do protótipo.
    PedidosRepo.demoConclusao = false;
    ConclusaoServicoPage.clienteConfirmaEm = null;
  });
  consultaCpf = ConsultaCpfMock(demora: Duration.zero);
  ProtecaoTela.ativa = false;
  ToqueChamado.ativo = false;
  SomEncontrado.ativo = false;
  ProcurandoPage.aceitaEm = null;
  CameraVerificacaoPage.cameraAoVivo = false;
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

  // RN-173: sugestão ao Tatu (cliente e profissional usam as mesmas telas).
  testWidgets('enviar-sugestao', (t) async {
    await _capturar(
      t,
      'enviar-sugestao',
      const EnviarSugestaoPage(conta: 'Ana', modo: ModoConta.cliente),
      preparar: () async {
        await t.tap(find.text('Ideia'));
        await t.enterText(
          find.byType(TextField),
          'Seria bom poder salvar um profissional favorito para chamar de novo.',
        );
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  testWidgets('sugestao-enviada', (t) async {
    await _capturar(t, 'sugestao-enviada', const SugestaoEnviadaPage());
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

  // RN-150: Termos de uso lidos de docs/termos-de-uso.md (C71).
  testWidgets('termos-de-uso', (t) async {
    await _capturar(
      t,
      'termos-de-uso',
      const DocumentoLegalPage(tipo: TipoDocumento.termos),
    );
  });

  // RN-150: uma seção, com anterior e próxima (C72).
  testWidgets('termos-secao', (t) async {
    final d = documentosLegais.termos!;
    await _capturar(
      t,
      'termos-secao',
      SecaoDocumentoPage(
        documento: d,
        indice: d.secoes.indexWhere((s) => s.numero == '8'),
      ),
    );
  });

  // RN-150: Política de privacidade lida de docs/ (C73).
  testWidgets('politica-privacidade', (t) async {
    await _capturar(
      t,
      'politica-privacidade',
      DocumentoLegalPage(tipo: TipoDocumento.politica, onSeusDados: () {}),
    );
  });

  // RN-151: versão nova bloqueia até aceitar (C74). Demonstração: uma
  // versão 1.1 dos Termos, já vigente.
  testWidgets('termos-atualizados-aceite', (t) async {
    final atual = documentosLegais.termos!;
    documentosLegais.definir(versaoNovaDemo(atual));
    await _capturar(
      t,
      'termos-atualizados-aceite',
      TermosAtualizadosPage(
        documento: documentosLegais.termos!,
        tipo: TipoAceite.cliente,
      ),
      preparar: () async {
        await t.pumpAndSettle();
      },
    );
    documentosLegais.definir(atual);
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

  testWidgets('servico-concluido', (t) async {
    await _capturar(
      t,
      'servico-concluido',
      ServicoFinalizadoPage(pedido: PedidosRepo().concluidos.first),
    );
  });

  testWidgets('servico-nao-realizado', (t) async {
    await _capturar(
      t,
      'servico-nao-realizado',
      ServicoFinalizadoPage(
        pedido: PedidosRepo().concluidos.first,
        realizado: false,
      ),
    );
  });

  testWidgets('contestar', (t) async {
    await _capturar(t, 'contestar', const ContestarServicoPage());
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

  // RN-115/RN-116: primeiro acesso: só o Tatu, fixado (C122).
  testWidgets('mensagens-primeiro-acesso-tatu', (t) async {
    await _capturar(
      t,
      'mensagens-primeiro-acesso-tatu',
      const MensagensPage(),
      preparar: () async {
        conversas.limpar();
        canalTatu.cliente.comecar(boasVindasCliente('Ana'));
        await t.pump();
      },
    );
  });

  // RN-116: boas-vindas no canal do Tatu (C124).
  testWidgets('chat-tatu-boas-vindas', (t) async {
    await _capturar(
      t,
      'chat-tatu-boas-vindas',
      CanalTatuPage(
        canal: canalTatu.cliente,
        onDestino: abrirDestinoTatuCliente,
      ),
      preparar: () async {
        canalTatu.cliente.comecar(boasVindasCliente('Ana'));
        await t.pump();
      },
    );
  });

  // RN-117: novidade pelo canal (C125).
  testWidgets('chat-tatu-novidade', (t) async {
    await _capturar(
      t,
      'chat-tatu-novidade',
      CanalTatuPage(
        canal: canalTatu.cliente,
        onDestino: abrirDestinoTatuCliente,
      ),
    );
  });

  // RN-118: Dicas Tatu em breve (C126).
  testWidgets('dicas-tatu-em-breve', (t) async {
    await _capturar(t, 'dicas-tatu-em-breve', const DicasTatuPage());
  });

  testWidgets('chat', (t) async {
    await _capturar(
      t,
      'chat',
      ChatPage(conversa: ConversasRepo().conversas.first),
    );
  });

  testWidgets('chat-pedir-valor', (t) async {
    await _capturar(
      t,
      'chat-pedir-valor',
      ChatPage(conversa: ConversasRepo().conversas.first),
      preparar: () async {
        await t.tap(find.text('Pedir outro valor'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).last, '150');
        await t.pump();
      },
    );
  });

  testWidgets('chat-valor-confirmado', (t) async {
    final c = ConversasRepo().conversas.first
      ..dicaLigarVista = true;
    c.valor!.situacao = SituacaoValor.confirmado;
    await _capturar(t, 'chat-valor-confirmado', ChatPage(conversa: c));
  });

  // RN-140: valor confirmado libera o ligar pelo Tatu (C104).
  testWidgets('chat-ligar-liberado', (t) async {
    final r = ConversasRepo();
    final c = r.conversas.first;
    r.confirmarValor(c);
    await _capturar(t, 'chat-ligar-liberado', ChatPage(conversa: c));
  });

  // RN-140: ligação pelo app, sem número (C105).
  testWidgets('ligacao-pelo-app', (t) async {
    await _capturar(t, 'ligacao-pelo-app', const LigacaoPage(nome: 'Luiza Souza'));
  });

  // RN-138: ditando no chat (C137).
  testWidgets('chat-ditando', (t) async {
    ditado = DitadoMock(
      frase: 'Pode vir agora, o registro fica embaixo da pia',
      passo: const Duration(milliseconds: 100),
    );
    final c = ConversasRepo().conversas.first..valor = null;
    await _capturar(
      t,
      'chat-ditando',
      ChatPage(conversa: c),
      preparar: () async {
        await t.tap(find.bySemanticsLabel('Ditar'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 7050));
      },
    );
    ditado = DitadoMock();
  });

  // RN-138: ditado pronto para conferir e enviar como texto (C138).
  testWidgets('chat-ditado-pronto', (t) async {
    ditado = DitadoMock(
      frase: 'Pode vir agora, o registro fica embaixo da pia, do lado esquerdo.',
      passo: const Duration(milliseconds: 10),
    );
    final c = ConversasRepo().conversas.first..valor = null;
    await _capturar(
      t,
      'chat-ditado-pronto',
      ChatPage(conversa: c),
      preparar: () async {
        await t.tap(find.bySemanticsLabel('Ditar'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 500));
        await t.tap(find.bySemanticsLabel('Parar ditado'));
        await t.pumpAndSettle();
      },
    );
    ditado = DitadoMock();
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

  // RN-42: a conversa continua depois do serviço (C125).
  Conversa conversaContinua({ValorProposta? valor}) {
    final l = ConversasRepo().conversas.first;
    return Conversa(
      nome: l.nome,
      profissao: l.profissao,
      feminino: l.feminino,
      servico: l.servico,
      descricao: l.descricao,
      rua: l.rua,
      quando: '12 nov',
      concluidoEm: '04 nov',
      mensagens: [
        ...l.mensagens,
        MensagemChat.concluido('Serviço concluído · R\$ 190,00 · 04 nov'),
        MensagemChat.dia('12 nov'),
        MensagemChat(
          texto: 'A torneira do banheiro começou a pingar.',
          minha: true,
        ),
        MensagemChat(texto: 'Consigo passar aí hoje. Já te mando o valor.'),
      ],
      valor: valor,
    );
  }

  testWidgets('chat-conversa-continua', (t) async {
    await _capturar(
      t,
      'chat-conversa-continua',
      ChatPage(conversa: conversaContinua()),
    );
  });

  // RN-87 e RN-91: novo valor na mesma conversa, parcelado (C126–C127).
  ValorProposta valorNovo() => ValorProposta(
    visita: 0,
    servico: 1200,
    descricao: 'troca da tubulação',
    novo: true,
    parcelas: 6,
  );

  Future<void> rolarAteValor(WidgetTester t) async {
    await t.scrollUntilVisible(
      find.text('Pedir outro valor'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await t.pump();
  }

  testWidgets('chat-novo-valor-parcelado', (t) async {
    await _capturar(
      t,
      'chat-novo-valor-parcelado',
      ChatPage(conversa: conversaContinua(valor: valorNovo())),
      preparar: () => rolarAteValor(t),
    );
  });

  testWidgets('chat-escolher-parcelas', (t) async {
    await _capturar(
      t,
      'chat-escolher-parcelas',
      ChatPage(conversa: conversaContinua(valor: valorNovo())),
      preparar: () async {
        await rolarAteValor(t);
        await t.tap(find.text('Mudar'));
        await t.pumpAndSettle();
      },
    );
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

  /// Plano fixo de demonstração com a Luiza (C197).
  PlanoFixo planoDemo() => planosFixos.demo(inicio: DateTime(2026, 11, 3));

  // RN-144: "Tornar Luiza fixa" (C195).
  testWidgets('fixo-tornar-fixa', (t) async {
    await _capturar(
      t,
      'fixo-tornar-fixa',
      ChatPage(conversa: ConversasRepo().conversas.first),
      preparar: () async {
        await t.tap(find.bySemanticsLabel(RegExp('^Opções da conversa')));
        await t.pumpAndSettle();
        await t.tap(find.text('Tornar Luiza fixa'));
        await t.pumpAndSettle();
      },
    );
  });

  // RN-144/RN-146: valor do plano no chat do cliente (C196).
  testWidgets('fixo-proposta-valor', (t) async {
    final c = ConversasRepo().conversas.first..valor = null;
    await _capturar(
      t,
      'fixo-proposta-valor',
      ChatPage(conversa: c),
      preparar: () async {
        final p = planosFixos.pedir(
          cliente: 'Ana Martins',
          profissional: c.nome,
          endereco: c.rua,
          frequencia: FrequenciaPlano.mensal,
          visitasPorSemana: 1,
          dias: const [2],
          horario: '9:00',
        )!;
        planosFixos.enviarValor(p, 150);
        await t.pump();
      },
    );
  });

  // RN-146/RN-148: plano ativo do cliente (C197).
  testWidgets('fixo-plano-ativo', (t) async {
    await _capturar(
      t,
      'fixo-plano-ativo',
      const SizedBox(),
      preparar: () async {
        final p = planoDemo();
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: PlanoFixoPage(plano: p),
          ),
        );
      },
    );
  });

  // RN-145: 3ª visita na semana bloqueada (C198).
  testWidgets('fixo-limite-semana', (t) async {
    await _capturar(
      t,
      'fixo-limite-semana',
      const SizedBox(),
      preparar: () async {
        final p = planoDemo();
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: Builder(
              builder: (ctx) => PlanoFixoPage(plano: p),
            ),
          ),
        );
        mostrarLimiteSemana(t.element(find.byType(PlanoFixoPage)));
        await t.pumpAndSettle();
      },
    );
  });

  // RN-147: aviso do Tatu de que a visita não acontece (C199).
  testWidgets('fixo-visita-nao-vai', (t) async {
    await _capturar(
      t,
      'fixo-visita-nao-vai',
      const SizedBox(),
      preparar: () async {
        final p = planoDemo();
        canalTatu.cliente
          ..mensagens = []
          ..naoLidas = 0;
        planosFixos.naoVou(p, p.proximas.first);
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: CanalTatuPage(
              canal: canalTatu.cliente,
              onDestino: abrirDestinoTatuCliente,
            ),
          ),
        );
      },
    );
  });

  testWidgets('chat-denuncia-enviada', (t) async {
    await _capturar(t, 'chat-denuncia-enviada', const DenunciaEnviadaPage());
  });

  /// Conversa com a Luiza e uma mensagem de assédio dela (C135–C137).
  Conversa conversaAssedio({bool denunciada = false}) {
    final c = ConversasRepo().conversas.first..valor = null;
    c.mensagens.add(
      MensagemChat(texto: 'Manda uma foto sua, linda.')
        ..denunciada = denunciada,
    );
    return c;
  }

  // RN-134: segurar a mensagem (C135).
  testWidgets('chat-segurar-mensagem', (t) async {
    await _capturar(
      t,
      'chat-segurar-mensagem',
      ChatPage(conversa: conversaAssedio()),
      preparar: () async {
        await t.longPress(find.text('Manda uma foto sua, linda.'));
        await t.pumpAndSettle();
      },
    );
  });

  // RN-134: motivos da denúncia de mensagem (C136).
  testWidgets('chat-denunciar-mensagem', (t) async {
    await _capturar(
      t,
      'chat-denunciar-mensagem',
      ChatPage(conversa: conversaAssedio()),
      preparar: () async {
        await t.longPress(find.text('Manda uma foto sua, linda.'));
        await t.pumpAndSettle();
        await t.tap(find.text('Denunciar mensagem'));
        await t.pumpAndSettle();
        await t.tap(find.text('Assédio ou ofensa'));
        await t.pump();
      },
    );
  });

  // RN-134: mensagem denunciada, só para quem denunciou (C137).
  testWidgets('chat-mensagem-denunciada', (t) async {
    await _capturar(
      t,
      'chat-mensagem-denunciada',
      ChatPage(conversa: conversaAssedio(denunciada: true)),
    );
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
          await t.tap(find.bySemanticsLabel('Anexar'));
          await t.pumpAndSettle();
          await t.tap(find.text('Escolher da galeria'));
          await t.pumpAndSettle();
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  // RN-139: o clipe abre galeria ou arquivo (C89).
  testWidgets('chamar-anexar', (t) async {
    await _capturar(
      t,
      'chamar-anexar',
      const HomeClientePage(),
      preparar: () async {
        await descrever(t);
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
        await t.tap(find.bySemanticsLabel('Anexar'));
        await t.pumpAndSettle();
      },
    );
  });

  // RN-139: foto e PDF anexados (C90).
  testWidgets('chamar-com-arquivo', (t) async {
    final bytes = File('assets/avatares/avatar-2.png').readAsBytesSync();
    await _capturar(
      t,
      'chamar-com-arquivo',
      const HomeClientePage(),
      preparar: () async {
        perfil.escolherImagem = (_) async => bytes;
        await descrever(t);
        await t.tap(find.bySemanticsLabel('Anexar'));
        await t.pumpAndSettle();
        await t.tap(find.text('Escolher da galeria'));
        await t.pumpAndSettle();
        await t.tap(find.bySemanticsLabel('Anexar'));
        await t.pumpAndSettle();
        await t.tap(find.text('Arquivo (PDF, documento)'));
        await t.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  // RN-137: ditando a descrição (C15).
  testWidgets('home-gravando-audio', (t) async {
    ditado = DitadoMock(
      frase: 'minha pia da cozinha tá vazando embaixo e molhou tudo',
      passo: const Duration(milliseconds: 100),
    );
    await _capturar(
      t,
      'home-gravando-audio',
      const HomeClientePage(),
      preparar: () async {
        await t.tap(find.bySemanticsLabel('Ditar'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 7050));
      },
    );
    ditado = DitadoMock();
  });

  // RN-137: texto do ditado na descrição, para conferir (C16).
  testWidgets('home-audio-transcrito', (t) async {
    ditado = DitadoMock(
      frase: 'Minha pia da cozinha tá vazando embaixo e molhou tudo.',
      passo: const Duration(milliseconds: 10),
    );
    await _capturar(
      t,
      'home-audio-transcrito',
      const HomeClientePage(),
      preparar: () async {
        await t.tap(find.bySemanticsLabel('Ditar'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 500));
        await t.tap(find.bySemanticsLabel('Usar o texto'));
        await t.pumpAndSettle();
      },
    );
    ditado = DitadoMock();
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

  testWidgets('encontrado', (t) async {
    await _capturar(
      t,
      'encontrado',
      const EncontradoPage(
        servico: 'Encanador',
        endereco: 'Rua Bruno Lobo, 29',
        restante: 168,
        animar: false,
      ),
    );
  });

  testWidgets('encontrado-acabando', (t) async {
    await _capturar(
      t,
      'encontrado-acabando',
      const EncontradoPage(
        servico: 'Encanador',
        endereco: 'Rua Bruno Lobo, 29',
        restante: 15,
        animar: false,
      ),
    );
  });

  testWidgets('encontrado-ver-outro', (t) async {
    await _capturar(
      t,
      'encontrado-ver-outro',
      const EncontradoPage(
        servico: 'Encanador',
        endereco: 'Rua Bruno Lobo, 29',
        restante: 168,
        animar: false,
      ),
      preparar: () async {
        await t.tap(find.text('Ver outro'));
        await t.pumpAndSettle();
      },
    );
  });

  Future<void> abrirPerfilEncontrado(WidgetTester t) async {
    await t.tap(find.text('Ver perfil'));
    await t.pumpAndSettle();
  }

  testWidgets('encontrado-perfil', (t) async {
    await _capturar(
      t,
      'encontrado-perfil',
      const EncontradoPage(
        servico: 'Encanador',
        endereco: 'Rua Bruno Lobo, 29',
        restante: 168,
        animar: false,
      ),
      preparar: () => abrirPerfilEncontrado(t),
    );
  });

  testWidgets('encontrado-perfil-avaliacoes', (t) async {
    await _capturar(
      t,
      'encontrado-perfil-avaliacoes',
      const EncontradoPage(
        servico: 'Encanador',
        endereco: 'Rua Bruno Lobo, 29',
        restante: 168,
        animar: false,
      ),
      preparar: () async {
        await abrirPerfilEncontrado(t);
        await t.drag(find.byType(ListView).first, const Offset(0, -700));
        await t.pump();
      },
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

  // RN-141/RN-142: avaliação com gorjeta de R$ 5 (C111).
  testWidgets('avaliacao-com-gorjeta', (t) async {
    await _capturar(
      t,
      'avaliacao-com-gorjeta',
      AvaliarPage(pedido: PedidosRepo().concluidos.first),
      preparar: () async {
        await t.tap(find.bySemanticsLabel('5 estrelas'));
        await t.tap(find.text('Pontual'));
        await t.tap(find.text('Educada'));
        await t.tap(find.text('R\$ 5'));
        await t.pump();
      },
    );
  });

  // RN-141: outro valor, até R$ 100 (C112).
  testWidgets('gorjeta-outro-valor', (t) async {
    await _capturar(
      t,
      'gorjeta-outro-valor',
      AvaliarPage(pedido: PedidosRepo().concluidos.first),
      preparar: () async {
        await t.tap(find.bySemanticsLabel('5 estrelas'));
        await t.tap(find.text('Pontual'));
        await t.tap(find.text('Educada'));
        await t.tap(find.text('Outro'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).last, '15');
        await t.pump();
      },
    );
  });

  // RN-142: avaliação e café enviados (C113).
  testWidgets('gorjeta-enviada', (t) async {
    await _capturar(
      t,
      'gorjeta-enviada',
      GorjetaEnviadaPage(
        nome: 'Luiza',
        feminino: true,
        valor: 5,
        cartao: 'Visa 4242',
        onInicio: () {},
      ),
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

  // RN-111: nome completo e CPF (C09).
  testWidgets('cadastro-dados', (t) async {
    await _capturar(
      t,
      'cadastro-dados',
      const DadosClientePage(),
      preparar: () async {
        await t.enterText(find.byType(TextField).first, 'Ana Martins');
        await t.enterText(find.byType(TextField).last, '12345678909');
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  // RN-150: caixa de aceite marcada; "Continuar" liberado (C10).
  testWidgets('cadastro-dados-aceite', (t) async {
    await _capturar(
      t,
      'cadastro-dados-aceite',
      const DadosClientePage(),
      preparar: () async {
        await t.enterText(find.byType(TextField).first, 'Ana Martins');
        await t.enterText(find.byType(TextField).last, '12345678909');
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.tap(find.bySemanticsLabel(RegExp('^Li e concordo')).first);
        await t.pump();
      },
    );
  });

  // RN-150: "Antes de enviar", com a caixa marcada (P15).
  testWidgets('pro-passo4-aceite', (t) async {
    await _capturar(
      t,
      'pro-passo4-aceite',
      AceiteProfissionalPage(onEnviar: () {}),
      preparar: () async {
        await t.tap(find.bySemanticsLabel(RegExp('^Li e concordo')).first);
        await t.pump();
      },
    );
  });

  // RN-110: menor de 18 não entra (C11).
  testWidgets('cadastro-menor-de-idade', (t) async {
    await _capturar(t, 'cadastro-menor-de-idade', const MenorDeIdadePage());
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

  testWidgets('pro-outras-busca', (t) async {
    await _capturar(
      t,
      'pro-outras-busca',
      const ServicosProfissionalPage(),
      preparar: () async {
        await t.tap(find.text('Outros'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).last, 'bombeiro hidr');
        await t.pump();
      },
    );
  });

  testWidgets('pro-sugerir-profissao', (t) async {
    await _capturar(
      t,
      'pro-sugerir-profissao',
      const ServicosProfissionalPage(),
      preparar: () async {
        await t.tap(find.text('Outros'));
        await t.pumpAndSettle();
        await t.ensureVisible(find.text('Não achei a minha'));
        await t.pumpAndSettle();
        await t.tap(find.text('Não achei a minha'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).last, 'Afinador de piano');
        await t.pump();
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

  testWidgets('pro-foto-conferir', (t) async {
    final bytes = File('assets/avatares/avatar-2.png').readAsBytesSync();
    await _capturar(
      t,
      'pro-foto-conferir',
      const CameraVerificacaoPage(etapa: EtapaFoto.selfie),
      preparar: () async {
        profissional.tirarFoto = ({required bool frontal}) async => bytes;
        await t.tap(find.bySemanticsLabel('Tirar foto'));
        await t.pump();
        await t.pump();
      },
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

  testWidgets('pro-home-pausada', (t) async {
    await comDemo(
      t,
      'pro-home-pausada',
      const HomeProfissionalPage(),
      depois: () async {
        profissional.pausarParaDemo();
        await t.pump();
      },
    );
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

  testWidgets('pro-home-so-mulheres', (t) async {
    await comDemo(
      t,
      'pro-home-so-mulheres',
      const HomeProfissionalPage(),
      depois: () async {
        seguranca.definirSoMulheres(true);
        await t.tap(find.text('Ficar online'));
        await t.pump();
      },
    );
  });

  testWidgets('cliente-preferencias', (t) async {
    await _capturar(t, 'cliente-preferencias', const PreferenciasClientePage());
  });

  testWidgets('cliente-verificar', (t) async {
    await _capturar(t, 'cliente-verificar', const VerificarIdentidadePage());
  });

  testWidgets('cliente-camera-documento', (t) async {
    await _capturar(
      t,
      'cliente-camera-documento',
      const CameraVerificacaoPage(etapa: EtapaFoto.frente, cliente: true),
    );
  });

  testWidgets('cliente-camera-selfie', (t) async {
    await _capturar(
      t,
      'cliente-camera-selfie',
      const CameraVerificacaoPage(etapa: EtapaFoto.selfie, cliente: true),
    );
  });

  testWidgets('cliente-identidade-verificada', (t) async {
    await _capturar(
      t,
      'cliente-identidade-verificada',
      const IdentidadeVerificadaPage(),
    );
  });

  testWidgets('procurando-so-mulheres', (t) async {
    await _capturar(
      t,
      'procurando-so-mulheres',
      const ProcurandoPage(
        servico: 'Encanador',
        endereco: 'Rua Bruno Lobo, 29',
        animar: false,
      ),
      preparar: () async {
        seguranca.definirIdentidade(Identidade.mulher);
        seguranca.definirPreferirMulheres(true);
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
    // RN-80: 2 min 18 s de espera (o protótipo anda 20× mais rápido).
    await withClock(Clock.fixed(DateTime(2026, 11, 14, 14, 32)), () async {
      await _capturar(
        t,
        'pro-chegou',
        const ACaminhoPage(
          chegou: true,
          esperou: Duration(minutes: 2, seconds: 18),
        ),
        // RN-80: "Ver tempo de espera" a partir do código.
        preparar: () async {
          await t.tap(find.text('A Ana não está? Ver tempo de espera'));
          await t.pump();
        },
      );
    });
  });

  testWidgets('pro-cliente-nao-apareceu', (t) async {
    await withClock(Clock.fixed(DateTime(2026, 11, 14, 14, 32)), () async {
      await _capturar(
        t,
        'pro-cliente-nao-apareceu',
        const ACaminhoPage(chegou: true, esperou: Duration(minutes: 10)),
        preparar: () async {
          await t.tap(find.text('A Ana não está? Ver tempo de espera'));
          await t.pump();
          await t.tap(find.text('Cliente não apareceu'));
          await t.pumpAndSettle();
        },
      );
    });
  });

  // RN-39/RN-167: o profissional digita o código.
  Future<void> digitar(WidgetTester t, String codigo) async {
    for (final d in codigo.split('')) {
      await t.tap(find.text(d).last);
      await t.pump();
    }
  }

  testWidgets('pro-chegou-digitar-codigo', (t) async {
    atendimentoProfissional.restaurar();
    await _capturar(
      t,
      'pro-chegou-digitar-codigo',
      const ACaminhoPage(chegou: true),
      preparar: () => digitar(t, '48'),
    );
  });

  testWidgets('pro-chegou-codigo-incorreto', (t) async {
    atendimentoProfissional.restaurar();
    await _capturar(
      t,
      'pro-chegou-codigo-incorreto',
      const ACaminhoPage(chegou: true),
      preparar: () => digitar(t, '4831'),
    );
    atendimentoProfissional.restaurar();
  });

  // RN-165: acompanhar o profissional (relógio fixo: previsão 14:52).
  Future<void> acompanhar(
    WidgetTester t,
    String nome,
    Widget tela,
    Future<void> Function() preparar,
  ) => withClock(Clock.fixed(DateTime(2026, 11, 14, 14, 40)), () async {
    final antes = Prazos.aceleracao;
    Prazos.aceleracao = 1;
    await _capturar(t, nome, tela, preparar: preparar);
    Prazos.aceleracao = antes;
    pedidos.restaurar();
  });

  const combinado = PedidoAndamento(
    servico: 'Encanador',
    profissao: 'Encanadora',
    profissional: 'Luiza Souza',
    nota: '4,9',
    endereco: 'Rua das Flores, 120',
    valor: r'R$ 190,00',
    pagamento: 'Visa 4242',
    etapasFeitas: 1,
  );

  testWidgets('acompanhar-antes-de-sair', (t) async {
    await acompanhar(t, 'acompanhar-antes-de-sair', const PedidoAndamentoPage(),
        () async {
      pedidos.aceitar(combinado);
      // Confirmou há 3 min: faltam 7 min para sair.
      await withClock(Clock.fixed(DateTime(2026, 11, 14, 14, 37)), () async {
        pedidos.valorConfirmado();
      });
      await t.pump();
    });
  });

  testWidgets('acompanhar-a-caminho', (t) async {
    await acompanhar(t, 'acompanhar-a-caminho', const PedidoAndamentoPage(),
        () async {
      pedidos.aceitar(combinado);
      pedidos.saiu();
      await t.pump();
    });
  });

  testWidgets('acompanhar-chegando', (t) async {
    await acompanhar(t, 'acompanhar-chegando', const PedidoAndamentoPage(),
        () async {
      pedidos.aceitar(combinado);
      await withClock(Clock.fixed(DateTime(2026, 11, 14, 14, 29)), () async {
        pedidos.saiu();
      });
      await t.pump();
    });
  });

  testWidgets('acompanhar-chegou', (t) async {
    await acompanhar(t, 'acompanhar-chegou', const PedidoAndamentoPage(),
        () async {
      pedidos.aceitar(combinado);
      pedidos.saiu();
      pedidos.chegou();
      await t.pump();
    });
  });

  testWidgets('home-profissional-a-caminho', (t) async {
    await acompanhar(t, 'home-profissional-a-caminho', const HomeClientePage(),
        () async {
      pedidos.saiu();
      await t.pump();
    });
  });

  // RN-169: a Luiza começou às 14:32 (relógio da captura: 14:57).
  Future<void> trabalhando() async {
    await withClock(Clock.fixed(DateTime(2026, 11, 14, 14, 32)), () async {
      pedidos
        ..chegou()
        ..codigoDigitado();
    });
  }

  Future<void> servico(
    WidgetTester t,
    String nome,
    Widget tela,
    Future<void> Function() preparar,
  ) => withClock(Clock.fixed(DateTime(2026, 11, 14, 14, 57)), () async {
    final antes = Prazos.aceleracao;
    Prazos.aceleracao = 1;
    await _capturar(t, nome, tela, preparar: preparar);
    Prazos.aceleracao = antes;
    pedidos.restaurar();
  });

  testWidgets('servico-em-andamento', (t) async {
    await servico(t, 'servico-em-andamento', const PedidoAndamentoPage(),
        () async {
      await trabalhando();
      await t.pump();
    });
  });

  testWidgets('home-profissional-trabalhando', (t) async {
    await servico(
      t,
      'home-profissional-trabalhando',
      const HomeClientePage(),
      () async {
        await trabalhando();
        await t.pump();
      },
    );
  });

  testWidgets('home-varios-profissionais', (t) async {
    await servico(t, 'home-varios-profissionais', const HomeClientePage(),
        () async {
      await trabalhando();
      final luiza = pedidos.andamento!;
      pedidos
        ..aceitar(
          const PedidoAndamento(
            servico: 'Eletricista',
            profissao: 'Eletricista',
            profissional: 'Marcos Dias',
            nota: '4,8',
            endereco: 'Rua das Flores, 120',
            valor: r'R$ 120,00',
            pagamento: 'Visa 4242',
            etapasFeitas: 1,
            chegaEm: '8 min',
          ),
        )
        ..saiu()
        ..abrir(luiza);
      await t.pump();
    });
  });

  testWidgets('servico-confirmar-conclusao', (t) async {
    await servico(
      t,
      'servico-confirmar-conclusao',
      const PedidoAndamentoPage(),
      () async {
        await trabalhando();
        await t.pump();
        pedidos.profissionalConcluiu();
        await t.pump();
        await t.pump(const Duration(minutes: 2));
      },
    );
  });

  testWidgets('home-confirmar-servico', (t) async {
    await servico(t, 'home-confirmar-servico', const HomeClientePage(),
        () async {
      await trabalhando();
      pedidos.profissionalConcluiu();
      await t.pump(const Duration(minutes: 2));
    });
  });

  // RN-31/RN-171: profissional depois de "Concluir serviço".
  const servicoAna = ServicoAceito(
    cliente: 'Ana Martins',
    descricao: 'Vazamento na pia',
    valor: 190,
  );

  testWidgets('pro-aguardando-confirmacao', (t) async {
    await _capturar(
      t,
      'pro-aguardando-confirmacao',
      const ConclusaoServicoPage(servico: servicoAna),
    );
  });

  testWidgets('pro-cliente-confirmou', (t) async {
    await _capturar(
      t,
      'pro-cliente-confirmou',
      const ConclusaoServicoPage(servico: servicoAna, confirmado: true),
    );
  });

  testWidgets('cliente-ausente', (t) async {
    await _capturar(
      t,
      'cliente-ausente',
      VoceNaoEstavaPage(pedido: pedidos.andamento!),
    );
  });

  testWidgets('cliente-home-pausada', (t) async {
    await _capturar(
      t,
      'cliente-home-pausada',
      const HomeClientePage(),
      preparar: () async {
        conta.pausarPorAusenciasParaDemo();
        await t.pump();
      },
    );
  });

  testWidgets('pro-quase-la', (t) async {
    await _capturar(t, 'pro-quase-la', const ACaminhoPage(perto: true));
  });

  testWidgets('pro-rota-escolher', (t) async {
    await _capturar(
      t,
      'pro-rota-escolher',
      const ACaminhoPage(chegaEm: Duration(hours: 1)),
      preparar: () async {
        await t.tap(find.text('Abrir rota'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-rota-nao-instalado', (t) async {
    await _capturar(
      t,
      'pro-rota-nao-instalado',
      const ACaminhoPage(chegaEm: Duration(hours: 1)),
      preparar: () async {
        await t.tap(find.text('Abrir rota'));
        await t.pumpAndSettle();
        await t.tap(find.text('Waze'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-localizacao', (t) async {
    await _capturar(
      t,
      'pro-localizacao',
      const LocalizacaoCaminhoPage(cliente: 'Ana'),
    );
  });

  testWidgets('pro-app-navegacao', (t) async {
    await _capturar(
      t,
      'pro-app-navegacao',
      const AppNavegacaoPage(),
      preparar: () async {
        navegacao.escolher(AppNavegacao.google);
        await t.pump();
      },
    );
  });

  testWidgets('pro-em-andamento', (t) async {
    await _capturar(
      t,
      'pro-em-andamento',
      EmAndamentoPage(inicio: _hojeAs1432()),
    );
  });

  testWidgets('pro-so-visita', (t) async {
    await _capturar(
      t,
      'pro-so-visita',
      EmAndamentoPage(inicio: _hojeAs1432()),
      preparar: () async {
        await t.tap(find.text('Encerrar e cobrar só a visita'));
        await t.pumpAndSettle();
      },
    );
  });

  Future<void> abrirSegurancaCap(WidgetTester t) async {
    await t.tap(find.bySemanticsLabel('Segurança'));
    await t.pumpAndSettle();
  }

  testWidgets('pro-seguranca', (t) async {
    await _capturar(
      t,
      'pro-seguranca',
      EmAndamentoPage(inicio: _hojeAs1432()),
      preparar: () => abrirSegurancaCap(t),
    );
  });

  testWidgets('pro-alerta-ativo', (t) async {
    await _capturar(
      t,
      'pro-alerta-ativo',
      EmAndamentoPage(inicio: _hojeAs1432()),
      preparar: () async {
        seguranca.acionarAlerta(cliente: false);
        await t.pump();
      },
    );
  });

  testWidgets('pro-sair-atendimento', (t) async {
    await _capturar(
      t,
      'pro-sair-atendimento',
      EmAndamentoPage(inicio: _hojeAs1432()),
      preparar: () async {
        await abrirSegurancaCap(t);
        await t.tap(find.text('Sair agora'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-avaliacoes', (t) async {
    await _capturar(t, 'pro-avaliacoes', const AvaliacoesProfissionalPage());
  });

  testWidgets('pro-avaliacoes-baixas', (t) async {
    await _capturar(
      t,
      'pro-avaliacoes-baixas',
      const AvaliacoesProfissionalPage(filtro: 2),
    );
  });

  testWidgets('pro-avaliacoes-vazio', (t) async {
    await _capturar(
      t,
      'pro-avaliacoes-vazio',
      const AvaliacoesProfissionalPage(),
      preparar: () async {
        avaliacoesProfissional.limpar();
        await t.pump();
      },
    );
  });

  testWidgets('pro-contestar', (t) async {
    avaliacoesProfissional.restaurar();
    await _capturar(
      t,
      'pro-contestar',
      ContestarAvaliacaoPage(
        avaliacao: avaliacoesProfissional.recentes.last,
        motivo: 0,
      ),
      preparar: () async {
        await t.enterText(
          find.byType(TextField),
          'Me xingou por eu ser mulher.',
        );
        await t.pump();
      },
    );
  });

  testWidgets('pro-contestacao-recebida', (t) async {
    await _capturar(
      t,
      'pro-contestacao-recebida',
      const ContestacaoRecebidaPage(),
    );
  });

  // ---------- Profissional que não aparece (RN-76 a RN-79) ----------

  testWidgets('pro-ainda-vai', (t) async {
    await _capturar(
      t,
      'pro-ainda-vai',
      const ChatProfissionalPage(),
      preparar: () async {
        await t.tap(find.text('Enviar valor'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).last, '150');
        await t.pump();
        await t.tap(find.text('Enviar para Ana'));
        await t.pumpAndSettle();
        await t.pump(const Duration(seconds: 3));
        await t.tap(find.text('Aceitar R\$ 120,00'));
        await t.pump();
        // RN-76: passou o prazo para tocar "Estou a caminho".
        await t.pump(Prazos.naDemo(Prazos.estouACaminho));
        await t.pumpAndSettle();
      },
    );
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('pro-chamado-devolvido', (t) async {
    await _capturar(
      t,
      'pro-chamado-devolvido',
      const ChamadoDevolvidoPage(),
      preparar: () async {
        profissional.registrarAbandono();
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const ChamadoDevolvidoPage(key: ValueKey('de novo')),
          ),
        );
      },
    );
  });

  testWidgets('pro-home-pausada-abandonos', (t) async {
    await comDemo(
      t,
      'pro-home-pausada-abandonos',
      const HomeProfissionalPage(),
      depois: () async {
        profissional.pausarPorAbandonosParaDemo();
        await t.pump();
      },
    );
  });

  testWidgets('cliente-ainda-nao-saiu', (t) async {
    await _capturar(
      t,
      'cliente-ainda-nao-saiu',
      const PedidoAndamentoPage(),
      preparar: () async {
        pedidos.valorConfirmado();
        pedidos.aindaNaoSaiu();
        await t.pump();
      },
    );
    pedidos.restaurar(); // para os relógios do prazo
  });

  testWidgets('cliente-atraso', (t) async {
    await _capturar(
      t,
      'cliente-atraso',
      const PedidoAndamentoPage(),
      preparar: () async {
        // Previsto 12 min; com 37 min, está 25 min atrasada (RN-78).
        await t.pump(Prazos.naDemo(const Duration(minutes: 37)));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('cliente-busca-nao-confirmou', (t) async {
    await _capturar(
      t,
      'cliente-busca-nao-confirmou',
      ProcurandoPage(
        servico: 'Encanador',
        endereco: 'Rua das Flores, 120',
        animar: false,
        anterior: pedidos.andamento,
        troca: TrocaProfissional.naoConfirmou,
      ),
    );
  });

  testWidgets('pro-preferencias', (t) async {
    await comDemo(
      t,
      'pro-preferencias',
      const PreferenciasAtendimentoPage(),
      depois: () async {
        seguranca.definirSoMulheres(true);
        seguranca.definirSoVerificados(true);
        await t.pump();
      },
    );
  });

  testWidgets('cliente-dica-escudo', (t) async {
    await _capturar(
      t,
      'cliente-dica-escudo',
      const PedidoAndamentoPage(),
      preparar: () async {
        seguranca.mostrarDicaEscudo();
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const PedidoAndamentoPage(key: ValueKey('de novo')),
          ),
        );
        await t.pump(const Duration(milliseconds: 800));
        await t.pump();
      },
    );
    await t.pump(const Duration(seconds: 4));
  });

  testWidgets('cliente-seguranca', (t) async {
    await _capturar(
      t,
      'cliente-seguranca',
      const PedidoAndamentoPage(),
      preparar: () => abrirSegurancaCap(t),
    );
  });

  testWidgets('cliente-alerta-ativo', (t) async {
    await _capturar(
      t,
      'cliente-alerta-ativo',
      const PedidoAndamentoPage(),
      preparar: () async {
        seguranca.acionarAlerta(cliente: true);
        await t.pump();
      },
    );
  });

  testWidgets('cliente-ligar-190', (t) async {
    await _capturar(
      t,
      'cliente-ligar-190',
      Ligar190Page(servico: Atendimento.doPedido(pedidos.andamento!)),
    );
  });

  testWidgets('cliente-sair', (t) async {
    await _capturar(
      t,
      'cliente-sair',
      const PedidoAndamentoPage(),
      preparar: () async {
        await abrirSegurancaCap(t);
        await t.tap(find.text('Sair agora'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-voce-saiu', (t) async {
    await _capturar(t, 'pro-voce-saiu', const VoceSaiuPage());
  });

  testWidgets('pro-ligar-190', (t) async {
    await _capturar(t, 'pro-ligar-190', const Ligar190Page());
  });

  testWidgets('pro-contatos-confianca', (t) async {
    await _capturar(t, 'pro-contatos-confianca', const ContatosConfiancaPage());
  });

  testWidgets('pro-novo-chamado', (t) async {
    await _capturar(t, 'pro-novo-chamado', const NovoChamadoPage(restante: 22));
  });

  testWidgets('pro-chat', (t) async {
    await _capturar(t, 'pro-chat', const ChatProfissionalPage());
  });

  // RN-85: telefone digitado não é enviado.
  testWidgets('pro-chat-contato-bloqueado', (t) async {
    await _capturar(
      t,
      'pro-chat-contato-bloqueado',
      const ChatProfissionalPage(),
      preparar: () async {
        await t.enterText(
          find.byType(TextField).last,
          'me chama no 11 98888-7777',
        );
        await t.pump();
      },
    );
  });

  // RN-85: contato recebido aparece oculto.
  testWidgets('chat-contato-oculto', (t) async {
    final c = ConversasRepo().conversas.first
      ..valor = null
      ..mensagens.add(
        MensagemChat(texto: 'Se precisar de novo, me chama no 11 97777-1234'),
      );
    await _capturar(t, 'chat-contato-oculto', ChatPage(conversa: c));
  });

  Future<void> enviarValor(WidgetTester t, String centavos) async {
    await t.tap(find.text('Enviar valor').last);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, centavos);
    await t.pump();
    await t.tap(find.text('Enviar para Ana'));
    await t.pumpAndSettle();
  }

  testWidgets('pro-enviar-valor', (t) async {
    await _capturar(
      t,
      'pro-enviar-valor',
      const ChatProfissionalPage(),
      preparar: () async {
        await t.tap(find.text('Enviar valor'));
        await t.pumpAndSettle();
        await t.enterText(find.widgetWithText(TextField, 'R\$ 0').first, '40');
        await t.enterText(find.byType(TextField).last, '150');
        await t.pump();
      },
    );
  });

  testWidgets('pro-chat-valor', (t) async {
    await _capturar(
      t,
      'pro-chat-valor',
      const ChatProfissionalPage(resposta: Duration(hours: 1)),
      preparar: () => enviarValor(t, '150'),
    );
  });

  testWidgets('pro-chat-proposta', (t) async {
    await _capturar(
      t,
      'pro-chat-proposta',
      const ChatProfissionalPage(),
      preparar: () async {
        await enviarValor(t, '150');
        await t.pump(const Duration(seconds: 3));
      },
    );
  });

  testWidgets('pro-chat-combinado', (t) async {
    await _capturar(
      t,
      'pro-chat-combinado',
      const ChatProfissionalPage(),
      preparar: () async {
        await enviarValor(t, '150');
        await t.pump(const Duration(seconds: 3));
        await t.tap(find.textContaining('Aceitar R'));
        await t.pump();
      },
    );
  });

  testWidgets('pro-sem-acordo', (t) async {
    await _capturar(t, 'pro-sem-acordo', const SemAcordoPage());
  });

  testWidgets('pro-atividade', (t) async {
    await _capturar(t, 'pro-atividade', const AtividadeProfissionalPage());
  });

  testWidgets('pro-atividade-servico', (t) async {
    await _capturar(
      t,
      'pro-atividade-servico',
      const AtividadeProfissionalPage(aba: 0),
      preparar: () async {
        atendimentoProfissional.aceitar(chamadoExemplo);
        atendimentoProfissional.irAteCliente(servicoExemplo);
        await t.pump();
      },
    );
  });

  testWidgets('pro-atividade-andamento', (t) async {
    await _capturar(
      t,
      'pro-atividade-andamento',
      const AtividadeProfissionalPage(aba: 0),
    );
  });

  testWidgets('pro-ganhos', (t) async {
    await _capturar(t, 'pro-ganhos', const GanhosPage());
  });

  testWidgets('pro-ganhos-mes', (t) async {
    await _capturar(t, 'pro-ganhos-mes', const GanhosPage(periodo: 2));
  });

  const rascunho =
      'sou encanadora faz 9 anos, faço vazamento chuveiro e parte eletrica '
      'atendo zona sul sabado tbm';
  const ia = MelhoriaTextoMock(espera: Duration.zero);

  testWidgets('pro-sobre', (t) async {
    await _capturar(
      t,
      'pro-sobre',
      const SobrePage(ia: ia),
      preparar: () async {
        await t.enterText(find.byType(TextField), rascunho);
        await t.pump();
      },
    );
  });

  testWidgets('pro-sobre-sugestao', (t) async {
    await _capturar(
      t,
      'pro-sobre-sugestao',
      const SobrePage(ia: ia),
      preparar: () async {
        await t.enterText(find.byType(TextField), rascunho);
        await t.pump();
        await t.tap(find.text('Melhorar com IA'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-sobre-melhorado', (t) async {
    await _capturar(
      t,
      'pro-sobre-melhorado',
      const SobrePage(ia: ia),
      preparar: () async {
        await t.enterText(find.byType(TextField), rascunho);
        await t.pump();
        await t.tap(find.text('Melhorar com IA'));
        await t.pumpAndSettle();
        await t.tap(find.text('Usar este texto'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-sobre-contato', (t) async {
    await _capturar(
      t,
      'pro-sobre-contato',
      const SobrePage(ia: ia),
      preparar: () async {
        await t.enterText(
          find.byType(TextField),
          'Encanadora há 9 anos. Atendo a zona sul. Orçamento rápido, '
          'me chama no (11) 98888-7777',
        );
        await t.pump();
      },
    );
  });

  Uint8List fotoTeste() =>
      File('assets/avatares/avatar-2.png').readAsBytesSync();

  testWidgets('pro-fotos-vazio', (t) async {
    await comDemo(
      t,
      'pro-fotos-vazio',
      const FotosTrabalhoPage(),
      depois: () async {
        fotosTrabalho.limpar();
        await t.pump();
      },
    );
  });

  testWidgets('pro-fotos', (t) async {
    await comDemo(t, 'pro-fotos', const FotosTrabalhoPage());
  });

  testWidgets('pro-fotos-adicionar', (t) async {
    await comDemo(
      t,
      'pro-fotos-adicionar',
      const FotosTrabalhoPage(),
      depois: () async {
        await t.tap(find.text('Adicionar'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-fotos-nova', (t) async {
    final bytes = fotoTeste();
    await _capturar(
      t,
      'pro-fotos-nova',
      const SizedBox(),
      preparar: () async {
        profissional
          ..demo()
          ..definirProfissoes(const [
            ProfissaoEscolhida('Encanador', ['Reparos']),
            ProfissaoEscolhida('Eletricista', ['Reparos']),
          ]);
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: NovaFotoPage(imagem: bytes),
          ),
        );
        await t.enterText(find.byType(TextField), 'Troca de chuveiro');
        await t.pump();
      },
    );
  });

  testWidgets('pro-fotos-analise', (t) async {
    final bytes = fotoTeste();
    await comDemo(
      t,
      'pro-fotos-analise',
      const FotosTrabalhoPage(),
      depois: () async {
        fotosTrabalho.adicionar(
          FotoTrabalho(imagem: bytes, legenda: 'Torneira'),
          revisar: false,
        );
        await t.pump();
      },
    );
  });

  testWidgets('pro-fotos-recusada', (t) async {
    final bytes = fotoTeste();
    await comDemo(
      t,
      'pro-fotos-recusada',
      const FotosTrabalhoPage(),
      depois: () async {
        final f = FotoTrabalho(imagem: bytes, legenda: 'Torneira');
        fotosTrabalho
          ..adicionar(f, revisar: false)
          ..recusar(f, 'Aparece o rosto de uma pessoa.');
        await t.pump();
        await t.tap(find.text('Torneira'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-fotos-remover', (t) async {
    await comDemo(
      t,
      'pro-fotos-remover',
      const FotosTrabalhoPage(),
      depois: () async {
        await t.tap(find.bySemanticsLabel('Remover foto').first);
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-mensagens', (t) async {
    await comDemo(t, 'pro-mensagens', const MensagensProfissionalPage());
  });

  // RN-115/RN-116: primeiro acesso do profissional (P73).
  testWidgets('pro-mensagens-primeiro-acesso-tatu', (t) async {
    await comDemo(
      t,
      'pro-mensagens-primeiro-acesso-tatu',
      const MensagensProfissionalPage(),
      depois: () async {
        conversasProfissional.limpar();
        canalTatu.profissional.comecar(boasVindasProfissional('Luiza'));
        await t.pump();
      },
    );
  });

  // RN-116: boas-vindas do profissional (P75).
  testWidgets('pro-chat-tatu-boas-vindas', (t) async {
    await comDemo(
      t,
      'pro-chat-tatu-boas-vindas',
      CanalTatuPage(
        canal: canalTatu.profissional,
        onDestino: (_, _) {},
      ),
      depois: () async {
        canalTatu.profissional.comecar(boasVindasProfissional('Luiza'));
        await t.pump();
      },
    );
  });

  testWidgets('pro-chat-opcoes', (t) async {
    await comDemo(
      t,
      'pro-chat-opcoes',
      const ChatProfissionalPage(),
      depois: () async {
        await t.tap(find.bySemanticsLabel(RegExp('Opções da conversa')));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-chat-cancelar', (t) async {
    await comDemo(
      t,
      'pro-chat-cancelar',
      const ChatProfissionalPage(),
      depois: () async {
        await t.tap(find.bySemanticsLabel(RegExp('Opções da conversa')));
        await t.pumpAndSettle();
        await t.tap(find.text('Cancelar atendimento'));
        await t.pumpAndSettle();
      },
    );
  });

  // RN-42 e RN-87: conversa contínua do profissional (P77).
  testWidgets('pro-chat-conversa-continua', (t) async {
    await comDemo(
      t,
      'pro-chat-conversa-continua',
      const ChatProfissionalPage(
        concluidoPor: 190,
        concluidoEm: '04 nov',
        diaDepois: '12 nov',
        depois: [
          ('A torneira do banheiro começou a pingar.', false),
          ('Consigo passar aí hoje. Já te mando o valor.', true),
        ],
      ),
    );
  });

  // ---------- À distância (RN-92 a RN-98) ----------

  testWidgets('pro-distancia-como-atende', (t) async {
    await comDemo(
      t,
      'pro-distancia-como-atende',
      const ComoAtendePage(indice: 1),
    );
  });

  testWidgets('pro-distancia-home-online', (t) async {
    await comDemo(
      t,
      'pro-distancia-home-online',
      const HomeProfissionalPage(chamadoEm: Duration(hours: 1)),
      depois: () async {
        profissional.ficarOnline(true);
        await t.pump();
      },
    );
    profissional.ficarOnline(false);
  });

  testWidgets('pro-distancia-novo-chamado', (t) async {
    await comDemo(
      t,
      'pro-distancia-novo-chamado',
      const NovoChamadoPage(chamado: chamadoDistanciaExemplo, restante: 21),
    );
  });

  // RN-102: valor à distância com sinal (P110).
  testWidgets('pro-distancia-enviar-valor-sinal', (t) async {
    await comDemo(
      t,
      'pro-distancia-enviar-valor-sinal',
      const ChatProfissionalPage(chamado: chamadoDistanciaExemplo),
      depois: () async {
        await t.tap(find.text('Enviar valor'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).last, '250');
        await t.pump();
        await t.tap(find.byType(CupertinoSwitch));
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pumpAndSettle();
      },
    );
  });

  /// Chat do profissional à distância até o valor combinado com sinal.
  Future<void> proCombinado(
    WidgetTester t, {
    Duration resposta = const Duration(seconds: 1),
  }) async {
    await t.tap(find.text('Enviar valor'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '250');
    await t.pump();
    await t.tap(find.byType(CupertinoSwitch));
    await t.pump();
    await t.tap(find.text('Enviar para Ana'));
    await t.pumpAndSettle();
    await t.pump(resposta);
    await t.pumpAndSettle();
    await t.ensureVisible(find.textContaining('Aceitar'));
    await t.tap(find.textContaining('Aceitar'));
    await t.pumpAndSettle();
  }

  Future<void> proAnexo(
    WidgetTester t,
    String o, {
    bool concluir = true,
  }) async {
    await t.tap(find.bySemanticsLabel('Enviar foto'));
    await t.pumpAndSettle();
    if (o.isEmpty) return;
    await t.tap(find.text(o));
    await t.pumpAndSettle();
    // RN-125: na entrega, escolhe um arquivo e envia.
    if (o == 'Entrega' && concluir) {
      await t.tap(find.text('Arquivo'));
      await t.pump();
      await t.tap(find.text('entrega-final.zip'));
      await t.pump();
      await t.tap(find.widgetWithText(FilledButton, 'Enviar entrega'));
      await t.pumpAndSettle();
    }
  }

  // RN-99/RN-101: prévia ou entrega (P112).
  testWidgets('pro-distancia-previa-ou-entrega', (t) async {
    await comDemo(
      t,
      'pro-distancia-previa-ou-entrega',
      const ChatProfissionalPage(
        chamado: chamadoDistanciaExemplo,
        resposta: Duration(seconds: 1),
      ),
      depois: () async {
        await proCombinado(t);
        await proAnexo(t, '');
      },
    );
  });

  // RN-100/RN-103: entrega enviada, sinal liberado (P113).
  testWidgets('pro-distancia-entrega-enviada', (t) async {
    await comDemo(
      t,
      'pro-distancia-entrega-enviada',
      const ChatProfissionalPage(
        chamado: chamadoDistanciaExemplo,
        resposta: Duration(seconds: 5),
      ),
      depois: () async {
        await proCombinado(t, resposta: const Duration(seconds: 5));
        await proAnexo(t, 'Prévia protegida');
        await proAnexo(t, 'Entrega');
      },
    );
  });

  // RN-101: a cliente pediu ajuste (P114).
  testWidgets('pro-distancia-ajuste-pedido', (t) async {
    await comDemo(
      t,
      'pro-distancia-ajuste-pedido',
      const ChatProfissionalPage(
        chamado: chamadoDistanciaExemplo,
        resposta: Duration(seconds: 1),
      ),
      depois: () async {
        await proCombinado(t);
        await proAnexo(t, 'Entrega');
        await t.pump(const Duration(seconds: 1));
        await t.pumpAndSettle();
        await t.drag(find.byType(ListView).first, const Offset(0, -800));
        await t.pumpAndSettle();
      },
    );
  });

  // RN-125/RN-126: entrega por link do site (P119).
  testWidgets('pro-distancia-entrega-por-link', (t) async {
    await comDemo(
      t,
      'pro-distancia-entrega-por-link',
      const ChatProfissionalPage(
        chamado: chamadoDistanciaExemplo,
        resposta: Duration(seconds: 1),
      ),
      depois: () async {
        await proCombinado(t);
        await proAnexo(t, 'Entrega', concluir: false);
        await t.enterText(find.byType(TextField).last, 'padariadaana.com.br');
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pumpAndSettle();
      },
    );
  });

  // RN-120/RN-124: arquivo bloqueado e link no chat do profissional (P57).
  testWidgets('pro-chat-arquivo-bloqueado', (t) async {
    await comDemo(
      t,
      'pro-chat-arquivo-bloqueado',
      const ChatProfissionalPage(depois: [('\u0001bloqueada', true)]),
      depois: () async {
        await t.enterText(find.byType(TextField).last, 'www.meusite.com.br');
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  // RN-123: denunciar arquivo (P58).
  testWidgets('pro-chat-denunciar-arquivo', (t) async {
    await comDemo(
      t,
      'pro-chat-denunciar-arquivo',
      const ChatProfissionalPage(
        depois: [('\u0001arquivo:fotos.pdf|PDF · 2 MB', false)],
      ),
      depois: () async {
        await t.longPress(find.text('fotos.pdf'));
        await t.pumpAndSettle();
        await t.tap(find.text('Envolve menor de idade'));
        await t.pump();
      },
    );
  });

  // RN-122: conta suspensa (P59).
  testWidgets('pro-conta-suspensa', (t) async {
    await comDemo(
      t,
      'pro-conta-suspensa',
      const ContaSuspensaPage(profissional: true),
    );
  });

  // RN-131/RN-132: cliente suspenso; o Tatu encerra o chamado (P60).
  testWidgets('pro-chat-encerrado-pelo-tatu', (t) async {
    await comDemo(
      t,
      'pro-chat-encerrado-pelo-tatu',
      const ChatProfissionalPage(
        mensagens: [
          ('Oi! A pia não para de vazar.', false),
          ('Estou a caminho.', true),
        ],
      ),
      depois: () async {
        atendimentoProfissional
          ..aceitar(chamadoExemplo)
          ..irAteCliente(const ServicoAceito());
        atendimentoProfissional.clienteSuspenso();
        await t.pump();
      },
    );
  });

  // RN-106: conta pausada por sinais sem entrega (P115).
  testWidgets('pro-distancia-conta-pausada-sinais', (t) async {
    await comDemo(
      t,
      'pro-distancia-conta-pausada-sinais',
      const HomeProfissionalPage(chamadoEm: Duration(hours: 1)),
      depois: () async {
        profissional.pausarPorSinaisParaDemo();
        await t.pump();
      },
    );
  });

  testWidgets('pro-distancia-em-andamento', (t) async {
    await comDemo(
      t,
      'pro-distancia-em-andamento',
      EmAndamentoPage(
        servico: servicoDistanciaExemplo,
        inicio: DateTime(2026, 11, 14, 14, 32),
      ),
    );
  });

  testWidgets('distancia-home', (t) async {
    await _capturar(
      t,
      'distancia-home',
      const HomeClientePage(distancia: true),
      preparar: () async {
        await t.enterText(
          find.byType(TextField),
          'preciso de um logo para a minha loja de bolos',
        );
        await t.pump(const Duration(milliseconds: 600));
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  testWidgets('distancia-procurando', (t) async {
    await _capturar(
      t,
      'distancia-procurando',
      const ProcurandoPage(
        servico: 'Designer',
        endereco: 'À distância',
        distancia: true,
        animar: false,
      ),
    );
  });

  testWidgets('distancia-encontrado', (t) async {
    await _capturar(
      t,
      'distancia-encontrado',
      const EncontradoPage(
        servico: 'Designer',
        endereco: 'À distância',
        distancia: true,
        animar: false,
        restante: 168,
      ),
    );
  });

  /// Conversa à distância com a Marina (valor R$ 250 com sinal de R$ 75).
  Conversa conversaDistancia({bool primeiraResposta = true}) {
    final c = ConversasRepo().comecar(
      nome: 'Marina Reis',
      profissao: 'Designer',
      feminino: true,
      servico: 'Designer',
      rua: 'À distância',
      distancia: true,
    );
    return Conversa(
      nome: c.nome,
      profissao: c.profissao,
      feminino: true,
      servico: 'Designer',
      descricao: 'Logo para loja de bolos',
      rua: 'À distância',
      quando: 'agora',
      distancia: true,
      emAndamento: true,
      mensagens: [
        MensagemChat(texto: 'Oi, Ana! Que estilo você imagina?'),
        MensagemChat(texto: 'Algo simples e colorido.', minha: true),
        if (primeiraResposta) MensagemChat(texto: 'Consigo entregar amanhã.'),
      ],
      valor: c.valor,
    );
  }

  /// Conversa à distância já com o valor confirmado (RN-103).
  Conversa conversaConfirmada({bool primeiraResposta = true}) {
    final c = conversaDistancia(primeiraResposta: primeiraResposta);
    ConversasRepo().confirmarValor(c);
    return c;
  }

  // RN-102/RN-103: valor com sinal (C157).
  testWidgets('distancia-chat-valor-sinal', (t) async {
    await _capturar(
      t,
      'distancia-chat-valor-sinal',
      ChatPage(conversa: conversaDistancia(primeiraResposta: false)),
    );
  });

  // RN-99: prévia protegida no chat (C159).
  testWidgets('distancia-chat-previa', (t) async {
    final c = conversaConfirmada();
    final r = ConversasRepo();
    r.receberPrevia(c);
    c.mensagens.add(MensagemChat(texto: 'Gostei! Pode finalizar.', minha: true));
    await _capturar(t, 'distancia-chat-previa', ChatPage(conversa: c));
  });

  // RN-99: o visualizador protegido (C160).
  testWidgets('distancia-previa-protegida', (t) async {
    await _capturar(
      t,
      'distancia-previa-protegida',
      PreviaProtegidaPage(
        de: 'Marina',
        enviadaEm: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    );
  });

  /// Conversa com a 1ª entrega recebida (prévia vista antes).
  Conversa conversaEntrega1() {
    final c = conversaDistancia(primeiraResposta: false);
    final r = ConversasRepo();
    r.confirmarValor(c);
    c.mensagens.removeLast(); // o marcador não aparece nos desenhos 161–167
    c.mensagens.removeLast(); // "Algo simples…"
    r.receberPrevia(
      c,
      em: DateTime.now().subtract(const Duration(hours: 30)),
    );
    c.mensagens.add(MensagemChat(texto: 'Gostei! Pode finalizar.', minha: true));
    r.receberEntrega(c);
    return c;
  }

  // RN-100/RN-101: 1ª entrega (C161) e pedir ajuste (C162).
  testWidgets('distancia-entrega-1', (t) async {
    await _capturar(
      t,
      'distancia-entrega-1',
      ChatPage(conversa: conversaEntrega1()),
    );
  });

  testWidgets('distancia-pedir-ajuste', (t) async {
    await _capturar(
      t,
      'distancia-pedir-ajuste',
      ChatPage(conversa: conversaEntrega1()),
      preparar: () async {
        await t.tap(find.text('Pedir ajuste'));
        await t.pumpAndSettle();
        await t.enterText(
          find.byType(TextField).last,
          'Quero as letras maiores e o rosa um pouco mais claro.',
        );
        await t.pump();
      },
    );
  });

  /// Conversa com a 2ª entrega (depois do ajuste).
  Conversa conversaEntrega2() {
    final c = conversaDistancia(primeiraResposta: false);
    final r = ConversasRepo();
    r.confirmarValor(c);
    c.mensagens
      ..clear()
      ..add(MensagemChat(texto: 'Oi, Ana! Que estilo você imagina?'));
    r.receberEntrega(c);
    r.pedirAjuste(c, 'Quero as letras maiores.');
    c.mensagens.add(MensagemChat(texto: 'Ajustado! Vai a versão final.'));
    r.receberEntrega(c);
    // Nos desenhos a 1ª mensagem some atrás do marcador do ajuste.
    c.mensagens.removeAt(0);
    return c;
  }

  // RN-101: 2ª entrega (C163), aprovada (C164), reembolso (C165, C166).
  testWidgets('distancia-entrega-2', (t) async {
    await _capturar(
      t,
      'distancia-entrega-2',
      ChatPage(conversa: conversaEntrega2()),
    );
  });

  testWidgets('distancia-entrega-aprovada', (t) async {
    final c = conversaEntrega2();
    ConversasRepo().aprovarEntrega(c);
    await _capturar(t, 'distancia-entrega-aprovada', ChatPage(conversa: c));
  });

  testWidgets('distancia-pedir-reembolso', (t) async {
    await _capturar(
      t,
      'distancia-pedir-reembolso',
      ChatPage(conversa: conversaEntrega2()),
      preparar: () async {
        await t.tap(find.text('Reembolso'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('distancia-reembolso-em-analise', (t) async {
    final c = conversaEntrega2();
    ConversasRepo().pedirReembolso(c, 'Diferente do combinado');
    await _capturar(
      t,
      'distancia-reembolso-em-analise',
      ChatPage(conversa: c),
    );
  });

  /// Conversa com um programador à distância (C177, C178).
  Conversa conversaDiego(String pedido, String fala) {
    final r = ConversasRepo();
    final c = r.comecar(
      nome: 'Diego Rocha',
      profissao: 'Programador',
      feminino: false,
      servico: 'Programador',
      rua: 'À distância',
      distancia: true,
    );
    final d = Conversa(
      nome: c.nome,
      profissao: c.profissao,
      feminino: false,
      servico: 'Programador',
      descricao: pedido,
      rua: 'À distância',
      quando: 'agora',
      distancia: true,
      emAndamento: true,
      mensagens: [MensagemChat(texto: fala)],
      valor: c.valor,
    );
    r.confirmarValor(d);
    d.mensagens.removeLast(); // o marcador não aparece nos desenhos
    return d;
  }

  // RN-125: entrega por link do site (C177).
  testWidgets('distancia-entrega-link-site', (t) async {
    final c = conversaDiego('Site para a padaria', 'Site no ar! Confere aí.');
    ConversasRepo().receberEntrega(c, link: 'padariadaana.com.br');
    await _capturar(t, 'distancia-entrega-link-site', ChatPage(conversa: c));
  });

  // RN-126: entrega de programa: só baixa, com aviso (C178).
  testWidgets('distancia-entrega-executavel', (t) async {
    final c = conversaDiego('App para a padaria', 'Segue o app para instalar.');
    ConversasRepo().receberEntrega(
      c,
      arquivo: 'app-padaria.apk',
      detalhe: 'APK · 32 MB · sem vírus',
    );
    await _capturar(t, 'distancia-entrega-executavel', ChatPage(conversa: c));
  });

  // RN-120/RN-124: arquivo bloqueado e link no chat (C160).
  testWidgets('chat-arquivo-bloqueado', (t) async {
    final c = ConversasRepo().conversas.first
      ..valor = null
      ..mensagens.add(MensagemChat(minha: true, bloqueada: true));
    await _capturar(
      t,
      'chat-arquivo-bloqueado',
      ChatPage(conversa: c),
      preparar: () async {
        await t.enterText(find.byType(TextField), 'www.meusite.com.br');
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  // RN-123: denunciar arquivo (C161).
  testWidgets('chat-denunciar-arquivo', (t) async {
    final c = ConversasRepo().conversas.first
      ..valor = null
      ..mensagens.add(
        MensagemChat(arquivo: 'fotos.pdf', arquivoDetalhe: 'PDF · 2 MB'),
      );
    await _capturar(
      t,
      'chat-denunciar-arquivo',
      ChatPage(conversa: c),
      preparar: () async {
        await t.longPress(find.text('fotos.pdf'));
        await t.pumpAndSettle();
        await t.tap(find.text('Envolve menor de idade'));
        await t.pump();
      },
    );
  });

  // RN-130/RN-132: profissional suspensa; o Tatu encerra o pedido (C163).
  testWidgets('chat-encerrado-pelo-tatu', (t) async {
    final r = ConversasRepo();
    final c = r.conversas.first..mensagens.removeLast();
    r.profissionalSuspenso(c);
    await _capturar(t, 'chat-encerrado-pelo-tatu', ChatPage(conversa: c));
  });

  // RN-122: conta suspensa (C162).
  testWidgets('conta-suspensa', (t) async {
    await _capturar(t, 'conta-suspensa', const ContaSuspensaPage());
  });

  // RN-105: prazo acabou sem entrega (C167).
  testWidgets('distancia-sem-entrega', (t) async {
    final c = conversaConfirmada(primeiraResposta: false);
    c.entrega = EntregaDistancia(
      confirmadoEm: DateTime.now().subtract(const Duration(days: 8)),
    );
    c.mensagens
      ..add(MensagemChat.dia('há 7 dias'))
      ..add(MensagemChat(texto: 'Oi, alguma novidade?', minha: true));
    await _capturar(t, 'distancia-sem-entrega', ChatPage(conversa: c));
  });

  testWidgets('distancia-pedido-em-andamento', (t) async {
    await _capturar(
      t,
      'distancia-pedido-em-andamento',
      const PedidoAndamentoPage(),
      preparar: () async {
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
        await t.pump();
      },
    );
  });

  testWidgets('pro-denunciar', (t) async {
    await comDemo(
      t,
      'pro-denunciar',
      const DenunciarPage.pessoa(
        nome: 'Ana',
        feminino: true,
        denunciado: 'Ana Martins',
        motivo: 1,
      ),
    );
  });

  const conversaAssedioPro = [
    ('Oi! A pia não para de vazar.', false),
    ('Posso ir agora. Já te mando o valor.', true),
    ('Faz por 50 ou te dou nota 1.', false),
  ];

  // RN-134: segurar a mensagem do cliente (P84).
  testWidgets('pro-chat-segurar-mensagem', (t) async {
    await comDemo(
      t,
      'pro-chat-segurar-mensagem',
      const ChatProfissionalPage(mensagens: conversaAssedioPro),
      depois: () async {
        await t.longPress(find.text('Faz por 50 ou te dou nota 1.'));
        await t.pumpAndSettle();
      },
    );
  });

  // RN-134: motivos da denúncia de mensagem (P85).
  // RN-140: ligação pelo app, lado do profissional (P32).
  testWidgets('pro-ligacao-pelo-app', (t) async {
    await comDemo(
      t,
      'pro-ligacao-pelo-app',
      const LigacaoPage(nome: 'Ana Martins', profissional: true),
    );
  });

  // RN-138: ditando no chat do profissional (P88).
  testWidgets('pro-chat-ditando', (t) async {
    ditado = DitadoMock(
      frase: 'Combinado, chego em 12 minutos',
      passo: const Duration(milliseconds: 180),
    );
    await comDemo(
      t,
      'pro-chat-ditando',
      const ChatProfissionalPage(),
      depois: () async {
        await t.tap(find.bySemanticsLabel('Ditar'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 7050));
      },
    );
    ditado = DitadoMock();
  });

  // RN-138: ditado pronto no chat do profissional (P89).
  testWidgets('pro-chat-ditado-pronto', (t) async {
    ditado = DitadoMock(
      frase: 'Combinado, chego em 12 minutos.',
      passo: const Duration(milliseconds: 10),
    );
    await comDemo(
      t,
      'pro-chat-ditado-pronto',
      const ChatProfissionalPage(),
      depois: () async {
        await t.tap(find.bySemanticsLabel('Ditar'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 500));
        await t.tap(find.bySemanticsLabel('Parar ditado'));
        await t.pumpAndSettle();
      },
    );
    ditado = DitadoMock();
  });

  testWidgets('pro-chat-denunciar-mensagem', (t) async {
    await comDemo(
      t,
      'pro-chat-denunciar-mensagem',
      const ChatProfissionalPage(mensagens: conversaAssedioPro),
      depois: () async {
        await t.longPress(find.text('Faz por 50 ou te dou nota 1.'));
        await t.pumpAndSettle();
        await t.tap(find.text('Denunciar mensagem'));
        await t.pumpAndSettle();
        await t.tap(find.text('Assédio ou ofensa'));
        await t.pump();
      },
    );
  });

  // RN-134: mensagem denunciada, só para quem denunciou (P86).
  testWidgets('pro-chat-mensagem-denunciada', (t) async {
    await comDemo(
      t,
      'pro-chat-mensagem-denunciada',
      const ChatProfissionalPage(
        mensagens: [
          ('Oi! A pia não para de vazar.', false),
          ('Posso ir agora. Já te mando o valor.', true),
          ('\u0001denunciada', false),
        ],
      ),
    );
  });

  // RN-144: o pedido de plano chega no chat do profissional (P130).
  testWidgets('pro-fixo-pedido-do-cliente', (t) async {
    await comDemo(
      t,
      'pro-fixo-pedido-do-cliente',
      const ChatProfissionalPage(),
      depois: () async {
        planosFixos.pedir(
          cliente: 'Ana Martins',
          profissional: 'Luiza Souza',
          endereco: 'Rua das Flores, 120',
          frequencia: FrequenciaPlano.mensal,
          visitasPorSemana: 1,
          dias: const [2],
          horario: '9:00',
        );
        await t.pump();
      },
    );
  });

  // RN-144/RN-146: valor do plano, uma vez (P131).
  testWidgets('pro-fixo-enviar-valor', (t) async {
    await comDemo(
      t,
      'pro-fixo-enviar-valor',
      const ChatProfissionalPage(),
      depois: () async {
        planosFixos.pedir(
          cliente: 'Ana Martins',
          profissional: 'Luiza Souza',
          endereco: 'Rua das Flores, 120',
          frequencia: FrequenciaPlano.mensal,
          visitasPorSemana: 1,
          dias: const [2],
          horario: '9:00',
        );
        await t.pump();
        await t.tap(find.text('Enviar valor do plano'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).last, '150');
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pumpAndSettle();
      },
    );
  });

  // RN-146 a RN-148: plano ativo do profissional (P132).
  testWidgets('pro-fixo-plano-ativo', (t) async {
    await comDemo(
      t,
      'pro-fixo-plano-ativo',
      const SizedBox(),
      depois: () async {
        final p = planosFixos.demo(inicio: DateTime(2026, 11, 3));
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: PlanoFixoProfissionalPage(plano: p),
          ),
        );
      },
    );
  });

  /// Profissional com uma profissão livre e uma regulada (P06 a P10).
  void cadastroComRegistro({StatusRegistro? status}) {
    profissional
      ..salvarDados(
        nome: 'Renato Teixeira',
        cpf: '12345678909',
        celular: '11988887777',
      )
      ..definirProfissoes(const [
        ProfissaoEscolhida('Professor particular', ['Matemática', 'Física']),
        ProfissaoEscolhida('Personal trainer', ['Musculação', 'Funcional']),
      ]);
    if (status == null) return;
    final r = profissional.enviarRegistro(
      profissao: 'Personal trainer',
      conselho: 'CREF',
      uf: 'SP',
      numero: '012345-G',
    );
    r.status = status;
  }

  // RN-156: registro profissional, sem foto (P06).
  testWidgets('pro-registro-profissional', (t) async {
    await comDemo(
      t,
      'pro-registro-profissional',
      const SizedBox(),
      depois: () async {
        cadastroComRegistro();
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: RegistroProfissionalPage(
              profissao: 'Personal trainer',
              onEnviar: () {},
            ),
          ),
        );
        await t.enterText(find.byType(TextField).last, '012345-G');
        await t.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
      },
    );
  });

  // RN-157: registro em análise (P08).
  testWidgets('pro-suas-profissoes-registro-em-analise', (t) async {
    await comDemo(
      t,
      'pro-suas-profissoes-registro-em-analise',
      const SizedBox(),
      depois: () async {
        cadastroComRegistro(status: StatusRegistro.emAnalise);
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const ProfissoesPage(),
          ),
        );
      },
    );
  });

  // RN-158: registro não encontrado (P09).
  testWidgets('pro-registro-nao-encontrado', (t) async {
    await comDemo(
      t,
      'pro-registro-nao-encontrado',
      const SizedBox(),
      depois: () async {
        cadastroComRegistro(status: StatusRegistro.naoEncontrado);
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const RegistroNaoEncontradoPage(profissao: 'Personal trainer'),
          ),
        );
      },
    );
  });

  // RN-159: registro conferido (P10).
  testWidgets('pro-registro-conferido', (t) async {
    await comDemo(
      t,
      'pro-registro-conferido',
      const SizedBox(),
      depois: () async {
        cadastroComRegistro(status: StatusRegistro.conferido);
        await t.pumpWidget(
          MaterialApp(
            theme: tatuTheme(),
            debugShowCheckedModeBanner: false,
            home: const ProfissoesPage(),
          ),
        );
      },
    );
  });

  // RN-159: selo no perfil que o cliente vê (C85).
  testWidgets('encontrado-perfil-registro-conferido', (t) async {
    await _capturar(
      t,
      'encontrado-perfil-registro-conferido',
      PerfilPublicoPage(
        perfil: perfilDe(
          const ProfissionalEncontrado(
            nome: 'Renato Teixeira',
            profissao: 'Personal trainer',
            feminino: false,
            nota: '4,8',
            servicos: 96,
            chegaEm: '6 min',
            distancia: '1,8 km',
            resposta: '6 min',
            especialidades: ['Musculação', 'Funcional'],
            sobre: 'Personal trainer há 8 anos. Treinos em casa ou no parque.',
            registros: ['CREF 012345-G/SP'],
          ),
        ),
        avatar: const AvatarIniciais(nome: 'Renato Teixeira', tamanho: 96),
        rodape: Row(
          children: [
            Expanded(
              child: FilledButton(
                style: tatuBotaoSecundario(),
                onPressed: () {},
                child: const Text('Ver outro'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Aceitar Renato'),
              ),
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('pro-denuncia-enviada', (t) async {
    await comDemo(
      t,
      'pro-denuncia-enviada',
      const DenunciaEnviadaPage(
        texto: 'Nossa equipe vai analisar e pode\nfalar com você pelo app.',
      ),
    );
  });

  testWidgets('pro-perfil-foto', (t) async {
    await comDemo(
      t,
      'pro-perfil-foto',
      const PerfilProfissionalPage(),
      depois: () async {
        await t.tap(find.bySemanticsLabel(RegExp('Foto do perfil')));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-ajuda', (t) async {
    await comDemo(
      t,
      'pro-ajuda',
      const AjudaPage(conteudo: conteudoProfissional),
    );
  });

  testWidgets('pro-ajuda-ganhos', (t) async {
    await comDemo(
      t,
      'pro-ajuda-ganhos',
      AssuntoPage(
        assunto: assuntosAjudaProfissional[1],
        conteudo: conteudoProfissional,
      ),
    );
  });

  testWidgets('pro-ajuda-artigo', (t) async {
    await comDemo(
      t,
      'pro-ajuda-artigo',
      ArtigoPage(
        artigo: assuntosAjudaProfissional[1].artigos.first,
        conteudo: conteudoProfissional,
      ),
    );
  });

  testWidgets('pro-suporte-assunto', (t) async {
    await comDemo(
      t,
      'pro-suporte-assunto',
      const SuporteAssuntoPage(conteudo: conteudoProfissional),
    );
  });

  testWidgets('pro-suporte-chamado', (t) async {
    await comDemo(
      t,
      'pro-suporte-chamado',
      const EscolherPedidoPage(conteudo: conteudoProfissional),
    );
  });

  testWidgets('pro-suporte-chat', (t) async {
    await comDemo(
      t,
      'pro-suporte-chat',
      ChatSuportePage(
        pedido: chamadosRecentes.first,
        conteudo: conteudoProfissional,
      ),
      depois: () async {
        await t.enterText(
          find.byType(TextField),
          'O Pix desse serviço ainda não caiu.',
        );
        await t.pump();
        await t.tap(find.bySemanticsLabel('Enviar mensagem'));
        await t.pump();
        await t.pump(const Duration(seconds: 3));
      },
    );
  });

  testWidgets('pro-notificacoes', (t) async {
    await comDemo(t, 'pro-notificacoes', const NotificacoesProfissionalPage());
  });

  testWidgets('pro-notificacoes-desligar', (t) async {
    await comDemo(
      t,
      'pro-notificacoes-desligar',
      const NotificacoesProfissionalPage(),
      depois: () async {
        await t.tap(find.byType(CupertinoSwitch).first);
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-notificacoes-bloqueadas', (t) async {
    await comDemo(
      t,
      'pro-notificacoes-bloqueadas',
      const NotificacoesProfissionalPage(),
      depois: () async {
        notificacoesProfissional.negarNoCelular();
        await t.pump();
      },
    );
  });

  testWidgets('pro-som-chamado', (t) async {
    await comDemo(t, 'pro-som-chamado', const SomChamadoPage());
  });

  testWidgets('pro-permissao-avisos', (t) async {
    await comDemo(t, 'pro-permissao-avisos', const PermissaoAvisosPage());
  });

  testWidgets('pro-dados-conta', (t) async {
    await comDemo(t, 'pro-dados-conta', const DadosContaProfissionalPage());
  });

  testWidgets('pro-dados-documento', (t) async {
    await comDemo(
      t,
      'pro-dados-documento',
      const DadosContaProfissionalPage(),
      depois: () async {
        await t.tap(find.text('Luiza Vilela'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('pro-encerrar-perfil', (t) async {
    await comDemo(t, 'pro-encerrar-perfil', const EncerrarPerfilPage());
  });

  testWidgets('pro-perfil-encerrado', (t) async {
    await comDemo(t, 'pro-perfil-encerrado', const PerfilEncerradoPage());
  });

  testWidgets('pro-excluir-saldo', (t) async {
    await comDemo(t, 'pro-excluir-saldo', const ExcluirComSaldoPage());
  });
}

/// Hoje às 14:32 (início do serviço nas capturas; fica dentro dos 7 dias
/// da RN-89).
DateTime _hojeAs1432() {
  final h = DateTime.now();
  return DateTime(h.year, h.month, h.day, 14, 32);
}
