import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../data/icones_profissoes.dart';

/// RN-227: ícone de traço da profissão, na cor do texto (branco em pílula
/// selecionada). Junto de texto: 16 px.
class IconeProfissao extends StatelessWidget {
  const IconeProfissao(
    this.profissao, {
    super.key,
    this.tamanho = TatuMedidas.iconeProfissaoTexto,
    this.cor = TatuColors.action,
  }) : _caminho = null;

  /// O botão "Outros".
  const IconeProfissao.outros({
    super.key,
    this.tamanho = TatuMedidas.iconeProfissaoTexto,
    this.cor = TatuColors.action,
  }) : profissao = '',
       _caminho = '';

  final String profissao;
  final double tamanho;
  final Color cor;
  final String? _caminho;

  @override
  Widget build(BuildContext context) {
    final caminho = _caminho == null
        ? iconesProfissoes.de(profissao)
        : iconesProfissoes.outros;
    return SvgPicture.asset(
      caminho,
      width: tamanho,
      height: tamanho,
      excludeFromSemantics: true,
      colorFilter: ColorFilter.mode(cor, BlendMode.srcIn),
      // Nunca um espaço vazio enquanto carrega.
      placeholderBuilder: (_) => SizedBox.square(dimension: tamanho),
    );
  }
}

/// RN-227: seleção de profissão (cadastro, "Outras profissões", busca):
/// quadrado arredondado cinza de 52 px com o ícone de 24 px.
class IconeProfissaoQuadrado extends StatelessWidget {
  const IconeProfissaoQuadrado(
    this.profissao, {
    super.key,
    this.fundo = TatuColors.surfaceGrouped,
  });

  final String profissao;

  /// Branco quando a lista já é cinza (ex.: "Outros").
  final Color fundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TatuMedidas.iconeProfissaoSelecao,
      height: TatuMedidas.iconeProfissaoSelecao,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
      ),
      child: IconeProfissao(profissao, tamanho: 24),
    );
  }
}

/// RN-227: cards e listas (Atividade, novo chamado, histórico): círculo
/// cinza de 40 px com o ícone de 20 px.
class IconeProfissaoCirculo extends StatelessWidget {
  const IconeProfissaoCirculo(
    this.profissao, {
    super.key,
    this.fundo = TatuColors.fill,
  });

  final String profissao;
  final Color fundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TatuMedidas.iconeProfissaoCard,
      height: TatuMedidas.iconeProfissaoCard,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
      child: IconeProfissao(profissao, tamanho: 20),
    );
  }
}
