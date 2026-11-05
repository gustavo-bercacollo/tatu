import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/avaliacoes.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/estrelas.dart';

/// Cartão de uma avaliação: avatar, nome, quando, profissão e data,
/// estrelas e comentário.
class CartaoAvaliacao extends StatelessWidget {
  const CartaoAvaliacao({
    super.key,
    required this.avaliacao,
    required this.nome,
    this.onTap,
  });

  final Avaliacao avaliacao;

  /// Nome mostrado (curto nas recebidas, completo nas enviadas).
  final String nome;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final a = avaliacao;
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarIniciais(nome: a.nome),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nome,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(a.quando, style: TatuTexto.nota),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${a.profissao} · ${a.data}',
                      style: TatuTexto.detalhe,
                    ),
                    const SizedBox(height: 8),
                    Estrelas(nota: a.nota),
                    const SizedBox(height: 8),
                    Text(a.comentario, style: TatuTexto.comentario),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
