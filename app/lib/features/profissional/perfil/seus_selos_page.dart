import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../data/selos.dart';
import '../../../shared/widgets/selo.dart';
import '../../../shared/widgets/tela_interna.dart';

/// P85 · RN-217 a RN-219: "Seus selos": todos os selos, como cada um
/// funciona e "Você tem" ou "Ainda não". Sem barra de progresso nem
/// "faltam X": selos não são meta de jogo.
class SeusSelosPage extends StatelessWidget {
  const SeusSelosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profissional,
      builder: (context, _) {
        final p = profissional;
        final tem = p.selos;
        // Registro conferido só para quem tem profissão com registro.
        final lista = [
          for (final s in Selo.values)
            if (s != Selo.registroConferido || p.registros.isNotEmpty) s,
        ];
        return TelaInterna(
          titulo: 'Seus selos',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(bottom: TatuMedidas.entreSecoes),
            children: [
              const Text(
                'Os selos aparecem no seu perfil e ajudam o cliente a '
                'escolher. Vêm e vão sozinhos, pelos últimos 90 dias.',
                style: TatuTexto.detalhe,
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              for (final s in lista) ...[
                _CartaoSeuSelo(selo: s, tem: tem.contains(s)),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: TatuMedidas.entreItens),
              // RN-219: selos só informam.
              const Text(
                'Selos não mudam quem recebe chamados.',
                textAlign: TextAlign.center,
                style: TatuTexto.legenda,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartaoSeuSelo extends StatelessWidget {
  const _CartaoSeuSelo({required this.selo, required this.tem});

  final Selo selo;
  final bool tem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeloImagem(selo, tamanho: TatuMedidas.seloGrande, conquistado: tem),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selo.nome,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _Pilula(tem: tem),
                  ],
                ),
                const SizedBox(height: 4),
                Text(selo.comoFunciona, style: TatuTexto.legenda),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Você tem" (verde) ou "Ainda não" (cinza).
class _Pilula extends StatelessWidget {
  const _Pilula({required this.tem});

  final bool tem;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: ShapeDecoration(
      color: tem ? TatuColors.onlineSoft : TatuColors.fill,
      shape: const StadiumBorder(),
    ),
    child: Text(
      tem ? 'Você tem' : 'Ainda não',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: tem ? TatuColors.onlineTexto : TatuColors.textSecondary,
      ),
    ),
  );
}
