// Gera as imagens das telas do app para o fluxograma (docs/fluxo/app/).
// Uso (dentro de app/):
//   flutter test tool/capturas_test.dart --update-goldens
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/avaliacoes.dart';
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

  testWidgets('celular', (t) async {
    await _capturar(
      t,
      'celular',
      const CelularPage(),
      preparar: () async {
        await t.enterText(find.byType(TextField), '11988887777');
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
      const HomeClientePage(nome: 'Ana Martins'),
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
    await _capturar(
      t,
      'perfil-cliente',
      const PerfilClientePage(nome: 'Ana Martins'),
    );
  });

  testWidgets('foto-perfil', (t) async {
    await _capturar(
      t,
      'foto-perfil',
      const PerfilClientePage(nome: 'Ana Martins'),
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
      const PerfilClientePage(nome: 'Ana Martins'),
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

  testWidgets('home-vazia', (t) async {
    await _capturar(
      t,
      'home-vazia',
      const HomeClientePage(nome: 'Ana Martins'),
    );
  });

  testWidgets('home-ia', (t) async {
    await _capturar(
      t,
      'home-ia',
      const HomeClientePage(nome: 'Ana Martins'),
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
}
