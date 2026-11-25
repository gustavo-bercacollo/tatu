import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/enderecos.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../chamar/chamar.dart';
import '../chamar/procurando_page.dart';
import '../endereco/onde_sheet.dart';
import '../../../data/plano_fixo.dart';
import '../plano_fixo/plano_fixo.dart';
import 'package:clock/clock.dart';

/// RN-176: folha "Pedir de novo": chamar o mesmo profissional (se estiver
/// online) ou qualquer um do serviço. Serviço, descrição e endereço vêm do
/// pedido anterior; o endereço pode ser trocado. RN-177: com a mesma
/// pessoa, o chamado é só dela por 2 min ("Chamando a [nome]").
Future<void> abrirPedirDeNovo(BuildContext context, PedidoConcluido p) async {
  final escolha = await mostrarFolha<(bool, String, bool)>(
    context,
    builder: (_) => _FolhaPedirDeNovo(pedido: p),
  );
  if (escolha == null || !context.mounted) return;
  final (mesmo, endereco, fixo) = escolha;
  // RN-144: "Precisa toda semana? Tornar [nome] fixa".
  if (fixo) {
    return tornarFixo(
      context,
      profissional: p.profissional,
      profissao: p.profissao,
      feminino: p.feminino,
      endereco: p.endereco,
    );
  }
  // RN-145: com a mesma profissional, no máximo 2 visitas por semana no
  // mesmo endereço, somando o plano fixo.
  if (mesmo && !planosFixos.pedirAvulso(p.profissional, endereco, clock.now())) {
    return mostrarLimiteSemana(context);
  }
  if (mesmo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcurandoPage(
          servico: p.servico,
          endereco: endereco,
          direto: p.primeiroNome,
          diretoFeminino: p.feminino,
          descricao: p.descricao,
          deNovo: p,
        ),
      ),
    );
  } else {
    // RN-176: "Chamar qualquer": pedido normal, já preenchido.
    await chamarProfissional(
      context,
      p.servico,
      endereco: endereco,
      descricao: p.descricao,
    );
  }
}

class _FolhaPedirDeNovo extends StatefulWidget {
  const _FolhaPedirDeNovo({required this.pedido});

  final PedidoConcluido pedido;

  @override
  State<_FolhaPedirDeNovo> createState() => _FolhaPedirDeNovoState();
}

class _FolhaPedirDeNovoState extends State<_FolhaPedirDeNovo> {
  /// Mesmo profissional (só se estiver online) ou qualquer um.
  late bool _mesmo = widget.pedido.online;
  late String _endereco = widget.pedido.endereco;

  Future<void> _trocarEndereco() async {
    await abrirOndeServico(context);
    if (mounted) setState(() => _endereco = enderecos.atual.rua);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    final artigo = p.feminino ? 'a' : 'o';
    final servico = p.servico.toLowerCase();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margemCadastro,
          10,
          TatuMedidas.margemCadastro,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text(
              'Pedir de novo',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text('${p.servico} · ${p.descricao}', style: TatuTexto.detalhe),
            const SizedBox(height: TatuMedidas.entreSecoes),
            Opacity(
              opacity: p.online ? 1 : 0.5,
              child: _Opcao(
                selecionado: _mesmo,
                onTap: p.online ? () => setState(() => _mesmo = true) : null,
                icone: _AvatarStatus(nome: p.profissional, online: p.online),
                titulo: 'Chamar $artigo ${p.primeiroNome}',
                detalhe: p.online
                    ? 'Online · chega em ${p.chegaEm}'
                    : 'Offline agora',
              ),
            ),
            const SizedBox(height: TatuMedidas.entreItens),
            _Opcao(
              selecionado: !_mesmo,
              onTap: () => setState(() => _mesmo = false),
              icone: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: TatuColors.bg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(TablerIcons.users, size: 22),
              ),
              titulo: 'Chamar qualquer $servico',
              detalhe: 'Quem estiver mais perto',
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            Row(
              children: [
                const Icon(
                  TablerIcons.map_pin,
                  size: 18,
                  color: TatuColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(_endereco, style: TatuTexto.detalhe)),
                GestureDetector(
                  onTap: _trocarEndereco,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Trocar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TatuColors.verified,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop((_mesmo, _endereco, false)),
              child: Text(
                _mesmo
                    ? 'Chamar $artigo ${p.primeiroNome}'
                    : 'Chamar qualquer $servico',
              ),
            ),
            // RN-144: quem chama sempre a mesma pessoa pode tornar o
            // serviço fixo daqui (só sem plano com ela).
            if (planosFixos.planoCom(p.profissional) == null) ...[
              const SizedBox(height: 4),
              Center(
                child: LinkAzul(
                  'Precisa toda semana? '
                  '${textoTornarFixo(p.profissional, p.feminino).replaceFirst('Tornar ', 'Tornar $artigo ')}',
                  onTap: () =>
                      Navigator.of(context).pop((false, _endereco, true)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  const _Opcao({
    required this.selecionado,
    required this.onTap,
    required this.icone,
    required this.titulo,
    required this.detalhe,
  });

  final bool selecionado;
  final VoidCallback? onTap;
  final Widget icone;
  final String titulo;
  final String detalhe;

  @override
  Widget build(BuildContext context) {
    return OpcaoSelecionavel(
      selecionado: selecionado,
      rotulo: titulo,
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            icone,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      titulo,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(detalhe, style: TatuTexto.nota),
                ],
              ),
            ),
            const SizedBox(width: 8),
            BolinhaEscolha(selecionado: selecionado),
          ],
        ),
      ),
    );
  }
}

/// Iniciais com a bolinha de online (verde) ou offline (cinza).
class _AvatarStatus extends StatelessWidget {
  const _AvatarStatus({required this.nome, required this.online});

  final String nome;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AvatarIniciais(nome: nome, tamanho: 44),
          Positioned(
            right: -1,
            bottom: 0,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: online ? TatuColors.online : TatuColors.textSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: TatuColors.bg, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
