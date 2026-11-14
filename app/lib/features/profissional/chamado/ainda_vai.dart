import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/prazos.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../cadastro/resultado_page.dart' show abrirHomeProfissional;

/// RN-76/RN-77: folha "Ainda vai até a Ana?" com a contagem de
/// [Prazos.aindaVai]. Devolve `true` (saindo), `false` (não consegue ir)
/// ou `null` (o tempo acabou). Não fecha arrastando nem tocando fora.
Future<bool?> perguntarAindaVai(
  BuildContext context, {
  required String cliente,
  required bool feminino,
}) => mostrarFolha<bool>(
  context,
  fechavel: false,
  builder: (_) => _FolhaAindaVai(cliente: cliente, feminino: feminino),
);

class _FolhaAindaVai extends StatefulWidget {
  const _FolhaAindaVai({required this.cliente, required this.feminino});

  final String cliente;
  final bool feminino;

  @override
  State<_FolhaAindaVai> createState() => _FolhaAindaVaiState();
}

class _FolhaAindaVaiState extends State<_FolhaAindaVai> {
  /// Segundos que faltam (no relógio do app; ver [Prazos.aceleracao]).
  late int _restante = Prazos.aindaVai.inSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = _restante - Prazos.aceleracao;
      if (r <= 0) {
        _timer?.cancel();
        // RN-77: sem resposta, volta à busca.
        Navigator.of(context).pop();
        return;
      }
      setState(() => _restante = r);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _restante ~/ 60;
    final s = (_restante % 60).toString().padLeft(2, '0');
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
            Text(
              'Ainda vai até ${widget.feminino ? 'a' : 'o'} ${widget.cliente}?',
              textAlign: TextAlign.center,
              style: TatuTexto.tituloFolha,
            ),
            const SizedBox(height: 8),
            Text(
              'Você ainda não tocou em “Estou a caminho”.\n'
              'Sem resposta em $m:$s, o chamado volta à busca.',
              textAlign: TextAlign.center,
              style: TatuTexto.corpo,
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sim, estou saindo'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não consigo ir'),
            ),
          ],
        ),
      ),
    );
  }
}

/// RN-77/RN-79: o chamado voltou à busca e contou como abandono.
class ChamadoDevolvidoPage extends StatelessWidget {
  const ChamadoDevolvidoPage({
    super.key,
    this.cliente = 'Ana',
    this.feminino = true,
    this.naoConsegue = false,
  });

  final String cliente;
  final bool feminino;

  /// Tocou "Não consigo ir" (senão, não respondeu a tempo).
  final bool naoConsegue;

  @override
  Widget build(BuildContext context) {
    final p = profissional;
    final n = p.abandonosRecentes;
    final total = Prazos.abandonosParaPausar;
    final dias = Prazos.janelaAbandonos.inDays;
    final a = feminino ? 'a' : 'o';
    final motivo = naoConsegue
        ? 'Você avisou que não consegue ir e $a $cliente'
        : 'Você não confirmou a saída e $a $cliente';
    return TelaPermissao(
      voltar: false,
      aviso: true,
      icone: const Icon(
        TablerIcons.refresh,
        size: 44,
        color: TatuColors.warningTexto,
      ),
      titulo: 'O chamado voltou à busca',
      texto:
          '$motivo\nfoi ${feminino ? 'avisada' : 'avisado'}. '
          'Isso conta como abandono:\n'
          '$n de $total nos últimos $dias dias.'
          '${p.pausadaPorAbandonos ? '\nSua conta foi pausada.' : ''}',
      principal: 'Voltar ao início',
      estiloPrincipal: tatuBotaoSecundario(),
      onPrincipal: () => abrirHomeProfissional(context),
    );
  }
}
