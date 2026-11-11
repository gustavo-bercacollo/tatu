import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../cliente/home_page.dart';
import '../cadastro/pix_page.dart';
import '../cadastro/profissoes_page.dart';
import '../cadastro/resultado_page.dart';
import '../home/home_profissional_page.dart';
import 'previa_page.dart';
import 'regiao_page.dart';

/// P31 · Perfil do profissional.
class PerfilProfissionalPage extends StatelessWidget {
  const PerfilProfissionalPage({super.key});

  void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  void _abrir(BuildContext context, Widget tela) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));

  Future<void> _trocarParaCliente(BuildContext context) async {
    if (!await podeTrocarParaCliente(context) || !context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeClientePage()),
      (_) => false,
    );
  }

  String get _verificacao => switch (profissional.verificacao) {
    Verificacao.aprovada => 'Aprovada',
    Verificacao.emAnalise => 'Em análise',
    Verificacao.refazer => 'Refazer foto',
    Verificacao.reprovada => 'Não aprovada',
    Verificacao.naoEnviada => 'Pendente',
  };

  Widget? get _telaVerificacao => switch (profissional.verificacao) {
    Verificacao.emAnalise => const EmAnalisePage(),
    Verificacao.refazer => const RefazerFotoPage(),
    Verificacao.reprovada => const ReprovadoPage(),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profissional,
      builder: (context, _) {
        final p = profissional;
        return Scaffold(
          backgroundColor: TatuColors.surfaceGrouped,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: TatuMedidas.larguraMax,
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    TatuMedidas.topo,
                    TatuMedidas.margem,
                    TatuMedidas.base,
                  ),
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackCircleButton(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        AvatarIniciais(
                          nome: p.nome,
                          tamanho: TatuMedidas.avatarPerfil,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              p.verificacao == Verificacao.aprovada
                                  ? NomeVerificado(p.nome, tamanho: 24)
                                  : Text(
                                      p.nome,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TatuColors.fill,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          p.nota
                                              .toStringAsFixed(1)
                                              .replaceAll('.', ','),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Icon(
                                          TablerIcons.star_filled,
                                          size: 11,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${p.servicosFeitos} serviços',
                                    style: TatuTexto.nota,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => _abrir(context, const PreviaPage()),
                      icon: const Icon(TablerIcons.eye, size: 20),
                      label: const Text('Ver como o cliente vê'),
                    ),
                    const SizedBox(height: TatuMedidas.entreSecoes),
                    GrupoLista(
                      titulo: 'Seu perfil',
                      itens: [
                        ItemLista(
                          icone: TablerIcons.tools,
                          texto: 'Profissões',
                          valor: p.profissoes.map((e) => e.nome).join(', '),
                          onTap: () => _abrir(
                            context,
                            const ProfissoesPage(doPerfil: true),
                          ),
                        ),
                        ItemLista(
                          icone: TablerIcons.photo,
                          texto: 'Fotos de trabalhos',
                          valor: '${p.fotosTrabalhos}',
                          onTap: () => _emBreve(context, 'Fotos de trabalhos'),
                        ),
                        ItemLista(
                          icone: TablerIcons.user,
                          texto: 'Sobre você',
                          onTap: () => _emBreve(context, 'Sobre você'),
                        ),
                        ItemLista(
                          icone: TablerIcons.map_pin,
                          texto: 'Região de atendimento',
                          valor: 'até ${p.raioKm} km',
                          onTap: () => _abrir(context, const RegiaoPage()),
                        ),
                      ],
                    ),
                    const SizedBox(height: TatuMedidas.entreSecoes),
                    GrupoLista(
                      titulo: 'Conta',
                      itens: [
                        ItemLista(
                          icone: TablerIcons.wallet,
                          texto: 'Onde receber',
                          valor: p.temPix
                              ? 'Pix · ${p.pixTipo!.nome}'
                              : 'Cadastrar',
                          onTap: () =>
                              _abrir(context, const PixPage(doPerfil: true)),
                        ),
                        ItemLista(
                          icone: TablerIcons.rosette_discount_check,
                          texto: 'Verificação',
                          valor: _verificacao,
                          onTap: () {
                            final tela = _telaVerificacao;
                            tela == null
                                ? _emBreve(context, 'Verificação')
                                : _abrir(context, tela);
                          },
                        ),
                        ItemLista(
                          icone: TablerIcons.bell,
                          texto: 'Notificações',
                          valor: 'Ativadas',
                          onTap: () => _emBreve(context, 'Notificações'),
                        ),
                        ItemLista(
                          icone: TablerIcons.user_circle,
                          texto: 'Dados da conta',
                          onTap: () => _emBreve(context, 'Dados da conta'),
                        ),
                      ],
                    ),
                    const SizedBox(height: TatuMedidas.entreSecoes),
                    GrupoLista(
                      itens: [
                        ItemLista(
                          icone: TablerIcons.help_circle,
                          texto: 'Ajuda',
                          onTap: () => _emBreve(context, 'Ajuda'),
                        ),
                        ItemLista(
                          icone: TablerIcons.shield_lock,
                          texto: 'Privacidade e termos',
                          onTap: () =>
                              _emBreve(context, 'Privacidade e termos'),
                        ),
                      ],
                    ),
                    const SizedBox(height: TatuMedidas.entreSecoes),
                    GrupoLista(
                      titulo: 'Modo',
                      itens: [
                        ItemLista(
                          icone: TablerIcons.refresh,
                          texto: 'Trocar para modo cliente',
                          onTap: () => _trocarParaCliente(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
