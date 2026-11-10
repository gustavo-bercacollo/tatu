import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../abas.dart';

/// Ninguém ativo nesse momento: a busca continua em segundo plano e
/// avisamos quando alguém aceitar.
class NinguemAtivoPage extends StatelessWidget {
  const NinguemAtivoPage({super.key, required this.servico});

  final String servico;

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(TablerIcons.clock),
      titulo: 'Ninguém ativo nesse momento',
      texto: 'Continuamos buscando em segundo plano.\nAvisamos assim que alguém aceitar.',
      extra: _CartaoBusca(servico: servico),
      principal: 'Voltar ao início',
      onPrincipal: () => irParaAba(context, AbaCliente.inicio),
      alternativa: 'Cancelar pedido',
      onAlternativa: () {
        pedidos.cancelarBusca();
        irParaAba(context, AbaCliente.inicio);
      },
      abas: const AbasDoCliente(ativa: AbaCliente.inicio),
    );
  }
}

class _CartaoBusca extends StatelessWidget {
  const _CartaoBusca({required this.servico});

  final String servico;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: TatuColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscando em segundo plano',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pedido: $servico · válido por 1 hora',
                  style: TatuTexto.nota,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
