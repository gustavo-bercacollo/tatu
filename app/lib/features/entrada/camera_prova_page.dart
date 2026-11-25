import 'package:camera/camera.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../data/perfil.dart';
import '../../data/retorno.dart';

/// P57 · RN-40/RN-184: foto de prova pela câmera do app, na hora (com
/// data e hora; nunca da galeria). Usada na foto obrigatória do serviço
/// pronto e nas fotos do retorno. Devolve a [FotoProva] (nula se voltar).
///
/// A câmera abre ao vivo no quadro. Sem câmera ao vivo (navegador sem
/// HTTPS, testes), o botão abre a câmera do celular.
class CameraProvaPage extends StatefulWidget {
  const CameraProvaPage({
    super.key,
    required this.titulo,
    required this.aviso,
    required this.texto,
  });

  /// "Foto do serviço pronto".
  final String titulo;

  /// "Obrigatória para concluir".
  final String aviso;

  /// "Ela protege você se a Ana reclamar depois."
  final String texto;

  /// Desligado nos testes e nas capturas (sem câmera de verdade).
  static bool aoVivo = true;

  /// Sem câmera ao vivo: abre a câmera do celular (troque nos testes).
  static Future<FotoProva?> Function() semCameraAoVivo = _cameraDoCelular;

  @override
  State<CameraProvaPage> createState() => _CameraProvaPageState();
}

Future<FotoProva?> _cameraDoCelular() async {
  try {
    final img = await perfil.pedirImagem(OrigemFoto.camera);
    if (img == null) return null;
    return FotoProva(tiradaEm: clock.now(), imagem: img);
  } on CameraNegada {
    return null;
  }
}

/// Abre a câmera de prova e devolve a foto.
Future<FotoProva?> tirarFotoProva(
  BuildContext context, {
  String titulo = 'Foto do problema',
  String aviso = 'Tire na hora, no local',
  String texto = 'A foto leva a data e a hora.',
}) => Navigator.of(context).push<FotoProva>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) =>
        CameraProvaPage(titulo: titulo, aviso: aviso, texto: texto),
  ),
);

class _CameraProvaPageState extends State<CameraProvaPage> {
  CameraController? _camera;
  bool _tirando = false;

  bool get _aoVivo => _camera?.value.isInitialized ?? false;

  @override
  void initState() {
    super.initState();
    _ligar();
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _ligar() async {
    if (!CameraProvaPage.aoVivo) return;
    try {
      final cameras = await availableCameras().timeout(
        const Duration(seconds: 8),
      );
      final desc = cameras
          .where((c) => c.lensDirection == CameraLensDirection.back)
          .followedBy(cameras)
          .firstOrNull;
      if (desc == null) return;
      final c = CameraController(desc, ResolutionPreset.high, enableAudio: false);
      _camera = c;
      await c.initialize().timeout(const Duration(seconds: 8));
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
      FotoProva? foto;
      if (_aoVivo) {
        final arquivo = await _camera!.takePicture();
        foto = FotoProva(
          tiradaEm: clock.now(),
          imagem: await arquivo.readAsBytes(),
        );
      } else {
        foto = await CameraProvaPage.semCameraAoVivo();
      }
      if (!mounted || foto == null) return;
      Navigator.of(context).pop(foto);
    } finally {
      if (mounted) setState(() => _tirando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const branco = TatuColors.onAction;
    return Scaffold(
      backgroundColor: TatuColors.textPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TatuMedidas.margem),
          child: Column(
            children: [
              const SizedBox(height: TatuMedidas.topo),
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Voltar',
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: TatuColors.editorFundo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          TablerIcons.chevron_left,
                          color: branco,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: branco,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: TatuColors.action,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _aoVivo
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _camera!.value.previewSize?.height ?? 3,
                            height: _camera!.value.previewSize?.width ?? 4,
                            child: CameraPreview(_camera!),
                          ),
                        )
                      : const Icon(
                          TablerIcons.photo,
                          size: 44,
                          color: TatuColors.editorTrilho,
                        ),
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              Text(
                widget.aviso,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: branco,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: TatuColors.avisoEscuroTexto,
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              Semantics(
                button: true,
                label: 'Tirar foto',
                child: GestureDetector(
                  onTap: _tirar,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: branco, width: 4),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: branco,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TatuMedidas.base),
            ],
          ),
        ),
      ),
    );
  }
}
