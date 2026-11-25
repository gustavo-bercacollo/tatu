import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/plano_fixo.dart' show diaMes, diaCurto;
import '../../../data/retorno.dart';
import '../../../data/retorno_acoes.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/campo_texto_longo.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/retorno.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../data/conversas_profissional.dart';
import '../../entrada/camera_prova_page.dart';
import '../chamado/chat_profissional_page.dart';

/// P152 a P156 · o retorno no chat do profissional (RN-186 a RN-188).
/// [onOutroValor] abre o novo valor (RN-181) depois da foto no local.
List<Widget> secaoRetornoProfissional(
  BuildContext context,
  PedidoRetorno r, {
  required VoidCallback onOutroValor,
}) {
  final cliente = r.primeiroCliente;
  final a = r.clienteFeminina ? 'a' : 'o';
  SituacaoCartaoRetorno? linha;
  final depois = <Widget>[];
  switch (r.situacao) {
    case SituacaoRetorno.aguardando:
      linha = SituacaoCartaoRetorno(
        TablerIcons.clock,
        'Responda até ${diaHora(r.respondaAte)}',
        TatuColors.warningTexto,
      );
      depois.addAll([
        FilledButton(
          onPressed: () => aceitarRetorno(context, r),
          child: const Text('Aceitar retorno'),
        ),
        const SizedBox(height: 10),
        FilledButton(
          style: tatuBotaoSecundario(),
          onPressed: () => outroProblema(context, r, onOutroValor),
          child: const Text('É outro problema · enviar valor'),
        ),
        const SizedBox(height: 4),
        Center(
          child: LinkAzul(
            'Recusar',
            perigo: true,
            onTap: () => recusarRetorno(context, r),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sem custo e sem taxa. Marque o retorno em até '
          '${RegrasRetorno.marcarEm.inDays} dias.',
          textAlign: TextAlign.center,
          style: TatuTexto.nota,
        ),
      ]);
    case SituacaoRetorno.aceito:
      final m = r.marcadoPara;
      depois.addAll([
        CartaoSituacaoRetorno(
          titulo: 'Retorno aceito · sem custo',
          linha: m == null ? null : quandoRetorno(m),
          nota:
              'Na hora, peça o código à $cliente para começar.\n'
              'Ele aparece na sua Atividade.',
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        FilledButton(
          onPressed: () => digitarCodigoRetorno(context, r),
          child: const Text('Cheguei · digitar o código'),
        ),
        const SizedBox(height: 4),
        Center(
          child: LinkAzul(
            '$cliente não estava',
            onTap: () => clienteNaoEstava(context, r),
          ),
        ),
      ]);
    case SituacaoRetorno.outroProblema:
      linha = SituacaoCartaoRetorno(
        TablerIcons.alert_circle,
        'Você disse que é outro problema',
        TatuColors.warningTexto,
      );
    case SituacaoRetorno.recusado:
      linha = SituacaoCartaoRetorno(
        TablerIcons.x,
        'Recusado: “${r.motivoRecusa!.toLowerCase()}”',
        TatuColors.danger,
      );
    case SituacaoRetorno.feito:
      depois.add(
        CartaoSituacaoRetorno(
          titulo: 'Retorno feito · sem custo',
          nota: 'Esperando $a $cliente dizer se resolveu.',
        ),
      );
    case SituacaoRetorno.cumpridoAusente:
      depois.add(
        CartaoSituacaoRetorno(
          titulo: 'Retorno dado como cumprido',
          nota: '$cliente não estava no horário marcado.',
        ),
      );
    case SituacaoRetorno.resolvidoAutomatico:
      linha = SituacaoCartaoRetorno(
        TablerIcons.x,
        switch (r.falha) {
          FalhaProfissional.naoMarcou =>
            'Você não marcou o retorno em ${RegrasRetorno.marcarEm.inDays} dias',
          FalhaProfissional.naoVeio => 'Você não veio no retorno',
          _ =>
            'Você não respondeu em '
                '${RegrasRetorno.respostaProfissional.inHours} horas',
        },
        TatuColors.danger,
      );
      depois.add(
        CartaoSituacaoRetorno(
          aviso: true,
          titulo: 'Contou 1 falta',
          nota:
              '${reais(RegrasRetorno.devolucao(r.valorServico).doProfissional)}'
              ' descontados dos seus repasses.',
        ),
      );
    case SituacaoRetorno.emMediacao:
      linha = SituacaoCartaoRetorno(
        TablerIcons.shield_check,
        'O Tatu está analisando · até '
            '${diaMes(RegrasRetorno.prazoMediacao(r.mediacaoDesde!))}',
        TatuColors.textSecondary,
      );
    case SituacaoRetorno.encerrado:
      linha = SituacaoCartaoRetorno(
        TablerIcons.check,
        r.decisao == null
            ? 'Encerrado'
            : 'Decisão do Tatu: ${r.decisao!.rotulo.toLowerCase()}',
        TatuColors.onlineTexto,
      );
  }
  return [
    const SizedBox(height: 18),
    CartaoPedidoRetorno(pedido: r, situacao: linha),
    if (depois.isNotEmpty) const SizedBox(height: 18),
    ...depois,
  ];
}

/// P154 · RN-186: aceita e marca dia e hora em até 7 dias.
Future<void> aceitarRetorno(BuildContext context, PedidoRetorno r) async {
  final quando = await escolherQuandoRetorno(context, r);
  if (quando == null) return;
  retornos.aceitar(r, quando);
}

/// Folha "Quando você volta?": dia (próximos 7) e hora.
Future<DateTime?> escolherQuandoRetorno(
  BuildContext context,
  PedidoRetorno r,
) => mostrarFolha<DateTime>(
  context,
  builder: (_) => _FolhaQuando(retorno: r),
);

class _FolhaQuando extends StatefulWidget {
  const _FolhaQuando({required this.retorno});

  final PedidoRetorno retorno;

  @override
  State<_FolhaQuando> createState() => _FolhaQuandoState();
}

class _FolhaQuandoState extends State<_FolhaQuando> {
  static const _horas = [8, 10, 14, 16, 18];
  late final _hoje = clock.now();
  int _dia = 1;
  int _hora = 14;

  @override
  Widget build(BuildContext context) {
    final dias = [
      for (var i = 1; i <= RegrasRetorno.marcarEm.inDays; i++)
        DateTime(_hoje.year, _hoje.month, _hoje.day + i),
    ];
    final escolhido = dias[_dia - 1];
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
            const Text('Quando você volta?', style: TatuTexto.tituloFolha),
            const SizedBox(height: 6),
            Text(
              'Sem custo para ${widget.retorno.oCliente} e sem taxa. Em até '
              '${RegrasRetorno.marcarEm.inDays} dias.',
              style: TatuTexto.corpo,
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text('DIA', style: TatuTexto.secao),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, d) in dias.indexed)
                  TatuChip(
                    label: '${diaCurto(d.weekday)} ${d.day}',
                    selecionado: _dia == i + 1,
                    onTap: () => setState(() => _dia = i + 1),
                  ),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text('HORA', style: TatuTexto.secao),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in _horas)
                  TatuChip(
                    label: '${h}h',
                    selecionado: _hora == h,
                    onTap: () => setState(() => _hora = h),
                  ),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                DateTime(
                  escolhido.year,
                  escolhido.month,
                  escolhido.day,
                  _hora,
                ),
              ),
              child: const Text('Marcar retorno'),
            ),
          ],
        ),
      ),
    );
  }
}

