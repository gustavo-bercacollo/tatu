import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/enderecos.dart';

IconData iconeDoTipo(TipoEndereco t) => switch (t) {
  TipoEndereco.casa => TablerIcons.home,
  TipoEndereco.trabalho => TablerIcons.briefcase,
  TipoEndereco.outro => TablerIcons.map_pin,
};

/// Linha de endereço: ícone num círculo, título, detalhe cinza e um item
/// opcional à direita. [fundoIcone] contrasta com o fundo do cartão.
class LinhaEndereco extends StatelessWidget {
  const LinhaEndereco({
    super.key,
    required this.icone,
    required this.titulo,
    required this.detalhe,
    required this.onTap,
    this.fundoIcone = TatuColors.fill,
    this.corTitulo,
    this.direita,
    this.recuo = 14,
  });

  final IconData icone;
  final String titulo;
  final String detalhe;
  final VoidCallback onTap;
  final Color fundoIcone;
  final Color? corTitulo;
  final Widget? direita;

  /// Espaço antes do ícone (14 dentro de cartão; menor numa lista solta).
  final double recuo;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(recuo, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: fundoIcone,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icone,
                size: 18,
                color: corTitulo ?? TatuColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: corTitulo ?? TatuColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detalhe,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: TatuColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (direita != null) ...[const SizedBox(width: 8), direita!],
          ],
        ),
      ),
    );
  }
}

/// Divisor entre linhas de endereço, alinhado com o texto.
class DivisorEndereco extends StatelessWidget {
  const DivisorEndereco({super.key, this.inicio = 60});

  final double inicio;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: inicio),
    child: const Divider(height: 0.5),
  );
}
