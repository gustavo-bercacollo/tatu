import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';

/// P107 · "Como você atende?" numa profissão: no local, à distância ou os
/// dois (RN-97). [onContinuar] segue o cadastro; com [edicao], volta.
class ComoAtendePage extends StatefulWidget {
  const ComoAtendePage({
    super.key,
    required this.indice,
    this.onContinuar,
    this.edicao = false,
  });

  /// Posição em [profissional.profissoes].
  final int indice;
  final VoidCallback? onContinuar;
  final bool edicao;

  @override
  State<ComoAtendePage> createState() => _ComoAtendePageState();
}

class _ComoAtendePageState extends State<ComoAtendePage> {
  late final ProfissaoEscolhida _prof = profissional.profissoes[widget.indice];

  /// Profissão nova vem com o modo mais comum dela.
  late ModoAtendimento _modo = widget.edicao
      ? _prof.modo
      : modoSugerido(_prof.nome);

  void _seguir() {
    profissional.definirModo(_prof.nome, _modo);
    if (widget.edicao) {
      Navigator.of(context).pop();
    } else {
      widget.onContinuar?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Como você atende?',
      subtitulo:
          'Profissão: ${_prof.nome}.\nVocê pode mudar depois no Perfil.',
      botao: widget.edicao ? 'Salvar' : 'Continuar',
      onBotao: _seguir,
      children: [
        for (final (m, detalhe) in const [
          (ModoAtendimento.local, 'Você vai até o cliente'),
          (
            ModoAtendimento.distancia,
            'Atende online, clientes de qualquer cidade',
          ),
          (ModoAtendimento.ambos, null),
        ]) ...[
          OpcaoSelecionavel(
            selecionado: _modo == m,
            rotulo: m.nome,
            onTap: () => setState(() => _modo = m),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  BolinhaEscolha(selecionado: _modo == m),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.nome, style: const TextStyle(fontSize: 17)),
                        if (detalhe != null)
                          Text(detalhe, style: TatuTexto.nota),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens - 2),
        ],
      ],
    );
  }
}
