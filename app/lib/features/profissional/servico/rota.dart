import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/navegacao.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../../shared/widgets/tela_permissao.dart';

/// Abre um link fora do app (trocado nos testes).
Future<bool> Function(Uri) abrirLink = (u) =>
    launchUrl(u, mode: LaunchMode.externalApplication);

/// "Abrir rota": vai direto no app preferido ou pergunta qual usar.
Future<void> abrirRota(BuildContext context, ServicoAceito s) async {
  final preferido = navegacao.preferido;
  if (preferido != AppNavegacao.perguntar) {
    return _abrirNoApp(context, preferido, s);
  }
  final escolha = await mostrarFolha<_Escolha>(
    context,
    builder: (_) => _FolhaAbrirRota(servico: s),
  );
  if (escolha == null || !context.mounted) return;
  final app = escolha.app;
  if (app == null) {
    Clipboard.setData(ClipboardData(text: s.rua)).ignore();
    mostrarAvisoTopo(context, titulo: 'Endereço copiado', texto: s.rua);
    return;
  }
  if (escolha.sempre) navegacao.escolher(app);
  await _abrirNoApp(context, app, s);
}

Future<void> _abrirNoApp(
  BuildContext context,
  AppNavegacao app,
  ServicoAceito s,
) async {
  if (navegacao.instalados.contains(app)) {
    await abrirLink(app.link(s.rua));
    return;
  }
  // App escolhido não está no celular: abrir em outro ou baixar.
  final outro = AppNavegacao.values.firstWhere(
    (a) => a != AppNavegacao.perguntar && navegacao.instalados.contains(a),
    orElse: () => AppNavegacao.google,
  );
  final r = await perguntar(
    context,
    titulo: '${app.nome} não está instalado',
    texto: 'Quer abrir a rota em outro app?',
    confirmar: 'Abrir no ${outro.nome}',
    cancelar: 'Baixar o ${app.nome}',
    iconeAviso: false,
  );
  if (r == null) return;
  await abrirLink(r ? outro.link(s.rua) : app.loja);
}

class _Escolha {
  const _Escolha(this.app, {this.sempre = false});

  /// Nulo = copiar o endereço.
  final AppNavegacao? app;
  final bool sempre;
}

/// Folha "Abrir rota com": apps de mapa, copiar endereço e "Usar sempre".
class _FolhaAbrirRota extends StatefulWidget {
  const _FolhaAbrirRota({required this.servico});

  final ServicoAceito servico;

  @override
  State<_FolhaAbrirRota> createState() => _FolhaAbrirRotaState();
}

class _FolhaAbrirRotaState extends State<_FolhaAbrirRota> {
  bool _sempre = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.servico;
    final complemento = s.referencia.split(' · ').first;
    final apps = [AppNavegacao.google, AppNavegacao.waze, AppNavegacao.apple];
    return SafeArea(
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
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text('Abrir rota com', style: TatuTexto.tituloFolha),
            const SizedBox(height: 4),
            Text(
              complemento.isEmpty ? s.rua : '${s.rua} · $complemento',
              style: TatuTexto.detalhe,
            ),
            const SizedBox(height: 18),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: TatuColors.fill,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
              ),
              child: Column(
                children: [
                  for (final a in apps) ...[
                    LinhaApp(
                      app: a,
                      seta: true,
                      onTap: () =>
                          Navigator.of(context).pop(_Escolha(a, sempre: _sempre)),
                    ),
                    const _Divisor(),
                  ],
                  LinhaApp.copiar(
                    onTap: () => Navigator.of(context).pop(const _Escolha(null)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Usar sempre o app escolhido',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Semantics(
                  label: 'Usar sempre o app escolhido',
                  toggled: _sempre,
                  child: CupertinoSwitch(
                    value: _sempre,
                    activeTrackColor: TatuColors.online,
                    inactiveTrackColor: TatuColors.trilho,
                    onChanged: (v) => setState(() => _sempre = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  const _Divisor();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 0.5,
    indent: 66,
    color: TatuColors.hairline,
  );
}

/// Linha com o ícone colorido do app, o nome e seta ou ✓.
class LinhaApp extends StatelessWidget {
  const LinhaApp({
    super.key,
    required this.app,
    required this.onTap,
    this.seta = false,
    this.marcado = false,
  }) : _copiar = false;

  const LinhaApp.copiar({super.key, required this.onTap})
    : app = AppNavegacao.perguntar,
      seta = true,
      marcado = false,
      _copiar = true;

  final AppNavegacao app;
  final VoidCallback onTap;
  final bool seta;
  final bool marcado;
  final bool _copiar;

  @override
  Widget build(BuildContext context) {
    final Widget icone;
    if (_copiar || app == AppNavegacao.perguntar) {
      icone = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _copiar ? TatuColors.bg : TatuColors.fill,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _copiar ? TablerIcons.file_text : TablerIcons.help_circle,
          size: 18,
        ),
      );
    } else {
      final (cor, letra) = switch (app) {
        AppNavegacao.waze => (TatuColors.appWaze, 'W'),
        AppNavegacao.apple => (TatuColors.appApple, 'A'),
        _ => (TatuColors.appGoogle, 'G'),
      };
      icone = Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          letra,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TatuColors.onAction,
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      selected: marcado,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                icone,
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _copiar ? 'Copiar endereço' : app.nome,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                if (marcado)
                  const Icon(
                    TablerIcons.check,
                    size: 22,
                    color: TatuColors.verified,
                  )
                else if (seta)
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

/// Preferência "App de navegação" (Perfil do profissional).
class AppNavegacaoPage extends StatelessWidget {
  const AppNavegacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: 'App de navegação',
      fundoCinza: true,
      corpo: ListenableBuilder(
        listenable: navegacao,
        builder: (_, _) => ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Text(
                'Usado quando você toca em “Abrir rota”.',
                style: TatuTexto.detalhe,
              ),
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: TatuColors.bg,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
              ),
              child: Column(
                children: [
                  for (final a in AppNavegacao.values) ...[
                    if (a != AppNavegacao.perguntar) const _Divisor(),
                    LinhaApp(
                      app: a,
                      marcado: navegacao.preferido == a,
                      onTap: () => navegacao.escolher(a),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Localização desligada a caminho do cliente: o cliente acompanha pelo
/// mapa e o "Cheguei" depende dela. Devolve `true` se ativou.
class LocalizacaoCaminhoPage extends StatelessWidget {
  const LocalizacaoCaminhoPage({
    super.key,
    required this.cliente,
    this.feminino = true,
  });

  /// Primeiro nome do cliente ("Ana").
  final String cliente;
  final bool feminino;

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(TablerIcons.map_pin, riscado: true),
      titulo: 'Ative sua localização',
      texto:
          '${feminino ? 'A' : 'O'} $cliente acompanha você pelo mapa,\ne o “Cheguei” depende dela.',
      // Protótipo: "Abrir Ajustes" já liga a localização.
      onPrincipal: () {
        navegacao.ativarLocalizacao();
        Navigator.of(context).pop(true);
      },
      alternativa: 'Agora não',
      onAlternativa: () => Navigator.of(context).pop(false),
    );
  }
}
