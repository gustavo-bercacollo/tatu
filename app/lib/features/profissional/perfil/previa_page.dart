import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/fotos_trabalho.dart';
import '../../../data/perfil_publico.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/avatar_usuario.dart';
import '../../entrada/perfil_publico_page.dart';
import 'fotos_trabalho_page.dart';

/// P32 · Prévia: o perfil como o cliente vê.
class PreviaPage extends StatelessWidget {
  const PreviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = profissional;
    return PerfilPublicoPage(
      perfil: PerfilPublico(
        nome: p.nome,
        subtitulo:
            '${profissaoNoGenero(p.profissaoPrincipal, feminino: p.feminino)}'
            ' · na plataforma desde ${p.desdeAno}',
        nota: p.nota.toStringAsFixed(1).replaceAll('.', ','),
        servicos: p.servicosFeitos,
        resposta: '1 min',
        especialidades: [
          for (final prof in p.profissoes) ...prof.especialidades,
        ],
        sobre: p.sobre,
        verificado: p.verificacao == Verificacao.aprovada,
        fotos: [for (final f in fotosTrabalho.aprovadas) f.imagem],
        barrasNotas: p.barrasNotas,
        avaliacoes: p.avaliacoes,
        feminino: p.feminino,
        // RN-159: só os registros conferidos aparecem para o cliente.
        registros: [
          for (final r in p.registros.values)
            if (r.status == StatusRegistro.conferido) r.rotulo,
        ],
      ),
      avatar: AvatarUsuario(nome: p.nome, tamanho: 96),
      faixa: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: TatuColors.action,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(TablerIcons.eye, size: 18, color: TatuColors.onAction),
            SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Prévia: assim os clientes veem seu perfil.',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.onAction,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onVerFotos: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FotosTrabalhoPage()),
      ),
      rodape: FilledButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(TablerIcons.pencil, size: 20),
        label: const Text('Voltar a editar'),
      ),
    );
  }
}
