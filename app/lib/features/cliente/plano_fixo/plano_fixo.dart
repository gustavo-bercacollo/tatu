import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/plano_fixo.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/segmento.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../../shared/widgets/nota_icone.dart';

/// Escolhas da folha "Tornar [nome] fixa" (RN-144).
@immutable
class EscolhaPlano {
  const EscolhaPlano({
    required this.frequencia,
    required this.vezes,
    required this.dias,
    required this.horario,
  });

  final FrequenciaPlano frequencia;
  final int vezes;
  final List<int> dias;
  final String horario;
}

/// C195 · RN-144: "Tornar Luiza fixa": Mensal ou Semanal, 1 ou 2 vezes
/// por semana, dia(s) e horário.
Future<EscolhaPlano?> escolherPlano(
  BuildContext context, {
  required String nome,
  required bool feminino,
}) => mostrarFolha<EscolhaPlano>(
  context,
  builder: (_) => _FolhaTornarFixo(nome: nome, feminino: feminino),
);

class _FolhaTornarFixo extends StatefulWidget {
  const _FolhaTornarFixo({required this.nome, required this.feminino});

  final String nome;
  final bool feminino;

  @override
  State<_FolhaTornarFixo> createState() => _FolhaTornarFixoState();
}

class _FolhaTornarFixoState extends State<_FolhaTornarFixo> {
  var _frequencia = FrequenciaPlano.mensal;
  var _vezes = 1;
  final _dias = <int>[2];
  var _hora = const TimeOfDay(hour: 9, minute: 0);

  String get _horario =>
      '${_hora.hour}:${_hora.minute.toString().padLeft(2, '0')}';

  void _tocarDia(int d) => setState(() {
    if (_dias.contains(d)) {
      _dias.remove(d);
    } else {
      // Com 1 vez, trocar o dia; com 2, até 2 dias (RN-145).
      if (_dias.length >= _vezes) _dias.removeAt(0);
      _dias.add(d);
    }
  });

  Future<void> _escolherHora() async {
    final h = await showTimePicker(context: context, initialTime: _hora);
    if (h != null) setState(() => _hora = h);
  }

