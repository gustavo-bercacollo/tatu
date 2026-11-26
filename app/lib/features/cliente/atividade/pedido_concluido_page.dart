import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/ajuda.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/estrelas.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../ajuda/chat_suporte_page.dart';
import '../retorno/retorno_cliente.dart';
import 'pedir_de_novo_sheet.dart';

/// Pedido concluído: profissional, sua avaliação, resumo e total.
class PedidoConcluidoPage extends StatelessWidget {
  const PedidoConcluidoPage({super.key, required this.pedido});

  final PedidoConcluido pedido;

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    return TelaInterna(
      titulo: 'Pedido concluído',
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.symmetric(vertical: TatuMedidas.entreSecoes),
        children: [
          GrupoCartao(
            linhas: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AvatarIniciais(nome: p.profissional, tamanho: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.profissional,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p.profissao} · ${p.dia}, ${p.hora}',
                            style: TatuTexto.nota,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (p.avaliacao != null)
                SizedBox(
                  height: TatuMedidas.alturaLinha,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Sua avaliação',
                            style: TatuTexto.detalhe,
                          ),
                        ),
                        Estrelas(nota: p.avaliacao!, tamanho: 18),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          GrupoCartao(
            linhas: [
              LinhaRotuloValor(rotulo: 'Serviço', valor: p.descricao),
              LinhaRotuloValor(rotulo: 'Endereço', valor: p.endereco),
              LinhaRotuloValor(rotulo: 'Pagamento', valor: p.pagamento),
              LinhaRotuloValor(rotulo: 'Total', valor: p.valor, destaque: true),
            ],
          ),
          // RN-45/RN-183: "Pagamento protegido" ou "O problema voltou?".
          CartaoAlgoErrado(pedido: p),
        ],
      ),
      rodape: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            // RN-176: abre o pedido já preenchido (mesma pessoa ou qualquer).
            onPressed: () => abrirPedirDeNovo(context, p),
            child: const Text('Pedir de novo'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: tatuBotaoSecundario(),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatSuportePage(
                  pedido: PedidoRecente(
                    servico: p.servico,
                    profissional: p.profissional.split(' ').first,
                    resumo: p.descricao,
                    descricao: p.descricao,
                    quando: p.dia,
                  ),
                ),
              ),
            ),
            child: const Text('Preciso de ajuda com este pedido'),
          ),
        ],
      ),
    );
  }
}
