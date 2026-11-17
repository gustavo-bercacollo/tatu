import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/atendimento_profissional.dart';
import 'ainda_vai.dart';
import '../../../data/profissional.dart';
import '../../../data/prazos.dart';import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/servico_profissional.dart';
import '../../../data/ajuda.dart';
import '../../../data/conversas_profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../cliente/ajuda/ajuda_page.dart';
import '../../cliente/mensagens/denunciar_page.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/chat.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../servico/andamento_page.dart';
import 'enviar_valor_sheet.dart';

/// Cada lado pode propor até 3 valores.
const maxRodadas = 3;

/// Em que ponto está a combinação do valor.
enum EstadoValor { inicio, aguardando, contraproposta, combinado }

/// P23 · Chat do profissional com o cliente: combinar o valor.
/// O profissional envia um valor; o cliente aceita ou propõe outro
/// (até 3 rodadas). O endereço exato só aparece com o valor combinado.
///
/// Protótipo: o cliente responde sozinho em [resposta]. Ele propõe 20%
/// a menos no 1º valor e depois aceita qualquer valor até 15% acima da
/// proposta dele.
class ChatProfissionalPage extends StatefulWidget {
  const ChatProfissionalPage({
    super.key,
    this.chamado = chamadoExemplo,
    this.resposta = const Duration(seconds: 2),
    this.concluidoPor,
    this.concluidoEm,
    this.depois = const [],
    this.diaDepois,
  });

  final ChamadoNovo chamado;
  final Duration resposta;

  /// Serviço já concluído por esse valor. RN-42: a conversa continua e
  /// dá para enviar um novo valor (RN-87).
  final double? concluidoPor;
  final String? concluidoEm;

  /// Mensagens depois do serviço concluído (texto, minha) e o dia delas.
  final List<(String, bool)> depois;
  final String? diaDepois;

  @override
  State<ChatProfissionalPage> createState() => _ChatProfissionalPageState();
}

class _ChatProfissionalPageState extends State<ChatProfissionalPage> {
  final _campo = TextEditingController();
  Timer? _timer;

  /// RN-76: prazo para tocar "Estou a caminho" depois de combinar.
  Timer? _prazoSaida;

  /// (texto, minha): conversa de exemplo.
  final _mensagens = <(String, bool)>[
    ('Oi! A pia não para de vazar.', false),
    ('Posso ir agora. Já te mando o valor.', true),
  ];

  EstadoValor _estado = EstadoValor.inicio;
  int _rodada = 0; // quantos valores o profissional já enviou
  double _meuValor = 0;
  String _meuDetalhe = ''; // "Visita R$ 40 · Serviço R$ 150"
  double _minhaVisita = 0;
  double _proposta = 0; // proposta do cliente
  double _combinado = 0;

  String get _nome => widget.chamado.primeiroNome;

  @override
  void dispose() {
    _timer?.cancel();
    _prazoSaida?.cancel();
    _campo.dispose();
    super.dispose();
  }

  /// Já teve um serviço concluído nesta conversa (RN-42).
  bool get _concluida => widget.concluidoPor != null;

  /// Quantas mensagens vieram antes do serviço concluído.
  late final int _antes;

  @override
  void initState() {
    super.initState();
    _antes = _mensagens.length;
    _mensagens.addAll(widget.depois);
  }

