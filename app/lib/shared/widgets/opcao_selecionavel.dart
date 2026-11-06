import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Cartão cinza de escolha única: o escolhido ganha borda preta.
class OpcaoSelecionavel extends StatelessWidget {
  const OpcaoSelecionavel({
    super.key,
    required this.selecionado,
    required this.onTap,
    required this.child,
    this.rotulo,
  });

  final bool selecionado;
  final VoidCallback onTap;
  final Widget child;

  /// Nome lido pelo leitor de tela.
  final String? rotulo;

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      side: BorderSide(
        color: selecionado ? TatuColors.textPrimary : Colors.transparent,
        width: 2,
      ),
    );
    return Semantics(
      button: true,
      selected: selecionado,
      label: rotulo,
      child: Material(
        color: TatuColors.fill,
        shape: forma,
        child: InkWell(customBorder: forma, onTap: onTap, child: child),
      ),
    );
  }
}

/// Bolinha de escolha única (preta com miolo branco quando escolhida).
class BolinhaEscolha extends StatelessWidget {
  const BolinhaEscolha({super.key, required this.selecionado});

  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selecionado ? TatuColors.action : TatuColors.bg,
        border: selecionado
            ? null
            : Border.all(color: TatuColors.chevron, width: 1.5),
      ),
      child: selecionado
          ? Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: TatuColors.bg,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

/// Link azul em negrito (ex.: "Não é sobre um pedido", "Trocar número").
class LinkAzul extends StatelessWidget {
  const LinkAzul(this.texto, {super.key, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: TatuColors.verified,
            ),
          ),
        ),
      ),
    );
  }
}
