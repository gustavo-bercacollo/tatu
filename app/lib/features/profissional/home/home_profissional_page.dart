import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/seguranca.dart';
import '../../entrada/seguranca.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/ajuda.dart';
import '../../../data/prazos.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/conta_pausada.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../cliente/ajuda/abrir_ajuda.dart';
import '../../../shared/widgets/avatar_usuario.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../abas.dart';
import '../cadastro/pix_page.dart';
import '../perfil/perfil_profissional_page.dart';
import '../chamado/novo_chamado_page.dart';

/// P19–P21 · Home do profissional: mapa e painel offline/online.
/// O app sempre abre offline. Na primeira vez, mostra a dica do botão.
class HomeProfissionalPage extends StatefulWidget {
  const HomeProfissionalPage({
    super.key,
    this.chamadoEm = const Duration(seconds: 5),
  });

  /// Protótipo: tempo online até chegar um chamado de exemplo.
  final Duration chamadoEm;

  @override
  State<HomeProfissionalPage> createState() => _HomeProfissionalPageState();
}

class _HomeProfissionalPageState extends State<HomeProfissionalPage> {
  Timer? _chamado;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    profissional.addListener(_mudou);
    _mudou();
  }

  @override
  void dispose() {
    profissional.removeListener(_mudou);
    _chamado?.cancel();
    super.dispose();
  }

  /// Ao ficar online, um chamado chega depois de alguns segundos
  /// (uma vez por período online).
  void _mudou() {
    if (profissional.online == _online) return;
    _online = profissional.online;
    _chamado?.cancel();
    if (!_online) return;
    _chamado = Timer(widget.chamadoEm, () {
      if (!mounted || !profissional.online) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const NovoChamadoPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profissional,
      builder: (context, _) {
        final p = profissional;
        final dica = !p.dicaVista;
        return Scaffold(
          bottomNavigationBar: const AbasDoProfissional(
            ativa: AbaCliente.inicio,
          ),
          body: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: MapaFalso())),
              Center(child: _Ponto(online: p.online)),
              if (p.online)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 72),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ListenableBuilder(
                        listenable: seguranca,
                        builder: (_, _) => seguranca.soMulheres
                            ? const SeloPreferencia('Só clientes mulheres')
                            : seguranca.soVerificados
                            ? const SeloPreferencia('Só clientes verificados')
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    TatuMedidas.topo,
                    TatuMedidas.margem,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _Avatar(
                            nome: p.nome,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PerfilProfissionalPage(),
                              ),
                            ),
                          ),
                          const Spacer(),
                          _Situacao(online: p.online),
                        ],
                      ),
                      if (p.pausada) ...[
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        const _ContaPausada(),
                      ],
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _Painel(dica: dica),
              ),
              if (dica) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: p.verDica,
                    child: const ColoredBox(color: TatuColors.scrim),
                  ),
                ),
                const Align(alignment: Alignment.bottomCenter, child: _Dica()),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Ponto extends StatelessWidget {
  const _Ponto({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: online ? 120 : 34,
      height: online ? 120 : 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? TatuColors.radar : TatuColors.fillStrong,
      ),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: online ? TatuColors.action : TatuColors.textSecondary,
          border: Border.all(color: TatuColors.bg, width: 3),
        ),
      ),
    );
  }
}

/// Aviso vermelho: conta pausada por muitas visitas sem serviço (RN-63)
/// ou por abandonos (RN-79).
class _ContaPausada extends StatelessWidget {
  const _ContaPausada();

  @override
  Widget build(BuildContext context) {
    final p = profissional;
    return AvisoContaPausada(
      motivo: p.pausadaPorAbandonos
          // RN-79: 3 abandonos em 30 dias.
          ? '${p.abandonosRecentes} chamados abandonados em '
                '${Prazos.janelaAbandonos.inDays} dias. '
                'Fale com o suporte para voltar.'
          : '${p.visitasSemServico} das últimas $janelaVisitas '
                'visitas terminaram sem serviço. Fale com o '
                'suporte para voltar.',
      onSuporte: () => abrirSuporte(context, conteudoProfissional),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.nome, required this.onTap});

  final String nome;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Perfil',
      child: Material(
        color: TatuColors.bg,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: TatuColors.sombra,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: AvatarUsuario(nome: nome, tamanho: 40),
          ),
        ),
      ),
    );
  }
}

