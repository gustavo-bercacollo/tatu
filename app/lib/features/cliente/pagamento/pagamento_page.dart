import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/pagamentos.dart';
import '../../../shared/widgets/botao_tracejado.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/linha_icone.dart';
import '../../../shared/widgets/tela_interna.dart';
import 'cartao_page.dart';
import 'novo_cartao_page.dart';

/// Formas de pagamento (pelo Perfil). Sem cartões, mostra o estado vazio.
class PagamentoPage extends StatelessWidget {
  const PagamentoPage({super.key});

  void _novo(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const NovoCartaoPage()));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pagamentos,
      builder: (context, _) {
        final cartoes = pagamentos.cartoes;
        if (cartoes.isEmpty) {
          return TelaInterna(
            titulo: 'Pagamento',
            corpo: const EstadoVazio(
              icone: TablerIcons.credit_card,
              titulo: 'Nenhuma forma de pagamento',
              texto:
                  'Adicione um cartão para pagar pelo app.\n'
                  'Você também pode pagar por Pix\n'
                  'ou combinar direto com o profissional.',
            ),
            rodape: FilledButton(
              onPressed: () => _novo(context),
              child: const Text('Adicionar cartão'),
            ),
          );
        }
        return TelaInterna(
          titulo: 'Pagamento',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(top: 30),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  TatuMedidas.tituloSecao,
                ),
                child: Text('FORMAS DE PAGAMENTO', style: TatuTexto.secao),
              ),
              Material(
                color: TatuColors.bg,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final c in cartoes) ...[
                      LinhaIcone(
                        icone: TablerIcons.credit_card,
                        titulo: c.titulo,
                        detalhe: 'Vence ${c.validade}',
                        direita: pagamentos.ePadrao(c)
                            ? const _SeloPadrao()
                            : const Icon(
                                TablerIcons.chevron_right,
                                size: 16,
                                color: TatuColors.chevron,
                              ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CartaoPage(cartao: c),
                          ),
                        ),
                      ),
                      const DivisorLinha(),
                    ],
                    LinhaIcone(
                      icone: TablerIcons.square_rotated,
                      titulo: 'Pix',
                      detalhe: 'Você paga na hora, ao fim do serviço',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              BotaoTracejado(
                texto: 'Adicionar cartão',
                onTap: () => _novo(context),
              ),
              const SizedBox(height: 36),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      TablerIcons.lock,
                      size: 16,
                      color: TatuColors.textSecondary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Os dados do cartão são protegidos.\n'
                        'Você só paga depois que o serviço termina.',
                        style: TatuTexto.nota,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              const Text(
                'Pagar pelo app é opcional. Você também pode '
                'combinar o pagamento direto com o profissional.',
                style: TatuTexto.nota,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeloPadrao extends StatelessWidget {
  const _SeloPadrao();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: const ShapeDecoration(
      color: TatuColors.fill,
      shape: StadiumBorder(),
    ),
    child: const Text(
      'Padrão',
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );
}
