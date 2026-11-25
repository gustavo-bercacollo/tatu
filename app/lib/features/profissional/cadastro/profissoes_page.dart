import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/profissional.dart';
import '../../../data/servicos.dart';
import '../../../data/sugestoes_profissao.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import 'como_atende_page.dart';
import 'especialidades_page.dart';
import 'pix_page.dart';
import 'servicos_page.dart';
import 'registro_page.dart';

/// P06 · Passo 2: resumo das profissões, com "Editar" e "Adicionar outra".
/// Com [doPerfil], vem do Perfil: o botão é "Pronto" e só volta.
class ProfissoesPage extends StatelessWidget {
  const ProfissoesPage({super.key, this.doPerfil = false});

  final bool doPerfil;

  void _seguir(BuildContext context) {
    if (doPerfil) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PixPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([profissional, sugestoesProfissao]),
      builder: (context, _) {
        final lista = profissional.profissoes;
        final sugestoes = sugestoesProfissao.de(profissional.nome);
        final completas = lista.every((p) => p.especialidades.isNotEmpty);
        return CadastroScaffold(
          passo: doPerfil ? null : 2,
          titulo: 'Suas profissões',
          subtitulo: 'Você só recebe chamados das profissões que adicionar.',
          botao: doPerfil ? 'Pronto' : 'Continuar',
          onBotao: lista.isNotEmpty && completas
              ? () => _seguir(context)
              : null,
          children: [
            for (var i = 0; i < lista.length; i++) ...[
              _CartaoProfissao(
                profissao: lista[i],
                onEditar: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EspecialidadesPage(indice: i, edicao: true),
                  ),
                ),
                onModo: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ComoAtendePage(indice: i, edicao: true),
                  ),
                ),
              ),
              const SizedBox(height: TatuMedidas.entreItens),
            ],
            // RN-157: prazo da conferência do registro.
            if (profissional.registros.values.any(
              (r) => r.status == StatusRegistro.emAnalise && !r.faltaNumero,
            )) ...[
              Text(
                'Conferimos em até ${RegrasRegistro.diasUteisConferencia} '
                'dias úteis.',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
            ],
            // RN-162: profissões sugeridas ao Tatu ficam em análise aqui.
            if (sugestoes.isNotEmpty) ...[
              GrupoCartao(
                titulo: 'Sugestões',
                nota:
                    'Analisamos em até ${RegrasSugestao.diasUteis} dias úteis.',
                linhas: [
                  for (final s in sugestoes)
                    SizedBox(
                      height: TatuMedidas.alturaLinha,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.nome,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const EtiquetaCinza(
                              icone: TablerIcons.clock,
                              texto: 'Em análise',
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
            ],
            if (lista.length < maxProfissoes)
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const ServicosProfissionalPage(adicionar: true),
                  ),
                ),
                icon: const Icon(TablerIcons.plus, size: 18),
                label: const Text('Adicionar outra profissão'),
                style: tatuBotaoContorno(),
              ),
            const SizedBox(height: TatuMedidas.entreItens),
            Text(
              '${lista.length} de $maxProfissoes '
              '${lista.length == 1 ? 'profissão' : 'profissões'}',
              textAlign: TextAlign.center,
              style: TatuTexto.nota,
            ),
          ],
        );
      },
    );
  }
}

class _CartaoProfissao extends StatelessWidget {
  const _CartaoProfissao({
    required this.profissao,
    required this.onEditar,
    required this.onModo,
  });

  final ProfissaoEscolhida profissao;
  final VoidCallback onEditar;

  /// RN-97: muda como atende (no local, à distância ou os dois).
  final VoidCallback onModo;

  @override
  Widget build(BuildContext context) {
    final esp = profissao.especialidades;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        children: [
          IconeCirculo(iconeServico(profissao.nome), fundo: TatuColors.bg),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profissao.nome,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  esp.isEmpty ? 'Escolha as especialidades' : esp.join(' · '),
                  style: esp.isEmpty
                      ? TatuTexto.nota.copyWith(color: TatuColors.warningTexto)
                      : TatuTexto.nota,
                ),
                // RN-157/RN-159: situação do registro desta profissão.
                if (profissional.registros[profissao.nome] case final r?) ...[
                  const SizedBox(height: 8),
                  SeloRegistro(
                    registro: r,
                    onTap: switch (r.status) {
                      StatusRegistro.naoEncontrado => () =>
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegistroNaoEncontradoPage(
                              profissao: profissao.nome,
                            ),
                          ),
                        ),
                      StatusRegistro.emAnalise when r.faltaNumero => () =>
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => RegistroProfissionalPage(
                              profissao: profissao.nome,
                              passo: null,
                              onEnviar: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                        ),
                      _ => null,
                    },
                  ),
                ],
                const SizedBox(height: 4),
                // RN-97: só dá para mudar quando o catálogo permite mais
                // de um modo.
                if (modoUnico(profissao.nome) != null)
                  Text(
                    'Atende: ${profissao.modo.nome.toLowerCase()}',
                    style: TatuTexto.nota,
                  )
                else
                  GestureDetector(
                    onTap: onModo,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Atende: ${profissao.modo.nome.toLowerCase()} · Mudar',
                      style: TatuTexto.nota.copyWith(
                        color: TatuColors.verified,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          LinkAzul('Editar', onTap: onEditar),
        ],
      ),
    );
  }
}
