import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/enderecos.dart';
import '../../../shared/widgets/botao_tracejado.dart';
import '../../../shared/widgets/topo_tela.dart';
import 'buscar_endereco_page.dart';
import 'editar_endereco_page.dart';
import 'linha_endereco.dart';

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
        final vazio = salvos.isEmpty;
        return Scaffold(
          backgroundColor: vazio ? TatuColors.bg : TatuColors.surfaceGrouped,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TopoTela(titulo: 'Endereços'),
                      if (vazio)
                        ..._vazio(context)
                      else
                        Expanded(child: _lista(context, salvos)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _lista(BuildContext context, List<Endereco> salvos) {
    return ListView(
      padding: const EdgeInsets.only(top: 30),
      children: [
        Material(
          color: TatuColors.bg,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < salvos.length; i++) ...[
                if (i > 0) const DivisorEndereco(),
                LinhaEndereco(
                  icone: iconeDoTipo(salvos[i].tipo),
                  titulo: salvos[i].nome,
                  detalhe: [
                    salvos[i].rua,
                    if (salvos[i].complemento.isNotEmpty) salvos[i].complemento,
                  ].join(' · '),
                  direita: const Icon(
                    TablerIcons.chevron_right,
                    size: 16,
                    color: TatuColors.chevron,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditarEnderecoPage(endereco: salvos[i]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        BotaoTracejado(
          texto: 'Adicionar endereço',
          onTap: () => _adicionar(context),
        ),
        const SizedBox(height: 20),
        const Text(
          'Toque em um endereço para editar.',
          style: TextStyle(fontSize: 15, color: TatuColors.textSecondary),
        ),
      ],
    );
  }

  List<Widget> _vazio(BuildContext context) => [
    const Spacer(),
    Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          color: TatuColors.fill,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          TablerIcons.map_pin,
          size: 38,
          color: TatuColors.textSecondary,
        ),
      ),
    ),
    const SizedBox(height: 26),
    const Text(
      'Nenhum endereço salvo',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    const SizedBox(height: 10),
    const Text(
      'Salve sua casa ou seu trabalho\npara pedir mais rápido.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        height: 1.4,
        color: TatuColors.textSecondary,
      ),
    ),
    const Spacer(flex: 2),
    FilledButton(
      onPressed: () => _adicionar(context),
      child: const Text('Adicionar endereço'),
    ),
  ];
}
