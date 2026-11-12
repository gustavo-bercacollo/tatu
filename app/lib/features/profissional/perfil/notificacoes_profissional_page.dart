import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/notificacoes.dart';
import '../../../data/notificacoes_profissional.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../chamado/toque_chamado.dart';

/// "Padrão do iPhone" no iPhone; "Padrão do celular" nos outros.
String nomeDoSom(SomChamado s) =>
    s == SomChamado.padrao && defaultTargetPlatform == TargetPlatform.iOS
    ? 'Padrão do iPhone'
    : s.nome;

/// Abre as Notificações; na primeira vez, pede a permissão antes.
void abrirNotificacoesProfissional(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => notificacoesProfissional.perguntado
          ? const NotificacoesProfissionalPage()
          : const PermissaoAvisosPage(),
    ),
  );
}

/// Notificações do profissional: chamados, som, ganhos e extras.
class NotificacoesProfissionalPage extends StatelessWidget {
  const NotificacoesProfissionalPage({super.key});

  Future<void> _mudar(BuildContext context, TipoAviso a, bool valor) async {
    if (!valor && a.dePedido) {
      final desligar = await confirmar(
        context,
        icone: TablerIcons.alert_triangle,
        titulo: 'Desligar novo chamado?',
        texto:
            'Com o app fechado, você não vai saber\n'
            'quando um cliente chamar.',
        confirmar: 'Desligar mesmo assim',
        cancelar: 'Manter ligado',
        destacarCancelar: true,
      );
      if (!desligar) return;
    }
    notificacoesProfissional.definir(a.id, valor);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notificacoesProfissional,
      builder: (context, _) {
        final n = notificacoesProfissional;
        final permitido = n.permitidoNoCelular;
        List<Widget> linhas(List<TipoAviso> avisos) => [
          for (final a in avisos)
            LinhaInterruptor(
              texto: a.titulo,
              detalhe: a.detalhe,
              valor: n.ligado(a.id),
              habilitado: permitido,
              onMudar: (v) => _mudar(context, a, v),
            ),
        ];
        return TelaInterna(
          titulo: 'Notificações',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(
              top: TatuMedidas.topo,
              bottom: TatuMedidas.entreSecoes,
            ),
            children: [
              if (permitido)
                FilledButton(
                  style: tatuBotaoSecundario(),
                  onPressed: n.ativarTodas,
                  child: const Text('Ativar todas'),
                )
              else
                const AvisoNotificacoesBloqueadas(
                  texto:
                      'Sem elas, você só recebe chamados\n'
                      'com o app aberto na tela.',
                ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              GrupoCartao(titulo: 'Chamados', linhas: linhas(avisosDeChamado)),
              const SizedBox(height: TatuMedidas.entreItens),
              _LinhaSom(
                som: nomeDoSom(n.som),
                habilitado: permitido,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SomChamadoPage()),
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              GrupoCartao(titulo: 'Ganhos', linhas: linhas(avisosDeGanhos)),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              GrupoCartao(
                titulo: 'Extras',
                linhas: linhas(avisosExtrasProfissional),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LinhaSom extends StatelessWidget {
  const _LinhaSom({
    required this.som,
    required this.habilitado,
    required this.onTap,
  });

  final String som;
  final bool habilitado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cor = habilitado ? TatuColors.textPrimary : TatuColors.textSecondary;
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: TatuMedidas.alturaLinha,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(TablerIcons.bell, size: 22, color: cor),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Som do novo chamado',
                      maxLines: 1,
                      style: TextStyle(fontSize: 17, color: cor),
                    ),
                  ),
                ),
                Text(som, style: TatuTexto.detalhe),
                const SizedBox(width: 6),
                const Icon(
                  TablerIcons.chevron_right,
                  size: 18,
                  color: TatuColors.chevron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aviso vermelho quando as notificações estão bloqueadas no celular.
class AvisoNotificacoesBloqueadas extends StatelessWidget {
  const AvisoNotificacoesBloqueadas({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final aparelho = defaultTargetPlatform == TargetPlatform.iOS
        ? 'no iPhone'
        : 'no celular';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.dangerSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(TablerIcons.bell, size: 22, color: TatuColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desativadas $aparelho',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: TatuColors.danger,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: TatuColors.danger,
                    foregroundColor: TatuColors.onAction,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Abrir Ajustes: em breve')),
                    ),
                  child: const Text('Abrir Ajustes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Som do novo chamado: escolher o som, vibrar e ouvir.
class SomChamadoPage extends StatefulWidget {
  const SomChamadoPage({super.key});

  @override
  State<SomChamadoPage> createState() => _SomChamadoPageState();
}

class _SomChamadoPageState extends State<SomChamadoPage> {
  final _previa = ToqueChamado();

  @override
  void dispose() {
    _previa.parar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notificacoesProfissional,
      builder: (context, _) {
        final n = notificacoesProfissional;
        return TelaInterna(
          titulo: 'Som do novo chamado',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Toca até você aceitar ou recusar o chamado.',
                  style: TatuTexto.detalhe,
                ),
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              GrupoCartao(
                linhas: [
                  for (final s in SomChamado.values)
                    _OpcaoSom(
                      titulo: nomeDoSom(s),
                      detalhe: s == SomChamado.alerta
                          ? 'Alto, mais fácil de ouvir'
                          : null,
                      escolhido: s == n.som,
                      onTap: () {
                        _previa.parar();
                        n.escolherSom(s);
                      },
                    ),
                ],
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              GrupoCartao(
                linhas: [
                  LinhaInterruptor(
                    texto: 'Vibrar também',
                    valor: n.vibrar,
                    onMudar: n.definirVibrar,
                  ),
                ],
              ),
              const SizedBox(height: TatuMedidas.entreItens),
              Material(
                color: TatuColors.bg,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    await _previa.parar();
                    await _previa.tocar(repetir: false);
                  },
                  child: const SizedBox(
                    height: TatuMedidas.alturaLinha,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            TablerIcons.bell,
                            size: 22,
                            color: TatuColors.verified,
                          ),
                          SizedBox(width: 14),
                          Text(
                            'Ouvir o som',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: TatuColors.verified,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OpcaoSom extends StatelessWidget {
  const _OpcaoSom({
    required this.titulo,
    required this.escolhido,
    required this.onTap,
    this.detalhe,
  });

  final String titulo;
  final String? detalhe;
  final bool escolhido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: escolhido,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: TatuMedidas.alturaLinha),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: const TextStyle(fontSize: 17)),
                      if (detalhe != null) ...[
                        const SizedBox(height: 2),
                        Text(detalhe!, style: TatuTexto.nota),
                      ],
                    ],
                  ),
                ),
                if (escolhido)
                  const Icon(
                    TablerIcons.check,
                    size: 22,
                    color: TatuColors.verified,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Não perca nenhum chamado": pede a permissão de notificação.
class PermissaoAvisosPage extends StatelessWidget {
  const PermissaoAvisosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(
        TablerIcons.bell,
        cor: TatuColors.textPrimary,
      ),
      titulo: 'Não perca nenhum chamado',
      texto:
          'Avisamos quando um cliente perto chamar,\n'
          'mesmo com o app fechado.',
      extra: const _PreviaNotificacao(),
      principal: 'Ativar avisos',
      onPrincipal: () {
        notificacoesProfissional.responderPermissao(permitiu: true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const NotificacoesProfissionalPage(),
          ),
        );
      },
      alternativa: 'Agora não',
      onAlternativa: () {
        notificacoesProfissional.responderPermissao(permitiu: false);
        Navigator.of(context).pop();
      },
    );
  }
}

/// Exemplo de como a notificação aparece no celular.
class _PreviaNotificacao extends StatelessWidget {
  const _PreviaNotificacao();

  @override
  Widget build(BuildContext context) {
    final claro = TatuColors.onAction.withValues(alpha: 0.6);
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TatuColors.action,
          borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TatuColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                't',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tatu · agora',
                    style: TextStyle(fontSize: 13, color: claro),
                  ),
                  const SizedBox(height: 2),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Novo chamado · Encanador · 1,2 km',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TatuColors.onAction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
