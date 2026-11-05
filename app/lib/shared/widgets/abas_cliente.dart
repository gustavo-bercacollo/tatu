import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';

/// Barra de abas do cliente: Início · Atividade · Mensagens.
class AbasCliente extends StatelessWidget {
  const AbasCliente({super.key, this.onInicio});

  /// Toque em "Início" (ex.: o Perfil volta para a Home).
  final VoidCallback? onInicio;

  @override
  Widget build(BuildContext context) {
    void emBreve(String o) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$o: em breve')));

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
                ativa: true,
                onTap: onInicio,
              ),
              _Aba(
                icone: TablerIcons.clock,
                texto: 'Atividade',
                onTap: () => emBreve('Atividade'),
              ),
              _Aba(
                icone: TablerIcons.message_circle,
                texto: 'Mensagens',
                onTap: () => emBreve('Mensagens'),
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
