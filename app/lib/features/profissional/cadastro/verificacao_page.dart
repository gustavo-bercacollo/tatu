import 'dart:typed_data';

import 'package:camera/camera.dart';
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
/// A câmera abre ao vivo dentro do quadro: a de trás para o documento
/// (frente e verso) e a da frente para a selfie. A câmera fica aberta
/// entre as fotos, para ninguém esperar ela ligar de novo.
/// Sem câmera ao vivo (navegador sem permissão, testes), o botão abre a
/// câmera do celular.
/// Com [refazendo], tira só esta foto e volta para "Em análise".
class CameraVerificacaoPage extends StatefulWidget {
  const CameraVerificacaoPage({
    super.key,
    required this.etapa,
    this.refazendo = false,
  });

  final EtapaFoto etapa;
  final bool refazendo;

  /// Desligado nos testes e nas capturas (sem câmera de verdade).
  static bool cameraAoVivo = true;

  @override
  State<CameraVerificacaoPage> createState() => _CameraVerificacaoPageState();
}

class _CameraVerificacaoPageState extends State<CameraVerificacaoPage> {
  late EtapaFoto _etapa = widget.etapa;
  CameraController? _camera;
  List<CameraDescription> _cameras = const [];
  Uint8List? _foto;
  bool _tirando = false;

  bool get _selfie => _etapa == EtapaFoto.selfie;
  bool get _aoVivo => _camera?.value.isInitialized ?? false;

  @override
  void initState() {
    super.initState();
    _ligarCamera();
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  CameraDescription? _escolher(bool frontal) {
    final lado = frontal ? CameraLensDirection.front : CameraLensDirection.back;
    for (final c in _cameras) {
      if (c.lensDirection == lado) return c;
    }
    return _cameras.isEmpty ? null : _cameras.first;
  }

  Future<void> _ligarCamera() async {
    if (!CameraVerificacaoPage.cameraAoVivo) return;
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras().timeout(const Duration(seconds: 8));
      }
      final desc = _escolher(_selfie);
      if (desc == null) throw CameraException('sem-camera', '');
      final antiga = _camera;
      if (antiga != null && antiga.description == desc) return;
      final nova = CameraController(
        desc,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _camera = nova;
      await antiga?.dispose();
      await nova.initialize().timeout(const Duration(seconds: 8));
      if (mounted) setState(() {});
    } catch (_) {
      // Sem câmera ao vivo: o botão abre a câmera do celular.
      if (mounted) setState(() {});
    }
  }

  Future<void> _tirar() async {
    if (_tirando) return;
    setState(() => _tirando = true);
    try {
      Uint8List? foto;
      if (_aoVivo) {
        final arquivo = await _camera!.takePicture();
        foto = await arquivo.readAsBytes();
      } else {
        foto = await profissional.tirarFoto(frontal: _selfie);
      }
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
      if (mounted) setState(() => _tirando = false);
    }
  }

  void _usar() {
    final foto = _foto!;
    switch (_etapa) {
      case EtapaFoto.frente:
        profissional.fotoFrente = foto;
      case EtapaFoto.verso:
        profissional.fotoVerso = foto;
      case EtapaFoto.selfie:
        profissional.selfie = foto;
    }
    if (widget.refazendo || _selfie) {
      profissional.enviarVerificacao();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const EmAnalisePage()),
        (r) => r.isFirst,
      );
      return;
    }
    // Próxima foto na mesma tela, com a câmera já ligada.
    setState(() {
      _foto = null;
      _etapa = _etapa == EtapaFoto.frente ? EtapaFoto.verso : EtapaFoto.selfie;
    });
    if (_selfie) _ligarCamera();
  }

  String get _topo => switch (_etapa) {
    EtapaFoto.frente =>
      widget.refazendo ? 'Frente do documento' : 'Documento · 1 de 2',
    EtapaFoto.verso => 'Documento · 2 de 2',
    EtapaFoto.selfie => 'Selfie',
  };

  String get _titulo {
    if (_foto != null) return 'Ficou boa?';
    return switch (_etapa) {
      EtapaFoto.frente => 'Frente do documento',
      EtapaFoto.verso => 'Agora, o verso',
      EtapaFoto.selfie => 'Agora, uma selfie',
    };
  }

  String get _texto {
    if (_foto != null) {
      return _selfie
          ? 'Confira se o rosto aparece inteiro e nítido.'
          : 'Confira se dá para ler todos os dados.';
    }
    return switch (_etapa) {
      EtapaFoto.frente => 'Encaixe o documento no quadro.',
      EtapaFoto.verso => 'Vire o documento e encaixe no quadro.',
      EtapaFoto.selfie => 'Olhe para a câmera e fique parado.',
    };
  }

  /// O que aparece dentro do quadro: a foto tirada ou a câmera ao vivo.
  Widget _conteudoQuadro() {
    if (_foto != null) return Image.memory(_foto!, fit: BoxFit.cover);
    if (_aoVivo) {
      final tamanho = _camera!.value.previewSize;
      final larg = tamanho?.height ?? 3;
      final alt = tamanho?.width ?? 4;
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: larg,
          height: alt,
          child: CameraPreview(_camera!),
        ),
      );
    }
    return _selfie
        ? const FractionallySizedBox(
            widthFactor: 0.7,
            child: FittedBox(
              alignment: Alignment.bottomCenter,
              child: Icon(
                TablerIcons.user_filled,
                color: TatuColors.editorTrilho,
              ),
            ),
          )
        : const Icon(TablerIcons.id, size: 64, color: TatuColors.editorTrilho);
  }

  @override
  Widget build(BuildContext context) {
    const branco = TatuColors.onAction;
    final cinzaClaro = branco.withValues(alpha: 0.75);
    final quadro = _selfie
        ? AspectRatio(
            aspectRatio: 0.78,
            child: Container(
              decoration: const ShapeDecoration(
                color: TatuColors.editorFundo,
                shape: OvalBorder(
                  side: BorderSide(color: TatuColors.onAction, width: 4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _conteudoQuadro(),
            ),
          )
        : AspectRatio(
            aspectRatio: 1.58,
            child: Container(
              decoration: BoxDecoration(
                color: TatuColors.editorFundo,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                border: Border.all(color: TatuColors.onAction, width: 3),
              ),
              clipBehavior: Clip.antiAlias,
              child: _conteudoQuadro(),
            ),
          );
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
                  Expanded(child: Center(child: quadro)),
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
                      onPressed: () {
                        setState(() => _foto = null);
                        // Sem câmera ao vivo, já abre a câmera do celular.
                        if (!_aoVivo) _tirar();
                      },
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
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: _tirando
                                    ? branco.withValues(alpha: 0.5)
                                    : branco,
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
