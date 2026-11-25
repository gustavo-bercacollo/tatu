import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../core/theme/tatu_theme.dart';
import '../../data/plano_fixo.dart' show diaMes;
import '../../data/retorno.dart';
import '../../features/entrada/canal_tatu_page.dart' show AvatarTatu;
import 'avatar_iniciais.dart';
import 'botao_tracejado.dart';
import 'linha_do_tempo.dart' show SeloVerde;

/// RN-184: fotos de prova tiradas na hora (quadrado cinza com a data) e o
/// quadrado tracejado da câmera. Nunca galeria.
class FotosProva extends StatelessWidget {
  const FotosProva({
    super.key,
    required this.fotos,
    required this.onCamera,
    this.maximo = 3,
  });

  final List<FotoProva> fotos;

  /// Abre a câmera do app (nulo = já chegou no máximo).
  final VoidCallback onCamera;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: TatuMedidas.entreItens,
          runSpacing: TatuMedidas.entreItens,
          children: [
            for (final f in fotos) MiniaturaProva(foto: f),
            if (fotos.length < maximo)
              QuadradoFoto(
                icone: TablerIcons.camera,
                rotulo: 'Tirar foto',
                onTap: onCamera,
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Só pela câmera do app, na hora.', style: TatuTexto.nota),
      ],
    );
  }
}

/// Foto de prova com a data em cima ("24 nov").
class MiniaturaProva extends StatelessWidget {
  const MiniaturaProva({super.key, required this.foto, this.pequena = false});

  final FotoProva foto;

  /// Para dentro do cartão do chat (sem data).
  final bool pequena;

  @override
  Widget build(BuildContext context) {
    final lado = pequena ? 36.0 : TatuMedidas.quadradoFoto;
    final img = foto.imagem;
    return Semantics(
      label: 'Foto de ${diaMes(foto.tiradaEm)}',
      child: Container(
        width: pequena ? 48 : lado,
        height: lado,
        decoration: BoxDecoration(
          color: TatuColors.fill,
          borderRadius: BorderRadius.circular(pequena ? 8 : TatuMedidas.raioCampo),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (img != null)
              Image.memory(img, fit: BoxFit.cover)
            else
              Icon(
                TablerIcons.photo,
                size: pequena ? 18 : 24,
                color: TatuColors.textSecondary,
              ),
            if (!pequena)
              Positioned(
                left: 6,
                right: 6,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: TatuColors.textSecondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    diaMes(foto.tiradaEm),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.onAction,
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

/// Linha de situação no pé do cartão do pedido de retorno.
class SituacaoCartaoRetorno {
  const SituacaoCartaoRetorno(this.icone, this.texto, this.cor);

  final IconData icone;
  final String texto;
  final Color cor;
}

/// RN-184/RN-186: cartão "Pedido de retorno" no chat. Do lado do cliente
/// fica à direita ([meu]); do profissional, na largura toda.
class CartaoPedidoRetorno extends StatelessWidget {
  const CartaoPedidoRetorno({
    super.key,
    required this.pedido,
    this.meu = false,
    this.situacao,
  });

  final PedidoRetorno pedido;
  final bool meu;
  final SituacaoCartaoRetorno? situacao;

  @override
  Widget build(BuildContext context) {
    final s = situacao;
    final cartao = Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        border: Border.all(color: TatuColors.textPrimary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(TablerIcons.refresh, size: 20),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Pedido de retorno',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Serviço de ${pedido.diaServico} · ${pedido.descricaoServico}',
            style: TatuTexto.nota,
          ),
          const SizedBox(height: 6),
          Text(pedido.descricao, style: const TextStyle(fontSize: 17)),
          if (pedido.fotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final f in pedido.fotos)
                  MiniaturaProva(foto: f, pequena: true),
              ],
            ),
          ],
          if (s != null) ...[
            const SizedBox(height: TatuMedidas.entreItens),
            const Divider(height: 1, color: TatuColors.trilho),
            const SizedBox(height: TatuMedidas.entreItens),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(s.icone, size: 18, color: s.cor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.texto,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: s.cor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
    if (!meu) return cartao;
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(widthFactor: 0.86, child: cartao),
    );
  }
}

/// Cartão verde/amarelo/cinza do retorno no chat: título, linha forte e
/// nota (ex.: "Retorno aceito · sem custo", "Sexta, 28 nov · 14h").
class CartaoSituacaoRetorno extends StatelessWidget {
  const CartaoSituacaoRetorno({
    super.key,
    required this.titulo,
    this.linha,
    this.nota,
    this.aviso = false,
  });

  final String titulo;
  final String? linha;
  final String? nota;

  /// Amarelo de atenção (ex.: "Você não estava no retorno").
  final bool aviso;

  @override
  Widget build(BuildContext context) {
    final cor = aviso ? TatuColors.warningTexto : TatuColors.onlineTexto;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: aviso ? TatuColors.warningSoft : TatuColors.onlineSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                aviso ? TablerIcons.alert_triangle : TablerIcons.check,
                size: 20,
                color: cor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
          if (linha != null) ...[
            const SizedBox(height: 6),
            Text(linha!, style: const TextStyle(fontSize: 17)),
          ],
          if (nota != null) ...[
            const SizedBox(height: 4),
            Text(nota!, style: TatuTexto.detalhe),
          ],
        ],
      ),
    );
  }
}

/// Cartão do Tatu dentro do chat (RN-188/RN-189): cabeçalho "Tatu" (ou
/// escudo), título, texto e até dois botões. [verde] para devolução feita.
class CartaoTatuRetorno extends StatelessWidget {
  const CartaoTatuRetorno({
    super.key,
    required this.titulo,
    required this.texto,
    this.verde = false,
    this.escudo = false,
    this.botao,
    this.onBotao,
    this.segundo,
    this.onSegundo,
  });

