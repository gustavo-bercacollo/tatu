import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/fotos_trabalho.dart';
import '../../../data/perfil.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../cliente/foto/camera_desativada_page.dart';

/// Fotos de trabalhos do profissional (até 12). Cada foto é revisada
/// antes de aparecer: sem rosto de cliente nem endereço.
class FotosTrabalhoPage extends StatelessWidget {
  const FotosTrabalhoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: fotosTrabalho,
      builder: (context, _) {
        final vazio = fotosTrabalho.fotos.isEmpty;
        return TelaInterna(
          titulo: 'Fotos de trabalhos',
          fundoCinza: true,
          rodape: vazio
              ? FilledButton(
                  onPressed: () => adicionarFotoTrabalho(context),
                  child: const Text('Adicionar fotos'),
                )
              : null,
          corpo: vazio ? const _Vazio() : const _Grade(),
        );
      },
    );
  }
}

/// Folha "Tirar foto / Escolher da galeria" → "Nova foto".
/// Com [trocar], a foto nova entra no lugar dela (foto recusada).
Future<void> adicionarFotoTrabalho(
  BuildContext context, {
  FotoTrabalho? trocar,
}) async {
  final origem = await mostrarFolha<OrigemFoto>(
    context,
    builder: (ctx) => FolhaOpcoes(
      itens: [
        ItemLista(
          icone: TablerIcons.camera,
          texto: 'Tirar foto',
          seta: false,
          onTap: () => Navigator.of(ctx).pop(OrigemFoto.camera),
        ),
        ItemLista(
          icone: TablerIcons.photo,
          texto: 'Escolher da galeria',
          seta: false,
          onTap: () => Navigator.of(ctx).pop(OrigemFoto.galeria),
        ),
      ],
    ),
  );
  if (origem == null || !context.mounted) return;
  try {
    final imagem = await perfil.pedirImagem(origem);
    if (imagem == null || !context.mounted) return;
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NovaFotoPage(imagem: imagem, trocar: trocar),
      ),
    );
    if (salvou == true && context.mounted) {
      mostrarAvisoTopo(
        context,
        titulo: 'Foto adicionada',
        texto: 'Aparece no perfil assim que for aprovada.',
      );
    }
  } on CameraNegada {
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CameraDesativadaPage(semAvatar: true),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 112,
          height: 112,
          decoration: const BoxDecoration(
            color: TatuColors.fill,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            TablerIcons.photo,
            size: 48,
            color: TatuColors.textSecondary,
          ),
        ),
        const SizedBox(height: TatuMedidas.entreSecoes + 8),
        const Text(
          'Mostre seu trabalho',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Fotos de serviços feitos ajudam o\ncliente a escolher você. '
          'Até $maxFotosTrabalho fotos.',
          textAlign: TextAlign.center,
          style: TatuTexto.corpo,
        ),
        const SizedBox(height: TatuMedidas.entreSecoes + 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TatuColors.bg,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(TablerIcons.lock, size: 20),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sem rosto de cliente nem endereço.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fotos são revisadas antes de aparecer. '
                      'Costumam ser aprovadas em minutos.',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

class _Grade extends StatelessWidget {
  const _Grade();

  Future<void> _remover(BuildContext context, FotoTrabalho f) async {
    final sim = await confirmar(
      context,
      titulo: 'Remover esta foto?',
      texto: 'Ela some do seu perfil na hora.',
      confirmar: 'Remover',
      perigo: true,
    );
    if (sim) fotosTrabalho.remover(f);
  }

  Future<void> _recusada(BuildContext context, FotoTrabalho f) async {
    final outra = await mostrarFolha<bool>(
      context,
      builder: (ctx) => _FolhaRecusada(motivo: f.motivo ?? ''),
    );
    if (!context.mounted || outra == null) return;
    if (outra) {
      await adicionarFotoTrabalho(context, trocar: f);
    } else {
      fotosTrabalho.remover(f);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: fotosTrabalho,
    builder: (context, _) => _lista(context),
  );

  Widget _lista(BuildContext context) {
    final fotos = fotosTrabalho.fotos;
    return ListView(
      padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Mostre o que você já fez. Clientes\nescolhem mais quem tem fotos.',
            style: TextStyle(
              fontSize: 16,
              height: 1.35,
              color: TatuColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            TatuMedidas.tituloSecao,
          ),
          child: Text(
            '${fotos.length} DE $maxFotosTrabalho FOTOS',
            style: TatuTexto.secao,
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < fotos.length; i++)
              _Arrastavel(
                indice: i,
                child: _Miniatura(
                  foto: fotos[i],
                  onRemover: () => _remover(context, fotos[i]),
                  onTap: fotos[i].revisao == RevisaoFoto.recusada
                      ? () => _recusada(context, fotos[i])
                      : null,
                ),
              ),
            if (!fotosTrabalho.cheio)
              _Adicionar(onTap: () => adicionarFotoTrabalho(context)),
          ],
        ),
        if (fotos.length > 1) ...[
          const SizedBox(height: TatuMedidas.entreSecoes),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Toque e segure para reordenar.',
              style: TatuTexto.nota,
            ),
          ),
        ],
      ],
    );
  }
}

/// Toque e segure para arrastar a foto para outra posição.
class _Arrastavel extends StatelessWidget {
  const _Arrastavel({required this.indice, required this.child});

