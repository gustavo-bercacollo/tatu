import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';

/// Grupo da lista agrupada (estilo Ajustes do iPhone): título opcional em
/// maiúsculas e um cartão branco com as linhas separadas por divisores.
class GrupoLista extends StatelessWidget {
  const GrupoLista({super.key, this.titulo, required this.itens});

  final String? titulo;
  final List<ItemLista> itens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (titulo != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              TatuMedidas.tituloSecao,
            ),
            child: Text(titulo!.toUpperCase(), style: TatuTexto.secao),
          ),
        Material(
          color: TatuColors.bg,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < itens.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.only(left: 54),
                    child: Divider(height: 0.5),
                  ),
                itens[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Linha da lista: ícone de traço, texto, valor atual à direita e seta.
class ItemLista extends StatelessWidget {
  const ItemLista({
    super.key,
    required this.icone,
    required this.texto,
    required this.onTap,
    this.valor,
    this.cor,
    this.seta = true,
  });

  final IconData icone;
  final String texto;
  final String? valor;
  final VoidCallback onTap;

  /// Cor do ícone e do texto (ex.: vermelho em "Sair da conta").
  final Color? cor;
  final bool seta;

  @override
  Widget build(BuildContext context) {
    final c = cor ?? TatuColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: TatuMedidas.alturaLinha,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icone, size: 22, color: c),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  texto,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, color: c),
                ),
              ),
              if (valor != null) ...[
                const SizedBox(width: 8),
                Text(
                  valor!,
                  style: const TextStyle(
                    fontSize: 17,
                    color: TatuColors.textSecondary,
                  ),
                ),
              ],
              if (seta) ...[
                const SizedBox(width: 8),
                const Icon(
                  TablerIcons.chevron_right,
                  size: 16,
                  color: TatuColors.chevron,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
