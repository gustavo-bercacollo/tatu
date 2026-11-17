import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/protecao_tela.dart';
import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/conta.dart';
import '../../../data/arquivos_seguros.dart';
import '../../../data/conversas.dart';
import '../../../data/regras_distancia.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/chat.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';

/// C160 · Prévia protegida (RN-99): abre só no app, sem baixar nem
/// encaminhar, com marca d'água com o nome do cliente; print e gravação
/// de tela ficam pretos ([ProtecaoTela]). Expira em 24 h.
class PreviaProtegidaPage extends StatefulWidget {
  const PreviaProtegidaPage({
    super.key,
    required this.de,
    required this.enviadaEm,
  });

  /// Primeiro nome de quem mandou ("Marina").
  final String de;
  final DateTime enviadaEm;

  @override
  State<PreviaProtegidaPage> createState() => _PreviaProtegidaPageState();
}

class _PreviaProtegidaPageState extends State<PreviaProtegidaPage> {
  /// iPhone gravando a tela: a imagem some (RN-99).
  bool _gravando = false;

  @override
  void initState() {
    super.initState();
    ProtecaoTela.ligar(
      onGravando: (g) {
        if (mounted) setState(() => _gravando = g);
      },
    );
  }

  @override
  void dispose() {
    ProtecaoTela.desligar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resta =
        RegrasDistancia.validadePrevia -
        clock.now().difference(widget.enviadaEm);
    final horas = resta.inHours.clamp(0, 24);
    final marca = '${conta.nomeCompleto} · Tatu · prévia';
    return Scaffold(
      backgroundColor: TatuColors.textPrimary,
      body: SafeArea(
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
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        button: true,
                        label: 'Fechar',
                        child: Material(
                          color: TatuColors.editorFundo,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                TablerIcons.x,
                                size: 20,
                                color: TatuColors.onAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Prévia ${_daDo(widget.de)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: TatuColors.onAction,
                          ),
                        ),
                        Text(
                          'Expira em $horas h',
                          style: TatuTexto.nota.copyWith(
                            color: TatuColors.avisoEscuroTexto,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              AspectRatio(
                aspectRatio: 353 / 420,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
                  child: _gravando
                      ? const ColoredBox(
                          color: TatuColors.editorFundo,
                          child: Center(
                            child: Text(
                              'Gravação de tela: a prévia fica escondida.',
                              style: TextStyle(color: TatuColors.onAction),
                            ),
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            const _ArteExemplo(),
                            // RN-99: marca d'água com o nome do cliente.
                            CustomPaint(painter: _MarcaDagua(marca)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    TablerIcons.lock,
                    size: 16,
                    color: TatuColors.avisoEscuroTexto,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Não dá para baixar nem salvar.',
                    style: TextStyle(color: TatuColors.avisoEscuroTexto),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Print e gravação de tela ficam pretos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: TatuColors.avisoEscuroTexto),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: TatuColors.editorFundo,
                  foregroundColor: TatuColors.onAction,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Voltar ao chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "da Marina" / "do Tiago" pelo nome (protótipo: termina em "a").
String _daDo(String nome) => '${nome.endsWith('a') ? 'da' : 'do'} $nome';

/// Arte de exemplo da prévia (dados falsos).
class _ArteExemplo extends StatelessWidget {
  const _ArteExemplo();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TatuColors.previaFundo,
      child: Center(
        child: Container(
          width: 156,
          height: 156,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: TatuColors.previaArte,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Doces',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: TatuColors.onAction,
                ),
              ),
              Text(
                'da ${conta.nome}',
                style: const TextStyle(
                  fontSize: 18,
                  color: TatuColors.onAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Texto repetido na diagonal por cima da imagem (RN-99).
class _MarcaDagua extends CustomPainter {
  const _MarcaDagua(this.texto);

  final String texto;

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: TatuColors.marcaDagua,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 9);
    final passoX = tp.width + 24;
    const passoY = 64.0;
    for (var y = -size.height; y < size.height; y += passoY) {
      final deslocar = (y / passoY).round().isEven ? 0.0 : passoX / 2;
      for (var x = -size.width * 1.5; x < size.width; x += passoX) {
        tp.paint(canvas, Offset(x + deslocar, y));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarcaDagua oldDelegate) => oldDelegate.texto != texto;
}

/// Linha cinza com o arquivo (ícone, nome e detalhe).
class LinhaArquivo extends StatelessWidget {
  const LinhaArquivo({
    super.key,
    required this.nome,
    required this.detalhe,
    this.escuro = false,
    this.icone = TablerIcons.file_text,
  });

  final String nome;
  final String detalhe;

  /// Ícone à esquerda (arquivo ou, no link do site, navegação).
  final IconData icone;

  /// No cartão preto do profissional.
  final bool escuro;

  @override
  Widget build(BuildContext context) {
    final cor = escuro ? TatuColors.onAction : TatuColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: escuro ? TatuColors.editorFundo : TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
      ),
      child: Row(
        children: [
          Icon(icone, size: 22, color: cor),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cor,
                  ),
                ),
                Text(
                  detalhe,
                  style: TatuTexto.nota.copyWith(
                    color: escuro
                        ? TatuColors.avisoEscuroTexto
                        : TatuColors.textSecondary,
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

/// C161/C163 · Entrega recebida (RN-100, RN-101): na 1ª, Pedir ajuste ou
/// Aprovar; na 2ª (última), Reembolso ou Aprovar.
class CartaoEntregaRecebida extends StatelessWidget {
  const CartaoEntregaRecebida({
    super.key,
    required this.numero,
    required this.arquivo,
    required this.detalhe,
    required this.restante,
    required this.onAprovar,
    required this.onOutro,
    this.link = false,
  });

  final int numero;
  final String arquivo;
  final String detalhe;

  /// RN-125: entrega por link do site.
  final bool link;
  final double restante;
  final VoidCallback onAprovar;

  /// "Pedir ajuste" (1ª) ou "Reembolso" (2ª).
  final VoidCallback onOutro;

  bool get _ultima => numero >= RegrasDistancia.maxEntregas;

  @override
  Widget build(BuildContext context) {
    final max = RegrasDistancia.maxEntregas;
    final horas = RegrasDistancia.aprovacaoAutomatica.inHours;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: BoxDecoration(
                color: TatuColors.bg,
                borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
                border: Border.all(color: TatuColors.textPrimary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Entrega $numero de $max${_ultima ? ' · última' : ''}',
                    style: TatuTexto.nota,
                  ),
                  const SizedBox(height: 10),
                  LinhaArquivo(
                    nome: arquivo,
                    detalhe: detalhe,
                    icone: link ? TablerIcons.location : TablerIcons.file_text,
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  if (!link && executavel(arquivo))
                    // RN-126: o app só baixa; avisa antes.
                    Row(
                      children: [
                        const Icon(
                          TablerIcons.alert_triangle,
                          size: 16,
                          color: TatuColors.warningTexto,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Arquivo executável · abra só se você pediu',
                            style: TatuTexto.nota.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TatuColors.warningTexto,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Aprove para pagar o restante de ${reais(restante)}.',
                      style: TatuTexto.nota,
                    ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: tatuBotaoSecundario().copyWith(
                            minimumSize: const WidgetStatePropertyAll(
                              Size(0, 48),
                            ),
                          ),
                          onPressed: onOutro,
                          child: FittedBox(
                            child: Text(_ultima ? 'Reembolso' : 'Pedir ajuste'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                          onPressed: onAprovar,
                          child: const Text('Aprovar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        NotaChat(
          link
              // RN-124/RN-125: link só pela entrega.
              ? 'Links só podem ser enviados como entrega.'
              : executavel(arquivo)
              // RN-126: o Tatu nunca abre nem roda.
              ? 'O Tatu não abre nem roda este arquivo. Só baixa.'
              : _ultima
              ? 'Última entrega. Não gostou? Peça reembolso.'
              : 'Sem resposta em ${horas}h, a entrega é aprovada.',
        ),
      ],
    );
  }
}

/// C164 · Entrega aprovada (RN-100): o restante foi cobrado.
class CartaoEntregaAprovada extends StatelessWidget {
  const CartaoEntregaAprovada({
    super.key,
    required this.restante,
    required this.total,
    required this.nome,
    required this.onAvaliar,
  });

  final double restante;
  final double total;

  /// Primeiro nome de quem entregou.
  final String nome;
  final VoidCallback onAvaliar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TatuColors.onlineSoft,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                TablerIcons.check,
                size: 20,
                color: TatuColors.onlineTexto,
              ),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Você aprovou a entrega',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TatuColors.onlineTexto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${reais(restante)} cobrados · total ${reais(total)}',
                      style: TatuTexto.nota.copyWith(
                        color: TatuColors.onlineTexto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onAvaliar,
                      child: Text(
                        'Avaliar $nome',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TatuColors.verified,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        const NotaChat('A conversa continua aberta para novos pedidos.'),
      ],
    );
  }
}

/// Caixa laranja de pedido em análise no suporte (RN-104 e RN-105).
class CaixaEmAnalise extends StatelessWidget {
  const CaixaEmAnalise({super.key, required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.warningSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            TablerIcons.clock,
            size: 20,
            color: TatuColors.warning,
          ),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TatuColors.warningTexto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  texto,
                  style: TatuTexto.nota.copyWith(
                    color: TatuColors.warningTexto,
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

/// C167 · O prazo acabou sem entrega (RN-105): "Esperar mais" ou "Pedir
/// sinal de volta".
class CartaoSemEntrega extends StatelessWidget {
  const CartaoSemEntrega({
    super.key,
    required this.nome,
    required this.sinal,
    required this.onEsperar,
    required this.onPedirSinal,
  });

  /// "A Marina".
  final String nome;
  final double sinal;
  final VoidCallback onEsperar;
  final VoidCallback onPedirSinal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(TablerIcons.alert_triangle, size: 22),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$nome não enviou nada',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'O prazo acabou. O sinal de ${reaisInteiros(sinal)}\n'
                      'está guardado e pode voltar para você.',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          Row(
            children: [
              FilledButton(
                style: tatuBotaoSecundario().copyWith(
                  minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                onPressed: onEsperar,
                child: const Text('Esperar mais'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: onPedirSinal,
                  child: const FittedBox(child: Text('Pedir sinal de volta')),
                ),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          const Text(
            'O pedido vai para o suporte.',
            textAlign: TextAlign.center,
            style: TatuTexto.nota,
          ),
        ],
      ),
    );
  }
}

/// C162 · "O que precisa mudar?" (RN-101). Devolve o texto do ajuste.
Future<String?> pedirAjuste(BuildContext context, {required String nome}) =>
    mostrarFolha<String>(context, builder: (_) => _FolhaAjuste(nome: nome));

class _FolhaAjuste extends StatefulWidget {
  const _FolhaAjuste({required this.nome});

  /// "A Marina".
  final String nome;

  @override
  State<_FolhaAjuste> createState() => _FolhaAjusteState();
}

class _FolhaAjusteState extends State<_FolhaAjuste> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pronto = _texto.text.trim().isNotEmpty;
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
              const Text('O que precisa mudar?', style: TatuTexto.tituloFolha),
              const SizedBox(height: 4),
              Text(
                '${widget.nome} pode mandar mais 1 entrega.',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              Container(
                height: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: TatuColors.fill,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
                  border: Border.all(color: TatuColors.textPrimary, width: 1.5),
                ),
                child: TextField(
                  controller: _texto,
                  autofocus: true,
                  maxLines: null,
                  onChanged: (_) => setState(() {}),
                  cursorColor: TatuColors.textPrimary,
                  style: const TextStyle(fontSize: 17),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Ex.: letras maiores, outra cor…',
                  ),
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              FilledButton(
                onPressed: pronto
                    ? () => Navigator.of(context).pop(_texto.text.trim())
                    : null,
                child: const Text('Pedir ajuste'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// C165 · "Pedir reembolso" (RN-104). Devolve o motivo escolhido.
Future<String?> pedirReembolso(
  BuildContext context, {
  required double restante,
  required double sinal,
  required String nome,
}) => mostrarFolha<String>(
  context,
  builder: (_) => _FolhaReembolso(restante: restante, sinal: sinal, nome: nome),
);

class _FolhaReembolso extends StatefulWidget {
  const _FolhaReembolso({
    required this.restante,
    required this.sinal,
    required this.nome,
  });

  final double restante;
  final double sinal;

  /// "a Marina".
  final String nome;

  @override
  State<_FolhaReembolso> createState() => _FolhaReembolsoState();
}

class _FolhaReembolsoState extends State<_FolhaReembolso> {
  String _motivo = motivosReembolso.first;

  @override
  Widget build(BuildContext context) {
    final dias = RegrasDistancia.diasUteisSuporte;
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
            const Text('Pedir reembolso', style: TatuTexto.tituloFolha),
            const SizedBox(height: 4),
            Text(
              'O suporte olha o chat e responde em $dias dias úteis.',
              style: TatuTexto.nota,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            for (final m in motivosReembolso) ...[
              OpcaoSelecionavel(
                selecionado: _motivo == m,
                rotulo: m,
                onTap: () => setState(() => _motivo = m),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      BolinhaEscolha(selecionado: _motivo == m),
                      const SizedBox(width: 14),
                      Text(m, style: const TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TatuColors.surfaceGrouped,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
              ),
              child: Text(
                'Os ${reais(widget.restante)} ficam guardados até a decisão.'
                '${widget.sinal > 0 ? '\nO sinal de ${reaisInteiros(widget.sinal)} fica com ${widget.nome}.' : ''}',
                style: TatuTexto.nota,
              ),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_motivo),
              child: const Text('Enviar para o suporte'),
            ),
          ],
        ),
      ),
    );
  }
}
