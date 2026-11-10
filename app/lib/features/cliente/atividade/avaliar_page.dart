import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/estrelas.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tela_interna.dart';

/// Tamanho do avatar no topo das telas de avaliação.
const _avatar = 80.0;

/// Título grande centralizado das telas de avaliação.
const _titulo = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
);

/// Elogios que a pessoa pode marcar.
List<String> elogiosPara(PedidoConcluido p) => [
  'Pontual',
  p.feminino ? 'Educada' : 'Educado',
  'Preço justo',
  'Limpeza',
  'Resolveu rápido',
];

/// Avaliar o profissional: estrelas, elogios e comentário. Serve também
/// para editar uma avaliação já enviada.
class AvaliarPage extends StatefulWidget {
  const AvaliarPage({super.key, required this.pedido});

  final PedidoConcluido pedido;

  @override
  State<AvaliarPage> createState() => _AvaliarPageState();
}

class _AvaliarPageState extends State<AvaliarPage> {
  late final _anterior = widget.pedido.minhaAvaliacao;
  late int _nota = _anterior?.nota ?? 0;
  late final _tags = {...?_anterior?.tags};
  late final _comentario = TextEditingController(
    text: _anterior?.comentario ?? '',
  );

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _enviar() {
    final p = widget.pedido;
    pedidos.avaliar(
      p,
      AvaliacaoEnviada(
        nota: _nota,
        tags: [
          for (final t in elogiosPara(p))
            if (_tags.contains(t)) t,
        ],
        comentario: _comentario.text.trim(),
      ),
    );
    final nav = Navigator.of(context);
    mostrarAvisoTopo(
      context,
      titulo: _anterior == null ? 'Avaliação enviada' : 'Avaliação editada',
      texto:
          'Obrigado por avaliar ${p.feminino ? 'a' : 'o'} ${p.primeiroNome}.',
    );
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    final artigo = p.feminino ? 'a' : 'o';
    return TelaInterna(
      titulo: '',
      acao: _anterior == null ? 'Pular' : null,
      onAcao: () => Navigator.of(context).pop(),
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes + 8),
        children: [
          Center(
            child: AvatarIniciais(nome: p.profissional, tamanho: _avatar),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Como foi com $artigo ${p.primeiroNome}?',
              maxLines: 1,
              style: _titulo,
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          EstrelasEscolha(
            nota: _nota,
            onMudar: (n) => setState(() => _nota = n),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 8),
          Text(
            'O que foi bom?',
            textAlign: TextAlign.center,
            style: TatuTexto.grupo,
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in elogiosPara(p))
                TatuChip(
                  label: t,
                  selecionado: _tags.contains(t),
                  onTap: () => setState(
                    () => _tags.contains(t) ? _tags.remove(t) : _tags.add(t),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: TatuColors.fill,
              borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
            ),
            child: TextField(
              controller: _comentario,
              maxLines: null,
              expands: true,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: TatuColors.textPrimary,
              style: const TextStyle(fontSize: 17),
              decoration: const InputDecoration.collapsed(
                hintText: 'Comentário (opcional)',
                hintStyle: TextStyle(
                  fontSize: 17,
                  color: TatuColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          Text(
            '${p.feminino ? 'A' : 'O'} ${p.primeiroNome} também avalia você.',
            textAlign: TextAlign.center,
            style: TatuTexto.nota,
          ),
        ],
      ),
      rodape: FilledButton(
        onPressed: _nota == 0 ? null : _enviar,
        child: Text(
          _anterior == null ? 'Enviar avaliação' : 'Salvar avaliação',
        ),
      ),
    );
  }
}

/// Sua avaliação (já enviada): o que você deu e até quando dá para editar.
class SuaAvaliacaoPage extends StatelessWidget {
  const SuaAvaliacaoPage({super.key, required this.pedido});

  final PedidoConcluido pedido;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pedidos,
      builder: (context, _) {
        final p = pedidos.atual(pedido);
        final a = p.minhaAvaliacao;
        return TelaInterna(
          titulo: 'Sua avaliação',
          corpo: a == null
              ? const SizedBox.shrink()
              : ListView(
                  padding: const EdgeInsets.only(
                    top: TatuMedidas.entreSecoes + 8,
                  ),
                  children: [
                    Center(
                      child: AvatarIniciais(
                        nome: p.profissional,
                        tamanho: _avatar,
                      ),
                    ),
                    const SizedBox(height: TatuMedidas.entreSecoes),
                    Text(
                      p.profissional,
                      textAlign: TextAlign.center,
                      style: _titulo,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.profissao} · ${p.dia}',
                      textAlign: TextAlign.center,
                      style: TatuTexto.detalhe,
                    ),
                    const SizedBox(height: TatuMedidas.entreSecoes + 8),
                    EstrelasEscolha(nota: a.nota),
                    if (a.tags.isNotEmpty) ...[
                      const SizedBox(height: TatuMedidas.entreSecoes + 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in a.tags)
                            TatuChip(label: t, selecionado: true, onTap: () {}),
                        ],
                      ),
                    ],
                    if (a.comentario.isNotEmpty) ...[
                      const SizedBox(height: TatuMedidas.entreSecoes),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TatuColors.fill,
                          borderRadius: BorderRadius.circular(
                            TatuMedidas.raioCartao,
                          ),
                        ),
                        child: Text(
                          a.comentario,
                          style: const TextStyle(fontSize: 17, height: 1.4),
                        ),
                      ),
                    ],
                    if (p.editavelAte != null) ...[
                      const SizedBox(height: TatuMedidas.entreSecoes),
                      Text(
                        'Você pode editar até ${p.editavelAte}.',
                        textAlign: TextAlign.center,
                        style: TatuTexto.nota,
                      ),
                    ],
                  ],
                ),
          rodape: FilledButton(
            style: tatuBotaoSecundario(),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => AvaliarPage(pedido: p))),
            child: const Text('Editar avaliação'),
          ),
        );
      },
    );
  }
}
