import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/pagamento.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';

/// Protótipo: o Pix "cai" sozinho depois disso (nulo nos testes).
Duration? simularPixPago = const Duration(seconds: 8);

/// C111 · RN-224: "Pagar com Pix": valor, QR code, "Copiar código Pix" e
/// a validade do código. Devolve verdadeiro se pagou; falso se o código
/// venceu; nulo se fechou a folha.
Future<bool?> pagarComPix(
  BuildContext context, {
  required double valor,
  required String nome,
  required DateTime ate,
}) => mostrarFolha<bool>(
  context,
  builder: (_) => _FolhaPix(valor: valor, nome: nome, ate: ate),
);

class _FolhaPix extends StatefulWidget {
  const _FolhaPix({required this.valor, required this.nome, required this.ate});

  final double valor;

  /// "a Luiza".
  final String nome;
  final DateTime ate;

  @override
  State<_FolhaPix> createState() => _FolhaPixState();
}

class _FolhaPixState extends State<_FolhaPix> {
  Timer? _relogio;
  Timer? _pago;

  @override
  void initState() {
    super.initState();
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!clock.now().isBefore(widget.ate)) {
        Navigator.of(context).pop(false);
        return;
      }
      setState(() {});
    });
    final espera = simularPixPago;
    if (espera != null) {
      _pago = Timer(espera, () {
        if (mounted) Navigator.of(context).pop(true);
      });
    }
  }

  @override
  void dispose() {
    _relogio?.cancel();
    _pago?.cancel();
    super.dispose();
  }

  String get _resta {
    final d = widget.ate.difference(clock.now());
    final s = d.isNegative ? 0 : d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: codigoPixDemo(widget.valor)));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Código Pix copiado')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margemCadastro,
          10,
          TatuMedidas.margemCadastro,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text('Pagar com Pix', style: TatuTexto.tituloFolha),
                ),
                Text(
                  reais(widget.valor),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pago, o valor fica guardado até o serviço ser concluído. '
              'Não chega ${widget.nome.startsWith('o ') ? 'ao' : 'à'} '
              '${widget.nome.substring(2)} antes.',
              style: TatuTexto.nota.copyWith(fontSize: 14),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            Center(
              child: Semantics(
                label: 'QR code do Pix',
                child: CustomPaint(
                  size: const Size.square(TatuMedidas.qrPix),
                  painter: _QrFalso(codigoPixDemo(widget.valor)),
                ),
              ),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              onPressed: _copiar,
              child: const Text('Copiar código Pix'),
            ),
            const SizedBox(height: TatuMedidas.entreItens),
            Text(
              'Código vale ${RegrasPagamento.validadePix.inMinutes} min · '
              '$_resta',
              textAlign: TextAlign.center,
              style: TatuTexto.nota.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desenho de QR code de exemplo (o de verdade vem do banco).
class _QrFalso extends CustomPainter {
  _QrFalso(this.codigo);

  final String codigo;

  static const _n = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final m = size.width / _n;
    final tinta = Paint()..color = TatuColors.action;
    var semente = codigo.codeUnits.fold<int>(
      7,
      (a, b) => (a * 31 + b) & 0x7fffffff,
    );
    bool canto(int x, int y) =>
        (x < 7 && y < 7) || (x >= _n - 7 && y < 7) || (x < 7 && y >= _n - 7);
    for (var y = 0; y < _n; y++) {
      for (var x = 0; x < _n; x++) {
        if (canto(x, y)) continue;
        semente = (semente * 1103515245 + 12345) & 0x7fffffff;
        if (semente % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x * m, y * m, m, m), tinta);
        }
      }
    }
    // Os três quadrados dos cantos.
    for (final (cx, cy) in [(0, 0), (_n - 7, 0), (0, _n - 7)]) {
      final o = Offset(cx * m, cy * m);
      canvas
        ..drawRect(o & Size(7 * m, 7 * m), tinta)
        ..drawRect(
          (o + Offset(m, m)) & Size(5 * m, 5 * m),
          Paint()..color = TatuColors.bg,
        )
        ..drawRect((o + Offset(2 * m, 2 * m)) & Size(3 * m, 3 * m), tinta);
    }
  }

  @override
  bool shouldRepaint(_QrFalso old) => old.codigo != codigo;
}