  /// Toque no nome: ligar, ver chamado, ajuda, cancelar e denunciar.
  Future<void> _menu() async {
    final c = widget.chamado;
    final escolha = await mostrarFolha<String>(
      context,
      builder: (ctx) {
        ItemLista item(IconData i, String t, {bool perigo = false}) =>
            ItemLista(
              icone: i,
              texto: t,
              seta: false,
              cor: perigo ? TatuColors.danger : null,
              onTap: () => Navigator.of(ctx).pop(t),
            );
        return FolhaOpcoes(
          fechar: 'Fechar',
          itens: [
            item(TablerIcons.phone, 'Ligar para $_nome'),
            item(TablerIcons.file_text, 'Ver chamado'),
            item(TablerIcons.help_circle, 'Ajuda'),
            if (!_concluida || _estado != EstadoValor.inicio)
              item(TablerIcons.x, 'Cancelar atendimento', perigo: true),
            item(TablerIcons.alert_triangle, 'Denunciar cliente', perigo: true),
          ],
        );
      },
    );
    if (escolha == null || !mounted) return;
    switch (escolha) {
      case 'Cancelar atendimento':
        return _cancelar();
      case 'Denunciar cliente':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DenunciarPage.pessoa(
              nome: _nome,
              feminino: c.feminino,
              motivos: const [
                'Comportamento inadequado',
                'Não estava no endereço',
                'Não quis pagar',
                'Outro motivo',
              ],
            ),
          ),
        );
      case 'Ajuda':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AjudaPage(conteudo: conteudoProfissional),
          ),
        );
      default:
        _emBreve(escolha.startsWith('Ligar') ? 'Ligar' : escolha);
    }
  }

  Future<void> _cancelar() async {
    final c = widget.chamado;
    final sim = await confirmar(
      context,
      titulo: 'Cancelar atendimento?',
      texto:
          'A $_nome será avisada e vamos buscar\n'
          'outro profissional para ${c.feminino ? 'ela' : 'ele'}.',
      aviso: 'Cancelar muito baixa sua posição.',
      confirmar: 'Cancelar atendimento',
      cancelar: 'Continuar atendimento',
      perigo: true,
    );
    if (!sim || !mounted) return;
    _timer?.cancel();
    conversasProfissional.cancelar(c);
    atendimentoProfissional.encerrar();
    Navigator.of(context).pop();
  }

  void _emBreve(String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  void _enviar([String? pronto]) {
    final texto = (pronto ?? _campo.text).trim();
    if (texto.isEmpty) return;
    setState(() => _mensagens.add((texto, true)));
    if (pronto == null) _campo.clear();
  }

  Future<void> _enviarValor() async {
    final v = await pedirValor(
      context,
      cliente: _nome,
      rodada: _rodada + 1,
      distancia: widget.chamado.distancia,
    );
    if (v == null || !mounted) return;
    setState(() {
      _rodada++;
      _meuValor = v.total;
      _meuDetalhe = v.detalhe;
      _minhaVisita = v.visita;
      _estado = EstadoValor.aguardando;
    });
    _timer?.cancel();
    _timer = Timer(widget.resposta, _clienteResponde);
  }

  /// Resposta simulada do cliente.
  void _clienteResponde() {
    if (!mounted) return;
    final aceita = _rodada > 1 && _meuValor <= _proposta * 1.15;
    if (aceita) {
      setState(() {
        _combinado = _meuValor;
        _estado = EstadoValor.combinado;
      });
      _contarPrazoSaida();
    } else if (_rodada >= maxRodadas) {
      atendimentoProfissional.encerrar();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SemAcordoPage()),
      );
    } else {
      setState(() {
        _proposta = _rodada == 1
            ? (_meuValor * 0.8 / 10).round() * 10.0
            : _proposta + 10;
        _estado = EstadoValor.contraproposta;
      });
    }
  }

  void _aceitarProposta() {
    setState(() {
      _combinado = _proposta;
      _estado = EstadoValor.combinado;
    });
    _contarPrazoSaida();
  }

  /// RN-76: valor combinado; se não tocar em "Estou a caminho" dentro do
  /// prazo, o app pergunta "Ainda vai?".
  void _contarPrazoSaida() {
    _prazoSaida?.cancel();
    // RN-95: à distância não há "Estou a caminho" (abandono à distância
    // ainda é decisão em aberto).
    if (widget.chamado.distancia) return;
    _prazoSaida = Timer(
      Prazos.naDemo(Prazos.estouACaminho),
      _perguntarAindaVai,
    );
  }

  Future<void> _perguntarAindaVai() async {
    if (!mounted) return;
    final c = widget.chamado;
    final vai = await perguntarAindaVai(
      context,
      cliente: c.primeiroNome,
      feminino: c.feminino,
    );
    if (!mounted) return;
    if (vai == true) {
      _irAteOCliente();
    } else {
      _devolver(naoConsegue: vai == false);
    }
  }

  /// RN-77: "Não consigo ir" ou sem resposta: o chamado volta à busca,
  /// nada é cobrado do cliente e conta como abandono.
  void _devolver({required bool naoConsegue}) {
    _prazoSaida?.cancel();
    profissional.registrarAbandono();
    atendimentoProfissional.encerrar();
    final c = widget.chamado;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChamadoDevolvidoPage(
          cliente: c.primeiroNome,
          feminino: c.feminino,
          naoConsegue: naoConsegue,
        ),
      ),
    );
  }

  void _irAteOCliente() {
    _prazoSaida?.cancel();
    final c = widget.chamado;
    final s = ServicoAceito(
      cliente: c.cliente,
      notaCliente: c.notaCliente,
      rua: c.rua,
      referencia: c.complemento,
      descricao: c.resumo,
      valor: _combinado,
      visita: _minhaVisita < _combinado ? _minhaVisita : 0,
      distanciaKm: c.distanciaKm,
      minutos: c.minutos,
    );
    atendimentoProfissional.irAteCliente(s);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ACaminhoPage(servico: s)),
    );
  }

  /// RN-95: à distância, combinado o valor, vai direto para Em andamento
  /// (sem rota, "Cheguei" nem código na porta).
  void _comecarDistancia() {
    final c = widget.chamado;
    final s = ServicoAceito(
      cliente: c.cliente,
      notaCliente: c.notaCliente,
      rua: '',
      referencia: '',
      descricao: c.resumo,
      valor: _combinado,
      visita: 0,
      distanciaKm: 0,
      minutos: 0,
      feminino: c.feminino,
      distancia: true,
    );
    final agora = DateTime.now();
    atendimentoProfissional
      ..irAteCliente(s)
      ..iniciar(agora);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EmAndamentoPage(servico: s, inicio: agora),
      ),
    );
  }

  /// RN-42: faixa "Serviço concluído" e o dia das mensagens seguintes.
  List<Widget> _marco() => [
    const SizedBox(height: 18),
    MarcoConcluido(
      'Serviço concluído · ${reais(widget.concluidoPor!)}'
      '${widget.concluidoEm == null ? '' : ' · ${widget.concluidoEm}'}',
      nota: false,
    ),
    if (widget.diaDepois != null) ...[
      const SizedBox(height: 18),
      SeparadorDia(widget.diaDepois!),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final c = widget.chamado;
    final km = c.distanciaKm.toStringAsFixed(1).replaceAll('.', ',');
    return TelaChat(
      topo: Row(
        children: [
          const BackCircleButton(),
          Expanded(
            child: Semantics(
              container: true,
              button: true,
              label: 'Opções da conversa',
              child: GestureDetector(
                onTap: _menu,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarIniciais(nome: c.cliente),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c.cliente,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text('Cliente', style: TatuTexto.nota),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Ligar',
            child: IconButton(
              onPressed: () => _emBreve('Ligar'),
              icon: const Icon(TablerIcons.phone, size: 22),
            ),
          ),
        ],
      ),
      mensagens: [
        CartaoPedidoChat(
          rotulo: 'Chamado',
          servico: c.profissao,
          descricao: c.resumo,
          lado: c.distancia ? 'À distância' : '${c.bairro} · $km km',
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        const NotaChat('Você aceitou o chamado. Combinem o valor por aqui.'),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        for (final (i, m) in _mensagens.indexed) ...[
          if (_concluida && i == _antes) ..._marco(),
          Padding(
            padding: EdgeInsets.only(
              top: espacoAntesDoBalao(
                anteriorMinha: i == 0 ? null : _mensagens[i - 1].$2,
                minha: m.$2,
              ),
            ),
            child: BalaoChat(
              texto: m.$1,
              minha: m.$2,
              outro: '${c.feminino ? 'a' : 'o'} $_nome',
            ),
          ),
        ],
        if (_concluida && _mensagens.length == _antes) ..._marco(),
        const SizedBox(height: TatuMedidas.entreSecoes),
        ...switch (_estado) {
            EstadoValor.inicio => const <Widget>[],
            EstadoValor.aguardando => [
              _MeuValor(
                rodada: _rodada,
                valor: _meuValor,
                detalhe: _meuDetalhe,
                icone: TablerIcons.clock,
                situacao: 'Aguardando a $_nome',
              ),
            ],
            EstadoValor.contraproposta => [
              _MeuValor(
                rodada: _rodada,
                valor: _meuValor,
                detalhe: _meuDetalhe,
                icone: TablerIcons.refresh,
                situacao: '$_nome propôs outro valor',
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              _Proposta(
                nome: _nome,
                rodada: _rodada,
                valor: _proposta,
                onAceitar: _aceitarProposta,
                onOutro: _enviarValor,
              ),
            ],
            EstadoValor.combinado => [
              _ValorCombinado(valor: _combinado),
              const SizedBox(height: TatuMedidas.entreItens),
              // RN-28: no local, o endereço aparece; à distância não há.
              if (!c.distancia) _EnderecoLiberado(chamado: c),
            ],
          },
        const SizedBox(height: TatuMedidas.entreItens),
      ],
      // RN-42: a conversa nunca fecha.
      rodape: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_estado == EstadoValor.inicio && _concluida) ...[
                  // RN-87: cada valor combinado é um pagamento novo.
                  FilledButton(
                    onPressed: _enviarValor,
                    child: const Text('Enviar novo valor'),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                ] else if (_estado == EstadoValor.inicio) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        if (!c.distancia)
                        TatuChip(
                          label: 'Estou a caminho',
                          onTap: () => _enviar('Estou a caminho'),
                        ),
                        TatuChip(
                          label: c.distancia ? 'Mandar arquivo' : 'Mandar foto',
                          onTap: () => _emBreve('Mandar foto'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  FilledButton(
                    onPressed: _enviarValor,
                    child: const Text('Enviar valor'),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                ],
                if (_estado == EstadoValor.combinado) ...[
                  FilledButton(
                    onPressed: c.distancia ? _comecarDistancia : _irAteOCliente,
                    child: Text(c.distancia ? 'Ver em andamento' : 'Estou a caminho'),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                ],
                // RN-85: contato não passa pelo chat.
                BarraMensagem(
                  controller: _campo,
                  onEnviar: _enviar,
                  onCamera: () => _emBreve('Mandar foto'),
                  porQue:
                      'Pelo Tatu você recebe garantido, e o serviço conta '
                      'para sua nota.',
                ),
              ],
            ),
    );
  }
}

/// Cartão com contorno, à direita: o valor que o profissional enviou.
class _MeuValor extends StatelessWidget {
  const _MeuValor({
    required this.rodada,
    required this.valor,
    required this.detalhe,
    required this.icone,
    required this.situacao,
  });

  final int rodada;
  final double valor;
  final String detalhe;
  final IconData icone;
  final String situacao;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.74,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            border: Border.all(color: TatuColors.textPrimary, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Seu valor · $rodada de $maxRodadas', style: TatuTexto.nota),
              const SizedBox(height: 2),
              _Valor(valor),
              if (detalhe.isNotEmpty) Text(detalhe, style: TatuTexto.nota),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(icone, size: 15, color: TatuColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      situacao,
                      style: TatuTexto.nota.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão cinza, à esquerda: o valor que o cliente propôs.
class _Proposta extends StatelessWidget {
  const _Proposta({
    required this.nome,
    required this.rodada,
    required this.valor,
    required this.onAceitar,
    required this.onOutro,
  });

  final String nome;
  final int rodada;
  final double valor;
  final VoidCallback onAceitar;
  final VoidCallback onOutro;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Proposta da $nome · $rodada de $maxRodadas',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: 2),
              _Valor(valor),
              const SizedBox(height: TatuMedidas.entreItens),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(TatuMedidas.alturaBusca),
                ),
                onPressed: onAceitar,
                child: Text('Aceitar ${reais(valor)}'),
              ),
              const SizedBox(height: 4),
              Center(child: LinkAzul('Enviar outro valor', onTap: onOutro)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Valor extends StatelessWidget {
  const _Valor(this.valor);

  final double valor;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      reais(valor),
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
    ),
  );
}

/// Cartão verde: os dois lados fecharam o valor.
class _ValorCombinado extends StatelessWidget {
  const _ValorCombinado({required this.valor});

  final double valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.onlineSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: TatuColors.online,
            child: Icon(
              TablerIcons.check,
              size: 18,
              color: TatuColors.onAction,
            ),
          ),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor combinado',
                  style: TatuTexto.nota.copyWith(color: TatuColors.onlineTexto),
                ),
                const SizedBox(height: 2),
                Text(
                  reais(valor),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão cinza: endereço exato, liberado só com o valor combinado.
class _EnderecoLiberado extends StatelessWidget {
  const _EnderecoLiberado({required this.chamado});

  final ChamadoNovo chamado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(TablerIcons.map_pin, size: 20),
          ),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Endereço liberado', style: TatuTexto.nota),
                const SizedBox(height: 2),
                Text(
                  '${chamado.rua} · ${chamado.complemento}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${chamado.bairro}, ${chamado.cidade}',
                  style: TatuTexto.nota,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// P28 · As 3 rodadas acabaram sem acordo: o chamado é encerrado.
class SemAcordoPage extends StatelessWidget {
  const SemAcordoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      icone: const IconePermissao(TablerIcons.x, cor: TatuColors.textPrimary),
      titulo: 'Sem acordo de valor',
      texto:
          'Vocês usaram as 3 rodadas.\n'
          'O chamado foi encerrado e você\n'
          'continua online para novos chamados.',
      principal: 'Voltar para o início',
      onPrincipal: () => Navigator.of(context).popUntil((r) => r.isFirst),
    );
  }
}
