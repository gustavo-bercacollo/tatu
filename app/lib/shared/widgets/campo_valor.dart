import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../formatadores.dart';

/// Campo de valor em reais grande, com rótulo cinza em cima, fundo cinza e
/// contorno preto (ex.: "Total (visita + serviço)", "Sua proposta por
/// visita").
class CampoValorGrande extends StatelessWidget {
  const CampoValorGrande({
    super.key,
    required this.rotulo,
    required this.controller,
    required this.onChanged,
    this.autofocus = true,
  });

  final String rotulo;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  static const _estilo = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
        border: Border.all(color: TatuColors.textPrimary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: TatuTexto.nota),
          TextField(
            controller: controller,
            autofocus: autofocus,
            keyboardType: TextInputType.number,
            inputFormatters: [ReaisFormatter()],
            onChanged: onChanged,
            cursorColor: TatuColors.textPrimary,
            style: _estilo,
            decoration: InputDecoration.collapsed(
              hintText: 'R\$ 0',
              hintStyle: _estilo.copyWith(color: TatuColors.textDisabled),
            ),
          ),
        ],
      ),
    );
  }
}
