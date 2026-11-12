import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
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
                LinhaDado(
                  rotulo: 'Nome',
                  valor: conta.nomeCompleto,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditarNomePage()),
                  ),
                ),
                LinhaDado(
                  rotulo: 'Celular',
                  valor: conta.celularFormatado ?? 'Adicionar',
                  confirmado: conta.celular != null,
                  onTap: () => _trocarCelular(context),
                ),
                LinhaDado(
                  rotulo: 'E-mail',
                  valor: conta.email ?? 'Adicionar',
                  confirmado: conta.email != null,
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
