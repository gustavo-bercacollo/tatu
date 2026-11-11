import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';

/// P09 · Folha "Taxas do Tatu".
Future<void> mostrarTaxas(BuildContext context) => mostrarFolha<void>(
  context,
  fundo: TatuColors.surfaceGrouped,
  builder: (_) => const _FolhaTaxas(),
);

class _FolhaTaxas extends StatelessWidget {
  const _FolhaTaxas();

  @override
  Widget build(BuildContext context) {
    const exemplo = 150.0;
    const taxa = exemplo * taxaTatu;
    final pct = '${(taxaTatu * 100).round()}%';
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 36),
                const Expanded(
                  child: Text(
                    'Taxas do Tatu',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Fechar',
                  child: Material(
                    color: TatuColors.fill,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(TablerIcons.x, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'O Tatu só cobra quando o cliente paga pelo app. '
              'Pagamento por fora não tem taxa.',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: TatuColors.textPrimary,
              ),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            _Cartao(
              children: [
                const Text('Serviço pago pelo app', style: TatuTexto.nota),
                const SizedBox(height: 6),
                Text(
                  pct,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const Text('descontados do valor', style: TatuTexto.detalhe),
                const SizedBox(height: TatuMedidas.entreItens),
                const Divider(height: 1),
                const SizedBox(height: TatuMedidas.entreItens),
                const Text('Exemplo', style: TatuTexto.nota),
                _Linha('Serviço', reais(exemplo)),
                const Divider(height: 1),
                _Linha('Taxa do Tatu', '– ${reais(taxa)}', cinza: true),
                const Divider(height: 1),
                _Linha('Você recebe', reais(exemplo - taxa), forte: true),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            const _Cartao(
              children: [
                _Gratis('Cadastro e perfil: grátis'),
                Divider(height: 1, indent: 32),
                _Gratis('Receber chamados: grátis'),
                Divider(height: 1, indent: 32),
                _Gratis('Pagamento por fora: sem taxa'),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreSecoes + 8),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    decoration: BoxDecoration(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

class _Linha extends StatelessWidget {
  const _Linha(
    this.rotulo,
    this.valor, {
    this.cinza = false,
    this.forte = false,
  });

  final String rotulo;
  final String valor;
  final bool cinza;
  final bool forte;

  @override
  Widget build(BuildContext context) {
    final peso = forte ? FontWeight.w700 : FontWeight.w400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: TextStyle(fontSize: 16, fontWeight: peso),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cinza ? TatuColors.textSecondary : TatuColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Gratis extends StatelessWidget {
  const _Gratis(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        const Icon(TablerIcons.circle_check, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );
}
