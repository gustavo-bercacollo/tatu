import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/conversas.dart';
import '../../../data/encontrados.dart';
import '../../../data/limites.dart';
import '../../../data/pedidos.dart';
import '../../../data/seguranca.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../../profissional/cadastro/resultado_page.dart' show NomeVerificado;
import '../../entrada/perfil_publico_page.dart';
import '../abas.dart';
import '../mensagens/chat_page.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/selo.dart';
import 'procurando_page.dart';
import 'som_encontrado.dart';

/// Alguém aceitou o pedido: mapa com a rota até você, quem é, nota,
/// serviços, tempo de chegada e a estimativa da região. Toca o som de
/// "achou!". A pessoa tem [prazo] para aceitar; "Ver outro" ou o prazo
/// acabando chamam o próximo da fila (mesma tela).
class EncontradoPage extends StatefulWidget {
  const EncontradoPage({
    super.key,
    required this.servico,
    required this.endereco,
    this.indice = 0,
    this.inicio,
    this.restante,
    this.animar = true,
    this.distancia = false,
    this.descricao = '',
    this.trocas = 0,
  });

  /// RN-239: quantas vezes o cliente já tocou em "Ver outro" neste pedido.
  final int trocas;

  /// O que a pessoa escreveu (vazio = o nome do serviço).
  final String descricao;

  /// RN-93/RN-94: profissional online, sem distância nem chegada.
  final bool distancia;

  final String servico;
  final String endereco;

  /// Posição em [filaEncontrados].
  final int indice;

  /// Onde a fila começou (nulo = em [indice]).
  final int? inicio;

  /// Segundos que faltam (capturas de tela); começa em [prazo].
  final int? restante;

  /// Desligado nas capturas (sem contagem nem som).
  final bool animar;

  static const prazo = Duration(minutes: 3);

  /// Abaixo disso o anel e o tempo ficam vermelhos.
  static const pouco = 15;

  @override
  State<EncontradoPage> createState() => _EncontradoPageState();
}

/// Profissão no feminino quando for uma mulher ("Encanadora").
String _profissao(String servico, bool feminino) =>
    feminino && servico.endsWith('or') ? '${servico}a' : servico;

class _EncontradoPageState extends State<EncontradoPage> {
  late int _restante = widget.restante ?? EncontradoPage.prazo.inSeconds;
  Timer? _timer;
  final _som = SomEncontrado();

  /// Onde a fila começou (para "Ver outro" passar por todos uma vez).
  int get _inicio => widget.inicio ?? widget.indice;

  ProfissionalEncontrado get _base => _fila[widget.indice % _fila.length];

  List<ProfissionalEncontrado> get _fila => filaPara(
    soMulheres: seguranca.preferirMulheres,
    distancia: widget.distancia,
  );

