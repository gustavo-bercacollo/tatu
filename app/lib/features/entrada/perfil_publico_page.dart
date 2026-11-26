import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/perfil_publico.dart';
import '../../data/profissional.dart' show AvaliacaoRecebida;
import '../../shared/widgets/back_circle_button.dart';
import '../../shared/widgets/estrelas.dart';
import '../../shared/widgets/opcao_selecionavel.dart';
import '../../shared/widgets/selo.dart';
import '../profissional/cadastro/resultado_page.dart';

/// Perfil do profissional como o cliente vê. Usado na Prévia do
/// profissional (P32) e no "Ver perfil" do cliente (C14–C15).
class PerfilPublicoPage extends StatefulWidget {
  const PerfilPublicoPage({
    super.key,
    required this.perfil,
    required this.avatar,
    required this.rodape,
    this.faixa,
    this.onVerFotos,
  });

  final PerfilPublico perfil;
  final Widget avatar;

  /// Barra fixa embaixo (ex.: "Voltar a editar" ou "Ver outro / Aceitar").
  final Widget rodape;

  /// Aviso no topo (ex.: "Prévia: assim os clientes veem seu perfil.").
  final Widget? faixa;
  final VoidCallback? onVerFotos;

  @override
  State<PerfilPublicoPage> createState() => _PerfilPublicoPageState();
}

class _PerfilPublicoPageState extends State<PerfilPublicoPage> {
  bool _sobreAberto = false;

  void _emBreve(String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  @override
  Widget build(BuildContext context) {
    final p = widget.perfil;
    final nota = p.nota;
    final fotos = p.fotos;
    final especialidades = p.especialidades;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.faixa != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      TatuMedidas.topo,
                      TatuMedidas.margem,
                      0,
                    ),
                    child: widget.faixa,
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      TatuMedidas.entreItens,
                      TatuMedidas.margem,
                      TatuMedidas.entreSecoes,
                    ),
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: BackCircleButton(),
                      ),
                      const SizedBox(height: 8),
                      Center(child: widget.avatar),
                      const SizedBox(height: TatuMedidas.entreItens),
                      Center(child: NomeVerificado(p.nome, tamanho: 26)),
                      const SizedBox(height: 4),
                      Text(
                        p.subtitulo,
                        textAlign: TextAlign.center,
                        style: TatuTexto.detalhe,
                      ),
                      const SizedBox(height: TatuMedidas.entreItens + 4),
                      const Divider(height: 1),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            _Numero(nota, 'nota', estrela: true),
                            const VerticalDivider(
                              width: 1,
                              indent: 12,
                              endIndent: 12,
                            ),
                            _Numero('${p.servicos}', 'serviços feitos'),
                            const VerticalDivider(
                              width: 1,
                              indent: 12,
                              endIndent: 12,
                            ),
                            _Numero(p.resposta, 'resposta média'),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // C166 · RN-219: um card por selo, com uma frase.
                      if (p.todosOsSelos.isNotEmpty) ...[
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        const Text('SELOS', style: TatuTexto.secao),
                        const SizedBox(height: TatuMedidas.tituloSecao),
                        for (final s in p.todosOsSelos) ...[
                          CartaoSelo(s),
                          const SizedBox(height: 8),
                        ],
                      ],
                      // RN-159: registro conferido no conselho pelo Tatu.
                      if (p.registros.isNotEmpty) ...[
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        const _Titulo('Registro profissional'),
                        const SizedBox(height: 6),
                        for (final r in p.registros) ...[
                          SeloRegistroConferido(r),
                          const SizedBox(height: 8),
                        ],
                      ],
                      const SizedBox(height: TatuMedidas.entreItens + 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final e in especialidades)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: const ShapeDecoration(
                                color: TatuColors.fill,
                                shape: StadiumBorder(),
                              ),
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: TatuMedidas.entreSecoes),
                      const _Titulo('Sobre'),
                      const SizedBox(height: 6),
                      Text(
                        p.sobre,
                        maxLines: _sobreAberto ? null : 3,
                        overflow: _sobreAberto ? null : TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                      if (!_sobreAberto)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: LinkAzul(
                            'Ler mais',
                            onTap: () => setState(() => _sobreAberto = true),
                          ),
                        ),
                      const SizedBox(height: TatuMedidas.entreItens + 4),
                      if (p.verificado)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: TatuColors.fill,
                            borderRadius: BorderRadius.circular(
                              TatuMedidas.raioCartao,
                            ),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: TatuColors.verified,
                                child: Icon(
                                  TablerIcons.check,
                                  size: 16,
                                  color: TatuColors.onAction,
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Identidade verificada',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Confirmada com documento',
                                      style: TatuTexto.nota,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: TatuMedidas.entreSecoes + 4),
                      if (fotos.isNotEmpty) ...[
                        _Titulo(
                          'Fotos de trabalhos',
                          acao: 'Ver todas',
                          onAcao:
                              widget.onVerFotos ??
                              () => _emBreve('Fotos de trabalhos'),
                        ),
                        const SizedBox(height: TatuMedidas.entreItens),
                        SizedBox(
                          height: 108,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: fotos.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) => Container(
                              width: 108,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: TatuColors.fillStrong,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: fotos[i] != null
                                  ? Image.memory(
                                      fotos[i]!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      TablerIcons.photo,
                                      color: TatuColors.textSecondary,
                                    ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: TatuMedidas.entreSecoes + 4),
                      const _Titulo('Medalhas'),
                      const SizedBox(height: TatuMedidas.entreItens),
                      Row(
                        children: [
                          const _Medalha(TablerIcons.clock, 'Pontual'),
                          _Medalha(
                            TablerIcons.star,
                            p.feminino ? 'Bem avaliada' : 'Bem avaliado',
                          ),
                          const _Medalha(TablerIcons.award, 'Experiente'),
                        ],
                      ),
                      const SizedBox(height: TatuMedidas.entreSecoes + 4),
                      _Titulo(
                        'Avaliações',
                        acao: 'Ver todas',
                        onAcao: () => _emBreve('Avaliações'),
                      ),
                      const SizedBox(height: TatuMedidas.entreItens),
                      Row(
                        children: [
                          Text(
                            nota,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(TablerIcons.star_filled, size: 18),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              children: [
                                for (var i = 0; i < p.barrasNotas.length; i++)
                                  _Barra(5 - i, p.barrasNotas[i]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TatuMedidas.entreItens + 4),
                      SizedBox(
                        height: 168,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: p.avaliacoes.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, i) =>
                              _CartaoAvaliacao(p.avaliacoes[i]),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    TatuMedidas.entreItens,
                    TatuMedidas.margem,
                    TatuMedidas.base,
                  ),
                  child: widget.rodape,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero(this.valor, this.rotulo, {this.estrela = false});

  final String valor;
  final String rotulo;
  final bool estrela;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (estrela) ...[
                const Icon(TablerIcons.star_filled, size: 15),
                const SizedBox(width: 4),
              ],
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(rotulo, style: TatuTexto.nota),
        ],
      ),
    ),
  );
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto, {this.acao, this.onAcao});

  final String texto;
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          texto,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      if (acao != null) LinkAzul(acao!, onTap: onAcao ?? () {}),
    ],
  );
}

