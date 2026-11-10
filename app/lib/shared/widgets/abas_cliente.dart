import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';

/// Abas do cliente.
enum AbaCliente { inicio, atividade, mensagens }

/// Barra de abas do cliente: Início · Atividade · Mensagens.
class AbasCliente extends StatelessWidget {
  const AbasCliente({super.key, this.ativa = AbaCliente.inicio, this.onTrocar});

  final AbaCliente ativa;

  /// Toque numa aba (a navegação fica em `features/cliente/abas.dart`).
  final ValueChanged<AbaCliente>? onTrocar;

  @override
  Widget build(BuildContext context) {
    VoidCallback? ir(AbaCliente a) =>
        onTrocar == null ? null : () => onTrocar!(a);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TatuColors.tabBar,
        border: Border(
          top: BorderSide(color: TatuColors.tabBarLine, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 49,
          child: Row(
            children: [
              _Aba(
                icone: TablerIcons.home,
                texto: 'Início',
                ativa: ativa == AbaCliente.inicio,
                onTap: ir(AbaCliente.inicio),
              ),
              _Aba(
                icone: TablerIcons.clock,
                texto: 'Atividade',
                ativa: ativa == AbaCliente.atividade,
                onTap: ir(AbaCliente.atividade),
              ),
              _Aba(
                icone: TablerIcons.message_circle,
                texto: 'Mensagens',
                ativa: ativa == AbaCliente.mensagens,
                onTap: ir(AbaCliente.mensagens),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Aba extends StatelessWidget {
  const _Aba({
    required this.icone,
    required this.texto,
    this.ativa = false,
    this.onTap,
  });

  final IconData icone;
  final String texto;
  final bool ativa;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cor = ativa ? TatuColors.textPrimary : TatuColors.textSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: ativa,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 24, color: cor),
              const SizedBox(height: 3),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: ativa ? FontWeight.w600 : FontWeight.w500,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
