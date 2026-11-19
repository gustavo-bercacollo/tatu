import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ajuda.dart';
import '../../../data/atendimento_profissional.dart';
import '../../../data/codigo_porta.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../../cliente/ajuda/abrir_ajuda.dart';

/// P50–P51 · RN-39/RN-167: depois do "Cheguei", o profissional pede o
/// código ao cliente e digita. Certo: o serviço começa sozinho
/// ([onIniciou]). Errado: caixas em vermelho e as tentativas que
/// restam; 3 erros bloqueiam e oferecem o suporte. A espera do cliente
/// (RN-80) continua contando: "Ver tempo de espera" ([onVerEspera]).
class DigitarCodigoView extends StatefulWidget {
  const DigitarCodigoView({
    super.key,
    required this.servico,
    required this.onVerEspera,
    required this.onIniciou,
  });

  final ServicoAceito servico;
  final VoidCallback onVerEspera;
  final ValueChanged<DateTime> onIniciou;

  @override
  State<DigitarCodigoView> createState() => _DigitarCodigoViewState();
}

class _DigitarCodigoViewState extends State<DigitarCodigoView> {
  String _digitos = '';
  bool _errou = false;

  ConferenciaCodigo? get _conferencia => atendimentoProfissional.codigo;
  bool get _bloqueado => _conferencia?.bloqueado ?? false;

  void _tecla(String d) {
    if (_bloqueado) return;
    setState(() {
      // Depois de um erro, o próximo dígito começa de novo.
      if (_errou) {
        _digitos = '';
        _errou = false;
      }
      if (_digitos.length < RegrasCodigo.digitos) _digitos += d;
    });
    if (_digitos.length == RegrasCodigo.digitos) _conferir();
  }

  void _apagar() {
    if (_bloqueado || _digitos.isEmpty) return;
    setState(() {
      _errou = false;
      _digitos = _digitos.substring(0, _digitos.length - 1);
    });
  }

  void _conferir() {
    final a = atendimentoProfissional;
    // Protótipo: tela aberta direto (fluxograma e testes).
    if (a.codigo == null) {
      a
        ..irAteCliente(widget.servico)
        ..chegou();
    }
    final agora = DateTime.now();
    final r = a.digitarCodigo(_digitos, agora: agora);
    if (r == ResultadoCodigo.certo) {
      widget.onIniciou(agora);
      return;
    }
    setState(() => _errou = true);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.servico;
    final a = s.feminino ? 'a' : 'o';
    final nome = s.primeiroNome;
    final restam = _conferencia?.restam ?? RegrasCodigo.tentativas;
    final vermelho = _errou || _bloqueado;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(
                    painter: MapaFalso(),
                    foregroundPainter: _NaPorta(),
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
                    child: Align(
                      alignment: Alignment.topLeft,
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
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      10,
                      TatuMedidas.margem,
                      TatuMedidas.entreItens,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AlcaFolha(),
                        const SizedBox(height: 16),
                        Text(
                          'Peça o código para $a $nome',
                          style: TatuTexto.tituloFolha,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Digitou, o serviço começa sozinho.',
                          style: TatuTexto.nota,
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        Row(
                          children: [
                            for (var i = 0; i < RegrasCodigo.digitos; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: _Caixa(
                                  digito: i < _digitos.length
                                      ? _digitos[i]
                                      : '',
                                  atual: !vermelho && i == _digitos.length,
                                  erro: vermelho,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        Text(
                          _bloqueado
                              ? 'Código incorreto ${RegrasCodigo.tentativas} '
                                    'vezes. Por segurança, novas tentativas '
                                    'estão bloqueadas.'
                              : _errou
                              ? 'Código incorreto. Confira com $a $nome · '
                                    '${restam == 1 ? 'resta 1 tentativa' : 'restam $restam tentativas'}.'
                              : 'O código está no app ${s.feminino ? 'da' : 'do'} '
                                    '$nome.',
                          style: (vermelho ? TatuTexto.legenda : TatuTexto.nota)
                              .copyWith(
                                color: vermelho ? TatuColors.danger : null,
                              ),
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        // RN-167: bloqueado, oferece o suporte.
                        if (_bloqueado) ...[
                          FilledButton(
                            onPressed: () =>
                                abrirSuporte(context, conteudoProfissional),
                            child: const Text('Falar com o suporte'),
                          ),
                          const SizedBox(height: TatuMedidas.entreItens),
                        ],
                        // RN-80: a espera do cliente continua contando.
                        _Link(
                          '${s.feminino ? 'A' : 'O'} $nome não está? '
                          'Ver tempo de espera',
                          onTap: widget.onVerEspera,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_bloqueado) _Teclado(onTecla: _tecla, onApagar: _apagar),
        ],
      ),
    );
  }
}

class _Caixa extends StatelessWidget {
  const _Caixa({required this.digito, required this.atual, required this.erro});

  final String digito;
  final bool atual;
  final bool erro;

  @override
  Widget build(BuildContext context) => Container(
    height: TatuMedidas.codigoDigitarAltura,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: TatuColors.fill,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      border: erro
          ? Border.all(color: TatuColors.danger, width: 1.5)
          : atual
          ? Border.all(color: TatuColors.action, width: 1.5)
          : null,
    ),
    child: Text(digito, style: TatuTexto.digito),
  );
}

class _Link extends StatelessWidget {
  const _Link(this.texto, {required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: TatuColors.verified,
          ),
        ),
      ),
    ),
  );
}

/// Teclado numérico do desenho (1–9, 0 e apagar).
class _Teclado extends StatelessWidget {
  const _Teclado({required this.onTecla, required this.onApagar});

  final ValueChanged<String> onTecla;
  final VoidCallback onApagar;

  @override
  Widget build(BuildContext context) {
    Widget tecla(String t) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: TatuColors.bg,
          borderRadius: BorderRadius.circular(TatuMedidas.raioTecla),
          child: InkWell(
            borderRadius: BorderRadius.circular(TatuMedidas.raioTecla),
            onTap: () => onTecla(t),
            child: SizedBox(
              height: TatuMedidas.teclaAltura,
              child: Center(child: Text(t, style: TatuTexto.tecla)),
            ),
          ),
        ),
      ),
    );
    return Container(
      color: TatuColors.teclado,
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            for (final linha in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ])
              Row(children: [for (final t in linha) tecla(t)]),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                tecla('0'),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Apagar',
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: onApagar,
                      child: const SizedBox(
                        height: TatuMedidas.teclaAltura,
                        child: Icon(TablerIcons.backspace, size: 26),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ponto verde (você) colado no ponto preto (cliente).
class _NaPorta extends CustomPainter {
  const _NaPorta();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 393;
    final sy = size.height / 580;
    final cliente = Offset(262 * sx, 250 * sy);
    final eu = Offset(250 * sx, 232 * sy);
    canvas.drawCircle(cliente, 13, Paint()..color = TatuColors.bg);
    canvas.drawCircle(cliente, 10, Paint()..color = TatuColors.action);
    canvas.drawCircle(eu, 10, Paint()..color = TatuColors.bg);
    canvas.drawCircle(eu, 7.5, Paint()..color = TatuColors.online);
  }

  @override
  bool shouldRepaint(_NaPorta old) => false;
}
