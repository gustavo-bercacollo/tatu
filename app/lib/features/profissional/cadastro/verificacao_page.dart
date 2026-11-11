import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/nota_icone.dart';
import 'resultado_page.dart';

/// P12 · Passo 4: o que vai ser pedido na verificação.
class VerificacaoIntroPage extends StatelessWidget {
  const VerificacaoIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      passo: 4,
      titulo: 'Vamos confirmar que é você',
      subtitulo: 'É rápido e deixa seu perfil mais seguro para os clientes.',
      botao: 'Começar',
      onBotao: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CameraVerificacaoPage(etapa: EtapaFoto.frente),
        ),
      ),
      children: const [
        ItemVantagem(
          fundo: true,
          icone: TablerIcons.id,
          titulo: 'Foto do documento',
          texto: 'RG ou CNH, frente e verso.',
        ),
        ItemVantagem(
          fundo: true,
          icone: TablerIcons.face_id,
          titulo: 'Uma selfie',
          texto: 'Para comparar com o documento.',
        ),
        ItemVantagem(
          fundo: true,
          icone: TablerIcons.rosette_discount_check,
          titulo: 'Selo de verificado',
          texto: 'Aparece no seu perfil e os clientes confiam mais.',
        ),
        NotaIcone(
          icone: TablerIcons.lock,
          texto:
              'Suas fotos ficam protegidas e são usadas só para confirmar '
              'sua identidade.',
        ),
      ],
    );
  }
}

enum EtapaFoto { frente, verso, selfie }

/// P13/P14 · Fotos da verificação (só câmera, sem galeria).
/// O botão abre a câmera do celular; a foto tirada aparece no quadro
/// para conferir ("Usar esta foto" ou "Tirar outra").
/// Com [refazendo], tira só esta foto e volta para "Em análise".
class CameraVerificacaoPage extends StatefulWidget {
  const CameraVerificacaoPage({
    super.key,
    required this.etapa,
    this.refazendo = false,
  });

  final EtapaFoto etapa;
  final bool refazendo;

  @override
  State<CameraVerificacaoPage> createState() => _CameraVerificacaoPageState();
}

class _CameraVerificacaoPageState extends State<CameraVerificacaoPage> {
  Uint8List? _foto;
  bool _abrindo = false;

  bool get _selfie => widget.etapa == EtapaFoto.selfie;

  Future<void> _tirar() async {
    if (_abrindo) return;
    setState(() => _abrindo = true);
    try {
      final foto = await profissional.tirarFoto(frontal: _selfie);
      if (!mounted) return;
      setState(() => _foto = foto ?? _foto);
    } on CameraDoDocumentoNegada {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Permita o uso da câmera nos ajustes do celular.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _abrindo = false);
    }
  }

  void _usar() {
    final foto = _foto!;
    switch (widget.etapa) {
      case EtapaFoto.frente:
        profissional.fotoFrente = foto;
      case EtapaFoto.verso:
        profissional.fotoVerso = foto;
      case EtapaFoto.selfie:
        profissional.selfie = foto;
    }
    final nav = Navigator.of(context);
    if (widget.refazendo || _selfie) {
      profissional.enviarVerificacao();
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const EmAnalisePage()),
        (r) => r.isFirst,
      );
      return;
    }
    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) => CameraVerificacaoPage(
          etapa: widget.etapa == EtapaFoto.frente
              ? EtapaFoto.verso
              : EtapaFoto.selfie,
        ),
      ),
    );
  }

  String get _topo => switch (widget.etapa) {
    EtapaFoto.frente => 'Frente do documento',
    EtapaFoto.verso => 'Verso do documento',
    EtapaFoto.selfie => 'Selfie',
  };

  String get _titulo {
    if (_foto != null) return 'Ficou boa?';
    return _selfie ? 'Agora, uma selfie' : 'Fotografe o documento';
  }

  String get _texto {
    if (_foto != null) {
      return _selfie
          ? 'Confira se o rosto aparece inteiro e nítido.'
          : 'Confira se dá para ler todos os dados.';
    }
    return _selfie
        ? 'Olhe para a câmera e fique parado.'
        : 'O documento inteiro precisa aparecer na foto.';
  }

  @override
  Widget build(BuildContext context) {
    const branco = TatuColors.onAction;
    final cinzaClaro = branco.withValues(alpha: 0.75);
    return Scaffold(
      backgroundColor: TatuColors.action,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margemCadastro,
                TatuMedidas.topo,
                TatuMedidas.margemCadastro,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Fechar',
                        child: Material(
                          color: TatuColors.editorTrilho,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                TablerIcons.x,
                                size: 20,
                                color: branco,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _topo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: branco,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  Text(
                    _titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: branco,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _texto,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: cinzaClaro),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Center(
                      child: _selfie
                          ? _MolduraRosto(foto: _foto)
                          : _MolduraDocumento(foto: _foto),
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  if (_foto != null) ...[
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: branco,
                        foregroundColor: TatuColors.textPrimary,
                      ),
                      onPressed: _usar,
                      child: const Text('Usar esta foto'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: TatuColors.editorFundo,
                        foregroundColor: branco,
                      ),
                      onPressed: _tirar,
                      child: const Text('Tirar outra'),
                    ),
                  ] else ...[
                    NotaIcone(
                      icone: _selfie
                          ? TablerIcons.eyeglass_off
                          : TablerIcons.sun,
                      texto: _selfie
                          ? 'Sem óculos escuros ou boné.'
                          : 'Lugar claro, sem reflexo no documento.',
                      cor: cinzaClaro,
                    ),
                    const SizedBox(height: 10),
                    NotaIcone(
                      icone: _selfie ? TablerIcons.sun : TablerIcons.id,
                      texto: _selfie
                          ? 'Boa luz no rosto, sem sombras.'
                          : 'Tire o documento da capinha.',
                      cor: cinzaClaro,
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Semantics(
                        button: true,
                        label: 'Tirar foto',
                        child: GestureDetector(
                          onTap: _tirar,
                          child: Container(
                            width: 76,
                            height: 76,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: branco, width: 4),
                            ),
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                color: branco,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MolduraRosto extends StatelessWidget {
  const _MolduraRosto({this.foto});

  final Uint8List? foto;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.78,
      child: Container(
        decoration: const ShapeDecoration(
          color: TatuColors.editorFundo,
          shape: OvalBorder(
            side: BorderSide(color: TatuColors.onAction, width: 4),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: foto != null
            ? Image.memory(foto!, fit: BoxFit.cover)
            : const FractionallySizedBox(
                widthFactor: 0.7,
                child: FittedBox(
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                    TablerIcons.user_filled,
                    color: TatuColors.editorTrilho,
                  ),
                ),
              ),
      ),
    );
  }
}

class _MolduraDocumento extends StatelessWidget {
  const _MolduraDocumento({this.foto});

  final Uint8List? foto;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.58,
      child: Container(
        decoration: BoxDecoration(
          color: TatuColors.editorFundo,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          border: Border.all(color: TatuColors.onAction, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: foto != null
            ? Image.memory(foto!, fit: BoxFit.cover)
            : const Icon(
                TablerIcons.id,
                size: 64,
                color: TatuColors.editorTrilho,
              ),
      ),
    );
  }
}
