import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/pagamentos.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_interna.dart';

/// Detalhe do cartão: desenho do cartão, padrão, validade e remover.
class CartaoPage extends StatelessWidget {
  const CartaoPage({super.key, required this.cartao});

  final Cartao cartao;

  Future<void> _remover(BuildContext context) async {
    final ok = await confirmar(
      context,
      titulo: 'Remover este cartão?',
      texto:
          'O ${cartao.titulo} não poderá mais ser usado.\n'
          'Você pode adicionar de novo depois.',
      confirmar: 'Remover cartão',
      perigo: true,
    );
    if (!ok || !context.mounted) return;
    pagamentos.remover(cartao);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: cartao.titulo,
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.topo),
        children: [
          _DesenhoCartao(cartao: cartao),
          const SizedBox(height: TatuMedidas.entreSecoes),
          GrupoCartao(
            linhas: [
              ListenableBuilder(
                listenable: pagamentos,
                builder: (context, _) => LinhaInterruptor(
                  texto: 'Cartão padrão',
                  valor: pagamentos.ePadrao(cartao),
                  onMudar: (v) => pagamentos.definirPadrao(cartao, v),
                ),
              ),
              _LinhaValor(texto: 'Validade', valor: cartao.validade),
            ],
          ),
        ],
      ),
      rodape: TextButton(
        onPressed: () => _remover(context),
        style: TextButton.styleFrom(
          foregroundColor: TatuColors.danger,
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text('Remover cartão', style: TextStyle(fontSize: 17)),
      ),
    );
  }
}

/// Linha simples com texto e valor cinza à direita.
class _LinhaValor extends StatelessWidget {
  const _LinhaValor({required this.texto, required this.valor});

  final String texto;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TatuMedidas.alturaLinha,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Text(texto, style: const TextStyle(fontSize: 17))),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 17,
                color: TatuColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão preto com bandeira, chip, final do número, nome e validade.
class _DesenhoCartao extends StatelessWidget {
  const _DesenhoCartao({required this.cartao});

  final Cartao cartao;

  @override
  Widget build(BuildContext context) {
    const claro = Color(0xFFAEAEB2);
    // Altura mínima do desenho; cresce se o texto precisar (telas estreitas).
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 190),
      child: Container(
        padding: const EdgeInsets.all(TatuMedidas.margemCadastro),
        decoration: BoxDecoration(
          color: TatuColors.action,
          borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cartao.bandeira,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TatuColors.onAction,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3C),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              '•••• •••• •••• ${cartao.final4}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: TatuColors.onAction,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    cartao.nome,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: claro),
                  ),
                ),
                Text(
                  cartao.validade,
                  style: const TextStyle(fontSize: 13, color: claro),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
