import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../data/profissional.dart';
import '../../../data/seguranca.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_interna.dart';

/// Preferências de atendimento: quem pode chamar o profissional.
/// "Atender só clientes mulheres" só aparece para profissionais mulheres.
class PreferenciasAtendimentoPage extends StatelessWidget {
  const PreferenciasAtendimentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: 'Preferências de atendimento',
      fundoCinza: true,
      corpo: ListenableBuilder(
        listenable: Listenable.merge([seguranca, profissional]),
        builder: (_, _) {
          final mulher = profissional.feminino;
          return ListView(
            padding: const EdgeInsets.only(top: TatuMedidas.entreItens),
            children: [
              if (mulher) ...[
                GrupoCartao(
                  linhas: [
                    LinhaInterruptor(
                      destaque: true,
                      texto: 'Atender só clientes mulheres',
                      detalhe:
                          'Você recebe chamados só de clientes mulheres '
                          'verificadas. Pode receber menos chamados.',
                      valor: seguranca.soMulheres,
                      onMudar: seguranca.definirSoMulheres,
                    ),
                  ],
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
              ],
              GrupoCartao(
                linhas: [
                  LinhaInterruptor(
                    destaque: true,
                    texto: 'Só clientes verificados',
                    detalhe:
                        'Clientes com celular e documento conferidos pelo '
                        'Tatu.',
                    valor: seguranca.soVerificados,
                    onMudar: seguranca.definirSoVerificados,
                  ),
                ],
                nota: mulher
                    ? 'Disponível para profissionais mulheres.\n'
                          'Você pode mudar quando quiser.'
                    : 'Você pode mudar quando quiser.',
              ),
            ],
          );
        },
      ),
    );
  }
}
