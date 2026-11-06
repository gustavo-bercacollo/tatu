import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/folha.dart';
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
        _Consequencia(TablerIcons.user, 'Seu perfil e foto são apagados.'),
        _Consequencia(
          TablerIcons.map_pin,
          'Endereços e cartões salvos são removidos.',
        ),
        _Consequencia(TablerIcons.star, 'Suas avaliações deixam de aparecer.'),
        _Consequencia(
          TablerIcons.briefcase,
          'Se você também é profissional, o perfil profissional também é excluído.',
        ),
        SizedBox(height: 16),
        CadastroNota('Pedidos antigos ficam sem seus dados pessoais.'),
      ],
    );
  }
}

/// Linha com ícone num círculo cinza e o texto do que acontece.
class _Consequencia extends StatelessWidget {
  const _Consequencia(this.icone, this.texto);

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: TatuColors.fill,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 20, color: TatuColors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(texto, style: TatuTexto.comentario)),
        ],
      ),
    );
  }
}
