import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Aviso vermelho de conta pausada (profissional: RN-63/RN-79; cliente:
/// RN-82). [motivo] diz o porquê; [destaque] vem em negrito embaixo.
/// Com [onSuporte], mostra "Falar com o suporte"; com [onTap], o cartão
/// inteiro abre o suporte.
class AvisoContaPausada extends StatelessWidget {
  const AvisoContaPausada({
    super.key,
    required this.motivo,
    this.destaque,
    this.onSuporte,
    this.onTap,
  });

  final String motivo;
  final String? destaque;
  final VoidCallback? onSuporte;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const texto = TextStyle(
      fontSize: 15,
      height: 1.35,
      color: TatuColors.danger,
    );
    return Material(
      color: TatuColors.dangerSoft,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      child: InkWell(
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                TablerIcons.alert_triangle,
                size: 22,
                color: TatuColors.danger,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conta pausada',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: TatuColors.danger,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(motivo, style: texto),
                    if (destaque != null)
                      Text(
                        destaque!,
                        style: texto.copyWith(fontWeight: FontWeight.w600),
                      ),
                    if (onSuporte != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: TatuColors.danger,
                            foregroundColor: TatuColors.onAction,
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            textStyle: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          onPressed: onSuporte,
                          child: const Text('Falar com o suporte'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
