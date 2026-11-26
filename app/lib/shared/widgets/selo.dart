import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/selos.dart';

/// RN-220: o selo ondulado (preto com ícone branco; o verificado é azul).
/// [conquistado] falso: a versão cinza "Ainda não".
class SeloImagem extends StatelessWidget {
  const SeloImagem(
    this.selo, {
    super.key,
    this.tamanho = TatuMedidas.seloCartao,
    this.conquistado = true,
  });

  final Selo selo;
  final double tamanho;
  final bool conquistado;

  @override
  Widget build(BuildContext context) {
    final cinzaSemArquivo = !conquistado && !selo.temAindaNao;
    final img = SvgPicture.asset(
      selo.imagem(conquistado: conquistado || !selo.temAindaNao),
      width: tamanho,
      height: tamanho,
      excludeFromSemantics: true,
    );
    return Semantics(
      label: conquistado ? 'Selo ${selo.nome}' : 'Selo ${selo.nome}, ainda não',
      child: cinzaSemArquivo ? Opacity(opacity: 0.35, child: img) : img,
    );
  }
}

/// C166 · RN-219: card do selo no perfil (selo + nome + uma frase).
class CartaoSelo extends StatelessWidget {
  const CartaoSelo(this.selo, {super.key});

  final Selo selo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
      ),
      child: Row(
        children: [
          SeloImagem(selo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selo.nome,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(selo.frase, style: TatuTexto.legenda),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// RN-219: selos pequenos embaixo do nome de quem aceitou o chamado
/// ("Pontual · Clientes voltam").
class SelosPequenos extends StatelessWidget {
  const SelosPequenos(this.selos, {super.key});

  final List<Selo> selos;

  @override
  Widget build(BuildContext context) {
    if (selos.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (final s in selos) ...[
          SeloImagem(s, tamanho: TatuMedidas.seloPequeno),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            selos.map((s) => s.nome).join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TatuTexto.legenda.copyWith(
              color: TatuColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
