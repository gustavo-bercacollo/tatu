import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/pedidos.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../abas.dart';
import 'avaliar_page.dart';
import 'contestar_page.dart';

/// Fim do serviço para o cliente. Concluído: cobra visita + serviço e
/// abre a avaliação. Não realizado (o profissional encerrou sem fazer):
/// só a visita é cobrada. Nos dois, "Algo errado?" contesta em até 24 h.
class ServicoFinalizadoPage extends StatelessWidget {
  const ServicoFinalizadoPage({
    super.key,
    required this.pedido,
    this.visita = 40,
    this.servico = 150,
    this.realizado = true,
    this.recibo = '000482',
  });

  final PedidoConcluido pedido;
  final double visita;
  final double servico;
  final bool realizado;
  final String recibo;

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    final nome = p.primeiroNome;
    final artigo = p.feminino ? 'a' : 'o';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 72),
                        Center(
                          child: realizado
                              ? const IconeResultado(
                                  TablerIcons.check,
                                  fundo: TatuColors.online,
                                  cor: TatuColors.onAction,
                                )
                              : const IconeResultado(TablerIcons.x),
                        ),
                        const SizedBox(height: TatuMedidas.entreSecoes + 8),
                        Text(
                          realizado
                              ? 'Serviço concluído'
                              : 'Serviço não realizado',
                          textAlign: TextAlign.center,
                          style: TatuTexto.tituloGrande,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          realizado
                              ? '${reais(visita + servico)} cobrado no '
                                    '${p.pagamento}'
                              : 'Só a visita foi cobrada: ${reais(visita)}',
                          textAlign: TextAlign.center,
                          style: TatuTexto.detalhe,
                        ),
                        const SizedBox(height: TatuMedidas.entreSecoes + 16),
                        Container(
                          padding: realizado
                              ? const EdgeInsets.symmetric(vertical: 6)
                              : const EdgeInsets.fromLTRB(16, 18, 16, 28),
                          decoration: BoxDecoration(
                            color: TatuColors.surfaceGrouped,
                            borderRadius: BorderRadius.circular(
                              TatuMedidas.raioCartao,
                            ),
                          ),
                          child: realizado
                              ? Column(
                                  children: [
                                    LinhaRotuloValor(
                                      rotulo: 'Visita',
                                      valor: reais(visita),
                                    ),
                                    LinhaRotuloValor(
                                      rotulo: 'Serviço',
                                      valor: reais(servico),
                                    ),
                                    LinhaRotuloValor(
                                      rotulo: 'Forma',
                                      valor: 'Cartão ${p.pagamento}',
                                    ),
                                    LinhaRotuloValor(
                                      rotulo: 'Recibo',
                                      valor: 'nº $recibo',
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${artigo == 'a' ? 'A' : 'O'} $nome '
                                      'encerrou sem fazer o serviço.',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Os ${reaisInteiros(servico)} do '
                                      'serviço não foram cobrados.',
                                      style: TatuTexto.detalhe,
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: realizado
                        ? () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => AvaliarPage(pedido: p),
                            ),
                          )
                        : () => irParaAba(context, AbaCliente.inicio),
                    child: Text(
                      realizado
                          ? 'Avaliar $artigo $nome'
                          : 'Chamar outro ${p.servico.toLowerCase()}',
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  LinkAzul(
                    'Algo errado? Avise em até 24h',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ContestarServicoPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
