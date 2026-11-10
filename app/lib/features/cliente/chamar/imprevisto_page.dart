import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../abas.dart';
import 'chamando_outro_page.dart';

/// O profissional cancelou depois de aceitar: chamar outro ou cancelar.
class ImprevistoPage extends StatelessWidget {
  const ImprevistoPage({super.key, required this.pedido});

  final PedidoAndamento pedido;

  @override
  Widget build(BuildContext context) {
    final ela = pedido.profissao.endsWith('a');
    return TelaPermissao(
      aviso: true,
      icone: const IconePermissao(
        TablerIcons.alert_triangle,
        cor: TatuColors.warning,
      ),
      titulo: '${ela ? 'A' : 'O'} ${pedido.primeiroNome} teve um imprevisto',
      texto:
          '${ela ? 'Ela' : 'Ele'} cancelou o atendimento.\nNada foi cobrado.',
      principal: 'Chamar outro ${pedido.servico.toLowerCase()}',
      onPrincipal: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ChamandoOutroPage(pedido: pedido)),
      ),
      alternativa: 'Cancelar pedido',
      onAlternativa: () {
        pedidos.cancelarAndamento();
        irParaAba(context, AbaCliente.inicio);
      },
    );
  }
}
