import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import 'topo_tela.dart';

/// Esqueleto das telas internas (Endereços, Pagamento, Editar…): topo com
/// voltar e título, conteúdo e rodapé opcional, sempre com as mesmas margens.
class TelaInterna extends StatelessWidget {
  const TelaInterna({
    super.key,
    required this.titulo,
    required this.corpo,
    this.acao,
    this.onAcao,
    this.acaoIcone,
    this.rodape,
    this.fundoCinza = false,
  });

  final String titulo;
  final String? acao;
  final VoidCallback? onAcao;
  final IconData? acaoIcone;

  /// Conteúdo abaixo do topo (normalmente uma lista).
  final Widget corpo;

  /// Fixo embaixo (botão principal, "Excluir"…).
  final Widget? rodape;

  /// Fundo cinza de lista agrupada em vez de branco.
  final bool fundoCinza;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoCinza ? TatuColors.surfaceGrouped : TatuColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TopoTela(
                    titulo: titulo,
                    acao: acao,
                    onAcao: onAcao,
                    acaoIcone: acaoIcone,
                  ),
                  Expanded(child: corpo),
                  ?rodape,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
