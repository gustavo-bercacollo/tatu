import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/seguranca.dart';
import '../../shared/widgets/folha.dart';
import '../../shared/widgets/grupo_cartao.dart';
import '../../shared/widgets/lista_agrupada.dart';
import '../../shared/widgets/tela_interna.dart';

/// Preferências de atendimento do cliente: preferir profissionais
/// mulheres (só para quem se identifica como mulher).
class PreferenciasClientePage extends StatelessWidget {
  const PreferenciasClientePage({super.key});

  Future<void> _identidade(BuildContext context) async {
    final escolha = await mostrarFolha<Identidade>(
      context,
      builder: (ctx) => FolhaOpcoes(
        itens: [
          for (final i in Identidade.values)
            if (i != Identidade.naoInformado)
              ItemLista(
                icone: seguranca.identidade == i
                    ? TablerIcons.circle_check
                    : TablerIcons.circle,
                texto: i.nome,
                seta: false,
                onTap: () => Navigator.of(ctx).pop(i),
              ),
        ],
      ),
    );
    if (escolha != null) seguranca.definirIdentidade(escolha);
  }

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: 'Preferências de atendimento',
      fundoCinza: true,
      corpo: ListenableBuilder(
        listenable: seguranca,
        builder: (_, _) {
          final s = seguranca;
          final pode = s.identidade == Identidade.mulher;
          final String nota;
          if (s.identidade == Identidade.naoInformado) {
            nota =
                'Para usar essa preferência, informe como você se '
                'identifica. Só o Tatu vê essa informação.';
          } else if (pode) {
            nota = 'Só o Tatu vê essa informação. Você pode mudar quando quiser.';
          } else {
            nota =
                '“Preferir profissionais mulheres” é para quem se identifica '
                'como mulher. Só o Tatu vê essa informação.';
          }
          return ListView(
            padding: const EdgeInsets.only(top: TatuMedidas.entreItens),
            children: [
              GrupoCartao(
                linhas: [
                  LinhaInterruptor(
                    destaque: true,
                    texto: 'Preferir profissionais mulheres',
                    detalhe:
                        'Seus pedidos vão só para profissionais mulheres. '
                        'Pode demorar um pouco mais para alguém aceitar.',
                    valor: s.preferirMulheres,
                    habilitado: pode,
                    onMudar: s.definirPreferirMulheres,
                  ),
                ],
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              Material(
                color: TatuColors.bg,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _identidade(context),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Como você se identifica',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(s.identidade.nome, style: TatuTexto.detalhe),
                            ],
                          ),
                        ),
                        const Icon(
                          TablerIcons.chevron_right,
                          size: 20,
                          color: TatuColors.chevron,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(nota, style: TatuTexto.nota),
              ),
            ],
          );
        },
      ),
    );
  }
}
