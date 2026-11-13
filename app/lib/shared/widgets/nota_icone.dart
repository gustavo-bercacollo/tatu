import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';

/// Nota pequena com ícone à esquerda (cadeado, lâmpada, sino…).
/// [cor] pinta ícone e texto (ex.: vermelho de erro).
class NotaIcone extends StatelessWidget {
  const NotaIcone({
    super.key,
    required this.icone,
    required this.texto,
    this.cor,
    this.escura = false,
  });

  final IconData icone;
  final String texto;
  final Color? cor;

  /// Texto preto em vez de cinza (ex.: dica em destaque).
  final bool escura;

  @override
  Widget build(BuildContext context) {
    final c =
        cor ?? (escura ? TatuColors.textPrimary : TatuColors.textSecondary);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icone, size: 16, color: c),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(texto, style: TatuTexto.nota.copyWith(color: c)),
        ),
      ],
    );
  }
}

/// Item com ícone, título e texto cinza (vantagens, passos, dicas).
/// Com [fundo], o ícone fica num quadrado arredondado.
class ItemVantagem extends StatelessWidget {
  const ItemVantagem({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    this.fundo = false,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final bool fundo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TatuMedidas.entreSecoes),
      child: Row(
        crossAxisAlignment: fundo
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (fundo)
            Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: TatuColors.fill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icone, size: 24),
            )
          else
            SizedBox(
              width: 46,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icone, size: 24),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(texto, style: TatuTexto.detalhe),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo grande com ícone no topo das telas de resultado
/// ("Recebemos seus dados", "Cadastro aprovado!").
class IconeResultado extends StatelessWidget {
  const IconeResultado(
    this.icone, {
    super.key,
    this.fundo = TatuColors.fill,
    this.cor = TatuColors.textPrimary,
  });

  final IconData icone;
  final Color fundo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
      child: Icon(icone, size: 36, color: cor),
    );
  }
}

/// Linha com ícone num círculo cinza e o texto do que acontece.
/// Caixa amarela de atenção (ícone de alerta + texto).
class CaixaAviso extends StatelessWidget {
  const CaixaAviso(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: TatuColors.warningSoft,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          TablerIcons.alert_triangle,
          size: 20,
          color: TatuColors.warningTexto,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: TatuColors.warningTexto,
            ),
          ),
        ),
      ],
    ),
  );
}

class LinhaConsequencia extends StatelessWidget {
  const LinhaConsequencia(this.icone, this.texto, {super.key});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: TatuColors.fill,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 20, color: TatuColors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(texto, style: TatuTexto.comentario)),
        ],
      ),
    );
  }
}
