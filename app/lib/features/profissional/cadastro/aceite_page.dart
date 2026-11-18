import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../data/aceites.dart';
import '../../../data/documentos_legais.dart';
import '../../../data/resumo_tatu.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../entrada/documentos_legais_page.dart';

const _icones = [
  TablerIcons.user,
  TablerIcons.wallet,
  TablerIcons.clock,
  TablerIcons.shield_check,
];

/// P15 · RN-150: "Antes de enviar": o profissional confirma de novo os
/// pontos principais (autônomo, taxa, Pix em 24 h, só pelo app) e aceita
/// os documentos. "Enviar para análise" só com a caixa marcada.
class AceiteProfissionalPage extends StatefulWidget {
  const AceiteProfissionalPage({super.key, required this.onEnviar});

  /// Envia a verificação (depois de registrar o aceite).
  final VoidCallback onEnviar;

  @override
  State<AceiteProfissionalPage> createState() => _AceiteProfissionalPageState();
}

class _AceiteProfissionalPageState extends State<AceiteProfissionalPage> {
  bool _aceitou = false;

  Future<void> _enviar() async {
    await documentosLegais.carregarTodos();
    // RN-150: registra o aceite (conta, tipo, versões, data e hora).
    aceites.registrar(
      conta: contaDoAceite(),
      tipo: TipoAceite.profissional,
      termos: documentosLegais.termos!,
      politica: documentosLegais.politica!,
    );
    if (mounted) widget.onEnviar();
  }

  @override
  Widget build(BuildContext context) => CadastroScaffold(
    titulo: 'Antes de enviar',
    subtitulo: 'Confira como funciona o trabalho no Tatu.',
    botao: 'Enviar para análise',
    onBotao: _aceitou ? _enviar : null,
    children: [
      const SizedBox(height: TatuMedidas.entreItens),
      for (final (i, p) in resumoProfissional().indexed) ...[
        ItemVantagem(
          icone: _icones[i],
          titulo: p.titulo,
          texto: p.texto,
        ),
        const SizedBox(height: TatuMedidas.entreItens + 6),
      ],
      const SizedBox(height: TatuMedidas.entreItens),
      CaixaAceite(
        marcado: _aceitou,
        onMudar: (v) => setState(() => _aceitou = v),
      ),
    ],
  );
}
