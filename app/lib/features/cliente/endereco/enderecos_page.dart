import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/enderecos.dart';
import '../../../shared/widgets/botao_tracejado.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/linha_icone.dart';
import '../../../shared/widgets/tela_interna.dart';
import 'buscar_endereco_page.dart';
import 'editar_endereco_page.dart';
import 'icone_endereco.dart';

/// Endereços salvos (pelo Perfil). Sem nenhum, mostra o estado vazio.
class EnderecosPage extends StatelessWidget {
  const EnderecosPage({super.key});

  void _adicionar(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const BuscarEnderecoPage()));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: enderecos,
      builder: (context, _) {
        final salvos = enderecos.salvos;
        if (salvos.isEmpty) {
          return TelaInterna(
            titulo: 'Endereços',
            corpo: const EstadoVazio(
              icone: TablerIcons.map_pin,
              titulo: 'Nenhum endereço salvo',
              texto: 'Salve sua casa ou seu trabalho\npara pedir mais rápido.',
            ),
            rodape: FilledButton(
              onPressed: () => _adicionar(context),
              child: const Text('Adicionar endereço'),
            ),
          );
        }
        return TelaInterna(
          titulo: 'Endereços',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(top: 30),
            children: [
              Material(
                color: TatuColors.bg,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < salvos.length; i++) ...[
                      if (i > 0) const DivisorLinha(),
                      LinhaIcone(
                        icone: iconeDoTipo(salvos[i].tipo),
                        titulo: salvos[i].nome,
                        detalhe: [
                          salvos[i].rua,
                          if (salvos[i].complemento.isNotEmpty)
                            salvos[i].complemento,
                        ].join(' · '),
                        direita: const Icon(
                          TablerIcons.chevron_right,
                          size: 16,
                          color: TatuColors.chevron,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EditarEnderecoPage(endereco: salvos[i]),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              BotaoTracejado(
                texto: 'Adicionar endereço',
                onTap: () => _adicionar(context),
              ),
              const SizedBox(height: 20),
              const Text(
                'Toque em um endereço para editar.',
                style: TatuTexto.nota,
              ),
            ],
          ),
        );
      },
    );
  }
}
