import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/enderecos.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tatu_field.dart';

/// Confirme o endereço: mapa com o pino, complemento e "Salvar como".
class ConfirmarEnderecoPage extends StatefulWidget {
  const ConfirmarEnderecoPage({super.key, required this.resultado});

  final ResultadoEndereco resultado;

  @override
  State<ConfirmarEnderecoPage> createState() => _ConfirmarEnderecoPageState();
}

class _ConfirmarEnderecoPageState extends State<ConfirmarEnderecoPage> {
  late final _endereco = TextEditingController(text: widget.resultado.rua);
  final _complemento = TextEditingController();
  TipoEndereco _tipo = TipoEndereco.casa;

  @override
  void dispose() {
    _endereco.dispose();
    _complemento.dispose();
    super.dispose();
  }

  void _confirmar() {
    enderecos.salvarNovo(
      resultado: widget.resultado,
      complemento: _complemento.text,
      tipo: _tipo,
    );
    // Volta para onde a busca começou (Home ou Endereços).
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            // O mapa passa 30 px por baixo da folha, para os cantos
            // arredondados dela aparecerem sobre o mapa.
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: -30,
                  child: CustomPaint(painter: _MapaFalso()),
                ),
                const Center(child: _Pino()),
                Positioned(
                  left: 20,
                  top: topo + 20,
                  child: Semantics(
                    button: true,
                    label: 'Voltar',
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: TatuColors.bg,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x1A000000), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(TablerIcons.chevron_left, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: TatuColors.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: TatuColors.fillStrong,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Confirme o endereço',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TatuField(
                      label: 'Endereço',
                      controller: _endereco,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TatuField(
                      hintText: 'Complemento (apto, bloco)',
                      controller: _complemento,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Salvar como',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: TatuColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final t in TipoEndereco.values)
                          TatuChip(
                            label: t.rotulo,
                            selecionado: _tipo == t,
                            onTap: () => setState(() => _tipo = t),
                          ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    FilledButton(
                      onPressed: _confirmar,
                      child: const Text('Confirmar endereço'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mapa ilustrativo (sem serviço de mapas ainda): quarteirões cinza,
/// ruas brancas levemente inclinadas e duas praças verdes.
class _MapaFalso extends CustomPainter {
  const _MapaFalso();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE9E9EE),
    );
    final verde = Paint()..color = const Color(0xFFDDEBD9);
    canvas.drawRRect(
      RRect.fromLTRBR(
        size.width * .64,
        50,
        size.width * .86,
        110,
        const Radius.circular(10),
      ),
      verde,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        size.width * .08,
        size.height * .74,
        size.width * .33,
        size.height * .9,
        const Radius.circular(10),
      ),
      verde,
    );
    final rua = Paint()
      ..color = Colors.white
      ..strokeWidth = 9;
    for (var x = -40.0; x < size.width + 40; x += 72) {
      canvas.drawLine(Offset(x + 10, 0), Offset(x - 10, size.height), rua);
    }
    for (var y = 40.0; y < size.height + 40; y += 92) {
      canvas.drawLine(Offset(0, y - 6), Offset(size.width, y + 6), rua);
    }
  }

  @override
  bool shouldRepaint(_MapaFalso oldDelegate) => false;
}

/// Pino preto com ponto branco e haste, apontando o centro do mapa.
class _Pino extends StatelessWidget {
  const _Pino();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: TatuColors.action,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(width: 3, height: 28, color: TatuColors.action),
        ],
      ),
    );
  }
}