  /// A profissão segue o serviço pedido.
  ProfissionalEncontrado get _p => ProfissionalEncontrado(
    nome: _base.nome,
    profissao: _profissao(widget.servico, _base.feminino),
    feminino: _base.feminino,
    nota: _base.nota,
    servicos: _base.servicos,
    chegaEm: _base.chegaEm,
    distancia: _base.distancia,
    resposta: _base.resposta,
    especialidades: _base.especialidades,
    sobre: _base.sobre,
    selos: _base.selos,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animar) {
      _som.tocar();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_restante <= 1) {
          _timer?.cancel();
          _proximo();
          return;
        }
        setState(() => _restante--);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _som.parar();
    super.dispose();
  }

  /// RN-239: ainda pode trocar de profissional neste pedido?
  bool get _podeTrocar => widget.trocas < Limites.trocasPorPedido;

  /// Próximo da fila; depois do último, volta a procurar. [troca]: veio
  /// do "Ver outro" (conta para a RN-239), não do fim do prazo.
  void _proximo({bool troca = false}) {
    if (!mounted) return;
    _timer?.cancel();
    _som.parar();
    final proximo = widget.indice + 1;
    // Fecha o perfil ou a folha abertos por cima antes de trocar.
    final nav = Navigator.of(context);
    final rota = ModalRoute.of(context);
    nav.popUntil((r) => r == rota);
    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) => proximo < _inicio + _fila.length
            ? EncontradoPage(
                servico: widget.servico,
                endereco: widget.endereco,
                indice: proximo,
                inicio: _inicio,
                distancia: widget.distancia,
                descricao: widget.descricao,
                trocas: widget.trocas + (troca ? 1 : 0),
              )
            : ProcurandoPage(
                servico: widget.servico,
                endereco: widget.endereco,
                simularAceite: false,
                distancia: widget.distancia,
                descricao: widget.descricao,
              ),
      ),
    );
  }

  Future<void> _verOutro() async {
    if (!_podeTrocar) return;
    _som.parar();
    final p = _p;
    final ok = await confirmar(
      context,
      titulo: 'Ver outro profissional?',
      texto:
          '${p.feminino ? 'A' : 'O'} ${p.primeiroNome} será liberad${p.artigo} '
          'e chamamos outro ${widget.servico.toLowerCase()} '
          '${widget.distancia ? 'online' : 'perto de você'}.',
      confirmar: 'Ver outro profissional',
      cancelar: 'Ficar com ${p.artigo} ${p.primeiroNome}',
      iconeAviso: false,
    );
    if (ok) _proximo(troca: true);
  }

  void _aceitar() {
    _timer?.cancel();
    _som.parar();
    final p = _p;
    pedidos.aceitar(
      PedidoAndamento(
        servico: widget.servico,
        profissao: p.profissao,
        profissional: p.nome,
        nota: p.nota,
        endereco: widget.endereco,
        valor: '',
        pagamento: '',
        etapasFeitas: 1,
        chegaEm: p.chegaEm,
        descricao: widget.descricao.isEmpty ? widget.servico : widget.descricao,
        distancia: widget.distancia,
      ),
    );
    final c = conversas.comecar(
      nome: p.nome,
      profissao: p.profissao,
      feminino: p.feminino,
      servico: widget.servico,
      rua: widget.distancia ? 'À distância' : widget.endereco,
      distancia: widget.distancia,
      descricao: widget.descricao.isEmpty ? null : widget.descricao,
    );
    final nav = Navigator.of(context);
    irParaAba(context, AbaCliente.mensagens);
    nav.push(MaterialPageRoute(builder: (_) => ChatPage(conversa: c)));
  }

  /// Perfil completo (C14–C15) com "Ver outro" e "Aceitar" fixos embaixo.
  Future<void> _verPerfil() async {
    _som.parar();
    final p = _p;
    final escolha = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => PerfilPublicoPage(
          perfil: perfilDe(p),
          avatar: AvatarIniciais(nome: p.nome, tamanho: 96),
          rodape: _Botoes(
            nome: p.primeiroNome,
            onVerOutro: _podeTrocar ? () => Navigator.of(ctx).pop(false) : null,
            onAceitar: () => Navigator.of(ctx).pop(true),
          ),
        ),
      ),
    );
    if (!mounted || escolha == null) return;
    escolha ? _aceitar() : _verOutro();
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    return Scaffold(
      body: Stack(
        children: [
          if (widget.distancia)
            Positioned.fill(child: _TopoOnline(nome: p.nome))
          else
            const Positioned.fill(
              child: CustomPaint(
                painter: MapaFalso(),
                foregroundPainter: _Rota(),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                0,
                0,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Semantics(
                  button: true,
                  label: 'Fechar',
                  child: Material(
                    color: TatuColors.bg,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        _som.parar();
                        Navigator.of(context).maybePop();
                      },
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(TablerIcons.x, size: 20),
                      ),
                    ),
                  ),
                ),
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
                    8,
                    TatuMedidas.margem,
                    TatuMedidas.base,
                  ),
                  child: _painel(p),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _painel(ProfissionalEncontrado p) {
    final servicos = '${p.servicos}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AlcaFolha(),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Encontramos ${p.feminino ? 'uma' : 'um'} '
                '${p.profissao.toLowerCase()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TatuColors.textSecondary,
                ),
              ),
            ),
            _Prazo(restante: _restante),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            AvatarIniciais(nome: p.nome, tamanho: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NomeVerificado(p.nome, tamanho: 20),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        TablerIcons.star_filled,
                        size: 13,
                        color: TatuColors.warning,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${p.nota} · $servicos serviços',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: TatuColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // RN-219: selos pequenos ("Pontual · Clientes voltam").
                  if (p.selos.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    SelosPequenos(p.selos),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: TatuColors.fill,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: _verPerfil,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(14, 7, 10, 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver perfil',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(TablerIcons.chevron_right, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _Caixa(valor: p.nota, rotulo: 'Nota', estrela: true),
            const SizedBox(width: 8),
            _Caixa(valor: servicos, rotulo: 'Serviços'),
            const SizedBox(width: 8),
            // RN-93: à distância não há chegada; mostra o tempo de resposta.
            widget.distancia
                ? _Caixa(valor: p.resposta, rotulo: 'Responde em')
                : _Caixa(valor: p.chegaEm, rotulo: 'Chega em'),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: TatuColors.surfaceGrouped,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.distancia
                    ? 'Estimativa para esse serviço'
                    : 'Estimativa na sua região',
                style: TextStyle(fontSize: 12, color: TatuColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                estimativaDe(widget.servico),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // RN-239: depois de 3 trocas, "Ver outro" some.
        _Botoes(
          nome: p.primeiroNome,
          onVerOutro: _podeTrocar ? _verOutro : null,
          onAceitar: _aceitar,
        ),
      ],
    );
  }
}

