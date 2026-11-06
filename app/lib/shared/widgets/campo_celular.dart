import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../formatadores.dart';
import 'tatu_field.dart';

/// Campo de celular com a caixa "BR +55" ao lado; formata (11) 98888-7777.
class CampoCelular extends StatelessWidget {
  const CampoCelular({
    super.key,
    required this.controller,
    this.label = 'Celular',
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Celular completo: DDD + 9 dígitos.
  static bool completo(String texto) => soDigitos(texto).length == 11;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 86,
          height: TatuMedidas.alturaCampo,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
          ),
          child: const Text(
            'BR +55',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TatuField(
            label: label,
            hintText: '(11) 98888-7777',
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MascaraFormatter(moldeCelular),
            ],
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }
}
