import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/consulta_registro.dart';
import 'package:tatu/data/encontrados.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/profissoes_reguladas.dart';
import 'package:tatu/data/servicos.dart';
import 'package:tatu/features/entrada/perfil_publico_page.dart';
import 'package:tatu/features/profissional/cadastro/registro_page.dart';
import 'package:tatu/shared/widgets/avatar_iniciais.dart';

/// Profissões reguladas (RN-156 a RN-160).

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

const _personal = 'Personal trainer';
const _professor = 'Professor particular';

/// Profissional com uma profissão regulada e uma livre.
void _cadastro() {
  profissional
    ..restaurar()
    ..salvarDados(nome: 'Renato Teixeira', cpf: '12345678909', celular: '11988887777')
    ..definirProfissoes(const [
      ProfissaoEscolhida(_professor, ['Matemática', 'Física']),
      ProfissaoEscolhida(_personal, ['Musculação', 'Funcional']),
    ]);
}

void main() {
  late ConsultaRegistroMock consulta;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _carregarInter();
    await profissoesReguladas.carregar();
  });
  setUp(() {
    consultaRegistro = consulta = ConsultaRegistroMock();
    demoConferencia = null;
    _cadastro();
  });

  group('RN-156/RN-160: lista lida do .md', () {
    test('campos de cada profissão', () {
      final p = profissoesReguladas.porNome(_personal)!;
      expect(p.regulada, isTrue);
      expect(p.permitida, isTrue);
      expect(p.conselho, 'CREF');
      expect(p.ondeConferir, 'Consulta do CONFEF/CREF');
      expect(p.atende, AtendeEm.ambos);
      expect(profissoesReguladas.porNome('Advogada')?.conselho, 'OAB');
      expect(profissoesReguladas.regulada('Eletricista'), isFalse);
      expect(profissoesReguladas.permitida('Médico'), isFalse);
      expect(profissoesReguladas.porNome('Frete e mudança')?.usaCnh, isTrue);
    });

    test('"fora do Tatu" não aparece na busca de profissões', () {
      final medico = buscarServicos('médico', profissional: true);
      expect(medico.map((s) => s.nome), isNot(contains('Médico')));
      expect(medico.map((s) => s.nome), contains('Médico veterinário'));
      expect(buscarServicos('dentista', profissional: true), isEmpty);
      expect(buscarServicos('dedetiza', profissional: true), isEmpty);
      // As reguladas aceitas aparecem, com o conselho.
      expect(
        buscarServicos('personal', profissional: true).map((s) => s.nome),
        contains('Personal trainer'),
      );
      // Sem repetir quem já estava no catálogo (Advogado).
      expect(
        buscarServicos('advogad', profissional: true).where(
          (s) => s.nome == 'Advogado',
        ),
        hasLength(1),
      );
    });
  });

  group('RN-157: chamados só depois de conferir', () {
    test('regulada em análise não recebe; as outras sim', () async {
      expect(profissional.chamadosDe, [_professor]);
      profissional.enviarRegistro(
        profissao: _personal,
        conselho: 'CREF',
        uf: 'SP',
        numero: '012345-G',
      );
      expect(profissional.chamadosDe, [_professor]);
      expect(profissional.podeReceberChamadosDe(_personal), isFalse);
      expect(
        await profissional.conferirRegistro(_personal),
        StatusRegistro.conferido,
      );
      expect(profissional.chamadosDe, [_professor, _personal]);
      expect(profissional.registros[_personal]!.rotulo, 'CREF 012345-G/SP');
    });

    test('nome diferente do documento não confere', () async {
      consulta.nomeTitular = 'Outra Pessoa';
      profissional.enviarRegistro(
        profissao: _personal,
        conselho: 'CREF',
        uf: 'SP',
        numero: '012345-G',
      );
      expect(
        await profissional.conferirRegistro(_personal),
        StatusRegistro.naoEncontrado,
      );
      expect(
        profissional.registros[_personal]!.motivo,
        'nome diferente do documento',
      );
      expect(profissional.chamadosDe, [_professor]);
    });

    test('RN-158: número que não existe → não encontrado', () async {
      profissional.enviarRegistro(
        profissao: _personal,
        conselho: 'CREF',
        uf: 'SP',
        numero: '000999-G',
      );
      expect(
        await profissional.conferirRegistro(_personal),
        StatusRegistro.naoEncontrado,
      );
      // Corrigir volta para análise.
      profissional.corrigirRegistro(_personal, uf: 'SP', numero: '012345-G');
      expect(profissional.registros[_personal]!.status, StatusRegistro.emAnalise);
    });
  });

  group('RN-160: rechecagem', () {
    test('suspenso pausa só aquela profissão', () async {
      final hoje = DateTime(2026, 11, 18);
      profissional.enviarRegistro(
        profissao: _personal,
        conselho: 'CREF',
        uf: 'SP',
        numero: '012345-G',
      );
      await profissional.conferirRegistro(_personal, agora: hoje);
      expect(profissional.paraRechecar(hoje), isEmpty);
      consulta.respostas['012345-G'] = const ResultadoRegistro(
        encontrado: true,
        nome: 'Renato Teixeira',
        situacao: SituacaoRegistro.suspenso,
      );
      final depois = hoje.add(RegrasRegistro.rechecarACada);
      expect(profissional.paraRechecar(depois), hasLength(1));
      await profissional.rechecarRegistros(depois);
      expect(profissional.registros[_personal]!.status, StatusRegistro.suspenso);
      expect(profissional.chamadosDe, [_professor]);
    });

    test('vencido também pausa; rechecado antes do vencimento', () async {
      final hoje = DateTime(2026, 11, 18);
      consulta.respostas['CNH1'] = ResultadoRegistro(
        encontrado: true,
        nome: 'Renato Teixeira',
        validade: hoje.add(const Duration(days: 20)),
      );
      profissional.definirProfissoes(const [
        ProfissaoEscolhida('Frete e mudança', ['Mudança']),
      ]);
      profissional
        ..documentoVerificacao = DocumentoVerificacao.cnh
        ..cnhDoDocumento = 'CNH1';
      profissional.registrarCnh('Frete e mudança');
      await profissional.conferirRegistro('Frete e mudança', agora: hoje);
      // Vence em 20 dias: entra na rechecagem antes do vencimento.
      expect(profissional.paraRechecar(hoje), hasLength(1));
      await profissional.rechecarRegistros(hoje.add(const Duration(days: 21)));
      expect(
        profissional.registros['Frete e mudança']!.status,
        StatusRegistro.suspenso,
      );
    });

    test('CNH: com RG na verificação, pede só o número', () {
      profissional.definirProfissoes(const [
        ProfissaoEscolhida('Motorista particular', ['Dia a dia']),
      ]);
      final r = profissional.registrarCnh('Motorista particular');
      expect(r.faltaNumero, isTrue);
      expect(profissional.podeReceberChamadosDe('Motorista particular'), isFalse);
    });
  });

  group('Telas', () {
    testWidgets('Registro profissional: conselho já preenchido, sem foto', (
      t,
    ) async {
      var enviou = false;
      await _abrir(
        t,
        RegistroProfissionalPage(
          profissao: _personal,
          onEnviar: () => enviou = true,
        ),
      );
      expect(find.text('Registro profissional'), findsOneWidget);
      expect(find.text('CREF'), findsOneWidget);
      expect(find.textContaining('Sem foto.'), findsOneWidget);
      await t.enterText(find.byType(TextField).last, '012345-G');
      await t.pump();
      await t.tap(find.text('Enviar registro'));
      await t.pump();
      expect(enviou, isTrue);
      expect(profissional.registros[_personal]!.status, StatusRegistro.emAnalise);
      expect(profissional.registros[_personal]!.uf, 'SP');
    });

    testWidgets('RN-159: selo no perfil para o cliente', (t) async {
      await _abrir(
        t,
        PerfilPublicoPage(
          perfil: perfilDe(
            const ProfissionalEncontrado(
              nome: 'Renato Teixeira',
              profissao: 'Personal trainer',
              feminino: false,
              nota: '4,8',
              servicos: 96,
              chegaEm: '',
              registros: ['CREF 012345-G/SP'],
            ),
          ),
          avatar: const AvatarIniciais(nome: 'Renato Teixeira', tamanho: 96),
          rodape: const SizedBox(),
        ),
      );
      expect(find.text('Registro profissional'), findsOneWidget);
      expect(find.text('CREF 012345-G/SP'), findsOneWidget);
      expect(find.text('Conferido no conselho pelo Tatu'), findsOneWidget);
    });
  });
}