class _Medalha extends StatelessWidget {
  const _Medalha(this.icone, this.texto);

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: TatuColors.fill,
            shape: BoxShape.circle,
          ),
          child: Icon(icone, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          texto,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

class _Barra extends StatelessWidget {
  const _Barra(this.estrelas, this.fracao);

  final int estrelas;
  final double fracao;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        SizedBox(width: 12, child: Text('$estrelas', style: TatuTexto.nota)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fracao,
              minHeight: 5,
              color: TatuColors.action,
              backgroundColor: TatuColors.trilho,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CartaoAvaliacao extends StatelessWidget {
  const _CartaoAvaliacao(this.a);

  final AvaliacaoRecebida a;

  @override
  Widget build(BuildContext context) => Container(
    width: 290,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TatuColors.fill,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                a.cliente,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Estrelas(nota: a.nota),
          ],
        ),
        const SizedBox(height: 2),
        Text('${a.servico} · ${a.quando}', style: TatuTexto.nota),
        const SizedBox(height: 10),
        Expanded(
          child: Text(
            a.texto,
            overflow: TextOverflow.fade,
            style: TatuTexto.comentario,
          ),
        ),
      ],
    ),
  );
}

/// RN-159: cartão verde "CREF 012345-G/SP · Conferido no conselho pelo
/// Tatu".
class SeloRegistroConferido extends StatelessWidget {
  const SeloRegistroConferido(this.rotulo, {super.key});

  final String rotulo;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Registro conferido, $rotulo',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TatuColors.onlineSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: TatuColors.bg,
            child: Icon(
              TablerIcons.check,
              size: 16,
              color: TatuColors.onlineTexto,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TatuColors.onlineTexto,
                  ),
                ),
                const Text(
                  'Conferido no conselho pelo Tatu',
                  style: TextStyle(fontSize: 13, color: TatuColors.onlineTexto),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