class _Situacao extends StatelessWidget {
  const _Situacao({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TatuColors.bg,
      shape: const StadiumBorder(),
      elevation: 2,
      shadowColor: TatuColors.sombra,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: online ? TatuColors.online : TatuColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              online ? 'Online' : 'Offline',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painel de baixo: situação, lembrete do Pix e botão online/offline.
class _Painel extends StatelessWidget {
  const _Painel({required this.dica});

  final bool dica;

  @override
  Widget build(BuildContext context) {
    final p = profissional;
    return Container(
      constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
      decoration: const BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TatuMedidas.raioFolha),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margem,
            10,
            TatuMedidas.margem,
            TatuMedidas.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AlcaFolha(),
              const SizedBox(height: 18),
              Text(
                p.online ? 'Você está online' : 'Você está offline',
                style: TatuTexto.tituloFolha,
              ),
              const SizedBox(height: 4),
              Text(
                p.online
                    ? 'Buscando chamados… Mantenha o app aberto.'
                    : 'Fique online para receber chamados perto de você.',
                style: TatuTexto.detalhe,
              ),
              if (!p.temPix) ...[
                const SizedBox(height: TatuMedidas.entreItens + 4),
                const _LembretePix(),
              ],
              const SizedBox(height: TatuMedidas.entreItens + 4),
              // Na dica, o botão aparece por cima do escuro.
              Opacity(
                opacity: dica ? 0 : 1,
                child: BotaoOnline(online: p.online),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão "Ficar online" / "Ficar offline".
class BotaoOnline extends StatelessWidget {
  const BotaoOnline({super.key, required this.online, this.aro = false});

  final bool online;

  /// Aro branco em volta (na dica da primeira vez).
  final bool aro;

  @override
  Widget build(BuildContext context) {
    final botao = online
        ? FilledButton(
            style: tatuBotaoSecundario(),
            onPressed: () => profissional.ficarOnline(false),
            child: const Text('Ficar offline'),
          )
        : FilledButton.icon(
            onPressed: profissional.pausada
                ? null
                : () {
                    profissional
                      ..verDica()
                      ..ficarOnline(true);
                  },
            icon: const Icon(TablerIcons.power, size: 20),
            label: const Text('Ficar online'),
          );
    if (!aro) return botao;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const ShapeDecoration(
        color: TatuColors.bg,
        shape: StadiumBorder(),
      ),
      child: botao,
    );
  }
}

class _LembretePix extends StatelessWidget {
  const _LembretePix();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
        border: Border.all(color: TatuColors.textPrimary, width: 1.5),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cadastre onde receber',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text('Para cobrar pelo app.', style: TatuTexto.nota),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, TatuMedidas.alturaChip),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PixPage(doPerfil: true)),
            ),
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }
}

/// Dica da primeira vez: balão sobre o botão "Ficar online".
class _Dica extends StatelessWidget {
  const _Dica();

  @override
  Widget build(BuildContext context) {
    final p = profissional;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margem,
            0,
            TatuMedidas.margem,
            TatuMedidas.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                decoration: BoxDecoration(
                  color: TatuColors.bg,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.feminino
                          ? 'Pronta para começar?'
                          : 'Pronto para começar?',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toque aqui quando quiser receber chamados. '
                      'Só quem está online recebe.',
                      style: TextStyle(fontSize: 15, height: 1.35),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: p.verDica,
                        style: TextButton.styleFrom(
                          foregroundColor: TatuColors.verified,
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Entendi'),
                      ),
                    ),
                  ],
                ),
              ),
              CustomPaint(size: const Size(22, 10), painter: _Bico()),
              const SizedBox(height: 8),
              BotaoOnline(online: p.online, aro: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bico extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 2;
    final path = Path()
      ..moveTo(c - 11, 0)
      ..lineTo(c + 11, 0)
      ..lineTo(c, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = TatuColors.bg);
  }

  @override
  bool shouldRepaint(_Bico oldDelegate) => false;
}

/// "Trocar para modo cliente": se estiver online, pergunta antes (P21b).
Future<bool> podeTrocarParaCliente(BuildContext context) async {
  if (!profissional.online) return true;
  final trocar = await confirmar(
    context,
    icone: TablerIcons.alert_triangle,
    titulo: 'Ficar offline e trocar?',
    texto:
        'Você está online. Ao trocar para cliente, deixa de receber chamados.',
    confirmar: 'Trocar para cliente',
    cancelar: 'Continuar online',
  );
  if (trocar) profissional.ficarOnline(false);
  return trocar;
}
