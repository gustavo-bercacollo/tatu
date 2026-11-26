import '../../../data/conta.dart';

import 'dart:async';

import '../mensagens/chat_page.dart';
import '../../../data/conversas.dart';

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
import '../../../shared/widgets/tatu_field.dart';
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
                color: _vezes == n
                    ? TatuColors.onAction
                    : TatuColors.textPrimary,
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
            Text('Tornar ${widget.nome} fixa', style: TatuTexto.tituloFolha),
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

/// C218 · RN-210: "Pedir outro valor": o cliente diz quanto quer pagar
/// por visita; o total do período aparece na hora. Devolve o valor.
Future<double?> pedirValorPorVisita(
  BuildContext context,
  PlanoFixo plano, {
  bool novoValor = false,
}) => mostrarFolha<double>(
  context,
  builder: (_) => _FolhaOutroValorPlano(plano, novoValor: novoValor),
);

class _FolhaOutroValorPlano extends StatefulWidget {
  const _FolhaOutroValorPlano(this.plano, {required this.novoValor});

  final PlanoFixo plano;
  final bool novoValor;

  @override
  State<_FolhaOutroValorPlano> createState() => _FolhaOutroValorPlanoState();
}

class _FolhaOutroValorPlanoState extends State<_FolhaOutroValorPlano> {
  final _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  double get _valor => (int.tryParse(soDigitos(_campo.text)) ?? 0).toDouble();

