import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';

/// Cartão branco de lista agrupada com qualquer conteúdo: título de seção
/// opcional, linhas separadas por divisores e nota opcional embaixo.
class GrupoCartao extends StatelessWidget {
  const GrupoCartao({
    super.key,
    required this.linhas,
    this.titulo,
    this.nota,
    this.inicioDivisor = 16,
  });

  final List<Widget> linhas;
  final String? titulo;
  final String? nota;

  /// Onde o divisor começa (alinhado com o texto das linhas).
  final double inicioDivisor;

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
              for (var i = 0; i < linhas.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: EdgeInsets.only(left: inicioDivisor),
                    child: const Divider(height: 0.5),
                  ),
                linhas[i],
              ],
            ],
          ),
        ),
        if (nota != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
            child: Text(nota!, style: TatuTexto.nota),
          ),
      ],
    );
  }
}

/// Linha com texto (e detalhe opcional) e interruptor verde à direita.
/// Com [habilitado] falso, fica cinza e não responde.
class LinhaInterruptor extends StatelessWidget {
  const LinhaInterruptor({
    super.key,
    required this.texto,
    required this.valor,
    required this.onMudar,
    this.detalhe,
    this.habilitado = true,
    this.destaque = false,
  });

  final String texto;
  final String? detalhe;
  final bool valor;
  final ValueChanged<bool> onMudar;
  final bool habilitado;

  /// Título em negrito e explicação maior (cartão de uma opção só).
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TatuMedidas.alturaLinha),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: destaque ? 16 : 12,
        ),
        child: Row(
          crossAxisAlignment: destaque
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      texto,
                      maxLines: destaque ? 1 : null,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: destaque ? FontWeight.w600 : null,
                        // No destaque, só o interruptor fica apagado.
                        color: habilitado || destaque
                            ? TatuColors.textPrimary
                            : TatuColors.textSecondary,
                      ),
                    ),
                  ),
                  if (detalhe != null) ...[
                    SizedBox(height: destaque ? 6 : 2),
                    Text(
                      detalhe!,
                      style: destaque ? TatuTexto.detalhe : TatuTexto.nota,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              label: texto,
              toggled: valor,
              child: CupertinoSwitch(
                value: valor,
                activeTrackColor: TatuColors.online,
                inactiveTrackColor: TatuColors.trilho,
                onChanged: habilitado ? onMudar : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão branco com uma ação centralizada (ex.: "Sair da conta",
/// "Excluir conta" em vermelho).
class CartaoBotao extends StatelessWidget {
  const CartaoBotao({
    super.key,
    required this.texto,
    required this.onTap,
    this.cor = TatuColors.danger,
  });

  final String texto;
  final VoidCallback onTap;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: TatuMedidas.alturaLinha,
          child: Center(
            child: Text(texto, style: TextStyle(fontSize: 17, color: cor)),
          ),
        ),
      ),
    );
  }
}

/// Linha de lista só com texto e seta (perguntas, artigos, resultados).
class LinhaSimples extends StatelessWidget {
  const LinhaSimples({super.key, required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: TatuMedidas.alturaLinha,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  texto,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              const Icon(
                TablerIcons.chevron_right,
                size: 18,
                color: TatuColors.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão branco de ação: ícone num círculo, título, detalhe e seta
/// (ex.: "Falar com o suporte", "Baixar meus dados").
class CartaoAcao extends StatelessWidget {
  const CartaoAcao({
    super.key,
    required this.icone,
    required this.titulo,
    required this.detalhe,
    required this.onTap,
    this.corTitulo = TatuColors.textPrimary,
  });

  /// Normalmente um círculo de 40 px com o ícone.
  final Widget icone;
  final String titulo;
  final String detalhe;
  final VoidCallback onTap;
  final Color corTitulo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            children: [
              icone,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: corTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(detalhe, style: TatuTexto.nota),
                  ],
                ),
              ),
              const Icon(
                TablerIcons.chevron_right,
                size: 18,
                color: TatuColors.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ícone de traço num círculo cinza de 40 px.
class IconeCirculo extends StatelessWidget {
  const IconeCirculo(
    this.icone, {
    super.key,
    this.cor = TatuColors.textPrimary,
    this.fundo = TatuColors.fill,
  });

  final IconData icone;
  final Color cor;
  final Color fundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
      child: Icon(icone, size: 20, color: cor),
    );
  }
}

/// Linha de dado: rótulo cinza à esquerda e valor à direita; [destaque]
/// deixa os dois em negrito (ex.: Total).
class LinhaRotuloValor extends StatelessWidget {
  const LinhaRotuloValor({
    super.key,
    required this.rotulo,
    required this.valor,
    this.destaque = false,
  });

  final String rotulo;
  final String valor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TatuMedidas.alturaLinha,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              rotulo,
              style: destaque
                  ? const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)
                  : const TextStyle(
                      fontSize: 17,
                      color: TatuColors.textSecondary,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                valor,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: destaque ? 20 : 17,
                  fontWeight: destaque ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha com rótulo cinza, valor, ✓ verde de confirmado e seta (ou
/// cadeado, quando o dado vem do documento).
class LinhaDado extends StatelessWidget {
  const LinhaDado({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.onTap,
    this.confirmado = false,
    this.bloqueado = false,
  });

  final String rotulo;
  final String valor;
  final VoidCallback onTap;
  final bool confirmado;

  /// Vem do documento: cadeado no lugar da seta.
  final bool bloqueado;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rotulo, style: TatuTexto.nota),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          valor,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                      if (confirmado) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          TablerIcons.check,
                          size: 18,
                          color: TatuColors.online,
                          semanticLabel: 'Confirmado',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              bloqueado ? TablerIcons.lock : TablerIcons.chevron_right,
              size: bloqueado ? 20 : 18,
              color: TatuColors.chevron,
              semanticLabel: bloqueado ? 'Do documento' : null,
            ),
          ],
        ),
      ),
    );
  }
}
