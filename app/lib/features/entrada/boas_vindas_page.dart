import '../suporte/painel_mediacao_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../shared/widgets/option_card.dart';
import '../profissional/cadastro/boas_vindas_profissional_page.dart';
import 'celular_page.dart';

/// Boas-vindas: primeira tela, comum ao cliente e ao profissional.
class BoasVindasPage extends StatelessWidget {
  const BoasVindasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            // Rola só se a tela for baixa; senão o rodapé fica embaixo.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(child: _conteudo(context)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _conteudo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TatuMedidas.margemCadastro,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 64),
          // Protótipo: segurar o nome abre o painel interno do suporte
          // (mediações, RN-190/RN-191). Não é uma tela dos usuários.
          GestureDetector(
            onLongPress: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PainelMediacaoPage()),
            ),
            child: const Text(
              'tatu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.3,
              ),
            ),
          ),
          const SizedBox(height: 92),
          const Text(
            'Como você quer usar o Tatu?',
            style: TextStyle(
              fontSize: 30,
              height: 36 / 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 26),
          OptionCard(
            icon: TablerIcons.home,
            title: 'Preciso de um serviço',
            subtitle: 'Peça um profissional e resolva rápido.',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CelularPage())),
          ),
          const SizedBox(height: 12),
          OptionCard(
            icon: TablerIcons.tools,
            title: 'Quero trabalhar',
            subtitle: 'Receba chamados de clientes perto de você.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BoasVindasProfissionalPage(),
              ),
            ),
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              text: 'Já tem conta? ',
              children: [
                TextSpan(
                  text: 'Entrar',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TatuColors.textPrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CelularPage.entrar(),
                      ),
                    ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: TatuColors.textSecondary,
            ),
          ),
          // RN-150: o aceite é ativo, na tela "Seus dados".
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
