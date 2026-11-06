import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conta.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_interna.dart';
import 'editar_nome_page.dart';
import 'excluir_bloqueado_page.dart';
import 'excluir_conta_page.dart';
import 'novo_celular_page.dart';
import 'novo_email_page.dart';

/// Dados da conta: nome, celular e e-mail (com ✓ de confirmado) e
/// "Excluir conta".
class DadosContaPage extends StatelessWidget {
  const DadosContaPage({super.key});

  Future<void> _trocarCelular(BuildContext context) async {
    final novo = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const NovoCelularPage()));
    if (novo == null || !context.mounted) return;
    conta.definirCelular(novo);
    mostrarAvisoTopo(
      context,
      titulo: 'Celular atualizado',
      texto: 'Use o novo número para entrar.',
    );
  }

  Future<void> _trocarEmail(BuildContext context) async {
    final novo = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const NovoEmailPage()));
    if (novo == null || !context.mounted) return;
    conta.definirEmail(novo);
    mostrarAvisoTopo(
      context,
      titulo: 'E-mail atualizado',
      texto: 'Seus recibos vão para o novo e-mail.',
    );
  }

  void _excluir(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => conta.pedidoEmAndamento
          ? const ExcluirBloqueadoPage()
          : const ExcluirContaPage(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: conta,
      builder: (context, _) => TelaInterna(
        titulo: 'Dados da conta',
        fundoCinza: true,
        corpo: ListView(
          padding: const EdgeInsets.only(top: TatuMedidas.topo * 2),
          children: [
            GrupoCartao(
              nota: 'Usamos o celular para entrar e avisar dos pedidos.',
              linhas: [
                _LinhaDado(
                  rotulo: 'Nome',
                  valor: conta.nomeCompleto,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditarNomePage()),
                  ),
                ),
                _LinhaDado(
                  rotulo: 'Celular',
                  valor: conta.celularFormatado,
                  confirmado: true,
                  onTap: () => _trocarCelular(context),
                ),
                _LinhaDado(
                  rotulo: 'E-mail',
                  valor: conta.email,
                  confirmado: true,
                  onTap: () => _trocarEmail(context),
                ),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreSecoes + 8),
            CartaoBotao(texto: 'Excluir conta', onTap: () => _excluir(context)),
          ],
        ),
      ),
    );
  }
}

/// Linha com rótulo cinza, valor, ✓ verde de confirmado e seta.
class _LinhaDado extends StatelessWidget {
  const _LinhaDado({
    required this.rotulo,
    required this.valor,
    required this.onTap,
    this.confirmado = false,
  });

  final String rotulo;
  final String valor;
  final VoidCallback onTap;
  final bool confirmado;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rotulo, style: TatuTexto.nota),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          valor,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                      if (confirmado) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          TablerIcons.check,
                          size: 18,
                          color: TatuColors.online,
                          semanticLabel: 'Confirmado',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              TablerIcons.chevron_right,
              size: 18,
              color: TatuColors.chevron,
            ),
          ],
        ),
      ),
    );
  }
}
