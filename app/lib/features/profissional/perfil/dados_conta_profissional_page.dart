import '../../../data/retorno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/conta.dart';
import '../../../data/ganhos.dart';
import '../../../data/profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../../cliente/conta/excluir_conta_page.dart';
import '../../cliente/conta/novo_celular_page.dart';
import '../../cliente/conta/novo_email_page.dart';
import '../../cliente/home_page.dart';
import '../atividade/ganhos_page.dart';
import '../cadastro/verificacao_page.dart';

/// Quanto ainda vai cair no Pix (já sem a taxa).
double get _aReceber => ganhos.semana.aReceber * (1 - taxaTatu);

/// Dados da conta do profissional: dados do documento (com cadeado),
/// contato, "Encerrar perfil profissional" e "Excluir conta".
class DadosContaProfissionalPage extends StatelessWidget {
  const DadosContaProfissionalPage({super.key});

  Future<void> _doDocumento(BuildContext context, String dado) async {
    final enviar = await confirmar(
      context,
      icone: TablerIcons.id,
      iconeAviso: false,
      titulo: '$dado vem do documento',
      texto:
          'Para mudar, envie um novo documento.\n'
          'Você continua recebendo chamados.',
      confirmar: 'Enviar novo documento',
    );
    if (!enviar || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CameraVerificacaoPage(
          etapa: EtapaFoto.frente,
          refazendo: true,
        ),
      ),
    );
  }

  Future<void> _trocarCelular(BuildContext context) async {
    final novo = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const NovoCelularPage()));
    if (novo == null || !context.mounted) return;
    conta.definirCelular(novo);
    mostrarAvisoTopo(
      context,
      titulo: 'Celular atualizado',
      texto: 'Use o novo número para entrar.',
    );
  }

  Future<void> _trocarEmail(BuildContext context) async {
    final novo = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const NovoEmailPage()));
    if (novo == null || !context.mounted) return;
    conta.definirEmail(novo);
    mostrarAvisoTopo(
      context,
      titulo: 'E-mail atualizado',
      texto: 'Seus recibos vão para o novo e-mail.',
    );
  }

  void _abrir(BuildContext context, Widget tela) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([conta, profissional]),
      builder: (context, _) {
        final p = profissional;
        return TelaInterna(
          titulo: 'Dados da conta',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(
              top: TatuMedidas.entreSecoes,
              bottom: TatuMedidas.entreSecoes,
            ),
            children: [
              GrupoCartao(
                titulo: 'Do seu documento',
                nota: 'Verificados na sua análise de cadastro.',
                linhas: [
                  LinhaDado(
                    rotulo: 'Nome',
                    valor: p.nome,
                    bloqueado: true,
                    onTap: () => _doDocumento(context, 'Seu nome'),
                  ),
                  LinhaDado(
                    rotulo: 'CPF',
                    valor: p.cpfMascarado,
                    bloqueado: true,
                    onTap: () => _doDocumento(context, 'Seu CPF'),
                  ),
                  LinhaDado(
                    rotulo: 'Nascimento',
                    valor: p.nascimento,
                    bloqueado: true,
                    onTap: () =>
                        _doDocumento(context, 'Sua data de nascimento'),
                  ),
                ],
              ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              GrupoCartao(
                titulo: 'Contato',
                linhas: [
                  LinhaDado(
                    rotulo: 'Celular',
                    valor: conta.celularFormatado ?? 'Adicionar',
                    confirmado: conta.celular != null,
                    onTap: () => _trocarCelular(context),
                  ),
                  LinhaDado(
                    rotulo: 'E-mail',
                    valor: conta.email ?? 'Adicionar',
                    confirmado: conta.email != null,
                    onTap: () => _trocarEmail(context),
                  ),
                ],
              ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              GrupoCartao(
                linhas: [
                  _LinhaPerigo(
                    'Encerrar perfil profissional',
                    onTap: () => _abrir(context, const EncerrarPerfilPage()),
                  ),
                  _LinhaPerigo(
                    'Excluir conta',
                    onTap: () => _abrir(
                      context,
                      _aReceber > 0
                          ? const ExcluirComSaldoPage()
                          : const ExcluirContaPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Linha de texto vermelho (ação destrutiva) dentro de um cartão.
class _LinhaPerigo extends StatelessWidget {
  const _LinhaPerigo(this.texto, {required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: TatuMedidas.alturaLinha,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            texto,
            style: const TextStyle(fontSize: 17, color: TatuColors.danger),
          ),
        ),
      ),
    ),
  );
}

/// Encerrar perfil profissional: a conta de cliente continua.
class EncerrarPerfilPage extends StatelessWidget {
  const EncerrarPerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // RN-185/RN-192: com retorno aberto ou dívida, não encerra.
    final abertos = retornos.abertosDe(profissional.nome).length;
    final bloqueio = profissional.comDivida
        ? 'Você tem ${reais(profissional.divida)} de retorno para acertar '
              'com o Tatu. Quite antes de encerrar.'
        : abertos > 0
        ? 'Você tem ${abertos == 1 ? 'um retorno aberto' : '$abertos retornos abertos'}. '
              'Resolva antes de encerrar.'
        : null;
    return CadastroScaffold(
      titulo: 'Encerrar perfil profissional?',
      subtitulo: 'Sua conta de cliente continua.',
      botao: 'Encerrar perfil profissional',
      perigo: true,
      onBotao: bloqueio != null
          ? null
          : () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PerfilEncerradoPage()),
            ),
      botaoSecundario: 'Manter perfil',
      onSecundario: () => Navigator.of(context).pop(),
      children: [
        if (bloqueio != null) ...[
          CaixaAviso(bloqueio),
          const SizedBox(height: TatuMedidas.entreItens),
        ],
        LinhaConsequencia(TablerIcons.bell, 'Você para de receber chamados.'),
        LinhaConsequencia(
          TablerIcons.users,
          'Seu perfil sai das buscas dos clientes.',
        ),
        LinhaConsequencia(
          TablerIcons.wallet,
          'Valores a receber caem no seu Pix normalmente.',
        ),
        const LinhaConsequencia(
          TablerIcons.refresh,
          'Para voltar, você refaz a verificação.',
        ),
      ],
    );
  }
}

/// Perfil profissional encerrado: segue como cliente.
class PerfilEncerradoPage extends StatelessWidget {
  const PerfilEncerradoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      sucesso: true,
      icone: const IconePermissao(TablerIcons.check, cor: TatuColors.online),
      titulo: 'Perfil profissional encerrado',
      texto: 'Você continua usando o Tatu\ncomo cliente.',
      principal: 'Ir para o modo cliente',
      onPrincipal: () {
        profissional.restaurar();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeClientePage()),
          (_) => false,
        );
      },
    );
  }
}

/// Agora não dá para excluir: ainda há valor a receber no Pix.
class ExcluirComSaldoPage extends StatelessWidget {
  const ExcluirComSaldoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      aviso: true,
      icone: const IconePermissao(
        TablerIcons.wallet,
        cor: TatuColors.warningTexto,
      ),
      titulo: 'Agora não dá para excluir',
      texto:
          'Você tem ${reais(_aReceber)} a receber.\n'
          'Assim que cair no seu Pix,\n'
          'você pode excluir a conta.',
      principal: 'Ver meus ganhos',
      onPrincipal: () => Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const GanhosPage())),
      alternativa: 'Voltar',
      onAlternativa: () => Navigator.of(context).pop(),
    );
  }
}
