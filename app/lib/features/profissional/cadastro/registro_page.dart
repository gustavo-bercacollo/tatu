import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../data/profissoes_reguladas.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../../cliente/ajuda/chat_suporte_page.dart';
import '../../../data/ajuda.dart';

/// Protótipo: a "consulta pública" responde depois deste tempo (nulo nos
/// testes, que conferem na mão).
Duration? demoConferencia = const Duration(seconds: 4);

/// P06 · RN-156: "Registro profissional": conselho já preenchido, estado
/// e número. Sem foto. Na CNH com RG na verificação, só o número.
class RegistroProfissionalPage extends StatefulWidget {
  const RegistroProfissionalPage({
    super.key,
    required this.profissao,
    required this.onEnviar,
    this.passo = 2,
  });

  final String profissao;
  final VoidCallback onEnviar;

  /// Nulo fora do cadastro (ex.: pelo Perfil).
  final int? passo;

  @override
  State<RegistroProfissionalPage> createState() =>
      _RegistroProfissionalPageState();
}

class _RegistroProfissionalPageState extends State<RegistroProfissionalPage> {
  late final RegistroProfissional? _atual =
      profissional.registros[widget.profissao];
  late final ProfissaoTatu? _info = profissoesReguladas.porNome(
    widget.profissao,
  );
  late String _uf = _atual?.uf == 'BR' ? 'SP' : (_atual?.uf ?? 'SP');
  late final _numero = TextEditingController(text: _atual?.numero ?? '');

  String get _conselho => _info?.conselho ?? _atual?.conselho ?? '';
  bool get _cnh => _info?.usaCnh ?? false;

  @override
  void dispose() {
    _numero.dispose();
    super.dispose();
  }

  Future<void> _estado() async {
    final uf = await mostrarFolha<String>(
      context,
      alturaRelativa: 0.6,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        children: [
          const AlcaFolha(),
          const SizedBox(height: TatuMedidas.entreItens),
          const Text('Estado', style: TatuTexto.tituloFolha),
          for (final u in RegrasRegistro.ufs)
            ListTile(
              title: Text(u, style: const TextStyle(fontSize: 17)),
              trailing: u == _uf ? const Icon(TablerIcons.check) : null,
              onTap: () => Navigator.of(ctx).pop(u),
            ),
        ],
      ),
    );
    if (uf != null) setState(() => _uf = uf);
  }

  void _enviar() {
    final p = widget.profissao;
    if (_atual != null) {
      profissional.corrigirRegistro(p, uf: _cnh ? 'BR' : _uf, numero: _numero.text);
    } else {
      profissional.enviarRegistro(
        profissao: p,
        conselho: _conselho,
        uf: _cnh ? 'BR' : _uf,
        numero: _numero.text,
      );
    }
    // RN-157: protótipo: a consulta pública responde sozinha.
    final espera = demoConferencia;
    if (espera != null) {
      Timer(espera, () => profissional.conferirRegistro(p));
    }
    widget.onEnviar();
  }

  @override
  Widget build(BuildContext context) => CadastroScaffold(
    passo: widget.passo,
    titulo: 'Registro profissional',
    subtitulo: _cnh
        ? '${widget.profissao} exige CNH. Seu documento da verificação foi '
              'o RG: informe só o número da CNH.'
        : '${widget.profissao} exige registro no $_conselho.\n'
              'Conferimos na consulta pública. Sem foto.',
    botao: 'Enviar registro',
    onBotao: _numero.text.trim().length >= 3 ? _enviar : null,
    children: [
      const SizedBox(height: TatuMedidas.entreItens),
      TatuField(
        label: 'Conselho',
        controller: TextEditingController(text: _cnh ? 'CNH' : _conselho),
        readOnly: true,
      ),
      const SizedBox(height: TatuMedidas.entreItens),
      Row(
        children: [
          if (!_cnh) ...[
            SizedBox(
              width: 110,
              child: GestureDetector(
                onTap: _estado,
                child: AbsorbPointer(
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TatuField(
                        label: 'Estado',
                        controller: TextEditingController(text: _uf),
                        readOnly: true,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 14),
                        child: Icon(
                          TablerIcons.chevron_down,
                          size: 16,
                          color: TatuColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TatuField(
              label: _cnh ? 'Número da CNH' : 'Número do registro',
              controller: _numero,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
      const SizedBox(height: TatuMedidas.entreItens),
      const Text(
        // RN-157.
        'O nome do registro precisa ser o mesmo\ndo seu documento.',
        style: TatuTexto.nota,
      ),
      const SizedBox(height: TatuMedidas.entreSecoes + 8),
      const NotaIcone(
        icone: TablerIcons.clock,
        texto:
            'Até conferir, essa profissão fica em análise.\n'
            'As outras já podem receber chamados.',
      ),
    ],
  );
}

/// P09 · RN-158: registro não encontrado (ou com nome diferente do
/// documento): corrigir ou falar com o suporte.
class RegistroNaoEncontradoPage extends StatelessWidget {
  const RegistroNaoEncontradoPage({super.key, required this.profissao});

  final String profissao;

  @override
  Widget build(BuildContext context) {
    final r = profissional.registros[profissao];
    final rotulo = r?.rotulo ?? profissao;
    final nomeDiferente = r?.motivo == 'nome diferente do documento';
    return TelaPermissao(
      aviso: true,
      icone: const IconePermissao(
        TablerIcons.alert_triangle,
        cor: TatuColors.warningTexto,
      ),
      titulo: 'Não encontramos seu registro',
      texto: nomeDiferente
          ? 'Achamos $rotulo, mas o nome não é o\n'
                'mesmo do seu documento.\nConfira o número e o estado.'
          : 'Procuramos $rotulo na consulta\n'
                'pública do conselho e não achamos.\n'
                'Confira o número e o estado.',
      extra: const Text(
        'As outras profissões continuam ativas.',
        textAlign: TextAlign.center,
        style: TatuTexto.nota,
      ),
      principal: 'Corrigir registro',
      onPrincipal: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => RegistroProfissionalPage(
            profissao: profissao,
            passo: null,
            onEnviar: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
      alternativa: 'Falar com o suporte',
      onAlternativa: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ChatSuportePage(conteudo: conteudoProfissional),
        ),
      ),
    );
  }
}

/// P08/P10 · RN-157/RN-159: selo do registro no cartão da profissão.
class SeloRegistro extends StatelessWidget {
  const SeloRegistro({super.key, required this.registro, this.onTap});

  final RegistroProfissional registro;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = registro;
    final (texto, icone, fundo, cor) = switch (r.status) {
      StatusRegistro.emAnalise when r.faltaNumero => (
        'Informe o número da CNH',
        TablerIcons.id,
        TatuColors.warningSoft,
        TatuColors.warningTexto,
      ),
      StatusRegistro.emAnalise => (
        'Registro em análise · ${r.conselho}',
        TablerIcons.clock,
        TatuColors.warningSoft,
        TatuColors.warningTexto,
      ),
      StatusRegistro.conferido => (
        'Registro conferido · ${r.rotulo}',
        TablerIcons.circle_check,
        TatuColors.onlineSoft,
        TatuColors.onlineTexto,
      ),
      StatusRegistro.naoEncontrado => (
        'Registro não encontrado',
        TablerIcons.alert_triangle,
        TatuColors.dangerSoft,
        TatuColors.danger,
      ),
      StatusRegistro.suspenso => (
        'Registro ${r.motivo ?? 'suspenso'} · profissão pausada',
        TablerIcons.player_pause,
        TatuColors.dangerSoft,
        TatuColors.danger,
      ),
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 14, color: cor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
