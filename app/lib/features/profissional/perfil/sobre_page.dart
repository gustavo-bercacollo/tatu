import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/filtro_palavras.dart';
import '../../../data/profissional.dart';
import '../../../data/sobre_ia.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/tela_interna.dart';

/// "Sobre você": texto do perfil do profissional (até 300 caracteres).
/// A IA sugere uma versão melhor; telefone, e-mail e redes sociais são
/// bloqueados (o contato com clientes é pelo chat do Tatu).
class SobrePage extends StatefulWidget {
  const SobrePage({super.key, this.ia = const MelhoriaTextoMock()});

  final MelhoriaTexto ia;

  @override
  State<SobrePage> createState() => _SobrePageState();
}

class _SobrePageState extends State<SobrePage> {
  late final _texto = _ControleComContato(text: profissional.sobre);
  final _foco = FocusNode();
  bool _melhorando = false;

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

  bool get _temContato => contatoProibido.hasMatch(_texto.text);

  /// RN-124: filtro de palavras no perfil (venda ou troca de arquivos).
  String? get _palavraBarrada => FiltroPalavras.barrada(_texto.text);
  bool get _vazio => _texto.text.trim().isEmpty;

  Future<void> _melhorar() async {
    FocusScope.of(context).unfocus();
    setState(() => _melhorando = true);
    final sugestao = await widget.ia.melhorar(_texto.text);
    if (!mounted) return;
    setState(() => _melhorando = false);
    final usar = await mostrarFolha<bool>(
      context,
      builder: (_) => _FolhaSugestao(texto: sugestao),
    );
    if (usar == true && mounted) setState(() => _texto.text = sugestao);
  }

  void _salvar() {
    profissional.definirSobre(_texto.text);
    Navigator.of(context).pop();
    mostrarAvisoTopo(
      context,
      titulo: 'Texto salvo',
      texto: 'Já aparece no seu perfil.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final barrada = _palavraBarrada != null;
    final erro = _temContato || barrada;
    final cor = erro ? TatuColors.danger : TatuColors.textSecondary;
    return TelaInterna(
      titulo: 'Sobre você',
      rodape: FilledButton(
        onPressed: erro || _vazio || _melhorando ? null : _salvar,
        child: const Text('Salvar'),
      ),
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
        children: [
          const Text(
            'Conte aos clientes quem você é.\nAparece no seu perfil.',
            style: TextStyle(
              fontSize: 16,
              height: 1.35,
              color: TatuColors.textSecondary,
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          GestureDetector(
            onTap: _foco.requestFocus,
            child: Container(
              height: 200,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: BoxDecoration(
                color: TatuColors.fill,
                borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
                border: Border.all(
                  color: erro
                      ? TatuColors.danger
                      : _foco.hasFocus
                      ? TatuColors.textPrimary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _texto,
                      focusNode: _foco,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(maxSobre),
                      ],
                      onChanged: (_) => setState(() {}),
                      cursorColor: TatuColors.textPrimary,
                      style: const TextStyle(fontSize: 17, height: 1.35),
                      decoration: const InputDecoration.collapsed(
                        hintText:
                            'Ex.: há quanto tempo trabalha, o que faz '
                            'melhor e onde atende.',
                        hintStyle: TextStyle(
                          fontSize: 17,
                          height: 1.35,
                          color: TatuColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${_texto.text.length}/$maxSobre',
                    textAlign: TextAlign.right,
                    style: TatuTexto.nota.copyWith(color: cor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          if (erro)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: NotaIcone(
                icone: TablerIcons.alert_triangle,
                texto: barrada
                    ? FiltroPalavras.aviso
                    : 'Tire telefone, e-mail e redes sociais.\n'
                          'O contato com clientes é pelo chat do Tatu.',
                cor: TatuColors.danger,
              ),
            )
          else if (!_vazio)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _melhorando ? null : _melhorar,
                icon: const Icon(TablerIcons.sparkles, size: 18),
                label: Text(_melhorando ? 'Melhorando…' : 'Melhorar com IA'),
                style: TextButton.styleFrom(
                  foregroundColor: TatuColors.verified,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pinta de vermelho o trecho com telefone, e-mail ou rede social.
class _ControleComContato extends TextEditingController {
  _ControleComContato({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final partes = <TextSpan>[];
    var i = 0;
    for (final m in contatoProibido.allMatches(text)) {
      if (m.start > i) partes.add(TextSpan(text: text.substring(i, m.start)));
      partes.add(
        TextSpan(
          text: m.group(0),
          style: const TextStyle(
            color: TatuColors.danger,
            backgroundColor: TatuColors.dangerSoft,
          ),
        ),
      );
      i = m.end;
    }
    if (i < text.length) partes.add(TextSpan(text: text.substring(i)));
    return TextSpan(style: style, children: partes);
  }
}

/// Folha "Sugestão de texto": usar a versão da IA ou manter o próprio.
class _FolhaSugestao extends StatelessWidget {
  const _FolhaSugestao({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 22),
            const Row(
              children: [
                Icon(TablerIcons.sparkles, size: 22),
                SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Sugestão de texto',
                      style: TatuTexto.tituloFolha,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TatuColors.surfaceGrouped,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
              ),
              child: Text(
                texto,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
            const SizedBox(height: TatuMedidas.entreItens),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Você pode editar depois de usar.',
                style: TatuTexto.nota,
              ),
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Usar este texto'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Manter o meu'),
            ),
          ],
        ),
      ),
    );
  }
}
