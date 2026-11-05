import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';

/// Ajustar foto: arrastar e dar zoom para enquadrar no círculo.
/// Devolve a foto recortada (PNG quadrado) ou null ao cancelar.
class AjustarFotoPage extends StatefulWidget {
  const AjustarFotoPage({super.key, required this.imagem});

  final Uint8List imagem;

  @override
  State<AjustarFotoPage> createState() => _AjustarFotoPageState();
}

class _AjustarFotoPageState extends State<AjustarFotoPage> {
  static const _circulo = TatuMedidas.circuloRecorte;
  static const _zoomMax = 3.0;

  final _recorte = GlobalKey();
  Size? _base; // tamanho da imagem cobrindo o círculo, sem zoom
  double _zoom = 1;
  double _zoomInicial = 1;
  Offset _desloc = Offset.zero;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _medir();
  }

  Future<void> _medir() async {
    final img = await decodeImageFromList(widget.imagem);
    final s = _circulo / math.min(img.width, img.height);
    img.dispose();
    if (mounted) {
      setState(() => _base = Size(img.width * s, img.height * s));
    }
  }

  Offset _limitar(Offset o) {
    final b = _base;
    if (b == null) return Offset.zero;
    final mx = (b.width * _zoom - _circulo) / 2;
    final my = (b.height * _zoom - _circulo) / 2;
    return Offset(o.dx.clamp(-mx, mx), o.dy.clamp(-my, my));
  }

  void _mudarZoom(double z) => setState(() {
    _zoom = z.clamp(1.0, _zoomMax);
    _desloc = _limitar(_desloc);
  });

  Future<void> _usar() async {
    if (_salvando || _base == null) return;
    setState(() => _salvando = true);
    final borda =
        _recorte.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await borda.toImage(pixelRatio: 2);
    final dados = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    if (!mounted) return;
    Navigator.of(context).pop(dados?.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final b = _base;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: TatuColors.textPrimary,
        body: SafeArea(
          child: Column(
            children: [
              _topo(),
              Expanded(
                child: GestureDetector(
                  onScaleStart: (_) => _zoomInicial = _zoom,
                  onScaleUpdate: (d) => setState(() {
                    _zoom = (_zoomInicial * d.scale).clamp(1.0, _zoomMax);
                    _desloc = _limitar(_desloc + d.focalPointDelta);
                  }),
                  child: Container(
                    color: TatuColors.editorFundo,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: RepaintBoundary(
                            key: _recorte,
                            child: SizedBox.square(
                              dimension: _circulo,
                              child: b == null
                                  ? null
                                  : OverflowBox(
                                      maxWidth: double.infinity,
                                      maxHeight: double.infinity,
                                      child: Transform.translate(
                                        offset: _desloc,
                                        child: Transform.scale(
                                          scale: _zoom,
                                          child: Image.memory(
                                            widget.imagem,
                                            width: b.width,
                                            height: b.height,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const IgnorePointer(
                          child: CustomPaint(painter: _Mascara(_circulo)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _rodape(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topo() {
    return SizedBox(
      height: TatuMedidas.alturaBotao + TatuMedidas.topo,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: TatuColors.onAction,
                padding: const EdgeInsets.symmetric(
                  horizontal: TatuMedidas.margem,
                ),
                textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 17),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ),
          const Text(
            'Ajustar foto',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: TatuColors.onAction,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rodape() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margem,
            TatuMedidas.entreSecoes + 8,
            TatuMedidas.margem,
            TatuMedidas.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    activeTrackColor: TatuColors.onAction,
                    inactiveTrackColor: TatuColors.editorTrilho,
                    thumbColor: TatuColors.onAction,
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Semantics(
                    label: 'Zoom',
                    child: Slider(
                      value: _zoom,
                      min: 1,
                      max: _zoomMax,
                      onChanged: _mudarZoom,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              const Text(
                'Arraste e use o zoom para ajustar',
                textAlign: TextAlign.center,
                style: TatuTexto.detalhe,
              ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: TatuColors.onAction,
                  foregroundColor: TatuColors.textPrimary,
                ),
                onPressed: _base == null || _salvando ? null : _usar,
                child: const Text('Usar foto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Escurece fora do círculo e desenha o contorno branco.
class _Mascara extends CustomPainter {
  const _Mascara(this.diametro);

  final double diametro;

  @override
  void paint(Canvas canvas, Size size) {
    final circulo = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: diametro / 2,
    );
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addOval(circulo),
      Paint()..color = TatuColors.editorSombra,
    );
    canvas.drawOval(
      circulo,
      Paint()
        ..color = TatuColors.onAction
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_Mascara oldDelegate) => oldDelegate.diametro != diametro;
}
