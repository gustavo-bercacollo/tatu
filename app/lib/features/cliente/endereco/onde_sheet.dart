import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/enderecos.dart';
import '../../../shared/widgets/botao_tracejado.dart';
import '../../../shared/widgets/campo_busca.dart';
import 'buscar_endereco_page.dart';
import 'linha_endereco.dart';
import 'localizacao_desativada_page.dart';

/// Folha "Onde é o serviço?", aberta pelo endereço no topo da Home.
Future<void> abrirOndeServico(BuildContext context) {
  final nav = Navigator.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: TatuColors.bg,
    barrierColor: TatuColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (ctx) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _OndeServico(
        // Fecha a folha e abre a próxima tela na pilha da Home.
        ir: (tela) {
          Navigator.of(ctx).pop();
          nav.push(MaterialPageRoute(builder: (_) => tela));
        },
      ),
    ),
  );
}

class _OndeServico extends StatelessWidget {
  const _OndeServico({required this.ir});

  final void Function(Widget tela) ir;

  @override
  Widget build(BuildContext context) {
    void fechar() => Navigator.of(context).pop();

    return ListenableBuilder(
      listenable: enderecos,
      builder: (context, _) {
        final salvos = enderecos.salvos;
        final atual = enderecos.atual;
        const local = EnderecosRepo.localAtual;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: TatuColors.fillStrong,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Onde é o serviço?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Fechar',
                  child: GestureDetector(
                    onTap: fechar,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: TatuColors.fill,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(TablerIcons.x, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CampoBusca(
              hint: 'Buscar rua e número',
              onTap: () => ir(const BuscarEnderecoPage()),
            ),
            const SizedBox(height: 16),
            Material(
              color: TatuColors.fill,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: LinhaEndereco(
                icone: TablerIcons.navigation,
                titulo: 'Usar minha localização atual',
                detalhe: '${local.rua} · ${local.bairro}',
                fundoIcone: TatuColors.bg,
                corTitulo: TatuColors.verified,
                onTap: () {
                  if (enderecos.usarLocalizacao()) {
                    fechar();
                  } else {
                    ir(const LocalizacaoDesativadaPage());
                  }
                },
              ),
            ),
            if (salvos.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'SALVOS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                    color: TatuColors.textSecondary,
                  ),
                ),
              ),
              Material(
                color: TatuColors.fill,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < salvos.length; i++) ...[
                      if (i > 0) const DivisorEndereco(),
                      LinhaEndereco(
                        icone: iconeDoTipo(salvos[i].tipo),
                        titulo: salvos[i].nome,
                        detalhe: salvos[i].rua,
                        fundoIcone: TatuColors.bg,
                        direita: salvos[i].id == atual.id
                            ? Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: TatuColors.action,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  TablerIcons.check,
                                  size: 14,
                                  color: TatuColors.onAction,
                                  semanticLabel: 'Em uso',
                                ),
                              )
                            : null,
                        onTap: () {
                          enderecos.usar(salvos[i]);
                          fechar();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            BotaoTracejado(
              texto: 'Adicionar endereço',
              onTap: () => ir(const BuscarEnderecoPage()),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    TablerIcons.lock,
                    size: 16,
                    color: TatuColors.textSecondary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'O profissional só vê o endereço exato\ndepois que você confirma o valor.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        color: TatuColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