/// P153 · RN-186: motivo obrigatório da recusa.
Future<void> recusarRetorno(BuildContext context, PedidoRetorno r) async {
  final motivo = await mostrarFolha<String>(
    context,
    builder: (_) => _FolhaRecusar(retorno: r),
  );
  if (motivo == null) return;
  retornos.recusar(r, motivo);
}

class _FolhaRecusar extends StatefulWidget {
  const _FolhaRecusar({required this.retorno});

  final PedidoRetorno retorno;

  @override
  State<_FolhaRecusar> createState() => _FolhaRecusarState();
}

class _FolhaRecusarState extends State<_FolhaRecusar> {
  int? _motivo;

  @override
  Widget build(BuildContext context) {
    final r = widget.retorno;
    final m = _motivo;
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
            const Text('Por que vai recusar?', style: TatuTexto.tituloFolha),
            const SizedBox(height: TatuMedidas.entreSecoes),
            for (final (i, motivo) in motivosRecusaRetorno.indexed) ...[
              OpcaoSelecionavel(
                selecionado: m == i,
                rotulo: motivo,
                onTap: () => setState(() => _motivo = i),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: TatuMedidas.alturaBotao,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        BolinhaEscolha(selecionado: m == i),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            motivo,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: TatuMedidas.entreItens),
            CaixaAviso(
              '${r.oCliente[0].toUpperCase()}${r.oCliente.substring(1)} pode '
              'pedir ajuda ao Tatu. Recusar sem motivo conta como falta.',
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            FilledButton(
              style: tatuBotaoPerigo(),
              // RN-186: motivo obrigatório.
              onPressed: m == null
                  ? null
                  : () => Navigator.of(context).pop(motivosRecusaRetorno[m]),
              child: const Text('Recusar retorno'),
            ),
          ],
        ),
      ),
    );
  }
}

/// P155 · RN-186: "É outro problema": foto no local + descrição, depois
/// o novo valor (RN-181).
Future<void> outroProblema(
  BuildContext context,
  PedidoRetorno r,
  VoidCallback onOutroValor,
) async {
  final ok = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => OutroProblemaPage(retorno: r)),
  );
  if (ok == true) onOutroValor();
}

class OutroProblemaPage extends StatefulWidget {
  const OutroProblemaPage({super.key, required this.retorno});

  final PedidoRetorno retorno;

  @override
  State<OutroProblemaPage> createState() => _OutroProblemaPageState();
}

