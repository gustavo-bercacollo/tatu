import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../data/pagamentos.dart';
import '../../../data/profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../entrada/boas_vindas_page.dart';

/// Excluir sua conta: o que acontece, "Excluir minha conta" (com folha de
/// confirmação) ou "Manter minha conta".
class ExcluirContaPage extends StatelessWidget {
  const ExcluirContaPage({super.key});

  Future<void> _excluir(BuildContext context) async {
    final sim = await confirmar(
      context,
      titulo: 'Excluir de vez?',
      texto: 'Sua conta e seus dados serão apagados.\nNão dá para desfazer.',
      confirmar: 'Sim, excluir conta',
      perigo: true,
    );
    if (!sim || !context.mounted) return;
    // Sem backend ainda: só volta para o começo do app.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BoasVindasPage()),
      (_) => false,
    );
  }

  /// RN-15/RN-192: dívida no Tatu (do cliente, RN-226, ou do
  /// profissional, RN-192). A exclusão é aceita mesmo assim.
  static double get _divida =>
      (pagamentos.pendencia ?? 0) + profissional.divida;

  @override
  Widget build(BuildContext context) {
    final divida = _divida;
    return CadastroScaffold(
      titulo: 'Excluir sua conta?',
      subtitulo: 'Isso não pode ser desfeito.',
      botao: 'Excluir minha conta',
      perigo: true,
      onBotao: () => _excluir(context),
      botaoSecundario: 'Manter minha conta',
      onSecundario: () => Navigator.of(context).pop(),
      children: [
        const LinhaConsequencia(
          TablerIcons.user,
          'Seu perfil e foto são apagados.',
        ),
        const LinhaConsequencia(
          TablerIcons.map_pin,
          'Endereços e cartões salvos são removidos.',
        ),
        const LinhaConsequencia(
          TablerIcons.star,
          'Suas avaliações deixam de aparecer.',
        ),
        const LinhaConsequencia(
          TablerIcons.briefcase,
          'Se você também é profissional, o perfil profissional também é excluído.',
        ),
        // RN-15: com dívida, a exclusão é aceita, mas a dívida continua
        // ligada ao CPF dentro do Tatu (LGPD, art. 16).
        if (divida > 0)
          LinhaConsequencia(
            TablerIcons.receipt,
            'Sua dívida de ${reais(divida)} continua ligada ao seu CPF no '
            'Tatu.',
          ),
        const SizedBox(height: 16),
        const CadastroNota(
          'Pedidos antigos ficam sem seus dados pessoais. O Tatu guarda só o '
          'que a lei exige: dívida, provas e registros.',
        ),
      ],
    );
  }
}