  final String titulo;
  final String texto;
  final bool verde;

  /// Ícone de escudo no lugar do "Tatu" (ex.: "Quer ajuda do Tatu?").
  final bool escudo;
  final String? botao;
  final VoidCallback? onBotao;
  final String? segundo;
  final VoidCallback? onSegundo;

  @override
  Widget build(BuildContext context) {
    final tituloTexto = Text(
      titulo,
      style: TextStyle(
        fontSize: escudo ? 18 : 20,
        fontWeight: FontWeight.w700,
        color: verde ? TatuColors.onlineTexto : TatuColors.textPrimary,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: verde ? TatuColors.onlineSoft : TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (escudo)
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: TatuColors.bg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(TablerIcons.shield_check, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: tituloTexto),
              ],
            )
          else ...[
            const Row(
              children: [
                AvatarTatu(tamanho: 28),
                SizedBox(width: 10),
                Text('Tatu', style: TatuTexto.detalhe),
              ],
            ),
            const SizedBox(height: 8),
            tituloTexto,
          ],
          const SizedBox(height: 6),
          Text(texto, style: TatuTexto.detalhe),
          if (botao != null) ...[
            const SizedBox(height: TatuMedidas.entreItens + 4),
            FilledButton(
              onPressed: onBotao,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(TatuMedidas.alturaBotaoCartao),
              ),
              child: Text(botao!),
            ),
          ],
          if (segundo != null) ...[
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onSegundo,
              style: tatuBotaoSecundario().copyWith(
                minimumSize: const WidgetStatePropertyAll(
                  Size.fromHeight(TatuMedidas.alturaBotaoCartao),
                ),
              ),
              child: Text(segundo!),
            ),
          ],
        ],
      ),
    );
  }
}

/// RN-187: card "Retorno · sem custo" na Atividade dos dois.
class CartaoRetornoAtividade extends StatelessWidget {
  const CartaoRetornoAtividade({
    super.key,
    required this.retorno,
    required this.onTap,
    this.profissional = false,
  });

  final PedidoRetorno retorno;
  final VoidCallback onTap;

  /// Do lado do profissional mostra o cliente; do cliente, o profissional.
  final bool profissional;

  @override
  Widget build(BuildContext context) {
    final r = retorno;
    final nome = profissional ? r.cliente : r.profissional;
    final m = r.marcadoPara;
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AvatarIniciais(nome: nome, tamanho: 44),
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
                    Text(
                      m == null
                          ? r.descricaoServico
                          : '${quandoRetorno(m)} · ${r.descricaoServico}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const SeloVerde('Retorno · sem custo', pequeno: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// RN-191: cartão "Decisão do Tatu" no canal oficial.
class CartaoDecisaoTatu extends StatelessWidget {
  const CartaoDecisaoTatu({
    super.key,
    required this.titulo,
    required this.texto,
    required this.rodape,
    this.rodapeAviso = false,
  });

  /// "Devolvemos R$ 150,00".
  final String titulo;
  final String texto;

  /// "O pedido foi encerrado" (verde) ou "A recusa… contou 1 falta"
  /// ([rodapeAviso], laranja).
  final String rodape;
  final bool rodapeAviso;

  @override
  Widget build(BuildContext context) {
    final cor = rodapeAviso ? TatuColors.warningTexto : TatuColors.onlineTexto;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: 0.86,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          border: Border.all(color: TatuColors.textPrimary, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Decisão do Tatu', style: TatuTexto.nota),
            const SizedBox(height: 6),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(texto, style: TatuTexto.detalhe),
            const SizedBox(height: TatuMedidas.entreItens),
            const Divider(height: 1, color: TatuColors.trilho),
            const SizedBox(height: TatuMedidas.entreItens),
            Row(
              children: [
                Icon(
                  rodapeAviso ? TablerIcons.alert_triangle : TablerIcons.check,
                  size: 18,
                  color: cor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rodape,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cor,
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
