import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/conta.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../conta/novo_email_page.dart';

/// Recibo do pedido pago pelo app. Se foi pago direto ao profissional, vira
/// "Comprovante" (do serviço, não do pagamento).
class ReciboPage extends StatelessWidget {
  const ReciboPage({super.key, required this.pedido});

  final PedidoConcluido pedido;

  void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  /// Sem e-mail na conta (cadastro pelo celular), pede antes de enviar.
  Future<void> _enviarPorEmail(BuildContext context) async {
    if (conta.email == null) {
      final email = await Navigator.of(
        context,
      ).push<String>(MaterialPageRoute(builder: (_) => const NovoEmailPage()));
      if (email == null) return;
      conta.definirEmail(email);
    }
    if (!context.mounted) return;
    mostrarAvisoTopo(
      context,
      titulo: 'Recibo enviado',
      texto: 'Enviamos para ${conta.email}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    final fora = p.pagoPorFora;
    return TelaInterna(
      titulo: fora ? 'Comprovante' : 'Recibo',
      fundoCinza: true,
      acao: 'Compartilhar',
      acaoIcone: TablerIcons.share_2,
      onAcao: () => _emBreve(context, 'Compartilhar'),
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: TatuMedidas.entreSecoes,
            ),
            decoration: BoxDecoration(
              color: TatuColors.bg,
              borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            ),
            child: Column(
              children: [
                Text(
                  '${p.servico} · ${p.dia} ${p.ano}, ${p.hora}',
                  style: TatuTexto.detalhe,
                ),
                const SizedBox(height: 4),
                Text(
                  p.valor,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                SeloVerde(
                  fora
                      ? 'Pago direto ao profissional'
                      : 'Pago · ${p.pagamento}',
                  aviso: fora,
                ),
              ],
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          GrupoCartao(
            nota: fora
                ? 'Pagamentos por fora não passam pelo Tatu.\n'
                      'Este é um comprovante do serviço,\nnão do pagamento.'
                : null,
            linhas: [
              LinhaRotuloValor(rotulo: 'Serviço', valor: p.descricao),
              LinhaRotuloValor(rotulo: 'Profissional', valor: p.profissional),
              LinhaRotuloValor(rotulo: 'Endereço', valor: p.endereco),
              LinhaRotuloValor(rotulo: 'Pedido', valor: p.numero),
            ],
          ),
        ],
      ),
      rodape: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () =>
                _emBreve(context, fora ? 'Baixar comprovante' : 'Baixar PDF'),
            child: Text(fora ? 'Baixar comprovante' : 'Baixar PDF'),
          ),
          if (!fora) ...[
            const SizedBox(height: 10),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => _enviarPorEmail(context),
              child: const Text('Enviar por e-mail'),
            ),
          ],
        ],
      ),
    );
  }
}
