import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';

/// Etapas de um pedido: as feitas com ✓ verde, as próximas com círculo
/// vazio ligado por um traço.
class LinhaDoTempo extends StatelessWidget {
  const LinhaDoTempo({super.key, required this.etapas, required this.feitas});

  final List<String> etapas;
  final int feitas;

  static const _altura = 38.0;
  static const _bola = 22.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < etapas.length; i++)
          SizedBox(
            height: _altura,
            child: Row(
              children: [
                SizedBox(
                  width: _bola,
                  height: _altura,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Traço entre etapas que ainda não aconteceram.
                      if (i >= feitas && i < etapas.length - 1)
                        Positioned(
                          top: _altura / 2,
                          bottom: -_altura / 2,
                          child: Container(
                            width: 1.5,
                            color: TatuColors.chevron,
                          ),
                        ),
                      _Bola(feita: i < feitas),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  etapas[i],
                  style: TextStyle(
                    fontSize: 17,
                    color: i < feitas
                        ? TatuColors.textPrimary
                        : TatuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bola extends StatelessWidget {
  const _Bola({required this.feita});

  final bool feita;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LinhaDoTempo._bola,
      height: LinhaDoTempo._bola,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: feita ? TatuColors.online : TatuColors.bg,
        border: feita
            ? null
            : Border.all(color: TatuColors.chevron, width: 1.5),
      ),
      child: feita
          ? const Icon(TablerIcons.check, size: 14, color: TatuColors.onAction)
          : null,
    );
  }
}

/// Selo verde claro com a situação (ex.: "A caminho").
class SeloVerde extends StatelessWidget {
  const SeloVerde(this.texto, {super.key, this.aviso = false});

  final String texto;

  /// Laranja de atenção (ex.: "Pago direto ao profissional").
  final bool aviso;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: ShapeDecoration(
        color: aviso ? TatuColors.warningSoft : TatuColors.onlineSoft,
        shape: const StadiumBorder(),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: aviso ? TatuColors.warningTexto : TatuColors.onlineTexto,
        ),
      ),
    );
  }
}

/// Selo preto pequeno (ex.: tempo de chegada "12 min").
class SeloPreto extends StatelessWidget {
  const SeloPreto(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const ShapeDecoration(
        color: TatuColors.action,
        shape: StadiumBorder(),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: TatuColors.onAction,
        ),
      ),
    );
  }
}

/// Etapas na horizontal: bolinhas ligadas por uma linha, nomes embaixo.
/// A etapa atual (a última feita) ganha um anel.
class LinhaDoTempoHorizontal extends StatelessWidget {
  const LinhaDoTempoHorizontal({
    super.key,
    required this.etapas,
    required this.feitas,
  });

  final List<String> etapas;
  final int feitas;

  @override
  Widget build(BuildContext context) {
    final atual = feitas - 1;
    return Semantics(
      label: 'Etapa atual: ${etapas[atual.clamp(0, etapas.length - 1)]}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: 20,
              child: CustomPaint(
                size: Size.infinite,
                painter: _Trilho(total: etapas.length, atual: atual),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < etapas.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          etapas[i],
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == atual
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: i <= atual
                                ? TatuColors.textPrimary
                                : TatuColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Trilho extends CustomPainter {
  const _Trilho({required this.total, required this.atual});

  final int total;
  final int atual;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    double x(int i) => size.width * (i + 0.5) / total;
    final feito = Paint()
      ..color = TatuColors.action
      ..strokeWidth = 2;
    final falta = Paint()
      ..color = TatuColors.chevron
      ..strokeWidth = 2;
    for (var i = 0; i < total - 1; i++) {
      canvas.drawLine(
        Offset(x(i), y),
        Offset(x(i + 1), y),
        i < atual ? feito : falta,
      );
    }
    for (var i = 0; i < total; i++) {
      final c = Offset(x(i), y);
      if (i == atual) {
        canvas.drawCircle(c, 9, Paint()..color = TatuColors.action);
        canvas.drawCircle(c, 7, Paint()..color = TatuColors.bg);
        canvas.drawCircle(c, 5, Paint()..color = TatuColors.action);
      } else {
        canvas.drawCircle(c, 5.5, i < atual ? feito : falta);
      }
    }
  }

  @override
  bool shouldRepaint(_Trilho oldDelegate) =>
      oldDelegate.total != total || oldDelegate.atual != atual;
}