  @override
  Widget build(BuildContext context) {
    final p = widget.plano;
    final n = (widget.novoValor ? p.novoValor : null) ?? p.negociacao;
    final pediu = n.valor ?? 0;
    final visitas = p.visitasNoPeriodo;
    final ela = p.feminino ? 'Ela' : 'Ele';
    final v = _valor;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
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
              const Text('Quanto por visita?', style: TatuTexto.tituloFolha),
              const SizedBox(height: 4),
              Text(
                '${p.feminino ? 'A' : 'O'} ${p.primeiroNome} pode aceitar ou '
                'mandar outro valor.',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              TatuField(
                label: 'Sua proposta por visita',
                controller: _campo,
                autofocus: true,
                hintText: 'R\$ 0',
                keyboardType: TextInputType.number,
                inputFormatters: [ReaisFormatter()],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: TatuMedidas.entreItens),
              // RN-210: o total do período é calculado na hora.
              Text(
                '$visitas visita${visitas == 1 ? '' : 's'} · '
                '${reaisInteiros(v * visitas)} por ${p.periodo}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$ela pediu ${reaisInteiros(pediu)} por visita '
                '(${reaisInteiros(pediu * visitas)} por ${p.periodo}).',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              Text(
                'Proposta ${n.numero + 1} de ${RegrasPlanoFixo.maxPropostas}',
                style: TatuTexto.nota.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: TatuMedidas.entreItens),
              FilledButton(
                onPressed: v > 0 && v != pediu
                    ? () => Navigator.of(context).pop(v)
                    : null,
                child: const Text('Enviar proposta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _maiuscula(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
  StatusPlano.pendente => const SeloVerde(
    'Pendente',
    aviso: true,
    pequeno: true,
  ),
  StatusPlano.pausado => const SeloVerde('Pausado', cinza: true, pequeno: true),
  StatusPlano.cancelado => const SeloVerde(
    'Cancelado',
    cinza: true,
    pequeno: true,
  ),
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

/// Cabeçalho com avatar, nome, detalhe e selo (C216/P132).
class TopoPlano extends StatelessWidget {
  const TopoPlano({
    super.key,
    required this.plano,
    required this.nome,
    required this.detalhe,
    required this.rodape,
    this.acao,
  });

  final PlanoFixo plano;
  final String nome;
  final String detalhe;
  final String rodape;

  /// Botão embaixo do rodapé, na largura do cartão (C216: "Mensagem").
  final Widget? acao;

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
        if (acao != null) ...[
          const SizedBox(height: TatuMedidas.entreItens + 2),
          acao!,
        ],
      ],
    ),
  );
}

/// C216 · RN-146/RN-148: plano fixo do lado do cliente.
class PlanoFixoPage extends StatelessWidget {
  const PlanoFixoPage({super.key, required this.plano, this.doChat = false});

  final PlanoFixo plano;

  /// Aberta pelo chat com a profissional: "Mensagem" só volta para ele.
  final bool doChat;

  /// RN-202: "Mensagem" leva ao chat com a profissional do plano.
  void _mensagem(BuildContext context) {
    final nav = Navigator.of(context);
    if (doChat) {
      nav.pop();
      return;
    }
    final c = conversas.conversas
        .where((c) => c.nome == plano.profissional)
        .firstOrNull;
    if (c == null) return;
    nav.push(MaterialPageRoute(builder: (_) => ChatPage(conversa: c)));
  }

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
              // C216 · RN-202: volta para o chat com a profissional.
              acao: FilledButton.icon(
                style: tatuBotaoSecundario().copyWith(
                  minimumSize: const WidgetStatePropertyAll(
                    Size.fromHeight(TatuMedidas.alturaBotaoCartao),
                  ),
                ),
                onPressed: () => _mensagem(context),
                icon: const Icon(TablerIcons.message_circle, size: 20),
                label: const Text('Mensagem'),
              ),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            Text(p.mensal ? 'ESTE MÊS' : 'ESTA SEMANA', style: TatuTexto.secao),
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
                      if (i > 0) const Divider(height: 0.5, indent: 52),
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

/// Protótipo: o profissional responde com o valor por visita depois disso
/// (nulo nos testes).
Duration? respostaValorPlano = const Duration(seconds: 2);

/// "Tornar Júlia fixa" / "Tornar Carlos fixo".
String textoTornarFixo(String nome, bool feminino) =>
    'Tornar ${nome.split(' ').first} fix${feminino ? 'a' : 'o'}';

/// RN-144/RN-208/RN-209: "Tornar [nome] fixa" fora do chat (segurando a
/// conversa ou no card de Concluídos). Abre a mesma tela de escolha; com
/// plano já existente, abre o plano. Depois do pedido, abre a conversa,
/// onde chega o valor por visita.
Future<void> tornarFixo(
  BuildContext context, {
  required String profissional,
  required String profissao,
  required bool feminino,
  required String endereco,
}) async {
  final nav = Navigator.of(context);
  final conversa = conversas.conversas
      .where((c) => c.nome == profissional)
      .firstOrNull;
  final atual = planosFixos.planoCom(profissional);
  if (atual != null) {
    if (atual.status != StatusPlano.pendente) {
      nav.push(MaterialPageRoute(builder: (_) => PlanoFixoPage(plano: atual)));
    } else if (conversa != null) {
      nav.push(MaterialPageRoute(builder: (_) => ChatPage(conversa: conversa)));
    }
    return;
  }
  final e = await escolherPlano(
    context,
    nome: profissional.split(' ').first,
    feminino: feminino,
  );
  if (e == null || !context.mounted) return;
  final p = planosFixos.pedir(
    cliente: conta.nomeCompleto,
    profissional: profissional,
    endereco: endereco,
    frequencia: e.frequencia,
    visitasPorSemana: e.vezes,
    dias: e.dias,
    horario: e.horario,
    profissao: profissao,
    feminino: feminino,
  );
  // RN-145: passaria de 2 visitas na semana (com os avulsos).
  if (p == null) return mostrarLimiteSemana(context);
  final espera = respostaValorPlano;
  if (espera != null) {
    Timer(espera, () => planosFixos.enviarValor(p, 150));
  }
  if (conversa != null) {
    nav.push(MaterialPageRoute(builder: (_) => ChatPage(conversa: conversa)));
  } else {
    mostrarAvisoTopo(
      context,
      titulo: 'Pedido de plano fixo enviado',
      texto: '${feminino ? 'Ela' : 'Ele'} responde com o valor por visita.',
    );
  }
}
