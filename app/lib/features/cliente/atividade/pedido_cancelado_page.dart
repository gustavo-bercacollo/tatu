import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../abas.dart';

/// Pedido cancelado: profissional avisado, nada cobrado.
class PedidoCanceladoPage extends StatelessWidget {
  const PedidoCanceladoPage({super.key, required this.profissional});

  /// Primeiro nome de quem foi avisado.
  final String profissional;

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      icone: const IconePermissao(TablerIcons.x, cor: TatuColors.textPrimary),
      titulo: 'Pedido cancelado',
      texto: 'A $profissional foi avisada.\nNada foi cobrado.',
      principal: 'Pedir outro serviço',
      onPrincipal: () => irParaAba(context, AbaCliente.inicio),
      alternativa: 'Voltar para Atividade',
      onAlternativa: () => Navigator.of(context).pop(),
    );
  }
}
