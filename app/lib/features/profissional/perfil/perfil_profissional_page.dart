import '../../../data/sugestoes_tatu.dart' show ModoConta;
import '../../entrada/enviar_sugestao_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/fotos_trabalho.dart';
import '../../../data/ajuda.dart';
import '../../../data/notificacoes_profissional.dart';
import '../../../data/perfil.dart';
import '../../../data/avaliacoes_profissional.dart';
import '../../../data/navegacao.dart';
import '../../../data/profissional.dart';
import '../../../data/seguranca.dart';
import '../../../shared/widgets/avatar_usuario.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../cliente/ajuda/ajuda_page.dart';
import '../../cliente/foto/foto_perfil_sheet.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../cliente/home_page.dart';
import '../cadastro/pix_page.dart';
import '../cadastro/profissoes_page.dart';
import '../cadastro/resultado_page.dart';
import '../home/home_profissional_page.dart';
import 'dados_conta_profissional_page.dart';
import 'fotos_trabalho_page.dart';
import '../servico/rota.dart';
import '../../entrada/seguranca.dart';
import 'avaliacoes_profissional_page.dart';
import 'notificacoes_profissional_page.dart';
import 'preferencias_atendimento_page.dart';
import 'previa_page.dart';
import 'regiao_page.dart';
import 'sobre_page.dart';
import 'seus_selos_page.dart';
import '../../cliente/privacidade/privacidade_page.dart';

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
      listenable: Listenable.merge([
        profissional,
        fotosTrabalho,
        perfil,
        notificacoesProfissional,
        navegacao,
        seguranca,
        avaliacoesProfissional,
      ]),
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
                    Center(
                      child: Semantics(
                        button: true,
                        label: 'Foto do perfil',
                        child: GestureDetector(
                          onTap: () => trocarFotoDoPerfil(context),
                          child: AvatarUsuario(
                            nome: p.nome,
                            tamanho: TatuMedidas.avatarPerfil,
                            camera: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            p.nome,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (p.verificacao == Verificacao.aprovada) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            TablerIcons.circle_check_filled,
                            size: 20,
                            color: TatuColors.verified,
                            semanticLabel: 'Verificado',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          TablerIcons.star_filled,
                          size: 14,
                          color: TatuColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${p.nota.toStringAsFixed(1).replaceAll('.', ',')}'
                          ' · ${p.servicosFeitos} serviços',
                          style: TatuTexto.detalhe,
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    FilledButton.icon(
                      onPressed: () => _abrir(context, const PreviaPage()),
                      icon: const Icon(TablerIcons.eye, size: 20),
                      label: const Text('Ver como o cliente vê'),
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
                    const SizedBox(height: TatuMedidas.entreSecoes),
                    GrupoLista(
                      titulo: 'Seu perfil',
                      itens: [
                        ItemLista(
                          icone: TablerIcons.star,
                          texto: 'Minhas avaliações',
                          valor: avaliacoesProfissional.vazio
                              ? null
                              : avaliacoesProfissional.media
                                    .toStringAsFixed(1)
                                    .replaceAll('.', ','),
                          onTap: () => _abrir(
                            context,
                            const AvaliacoesProfissionalPage(),
                          ),
                        ),
                        // P85 · RN-219: selos de confiança.
                        ItemLista(
                          icone: TablerIcons.rosette,
                          texto: 'Seus selos',
                          valor: '${p.selos.length}',
                          onTap: () => _abrir(context, const SeusSelosPage()),
                        ),
                        ItemLista(
                          icone: TablerIcons.tools,
                          texto: 'Profissões',
                          valor: p.profissoes.length > 1
                              ? '${p.profissoes.first.nome} +${p.profissoes.length - 1}'
                              : p.profissoes.map((e) => e.nome).join(', '),
                          onTap: () => _abrir(
                            context,
                            const ProfissoesPage(doPerfil: true),
                          ),
                        ),
                        ItemLista(
                          icone: TablerIcons.photo,
                          texto: 'Fotos de trabalhos',
                          valor: '${fotosTrabalho.fotos.length}',
                          onTap: () =>
                              _abrir(context, const FotosTrabalhoPage()),
                        ),
                        ItemLista(
                          icone: TablerIcons.user,
                          texto: 'Sobre você',
                          onTap: () => _abrir(context, const SobrePage()),
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
                          valor: notificacoesProfissional.ativas
                              ? 'Ativadas'
                              : 'Desativadas',
                          onTap: () => abrirNotificacoesProfissional(context),
                        ),
                        ItemLista(
                          icone: TablerIcons.navigation,
                          texto: 'App de navegação',
                          valor: navegacao.preferido.nome,
                          onTap: () =>
                              _abrir(context, const AppNavegacaoPage()),
                        ),
                        ItemLista(
                          icone: TablerIcons.shield_check,
                          texto: 'Contatos de confiança',
                          valor: '${seguranca.contatos.length}',
                          onTap: () =>
                              _abrir(context, const ContatosConfiancaPage()),
                        ),
                        ItemLista(
                          icone: TablerIcons.user_check,
                          texto: 'Preferências de atendimento',
                          onTap: () => _abrir(
                            context,
                            const PreferenciasAtendimentoPage(),
                          ),
                        ),
                        ItemLista(
                          icone: TablerIcons.user_circle,
                          texto: 'Dados da conta',
                          onTap: () => _abrir(
                            context,
                            const DadosContaProfissionalPage(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TatuMedidas.entreSecoes),
                    GrupoLista(
                      itens: [
                        ItemLista(
                          icone: TablerIcons.help_circle,
                          texto: 'Ajuda',
                          onTap: () => _abrir(
                            context,
                            const AjudaPage(conteudo: conteudoProfissional),
                          ),
                        ),
                        // RN-173: sugestão ao Tatu (mesmas telas).
                        ItemLista(
                          icone: TablerIcons.bulb,
                          texto: 'Enviar sugestão',
                          onTap: () => _abrir(
                            context,
                            EnviarSugestaoPage(
                              conta: profissional.nome,
                              modo: ModoConta.profissional,
                            ),
                          ),
                        ),
                        ItemLista(
                          icone: TablerIcons.shield_lock,
                          texto: 'Privacidade e termos',
                          onTap: () =>
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PrivacidadePage(),
                                ),
                              ),
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
