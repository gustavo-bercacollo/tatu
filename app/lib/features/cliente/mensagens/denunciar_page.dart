import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/conversas.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/tela_permissao.dart';

/// Denunciar o profissional: escolhe o motivo e envia (anônimo).
class DenunciarPage extends StatefulWidget {
  const DenunciarPage({super.key, required this.conversa, this.motivo});

  final Conversa conversa;

  /// Motivo já escolhido (para abrir a tela preenchida).
  final int? motivo;

  @override
  State<DenunciarPage> createState() => _DenunciarPageState();
}

class _DenunciarPageState extends State<DenunciarPage> {
  static const _motivos = [
    'Comportamento inadequado',
    'Golpe ou cobrança indevida',
    'Não compareceu',
    'Outro motivo',
  ];

  late int? _escolhido = widget.motivo;

  @override
  Widget build(BuildContext context) {
    final c = widget.conversa;
    return CadastroScaffold(
      titulo: 'Denunciar ${c.primeiroNome}',
      subtitulo:
          'O que aconteceu?\n${c.feminino ? 'Ela' : 'Ele'} não vê que foi você.',
      botao: 'Enviar denúncia',
      // Sem backend ainda: só confirma o envio.
      onBotao: _escolhido == null
          ? null
          : () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DenunciaEnviadaPage()),
            ),
      children: [
        for (final (i, m) in _motivos.indexed) ...[
          OpcaoSelecionavel(
            selecionado: i == _escolhido,
            rotulo: m,
            onTap: () => setState(() => _escolhido = i),
            child: SizedBox(
              height: TatuMedidas.alturaBotao,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    BolinhaEscolha(selecionado: i == _escolhido),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(m, style: const TextStyle(fontSize: 17)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Denúncia enviada: a equipe analisa; volta para a conversa.
class DenunciaEnviadaPage extends StatelessWidget {
  const DenunciaEnviadaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      sucesso: true,
      icone: const IconePermissao(TablerIcons.check, cor: TatuColors.online),
      titulo: 'Denúncia enviada',
      texto: 'Nossa equipe vai analisar.\nVocê não precisa fazer mais nada.',
      principal: 'Voltar para a conversa',
      onPrincipal: () => Navigator.of(context).pop(),
    );
  }
}
