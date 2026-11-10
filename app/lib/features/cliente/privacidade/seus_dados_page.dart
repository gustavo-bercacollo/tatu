import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conta.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../conta/dados_conta_page.dart';
import '../conta/excluir_bloqueado_page.dart';
import '../conta/excluir_conta_page.dart';
import 'baixar_dados_page.dart';

/// Seus dados e direitos: baixar, corrigir ou excluir.
class SeusDadosPage extends StatelessWidget {
  const SeusDadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    void abrir(Widget tela) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
    return TelaInterna(
      titulo: 'Seus dados',
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Você decide o que fazemos com suas informações.',
              style: TatuTexto.detalhe,
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          CartaoAcao(
            icone: const IconeCirculo(TablerIcons.file_text),
            titulo: 'Baixar meus dados',
            detalhe: 'Receba uma cópia por e-mail',
            onTap: () => abrir(const BaixarDadosPage()),
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          CartaoAcao(
            icone: const IconeCirculo(TablerIcons.pencil),
            titulo: 'Corrigir meus dados',
            detalhe: 'Nome, celular e e-mail',
            onTap: () => abrir(const DadosContaPage()),
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          CartaoAcao(
            icone: const IconeCirculo(TablerIcons.x, cor: TatuColors.danger),
            titulo: 'Excluir minha conta',
            corTitulo: TatuColors.danger,
            detalhe: 'Apaga seus dados do Tatu',
            onTap: () => abrir(
              conta.pedidoEmAndamento
                  ? const ExcluirBloqueadoPage()
                  : const ExcluirContaPage(),
            ),
          ),
        ],
      ),
    );
  }
}
