import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Excluir sua conta?',
      subtitulo: 'Isso não pode ser desfeito.',
      botao: 'Excluir minha conta',
      perigo: true,
      onBotao: () => _excluir(context),
      botaoSecundario: 'Manter minha conta',
      onSecundario: () => Navigator.of(context).pop(),
      children: const [
        LinhaConsequencia(TablerIcons.user, 'Seu perfil e foto são apagados.'),
        LinhaConsequencia(
          TablerIcons.map_pin,
          'Endereços e cartões salvos são removidos.',
        ),
        LinhaConsequencia(
          TablerIcons.star,
          'Suas avaliações deixam de aparecer.',
        ),
        LinhaConsequencia(
          TablerIcons.briefcase,
          'Se você também é profissional, o perfil profissional também é excluído.',
        ),
        SizedBox(height: 16),
        CadastroNota('Pedidos antigos ficam sem seus dados pessoais.'),
      ],
    );
  }
}
