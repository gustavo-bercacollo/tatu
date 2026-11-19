import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ajuda.dart';
import '../../../data/pedidos.dart';
import '../../../data/prazos.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../abas.dart';
import '../ajuda/abrir_ajuda.dart';

/// Abre "Você não estava no local" no lugar da tela atual (RN-81).
void mostrarAusencia(BuildContext context) {
  final p = pedidos.ausente;
  if (p == null) return;
  pedidos.consumirAusente();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => VoceNaoEstavaPage(pedido: p)),
  );
}

/// C95 · O cliente não apareceu: o profissional esperou e encerrou o
/// chamado; só a visita foi cobrada (RN-81).
class VoceNaoEstavaPage extends StatelessWidget {
  const VoceNaoEstavaPage({super.key, required this.pedido});

  final PedidoAndamento pedido;

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    return TelaPermissao(
      voltar: false,
      aviso: true,
      icone: const Icon(
        TablerIcons.door,
        size: 40,
        color: TatuColors.warningTexto,
      ),
      titulo: 'Você não estava no local',
      texto: 'A visita foi cobrada: ${reais(p.visita)}',
      extra: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TatuColors.surfaceGrouped,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${p.artigoNome} esperou ${Prazos.esperaCliente.inMinutes} '
              'minutos na porta.',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text('O serviço não foi cobrado.', style: TatuTexto.nota),
          ],
        ),
      ),
      principal: 'Pedir de novo',
      onPrincipal: () => irParaAba(context, AbaCliente.inicio),
      // RN-81: discordou? Avisa o suporte em até 24 h.
      link: 'Algo errado? Avise em até 24h',
      onLink: () => abrirSuporte(context, conteudoCliente),
    );
  }
}
