import 'dart:async';

import 'package:flutter/material.dart';

import 'package:clock/clock.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../data/atendimento_profissional.dart';
import '../../../data/prazos.dart';
import '../../../data/regras_distancia.dart';
import '../../../data/regras_valor.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/navegacao.dart';
import '../../../data/profissional.dart';
import '../../../data/seguranca.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import 'rota.dart';
import '../../entrada/seguranca.dart';

void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text('$o: em breve')));

/// P24 · A caminho do cliente: rota no mapa, endereço, "Abrir rota" e
/// "Cheguei", que só libera perto do local (protótipo: depois de
/// [chegaEm]) e com a localização ligada. Perto, vira "Quase lá" com o
/// aviso no topo. Depois do "Cheguei": "Aguardando a Ana" com a espera
/// de [Prazos.esperaCliente] (RN-80) e "Cliente não apareceu" (RN-81).
class ACaminhoPage extends StatefulWidget {
  const ACaminhoPage({
    super.key,
    this.servico = servicoExemplo,
    this.chegaEm = const Duration(seconds: 5),
    this.perto = false,
    this.chegou = false,
    this.esperou = Duration.zero,
  });

  /// Com [chegou]: quanto da espera já passou (fluxograma e testes).
  final Duration esperou;

  final ServicoAceito servico;
  final Duration chegaEm;

  /// Abre já perto do local (fluxograma e testes).
  final bool perto;

  /// Abre já no local (para o fluxograma e testes).
  final bool chegou;

  @override
  State<ACaminhoPage> createState() => _ACaminhoPageState();
}

class _ACaminhoPageState extends State<ACaminhoPage> {
  late bool _perto = widget.perto || widget.chegou;
  late bool _chegou = widget.chegou;
  Timer? _timer;

  /// RN-80: quando tocou em "Cheguei" (começa a espera).
  DateTime? _chegouEm;
  Timer? _relogioEspera;

