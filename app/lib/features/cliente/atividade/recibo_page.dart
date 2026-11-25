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
import '../../../shared/widgets/opcao_selecionavel.dart' show LinkAzul;
import '../../../shared/widgets/tela_interna.dart';
import '../../../data/recibo.dart';
import '../../../data/documentos_legais.dart';
import '../../entrada/documentos_legais_page.dart';
import '../conta/novo_email_page.dart';

/// Recibo do pedido (todo pagamento passa pelo app).
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
    // RN-197: o e-mail leva o termo de garantia.
    recibos.enviarEmail(pedido, conta.email!);
    mostrarAvisoTopo(
      context,
      titulo: 'Recibo enviado',
      texto: 'Enviamos para ${conta.email}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    return TelaInterna(
      titulo: 'Recibo',
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
                SeloVerde('Pago · ${p.pagamento}'),
              ],
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          GrupoCartao(
            linhas: [
              LinhaRotuloValor(rotulo: 'Serviço', valor: p.descricao),
              LinhaRotuloValor(rotulo: 'Profissional', valor: p.profissional),
              LinhaRotuloValor(rotulo: 'Endereço', valor: p.endereco),
              LinhaRotuloValor(rotulo: 'Pedido', valor: p.numero),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          // C144 · RN-197: termo de garantia.
          _BlocoGarantia(garantia: garantiaDe(p)),
        ],
      ),
      rodape: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () {
              // RN-197: o PDF leva o termo de garantia.
              recibos.gerarPdf(p);
              mostrarAvisoTopo(
                context,
                titulo: 'PDF pronto',
                texto: 'Recibo ${p.numero}, com o termo de garantia.',
              );
            },
            child: const Text('Baixar PDF'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: tatuBotaoSecundario(),
            onPressed: () => _enviarPorEmail(context),
            child: const Text('Enviar por e-mail'),
          ),
        ],
      ),
    );
  }
}

/// C144 · RN-197: "Garantia": até quando, como pedir, direitos do CDC e
/// o link para a seção 11 dos Termos.
class _BlocoGarantia extends StatelessWidget {
  const _BlocoGarantia({required this.garantia});

  final GarantiaRecibo garantia;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: TatuColors.onlineSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  TablerIcons.shield_check,
                  size: 18,
                  color: TatuColors.onlineTexto,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                GarantiaRecibo.titulo,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          Text(
            garantia.linhaRetorno,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(GarantiaRecibo.comoPedir, style: TatuTexto.nota),
          const Text(GarantiaRecibo.direitos, style: TatuTexto.nota),
          const SizedBox(height: 4),
          LinkAzul(
            GarantiaRecibo.link,
            onTap: () =>
                abrirSecaoDocumento(context, TipoDocumento.termos, '11.'),
          ),
        ],
      ),
    );
  }
}