/// RN-94: topo do encontrado à distância: círculos verdes, o avatar
/// grande com aro e "Online agora" (sem mapa nem rota).
class _TopoOnline extends StatelessWidget {
  const _TopoOnline({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TatuColors.surfaceGrouped,
      child: LayoutBuilder(
        builder: (context, c) {
          final centro = Offset(c.maxWidth / 2, c.maxHeight * 0.27);
          return Stack(
            children: [
              for (final r in const [170.0, 115.0])
                Positioned(
                  left: centro.dx - r,
                  top: centro.dy - r,
                  child: Container(
                    width: r * 2,
                    height: r * 2,
                    decoration: const BoxDecoration(
                      color: TatuColors.radar,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Positioned(
                left: centro.dx - 60,
                top: centro.dy - 60,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: TatuColors.radar,
                    shape: BoxShape.circle,
                  ),
                  child: AvatarIniciais(nome: nome, tamanho: 104),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: centro.dy + 66,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: const ShapeDecoration(
                      color: TatuColors.bg,
                      shape: StadiumBorder(),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: TatuColors.online,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Online agora',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "Ver outro" (cinza) e "Aceitar [nome]" (preto), lado a lado.
class _Botoes extends StatelessWidget {
  const _Botoes({
    required this.nome,
    required this.onVerOutro,
    required this.onAceitar,
  });

  final String nome;

  /// Nulo: sem "Ver outro" (RN-239); "Aceitar" ocupa a linha.
  final VoidCallback? onVerOutro;
  final VoidCallback onAceitar;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (onVerOutro != null) ...[
        SizedBox(
          width: 120,
          child: FilledButton(
            style: tatuBotaoSecundario().copyWith(
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            onPressed: onVerOutro,
            child: const Text('Ver outro', maxLines: 1, softWrap: false),
          ),
        ),
        const SizedBox(width: 10),
      ],
      Expanded(
        child: FilledButton(
          onPressed: onAceitar,
          child: FittedBox(fit: BoxFit.scaleDown, child: Text('Aceitar $nome')),
        ),
      ),
    ],
  );
}

/// Anel com o tempo para aceitar (verde; vermelho no fim).
class _Prazo extends StatelessWidget {
  const _Prazo({required this.restante});

  final int restante;

  @override
  Widget build(BuildContext context) {
    final acabando = restante <= EncontradoPage.pouco;
    final cor = acabando ? TatuColors.danger : TatuColors.online;
    final m = restante ~/ 60;
    final s = (restante % 60).toString().padLeft(2, '0');
    return Semantics(
      label: 'Faltam $m min e $s s para aceitar',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CircularProgressIndicator(
                value: restante / EncontradoPage.prazo.inSeconds,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
                color: cor,
                backgroundColor: TatuColors.circle,
              ),
            ),
            ExcludeSemantics(
              child: Text(
                '$m:$s',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: acabando ? TatuColors.danger : TatuColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Caixinha cinza com um número grande e o rótulo embaixo.
class _Caixa extends StatelessWidget {
  const _Caixa({
    required this.valor,
    required this.rotulo,
    this.estrela = false,
  });

  final String valor;
  final String rotulo;
  final bool estrela;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 64,
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valor,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (estrela) ...[
                  const SizedBox(width: 4),
                  const Icon(TablerIcons.star_filled, size: 15),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rotulo,
            style: const TextStyle(
              fontSize: 12,
              color: TatuColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Rota no mapa: ponto verde (profissional) até o ponto preto (você).
class _Rota extends CustomPainter {
  const _Rota();

  @override
  void paint(Canvas canvas, Size size) {
    // Medidas do desenho (393 × 852); o ponto preto fica logo acima do painel.
    final sx = size.width / 393;
    final sy = size.height / 852;
    Offset o(double x, double y) => Offset(x * sx, y * sy);
    final a = o(120, 120);
    final b = o(196, 310);
    final d = o(262, 385);
    final rota = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(160 * sx, 200 * sy, 140 * sx, 250 * sy, b.dx, b.dy)
      ..cubicTo(240 * sx, 360 * sy, 258 * sx, 360 * sy, d.dx, d.dy);
    canvas.drawPath(
      rota,
      Paint()
        ..color = TatuColors.action
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(a, 12, Paint()..color = TatuColors.bg);
    canvas.drawCircle(a, 9, Paint()..color = TatuColors.online);
    canvas.drawCircle(d, 15, Paint()..color = TatuColors.bg);
    canvas.drawCircle(d, 11, Paint()..color = TatuColors.action);
  }

  @override
  bool shouldRepaint(_Rota oldDelegate) => false;
}
