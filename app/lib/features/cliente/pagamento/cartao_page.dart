import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/pagamentos.dart';
import '../../../shared/widgets/folha.dart';
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
          Material(
            color: TatuColors.bg,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _Linha(
                  texto: 'Cartão padrão',
                  direita: ListenableBuilder(
                    listenable: pagamentos,
                    builder: (context, _) => CupertinoSwitch(
                      value: pagamentos.ePadrao(cartao),
                      activeTrackColor: TatuColors.online,
                      onChanged: (v) => pagamentos.definirPadrao(cartao, v),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Divider(height: 0.5),
                ),
                _Linha(
                  texto: 'Validade',
                  direita: Text(
                    cartao.validade,
                    style: const TextStyle(
                      fontSize: 17,
                      color: TatuColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
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

class _Linha extends StatelessWidget {
  const _Linha({required this.texto, required this.direita});

  final String texto;
  final Widget direita;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TatuMedidas.alturaLinha,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Text(texto, style: const TextStyle(fontSize: 17))),
            direita,
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