  @override
  Widget build(BuildContext context) {
    final pronto = _dias.length == _vezes;
    Widget vezes(int n) => Expanded(
      child: Semantics(
        button: true,
        selected: _vezes == n,
        child: GestureDetector(
          onTap: () => setState(() {
            _vezes = n;
            while (_dias.length > n) {
              _dias.removeAt(0);
            }
          }),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _vezes == n ? TatuColors.action : TatuColors.fill,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              n == 1 ? '1 vez' : '2 vezes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _vezes == n ? TatuColors.onAction : TatuColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margemCadastro,
          10,
          TatuMedidas.margemCadastro,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 22),
            Text(
              'Tornar ${widget.nome} fixa',
              style: TatuTexto.tituloFolha,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.feminino ? 'Ela' : 'Ele'} vem sempre no mesmo dia, '
              'sem pedir de novo.',
              style: TatuTexto.nota,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            Segmento(
              opcoes: const ['Mensal', 'Semanal'],
              selecionada: _frequencia == FrequenciaPlano.mensal ? 0 : 1,
              onMudar: (i) => setState(
                () => _frequencia = i == 0
                    ? FrequenciaPlano.mensal
                    : FrequenciaPlano.semanal,
              ),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text('Quantas vezes por semana?', style: TatuTexto.grupo),
            const SizedBox(height: 10),
            Row(spacing: 10, children: [vezes(1), vezes(2)]),
            const SizedBox(height: TatuMedidas.entreSecoes),
            Text(
              _vezes == 1 ? 'Qual dia?' : 'Quais dias?',
              style: TatuTexto.grupo,
            ),
            const SizedBox(height: 10),
            Row(
              spacing: 8,
              children: [
                for (var d = 1; d <= 6; d++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: _dias.contains(d),
                      child: GestureDetector(
                        onTap: () => _tocarDia(d),
                        child: Container(
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _dias.contains(d)
                                ? TatuColors.action
                                : TatuColors.fill,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Text(
                            diaCurto(d),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _dias.contains(d)
                                  ? TatuColors.onAction
                                  : TatuColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            Semantics(
              button: true,
              label: 'Horário, $_horario',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: _escolherHora,
                child: Container(
                  height: TatuMedidas.alturaBusca + 8,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: TatuColors.fill,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Horário', style: TatuTexto.detalhe),
                      ),
                      Text(
                        _horario,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            // RN-145: o limite legal aparece já na escolha.
            Text(
              'Pelo Tatu, a mesma profissional vem até '
              '${RegrasPlanoFixo.maxVisitasSemana} vezes por semana.',
              style: TatuTexto.legenda,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            FilledButton(
              onPressed: pronto
                  ? () => Navigator.of(context).pop(
                      EscolhaPlano(
                        frequencia: _frequencia,
                        vezes: _vezes,
                        dias: [..._dias]..sort(),
                        horario: _horario,
                      ),
                    )
                  : null,
              child: Text('Pedir valor à ${widget.nome}'),
            ),
          ],
        ),
      ),
    );
  }
}

/// C198 · RN-145: a 3ª visita na semana é bloqueada.
Future<void> mostrarLimiteSemana(BuildContext context) => mostrarFolha<void>(
  context,
  builder: (ctx) => SafeArea(
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
          const Center(
            child: IconeResultado(
              TablerIcons.calendar,
              cor: TatuColors.warningTexto,
              fundo: TatuColors.warningSoft,
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          Text(
            'Até ${RegrasPlanoFixo.maxVisitasSemana} visitas por semana',
            textAlign: TextAlign.center,
            style: TatuTexto.tituloFolha,
          ),
          const SizedBox(height: 8),
          const Text(
            RegrasPlanoFixo.avisoLimite,
            textAlign: TextAlign.center,
            style: TatuTexto.corpo,
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 8),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    ),
  ),
);

/// C196 · RN-144/RN-146: o valor do plano chegou no chat.
class CartaoPropostaPlano extends StatelessWidget {
  const CartaoPropostaPlano({
    super.key,
    required this.plano,
    required this.onConfirmar,
    required this.onOutroValor,
    required this.onTrocarCartao,
  });

  final PlanoFixo plano;
  final VoidCallback onConfirmar;
  final VoidCallback onOutroValor;
  final VoidCallback onTrocarCartao;

  @override
  Widget build(BuildContext context) {
    final p = plano;
    final cartao = p.cartao ?? 'Visa final 4242';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${p.primeiroNome} enviou o valor do plano',
          textAlign: TextAlign.center,
          style: TatuTexto.legenda,
        ),
        const SizedBox(height: 10),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.91,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
              border: Border.all(color: TatuColors.action, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Plano fixo · ${p.mensal ? 'Mensal' : 'Semanal'}',
                  style: TatuTexto.nota,
                ),
                const SizedBox(height: 6),
                Text(
                  '${reaisInteiros(p.valorDoPeriodo)} por ${p.periodo}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TatuColors.surfaceGrouped,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_maiuscula(p.quando)} · ${p.visitasNoPeriodo} '
                        'visita${p.visitasNoPeriodo == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reaisInteiros(p.valorPorVisita!)} por visita',
                        style: TatuTexto.nota,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                Text(
                  // RN-146: cobrança automática, só pelo que foi feito.
                  'Cobrado no fim de cada ${p.periodo},\n'
                  'só pelas visitas feitas.',
                  style: TatuTexto.legenda,
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: TatuColors.surfaceGrouped,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
                  ),
                  child: Row(
                    children: [
                      const Icon(TablerIcons.credit_card, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cartao,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      GestureDetector(
                        onTap: onTrocarCartao,
                        child: const Text(
                          'Trocar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TatuColors.verified,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                SizedBox(
                  height: TatuMedidas.alturaBotaoCartao,
                  child: FilledButton(
                    onPressed: onConfirmar,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        TatuMedidas.alturaBotaoCartao,
                      ),
                    ),
                    child: const Text('Confirmar plano'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        Center(
          child: TextButton(
            onPressed: onOutroValor,
            child: const Text(
              'Pedir outro valor',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TatuColors.verified,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _maiuscula(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "Terça, 25 nov · 9h".
String visitaTexto(PlanoFixo p, VisitaPlano v) =>
    '${_maiuscula(diaLongo(v.dia.weekday))}, ${diaMes(v.dia)} · '
    '${horaCurta(p.horario)}';

/// Selo do plano (Ativo, Pendente, Pausado…).
Widget seloPlano(PlanoFixo p) => switch (p.status) {
  StatusPlano.ativo when p.noProximoPeriodo != null => SeloVerde(
    p.noProximoPeriodo == StatusPlano.pausado
        ? 'Pausa no próximo ${p.periodo}'
        : 'Termina no fim do ${p.periodo}',
    aviso: true,
    pequeno: true,
  ),
  StatusPlano.ativo => const SeloVerde('Ativo', pequeno: true),
  StatusPlano.pendente => const SeloVerde('Pendente', aviso: true, pequeno: true),
  StatusPlano.pausado => const SeloVerde('Pausado', cinza: true, pequeno: true),
  StatusPlano.cancelado => const SeloVerde('Cancelado', cinza: true, pequeno: true),
};

/// Cartão branco das telas do plano.
class CartaoPlano extends StatelessWidget {
  const CartaoPlano({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: child,
  );
}

/// Cabeçalho com avatar, nome, detalhe e selo (C197/P132).
class TopoPlano extends StatelessWidget {
  const TopoPlano({
    super.key,
    required this.plano,
    required this.nome,
    required this.detalhe,
    required this.rodape,
  });

  final PlanoFixo plano;
  final String nome;
  final String detalhe;
  final String rodape;

  @override
  Widget build(BuildContext context) => CartaoPlano(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AvatarIniciais(nome: nome, tamanho: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(detalhe, style: TatuTexto.nota),
                ],
              ),
            ),
            seloPlano(plano),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Text(rodape, style: TatuTexto.nota),
      ],
    ),
  );
}

/// C197 · RN-146/RN-148: plano fixo do lado do cliente.
class PlanoFixoPage extends StatelessWidget {
  const PlanoFixoPage({super.key, required this.plano});

  final PlanoFixo plano;

  Future<void> _mudar(BuildContext context, {required bool cancelar}) async {
    final p = plano;
    final sim = await confirmar(
      context,
      titulo: cancelar ? 'Cancelar o plano?' : 'Pausar o plano?',
      texto:
          'Vale a partir do próximo ${p.periodo}. As visitas deste '
          '${p.periodo} continuam.',
      confirmar: cancelar ? 'Cancelar plano' : 'Pausar plano',
      cancelar: 'Voltar',
      perigo: cancelar,
      destacarCancelar: true,
    );
    if (!sim || !context.mounted) return;
    cancelar ? planosFixos.cancelar(p) : planosFixos.pausar(p);
    mostrarAvisoTopo(
      context,
      titulo: cancelar ? 'Plano cancelado' : 'Plano pausado',
      texto: 'A partir do próximo ${p.periodo}.',
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: planosFixos,
    builder: (context, _) {
      final p = plano;
      final porVisita = reaisInteiros(p.valorPorVisita ?? 0);
      final cobranca = p.proximaCobranca;
      final mudou = p.noProximoPeriodo != null;
      return TelaInterna(
        titulo: 'Plano fixo',
        fundoCinza: true,
        corpo: ListView(
          padding: const EdgeInsets.only(top: TatuMedidas.entreItens),
          children: [
            TopoPlano(
              plano: p,
              nome: p.profissional,
              detalhe: '${p.profissao} · ${p.quando}',
              rodape: '$porVisita por visita · cobrado no fim do ${p.periodo}',
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            Text(
              p.mensal ? 'ESTE MÊS' : 'ESTA SEMANA',
              style: TatuTexto.secao,
            ),
            const SizedBox(height: TatuMedidas.tituloSecao),
            CartaoPlano(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${p.feitas} de ${p.visitasNoPeriodo} visitas feitas',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.visitasNoPeriodo == 0
                          ? 0
                          : p.feitas / p.visitasNoPeriodo,
                      minHeight: 8,
                      backgroundColor: TatuColors.trilho,
                      color: TatuColors.action,
                    ),
                  ),
                  if (cobranca != null) ...[
                    const SizedBox(height: TatuMedidas.entreItens),
                    Text(
                      // RN-146: no fim do período, só pelo que foi feito.
                      'Próxima cobrança: ${diaMes(cobranca)} · até '
                      '${reaisInteiros(p.valorDoPeriodo)}',
                      style: TatuTexto.nota,
                    ),
                  ],
                ],
              ),
            ),
            if (p.proximas.isNotEmpty) ...[
              const SizedBox(height: TatuMedidas.entreSecoes),
              const Text('PRÓXIMAS VISITAS', style: TatuTexto.secao),
              const SizedBox(height: TatuMedidas.tituloSecao),
              CartaoPlano(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final (i, v) in p.proximas.take(3).indexed) ...[
                      if (i > 0)
                        const Divider(height: 0.5, indent: 52),
                      SizedBox(
                        height: TatuMedidas.alturaLinha - 8,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(TablerIcons.clock, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                visitaTexto(p, v),
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                            const Icon(
                              TablerIcons.chevron_right,
                              size: 16,
                              color: TatuColors.chevron,
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: TatuMedidas.entreSecoes + 16),
            if (p.status == StatusPlano.ativo && !mudou) ...[
              FilledButton(
                style: botaoBranco(),
                onPressed: () => _mudar(context, cancelar: false),
                child: const Text('Pausar plano'),
              ),
              const SizedBox(height: TatuMedidas.entreItens),
            ],
            if (p.status != StatusPlano.cancelado &&
                p.noProximoPeriodo != StatusPlano.cancelado) ...[
              Center(
                child: TextButton(
                  onPressed: () => _mudar(context, cancelar: true),
                  child: const Text(
                    'Cancelar plano',
                    style: TextStyle(fontSize: 17, color: TatuColors.danger),
                  ),
                ),
              ),
              Text(
                // RN-148.
                'Vale a partir do próximo ${p.periodo}.',
                textAlign: TextAlign.center,
                style: TatuTexto.legenda,
              ),
            ],
            const SizedBox(height: TatuMedidas.base),
          ],
        ),
      );
    },
  );
}

/// Botão secundário branco (fundo cinza da tela).
ButtonStyle botaoBranco() => tatuBotaoSecundario().copyWith(
  backgroundColor: const WidgetStatePropertyAll(TatuColors.bg),
);
