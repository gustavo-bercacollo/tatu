
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/arquivos_seguros.dart';
import '../../data/perfil.dart';
import '../../data/sugestoes_tatu.dart';
import '../../shared/widgets/cadastro_scaffold.dart';
import '../../shared/widgets/folha.dart';
import '../../shared/widgets/grupo_cartao.dart';
import '../../shared/widgets/lista_agrupada.dart';
import '../../shared/widgets/tatu_chip.dart';
import '../../shared/widgets/tela_permissao.dart';
import '../cliente/foto/camera_desativada_page.dart';

/// C68 · RN-173: "Sugira algo ao Tatu" (cliente e profissional usam a
/// mesma tela). Tipo (um obrigatório), texto obrigatório até 500
/// caracteres e print opcional (câmera ou galeria, verificado pela
/// RN-120). Enviada, mostra "Obrigado!".
class EnviarSugestaoPage extends StatefulWidget {
  const EnviarSugestaoPage({
    super.key,
    required this.conta,
    required this.modo,
  });

  /// Quem envia (nome da conta).
  final String conta;
  final ModoConta modo;

  /// Protótipo: o arquivo que o print vira para a verificação (RN-120).
  /// Os testes trocam para simular um print barrado.
  static ArquivoEnviado arquivoDoPrint = const ArquivoEnviado('print.jpg');

  @override
  State<EnviarSugestaoPage> createState() => _EnviarSugestaoPageState();
}

class _EnviarSugestaoPageState extends State<EnviarSugestaoPage> {
  TipoSugestao? _tipo;
  final _texto = TextEditingController();
  final _foco = FocusNode();
  Uint8List? _print;
  bool _verificando = false;

  @override
  void initState() {
    super.initState();
    _foco.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _texto.dispose();
    _foco.dispose();
    super.dispose();
  }

  bool get _pronto =>
      SugestoesTatuRepo.conferir(_tipo, _texto.text) == null && !_verificando;

  void _aviso(String texto) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));

  /// Câmera ou galeria; o print passa pela verificação (RN-120).
  Future<void> _anexar() async {
    final origem = await mostrarFolha<OrigemFoto>(
      context,
      builder: (ctx) => FolhaOpcoes(
        itens: [
          ItemLista(
            icone: TablerIcons.camera,
            texto: 'Tirar foto',
            seta: false,
            onTap: () => Navigator.of(ctx).pop(OrigemFoto.camera),
          ),
          ItemLista(
            icone: TablerIcons.photo,
            texto: 'Escolher da galeria',
            seta: false,
            onTap: () => Navigator.of(ctx).pop(OrigemFoto.galeria),
          ),
        ],
      ),
    );
    if (origem == null || !mounted) return;
    try {
      final imagem = await perfil.pedirImagem(origem);
      if (imagem == null || !mounted) return;
      setState(() => _verificando = true);
      final r = await sugestoesTatu.verificarPrint(
        EnviarSugestaoPage.arquivoDoPrint,
      );
      if (!mounted) return;
      setState(() => _verificando = false);
      switch (r) {
        case ResultadoEnvio.entregue:
          setState(() => _print = imagem);
        case ResultadoEnvio.tipoNaoPermitido:
          _aviso('Vão só fotos.');
        case ResultadoEnvio.grandeDemais:
          _aviso('Imagem grande demais.');
        case ResultadoEnvio.barrado ||
            ResultadoEnvio.contaSuspensa ||
            ResultadoEnvio.contaBanida:
          _aviso('Esta imagem foi bloqueada.');
      }
    } on CameraNegada {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CameraDesativadaPage(semAvatar: true),
        ),
      );
    }
  }

  void _enviar() {
    final erro = sugestoesTatu.enviar(
      conta: widget.conta,
      modo: widget.modo,
      tipo: _tipo,
      texto: _texto.text,
      print: _print,
    );
    if (erro != null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SugestaoEnviadaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _texto.text.length;
    return CadastroScaffold(
      titulo: 'Sugira algo ao Tatu',
      subtitulo: 'Ideias, melhorias ou algo que não funciona.\n'
          'A gente lê todas.',
      botao: 'Enviar sugestão',
      onBotao: _pronto ? _enviar : null,
      children: [
        const Text(
          'Sobre o quê?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: TatuColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in TipoSugestao.values)
              TatuChip(
                label: t.rotulo,
                selecionado: _tipo == t,
                onTap: () => setState(() => _tipo = t),
              ),
          ],
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        Container(
          height: TatuMedidas.alturaDescricao,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
            border: Border.all(
              color: _foco.hasFocus ? TatuColors.action : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _texto,
                  focusNode: _foco,
                  maxLines: null,
                  expands: true,
                  textCapitalization: TextCapitalization.sentences,
                  // RN-173: até 500 caracteres.
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      RegrasSugestaoTatu.maxCaracteres,
                    ),
                  ],
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Conte com suas palavras',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.only(top: 12),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$n/${RegrasSugestaoTatu.maxCaracteres}',
                  style: TatuTexto.legenda,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        Row(
          children: [
            Semantics(
              button: true,
              label: 'Anexar print',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: _verificando ? null : _anexar,
                child: const IconeCirculo(TablerIcons.camera),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _verificando
                    ? 'Verificando o print…'
                    : _print == null
                    ? 'Anexar print (opcional)'
                    : 'Print anexado',
                style: TatuTexto.nota.copyWith(
                  fontSize: 14,
                  color: _print == null ? null : TatuColors.textPrimary,
                ),
              ),
            ),
            if (_print != null)
              TextButton(
                onPressed: () => setState(() => _print = null),
                child: const Text('Remover'),
              ),
          ],
        ),
      ],
    );
  }
}

/// C69 · RN-173: "Obrigado!" depois de enviar.
class SugestaoEnviadaPage extends StatelessWidget {
  const SugestaoEnviadaPage({super.key});

  @override
  Widget build(BuildContext context) => TelaPermissao(
    voltar: false,
    sucesso: true,
    icone: const Icon(TablerIcons.check, size: 40, color: TatuColors.online),
    titulo: 'Obrigado!',
    texto:
        'Sua sugestão chegou ao time do Tatu.\n'
        'Se ela virar novidade, avisamos\npelo chat do Tatu.',
    principal: 'Voltar ao perfil',
    onPrincipal: () => Navigator.of(context).pop(),
  );
}