  final int indice;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => DragTarget<int>(
        onWillAcceptWithDetails: (d) => d.data != indice,
        onAcceptWithDetails: (d) => fotosTrabalho.mover(d.data, indice),
        builder: (context, candidatos, _) => LongPressDraggable<int>(
          data: indice,
          feedback: SizedBox(
            width: c.maxWidth,
            height: c.maxHeight,
            child: Opacity(opacity: 0.9, child: child),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: child),
          child: AnimatedScale(
            scale: candidatos.isEmpty ? 1 : 0.92,
            duration: const Duration(milliseconds: 120),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.foto, required this.onRemover, this.onTap});

  final FotoTrabalho foto;
  final VoidCallback onRemover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final analise = foto.revisao == RevisaoFoto.emAnalise;
    final recusada = foto.revisao == RevisaoFoto.recusada;
    final apagada = analise || recusada;
    return Semantics(
      button: onTap != null,
      label: foto.legenda.isEmpty ? 'Foto' : foto.legenda,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (foto.imagem != null)
                    Image.memory(foto.imagem!, fit: BoxFit.cover)
                  else
                    const ColoredBox(
                      color: TatuColors.fillStrong,
                      child: Icon(
                        TablerIcons.photo,
                        size: 28,
                        color: TatuColors.textSecondary,
                      ),
                    ),
                  if (apagada)
                    ColoredBox(
                      color: recusada
                          ? const Color(0x99000000)
                          : const Color(0x66000000),
                    ),
                  if (foto.legenda.isNotEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        color: apagada
                            ? const Color(0xB3000000)
                            : const Color(0x8C000000),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            foto.legenda,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: apagada
                                  ? TatuColors.textSecondary
                                  : TatuColors.onAction,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (apagada)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: ShapeDecoration(
                    color: recusada ? TatuColors.danger : TatuColors.bg,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    recusada ? 'Recusada' : 'Em análise',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: recusada
                          ? TatuColors.onAction
                          : TatuColors.textPrimary,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 6,
              top: 6,
              child: Semantics(
                container: true,
                button: true,
                label: 'Remover foto',
                child: GestureDetector(
                  onTap: onRemover,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: TatuColors.textPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: TatuColors.bg, width: 2),
                    ),
                    child: const Icon(
                      TablerIcons.x,
                      size: 12,
                      color: TatuColors.onAction,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Adicionar extends StatelessWidget {
  const _Adicionar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Adicionar foto',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const CustomPaint(
          painter: _Tracejado(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(TablerIcons.plus, size: 26),
              SizedBox(height: 4),
              Text(
                'Adicionar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tracejado extends CustomPainter {
  const _Tracejado();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(TatuMedidas.raioCartao),
    ).deflate(0.75);
    final tinta = Paint()
      ..color = TatuColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final m in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), tinta);
      }
    }
  }

  @override
  bool shouldRepaint(_Tracejado oldDelegate) => false;
}

/// Folha "Foto recusada": enviar outra ou remover. Devolve true para
/// "Enviar outra foto" e false para "Remover".
class _FolhaRecusada extends StatelessWidget {
  const _FolhaRecusada({required this.motivo});

  final String motivo;

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 26),
            const Row(
              children: [
                Icon(
                  TablerIcons.alert_triangle,
                  size: 24,
                  color: TatuColors.danger,
                ),
                SizedBox(width: 12),
                Text('Foto recusada', style: TatuTexto.tituloFolha),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreItens),
            Text(
              '$motivo\nEnvie outra mostrando só o serviço.',
              style: TatuTexto.corpo.copyWith(fontSize: 16),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes + 8),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enviar outra foto'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Remover'),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Nova foto": legenda opcional e o serviço da foto.
class NovaFotoPage extends StatefulWidget {
  const NovaFotoPage({super.key, required this.imagem, this.trocar});

  final Uint8List imagem;

  /// Foto recusada que esta substitui.
  final FotoTrabalho? trocar;

  @override
  State<NovaFotoPage> createState() => _NovaFotoPageState();
}

class _NovaFotoPageState extends State<NovaFotoPage> {
  final _legenda = TextEditingController();
  late String _servico = profissional.profissaoPrincipal;

  @override
  void dispose() {
    _legenda.dispose();
    super.dispose();
  }

  void _salvar() {
    final nova = FotoTrabalho(
      imagem: widget.imagem,
      legenda: _legenda.text.trim(),
      servico: _servico,
    );
    if (widget.trocar != null) {
      fotosTrabalho.trocar(widget.trocar!, nova);
    } else {
      fotosTrabalho.adicionar(nova);
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final servicos = [for (final p in profissional.profissoes) p.nome];
    return TelaInterna(
      titulo: 'Nova foto',
      rodape: FilledButton(
        onPressed: _salvar,
        child: const Text('Salvar foto'),
      ),
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            child: AspectRatio(
              aspectRatio: 1.18,
              child: Image.memory(widget.imagem, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 4),
          const Text(
            'O que é essa foto?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Opcional. Aparece embaixo da foto.',
            style: TatuTexto.nota,
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          TatuField(
            label: 'Legenda',
            hintText: 'Ex.: Troca de chuveiro',
            controller: _legenda,
            textCapitalization: TextCapitalization.sentences,
          ),
          if (servicos.length > 1) ...[
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text(
              'Qual serviço?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: TatuMedidas.entreItens),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in servicos)
                  TatuChip(
                    label: s,
                    selecionado: s == _servico,
                    onTap: () => setState(() => _servico = s),
                  ),
              ],
            ),
          ],
          const SizedBox(height: TatuMedidas.entreSecoes),
        ],
      ),
    );
  }
}