  @override
  void initState() {
    super.initState();
    if (widget.chegou) _comecarEspera(widget.esperou);
    if (!_perto) {
      _timer = Timer(widget.chegaEm, () {
        if (mounted) setState(() => _perto = true);
      });
    }
    // Atendimento novo: o alerta do anterior não continua.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => seguranca.encerrarAlerta(cliente: false),
    );
    if (!navegacao.localizacaoAtiva) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pedirLocalizacao());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _relogioEspera?.cancel();
    super.dispose();
  }

  /// RN-80: começa a contar a espera pelo cliente. Protótipo: o relógio
  /// anda [Prazos.aceleracao] vezes mais rápido.
  void _comecarEspera([Duration jaPassou = Duration.zero]) {
    _chegouEm = clock.now().subtract(jaPassou ~/ Prazos.aceleracao);
    _relogioEspera?.cancel();
    _relogioEspera = Timer.periodic(const Duration(milliseconds: 250), (t) {
      if (!mounted) return t.cancel();
      setState(() {});
      if (_restante == Duration.zero) t.cancel();
    });
  }

  /// Quanto falta da espera (zero quando acabou).
  Duration get _restante {
    final c = _chegouEm;
    if (c == null) return Prazos.esperaCliente;
    final r =
        Prazos.esperaCliente - clock.now().difference(c) * Prazos.aceleracao;
    return r.isNegative ? Duration.zero : r;
  }

  /// RN-81: a espera acabou e o cliente não apareceu: encerra o chamado
  /// e recebe só a visita. Não conta como visita sem serviço (RN-63):
  /// a ausência é do cliente (RN-82).
  Future<void> _clienteNaoApareceu() async {
    final s = widget.servico;
    final a = s.feminino ? 'A' : 'O';
    final visita = reais(s.visita);
    final sim = await confirmar(
      context,
      titulo: '$a ${s.primeiroNome} não apareceu?',
      texto:
          'Você encerra o chamado e recebe a visita.\n'
          '$a ${s.primeiroNome} é ${s.feminino ? 'cobrada' : 'cobrado'} $visita.',
      confirmar: 'Encerrar e receber a visita',
      cancelar: 'Esperar mais',
      iconeAviso: false,
    );
    if (!sim || !mounted) return;
    atendimentoProfissional.encerrar();
    mostrarAvisoTopo(
      context,
      titulo: 'Visita recebida',
      texto: '$a ${s.primeiroNome} pagou $visita pela visita.',
    );
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _pedirLocalizacao() async {
    if (!mounted) return;
    final s = widget.servico;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocalizacaoCaminhoPage(
          cliente: s.primeiroNome,
          feminino: s.feminino,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.servico;
    final localizacao = navegacao.localizacaoAtiva;
    final perto = _perto && localizacao && !_chegou;
    final daCliente = '${s.feminino ? 'da' : 'do'} ${s.primeiroNome}';
    final km = s.distanciaKm.toStringAsFixed(1).replaceAll('.', ',');
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const MapaFalso(),
              foregroundPainter: _chegou ? _NoLocal() : _Rota(perto: perto),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Semantics(
                      button: true,
                      label: 'Voltar',
                      child: Material(
                        color: TatuColors.bg,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(TablerIcons.chevron_left, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (perto) ...[
                    const SizedBox(height: 8),
                    AvisoEscuro(
                      icone: const Icon(
                        TablerIcons.map_pin,
                        color: TatuColors.onAction,
                        size: 22,
                      ),
                      titulo: 'Você chegou perto $daCliente',
                      texto:
                          'Toque em “Cheguei” para avisá-${s.feminino ? 'la' : 'lo'}.',
                    ),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: TatuMedidas.larguraMax,
              ),
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
                      const SizedBox(height: 16),
                      if (_chegou) ...[
                        ..._aguardando(s),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: () {
                            final agora = DateTime.now();
                            atendimentoProfissional.iniciar(agora);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EmAndamentoPage(servico: s, inicio: agora),
                              ),
                            );
                          },
                          child: const Text('Iniciar serviço'),
                        ),
                        const SizedBox(height: 10),
                        // RN-81: só depois da espera.
                        FilledButton(
                          style: tatuBotaoSecundario(),
                          onPressed: _restante == Duration.zero
                              ? _clienteNaoApareceu
                              : null,
                          child: const Text('Cliente não apareceu'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _restante == Duration.zero
                              ? 'A espera acabou.'
                              : 'Libera depois de '
                                    '${Prazos.esperaCliente.inMinutes} min '
                                    'de espera.',
                          textAlign: TextAlign.center,
                          style: TatuTexto.nota,
                        ),
                      ] else ...[
                        Text(
                          perto ? 'Quase lá' : 'A caminho $daCliente',
                          style: TatuTexto.tituloFolha,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          perto
                              ? '200 m $daCliente'
                              : 'Chegada em ${s.minutos} min · $km km',
                          style: TatuTexto.detalhe,
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        CartaoEndereco(servico: s),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        FilledButton(
                          style: tatuBotaoSecundario(),
                          onPressed: () => abrirRota(context, s),
                          child: const Text('Abrir rota'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          style: perto ? null : tatuBotaoSecundario(),
                          onPressed: perto
                              ? () {
                                  atendimentoProfissional.chegou();
                                  _comecarEspera();
                                  setState(() => _chegou = true);
                                }
                              : null,
                          child: const Text('Cheguei'),
                        ),
                        const SizedBox(height: 10),
                        if (!localizacao)
                          Center(
                            child: LinkAzul(
                              'Ativar localização',
                              onTap: _pedirLocalizacao,
                            ),
                          )
                        else
                          Text(
                            perto
                                ? 'Toque quando estiver na porta.'
                                : '“Cheguei” libera quando você estiver perto.',
                            textAlign: TextAlign.center,
                            style: TatuTexto.nota,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// RN-80: "Aguardando a Ana" com o tempo de espera.
  List<Widget> _aguardando(ServicoAceito s) {
    final c = _chegouEm ?? clock.now();
    final hora =
        '${c.hour.toString().padLeft(2, '0')}:'
        '${c.minute.toString().padLeft(2, '0')}';
    final r = _restante;
    final acabou = r == Duration.zero;
    final tempo =
        '${r.inMinutes}:${(r.inSeconds % 60).toString().padLeft(2, '0')}';
    final passou = 1 - r.inMilliseconds / Prazos.esperaCliente.inMilliseconds;
    return [
      Text(
        'Aguardando ${s.feminino ? 'a' : 'o'} ${s.primeiroNome}',
        style: TatuTexto.tituloFolha,
      ),
      const SizedBox(height: 4),
      Text(
        'Você chegou às $hora · ${s.feminino ? 'ela' : 'ele'} foi '
        '${s.feminino ? 'avisada' : 'avisado'}',
        style: TatuTexto.detalhe,
      ),
      const SizedBox(height: TatuMedidas.entreItens + 4),
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: TatuColors.fill,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tempo de espera',
                    style: TatuTexto.nota.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  tempo,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: acabou ? TatuColors.danger : TatuColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: passou.clamp(0, 1).toDouble(),
                minHeight: 6,
                backgroundColor: TatuColors.circle,
                color: acabou ? TatuColors.danger : TatuColors.action,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: TatuMedidas.entreItens + 4),
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              style: tatuBotaoSecundario(),
              onPressed: () => _emBreve(context, 'Mensagem'),
              icon: const Icon(TablerIcons.message_circle, size: 20),
              label: const Text('Mensagem'),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: FilledButton.icon(
              style: tatuBotaoSecundario(),
              onPressed: () => _emBreve(context, 'Ligar'),
              icon: const Icon(TablerIcons.phone, size: 20),
              label: const Text('Ligar'),
            ),
          ),
        ],
      ),
    ];
  }
}

/// P25 · Serviço em andamento: cliente, valor, início, escudo de
/// segurança no topo e "Concluir e cobrar". À distância (P111): sem
/// escudo (RN-98), sem visita e com "Enviar a entrega" (RN-96).
class EmAndamentoPage extends StatelessWidget {
  const EmAndamentoPage({
    super.key,
    this.servico = servicoExemplo,
    required this.inicio,
  });

  final ServicoAceito servico;
  final DateTime inicio;

  /// Fecha o atendimento e volta para a Home com o aviso no topo.
  void _encerrar(
    BuildContext context, {
    required bool semServico,
    required String titulo,
    required String texto,
  }) {
    profissional.registrarVisita(semServico: semServico);
    atendimentoProfissional.encerrar();
    // O aviso fica no Overlay raiz e continua na Home.
    mostrarAvisoTopo(context, titulo: titulo, texto: texto);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  /// Conclui: o cliente é cobrado do valor combinado.
  void _concluir(BuildContext context) {
    final s = servico;
    _encerrar(
      context,
      semServico: false,
      titulo: 'Serviço concluído',
      texto:
          '${s.cliente.split(' ').first} pagou ${reais(s.valor)}. '
          'Cai no seu Pix em até 1 dia útil.',
    );
  }

  /// Encerra sem serviço: só a visita é cobrada.
  Future<void> _soVisita(BuildContext context) async {
    final s = servico;
    final nome = s.cliente.split(' ').first;
    final visita = reaisInteiros(s.visita);
    final sim = await confirmar(
      context,
      titulo: 'Encerrar e cobrar só a visita?',
      texto:
          '${s.feminino ? 'A' : 'O'} $nome paga $visita pela visita. '
          'O serviço não é cobrado. Isso fica no seu histórico.',
      aviso: 'Muitas visitas sem serviço pausam sua conta.',
      confirmar: 'Encerrar e cobrar $visita',
      cancelar: 'Voltar',
      esquerda: true,
    );
    if (!sim || !context.mounted) return;
    _encerrar(
      context,
      semServico: true,
      titulo: 'Visita cobrada',
      texto: '$nome pagou ${reais(s.visita)} pela visita.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = servico;
    final hora =
        '${inicio.hour.toString().padLeft(2, '0')}:'
        '${inicio.minute.toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: TatuColors.surfaceGrouped,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BackCircleButton(),
                        ),
                        const Text(
                          'Em andamento',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // RN-98: à distância ninguém vai até ninguém.
                        if (!s.distancia)
                          Align(
                            alignment: Alignment.centerRight,
                            child: BotaoEscudo(
                              servico: Atendimento.doServico(
                                s,
                                chegouAs: hora,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: seguranca,
                    builder: (_, _) => seguranca.alertaProfissional
                        ? const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Center(child: SeloAlertaAtivo()),
                          )
                        : const SizedBox(height: 10),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 10),
                      children: [
                        // RN-89: valor aberto há mais de 7 dias.
                        if (RegrasValor.vencido(inicio, DateTime.now())) ...[
                          const CaixaAviso(
                            'Este valor está aberto há mais de 7 dias. '
                            'Conclua o serviço ou divida o trabalho em partes, '
                            'com um novo valor para cada uma.',
                          ),
                          const SizedBox(height: TatuMedidas.entreItens),
                        ],
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                          decoration: BoxDecoration(
                            color: TatuColors.bg,
                            borderRadius: BorderRadius.circular(
                              TatuMedidas.raioOpcao,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  AvatarIniciais(nome: s.cliente, tamanho: 44),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.cliente,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${s.descricao} · ${reais(s.valor)}',
                                          style: TatuTexto.detalhe,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(
                                height: 1,
                                color: TatuColors.hairline,
                              ),
                              const SizedBox(height: 16),
                              if (s.distancia)
                                // RN-101/RN-103: sinal e entregas.
                                ListenableBuilder(
                                  listenable: atendimentoProfissional,
                                  builder: (_, _) {
                                    final a = atendimentoProfissional;
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            s.sinal > 0
                                                ? 'Sinal ${reaisInteiros(s.sinal)} · '
                                                      '${a.sinalLiberado ? 'liberado' : 'sai na 1ª entrega'}'
                                                : 'À distância · iniciado às $hora',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TatuTexto.nota,
                                          ),
                                        ),
                                        Text(
                                          'Entregas: ${a.entregas} de '
                                          '${RegrasDistancia.maxEntregas}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              else
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Iniciado às $hora',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TatuTexto.detalhe,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: TatuColors.online,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Em serviço',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: TatuColors.onlineTexto,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 8),
                        if (s.distancia) ...[
                          // RN-99: prévias protegidas à vontade.
                          CartaoAcao(
                            icone: const Icon(TablerIcons.lock, size: 22),
                            titulo: 'Enviar prévia protegida',
                            detalhe:
                                '${s.feminino ? 'A' : 'O'} ${s.primeiroNome} vê, '
                                'mas não baixa. Mande quantas quiser.',
                            onTap: () => Navigator.of(context).pop('previa'),
                          ),
                          const SizedBox(height: TatuMedidas.entreItens),
                        ],
                        CartaoAcao(
                          icone: const Icon(TablerIcons.pencil, size: 22),
                          titulo: 'Precisa mudar o valor?',
                          detalhe: 'Envie uma nova proposta pelo chat.',
                          onTap: () => _emBreve(context, 'Chat'),
                        ),
                      ],
                    ),
                  ),
                  if (s.distancia)
                    // RN-96/RN-100: à distância quem conclui é o cliente;
                    // o profissional manda a entrega (no máximo 2).
                    ListenableBuilder(
                      listenable: atendimentoProfissional,
                      builder: (_, _) {
                        final a = atendimentoProfissional;
                        final n = a.entregas;
                        final max = RegrasDistancia.maxEntregas;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              n == 0
                                  ? 'Você tem $max entregas. Mande quando tiver certeza.'
                                  : a.podeEntregar
                                  ? 'Você tem mais ${max - n} entrega. É a última.'
                                  : 'Entregas enviadas. Aguardando '
                                        '${s.feminino ? 'a' : 'o'} '
                                        '${s.primeiroNome} aprovar.',
                              textAlign: TextAlign.center,
                              style: TatuTexto.nota,
                            ),
                            const SizedBox(height: TatuMedidas.entreItens),
                            FilledButton(
                              onPressed: a.podeEntregar
                                  ? () => Navigator.of(context).pop('entrega')
                                  : null,
                              child: const Text('Enviar entrega'),
                            ),
                          ],
                        );
                      },
                    )
                  else ...[
                  Text(
                    'Ao concluir, ${s.feminino ? 'a' : 'o'} '
                    '${s.cliente.split(' ').first} é cobrad'
                    '${s.feminino ? 'a' : 'o'} automaticamente.',
                    textAlign: TextAlign.center,
                    style: TatuTexto.nota,
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  FilledButton(
                    onPressed: () => _concluir(context),
                    child: const Text('Concluir serviço'),
                  ),
                  ],
                  if (s.visita > 0) ...[
                    const SizedBox(height: 4),
                    LinkAzul(
                      'Encerrar e cobrar só a visita',
                      onTap: () => _soVisita(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cliente com avatar de iniciais e botão de mensagem à direita.
class LinhaCliente extends StatelessWidget {
  const LinhaCliente({
    super.key,
    required this.titulo,
    required this.detalhe,
    required this.onMensagem,
  });

  final String titulo;
  final String detalhe;
  final VoidCallback onMensagem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarIniciais(nome: titulo, tamanho: 44),
        const SizedBox(width: TatuMedidas.entreItens),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
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
        Semantics(
          button: true,
          label: 'Mensagem',
          child: GestureDetector(
            onTap: onMensagem,
            child: const IconeCirculo(TablerIcons.message_circle),
          ),
        ),
      ],
    );
  }
}

/// Cartão cinza com o endereço revelado.
class CartaoEndereco extends StatelessWidget {
  const CartaoEndereco({super.key, required this.servico});

  final ServicoAceito servico;

  @override
  Widget build(BuildContext context) => _CartaoCinza(
    icone: TablerIcons.map_pin,
    titulo: servico.rua,
    detalhe: servico.referencia,
  );
}

/// Cartão cinza com o serviço e o valor combinado.
class CartaoServico extends StatelessWidget {
  const CartaoServico({
    super.key,
    required this.servico,
    this.comObservacao = false,
  });

  final ServicoAceito servico;
  final bool comObservacao;

  @override
  Widget build(BuildContext context) => _CartaoCinza(
    icone: TablerIcons.tool,
    titulo: servico.descricao,
    detalhe: comObservacao && servico.observacao.isNotEmpty
        ? servico.observacao
        : null,
    direita: reais(servico.valor),
  );
}

class _CartaoCinza extends StatelessWidget {
  const _CartaoCinza({
    required this.icone,
    required this.titulo,
    this.detalhe,
    this.direita,
  });

  final IconData icone;
  final String titulo;
  final String? detalhe;
  final String? direita;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
      ),
      child: Row(
        children: [
          Icon(icone, size: 20, color: TatuColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: detalhe != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (detalhe != null) ...[
                  const SizedBox(height: 2),
                  Text(detalhe!, style: TatuTexto.nota),
                ],
              ],
            ),
          ),
          if (direita != null) ...[
            const SizedBox(width: 8),
            Text(
              direita!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rota no mapa: ponto verde (você) até o ponto preto (cliente). [perto]
/// põe o ponto verde quase em cima do preto.
class _Rota extends CustomPainter {
  const _Rota({this.perto = false});

  final bool perto;

  @override
  void paint(Canvas canvas, Size size) {
    // Medidas do desenho (393 × 852).
    final sx = size.width / 393;
    final sy = size.height / 852;
    Offset o(double x, double y) => Offset(x * sx, y * sy);
    final a = o(90, 90);
    final d = o(262, 380);
    final rota = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(120 * sx, 130 * sy, 140 * sx, 230 * sy, 175 * sx, 275 * sy)
      ..cubicTo(205 * sx, 315 * sy, 255 * sx, 330 * sy, d.dx, d.dy);
    canvas.drawPath(
      rota,
      Paint()
        ..color = TatuColors.action
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    final eu = perto ? o(250, 360) : a;
    canvas.drawCircle(d, 15, Paint()..color = TatuColors.bg);
    canvas.drawCircle(d, 11, Paint()..color = TatuColors.action);
    canvas.drawCircle(eu, 12, Paint()..color = TatuColors.bg);
    canvas.drawCircle(eu, 9, Paint()..color = TatuColors.online);
  }

  @override
  bool shouldRepaint(_Rota oldDelegate) => oldDelegate.perto != perto;
}

/// No local: ponto preto com o círculo verde em volta.
class _NoLocal extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * .5, size.height * .25);
    canvas.drawCircle(c, 44, Paint()..color = TatuColors.radar);
    canvas.drawCircle(
      c,
      44,
      Paint()
        ..color = TatuColors.online.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(c, 11, Paint()..color = TatuColors.action);
  }

  @override
  bool shouldRepaint(_NoLocal oldDelegate) => false;
}