class _OutroProblemaPageState extends State<OutroProblemaPage> {
  final _texto = TextEditingController();
  FotoProva? _foto;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _camera() async {
    final f = await tirarFotoProva(
      context,
      titulo: 'Foto no local',
      aviso: 'Mostre o problema novo',
      texto:
          '${widget.retorno.oCliente[0].toUpperCase()}'
          '${widget.retorno.oCliente.substring(1)} vê a foto com o valor.',
    );
    if (f != null && mounted) setState(() => _foto = f);
  }

  void _continuar() {
    final f = _foto;
    if (f == null) return;
    retornos.outroProblema(widget.retorno, f, _texto.text.trim());
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.retorno.primeiroCliente;
    final a = widget.retorno.clienteFeminina ? 'A' : 'O';
    return CadastroScaffold(
      titulo: 'É outro problema?',
      subtitulo:
          'Tire uma foto no local mostrando o problema novo. $a $cliente vê '
          'a foto com o valor.',
      botao: 'Continuar para o valor',
      // RN-186: a foto no local é obrigatória.
      onBotao: _foto == null || _texto.text.trim().isEmpty ? null : _continuar,
      children: [
        const Text('Foto no local', style: TatuTexto.nota),
        const SizedBox(height: TatuMedidas.entreItens),
        FotosProva(
          fotos: [?_foto],
          onCamera: _camera,
          maximo: 1,
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        CampoTextoLongo(
          controller: _texto,
          hint: 'O que é o problema novo',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        CaixaAviso(
          'Se ${widget.retorno.oCliente} contestar e for o mesmo problema, '
          'conta como falta.',
        ),
      ],
    );
  }
}

/// RN-187: no dia, o cliente passa o código e o retorno começa e
/// termina (o profissional faz o reparo).
Future<void> digitarCodigoRetorno(BuildContext context, PedidoRetorno r) async {
  final controle = TextEditingController();
  final codigo = await mostrarFolha<String>(
    context,
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base + MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: TatuMedidas.entreSecoes),
            Text(
              'Código ${r.clienteFeminina ? 'da' : 'do'} ${r.primeiroCliente}',
              style: TatuTexto.tituloFolha,
            ),
            const SizedBox(height: 6),
            const Text(
              'Peça os 4 números na porta. O retorno começa com o código.',
              style: TatuTexto.corpo,
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            TextField(
              controller: controle,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: const TextStyle(fontSize: 30, letterSpacing: 12),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controle.text),
              child: const Text('Começar retorno'),
            ),
          ],
        ),
      ),
    ),
  );
  controle.dispose();
  if (codigo == null || !context.mounted) return;
  if (!retornos.digitarCodigo(r, codigo)) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Código errado.')));
  }
}

/// RN-187: cliente ausente no dia (depois da espera): dado como cumprido.
Future<void> clienteNaoEstava(BuildContext context, PedidoRetorno r) async {
  final sim = await confirmar(
    context,
    titulo: '${r.primeiroCliente} não estava?',
    texto:
        'Depois de ${RegrasRetorno.esperaNaPorta.inMinutes} min de espera, o '
        'retorno é dado como cumprido.',
    confirmar: 'Dar como cumprido',
    cancelar: 'Continuar esperando',
    destacarCancelar: true,
  );
  if (sim) retornos.clienteAusente(r);
}

/// P157 · RN-185: "R$ 150,00 presos · Retorno da Ana aberto · solta ao
/// resolver" (Ganhos).
class CartaoRepassePreso extends StatelessWidget {
  const CartaoRepassePreso({super.key, required this.profissional});

  final String profissional;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: retornos,
      builder: (context, _) {
        final presos = retornos.presosDe(profissional);
        if (presos <= 0) return const SizedBox.shrink();
        final abertos = retornos.abertosDe(profissional).toList();
        final quem = abertos.length == 1
            ? 'Retorno ${abertos.first.clienteFeminina ? 'da' : 'do'} '
                  '${abertos.first.primeiroCliente} aberto'
            : '${abertos.length} retornos abertos';
        return Padding(
          padding: const EdgeInsets.only(bottom: TatuMedidas.entreItens + 4),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            decoration: BoxDecoration(
              color: TatuColors.bg,
              borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            ),
            child: Row(
              children: [
                const Icon(
                  TablerIcons.lock,
                  size: 24,
                  color: TatuColors.warningTexto,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${reais(presos)} presos',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('$quem · solta ao resolver', style: TatuTexto.nota),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Abre o chat com o cliente do retorno (Atividade → card do retorno).
void abrirChatRetornoProfissional(BuildContext context, PedidoRetorno r) {
  final c = conversasProfissional.conversas
      .where((c) => c.chamado.cliente == r.cliente)
      .firstOrNull;
  if (c == null) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChatProfissionalPage(
        chamado: c.chamado,
        concluidoPor: c.concluidaPor,
        concluidoEm: c.concluidaEm,
        depois: c.depois,
        diaDepois: c.diaDepois,
      ),
    ),
  );
}

/// Confere os prazos do retorno (chamado ao abrir as telas).
void conferirRetornos() => conferirPrazosRetorno();
