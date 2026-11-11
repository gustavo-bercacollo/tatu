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
  const DenunciarPage({super.key, required this.conversa, this.motivo})
    : nome = null,
      feminino = null,
      motivos = null;

  /// Profissional denunciando o cliente.
  const DenunciarPage.pessoa({
    super.key,
    required String this.nome,
    required bool this.feminino,
    required List<String> this.motivos,
    this.motivo,
  }) : conversa = null;

  final Conversa? conversa;
  final String? nome;
  final bool? feminino;
  final List<String>? motivos;

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
    final nome = widget.nome ?? widget.conversa!.primeiroNome;
    final feminino = widget.feminino ?? widget.conversa!.feminino;
    final motivos = widget.motivos ?? _motivos;
    return CadastroScaffold(
      titulo: 'Denunciar $nome',
      subtitulo:
          'O que aconteceu?\n${feminino ? 'Ela' : 'Ele'} não vê que foi você.',
      botao: 'Enviar denúncia',
      // Sem backend ainda: só confirma o envio.
      onBotao: _escolhido == null
          ? null
          : () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => DenunciaEnviadaPage(
                  texto: widget.conversa == null
                      ? 'Nossa equipe vai analisar e pode\nfalar com você pelo app.'
                      : null,
                ),
              ),
            ),
      children: [
        for (final (i, m) in motivos.indexed) ...[
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
  const DenunciaEnviadaPage({super.key, this.texto});

  final String? texto;

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      sucesso: true,
      icone: const IconePermissao(TablerIcons.check, cor: TatuColors.online),
      titulo: 'Denúncia enviada',
      texto:
          texto ??
          'Nossa equipe vai analisar.\nVocê não precisa fazer mais nada.',
      principal: 'Voltar para a conversa',
      onPrincipal: () => Navigator.of(context).pop(),
    );
  }
}
