import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  });

  final String texto;
  final String? detalhe;
  final bool valor;
  final ValueChanged<bool> onMudar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TatuMedidas.alturaLinha),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texto,
                    style: TextStyle(
                      fontSize: 17,
                      color: habilitado
                          ? TatuColors.textPrimary
                          : TatuColors.textSecondary,
                    ),
                  ),
                  if (detalhe != null) ...[
                    const SizedBox(height: 2),
                    Text(detalhe!, style: TatuTexto.nota),
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
