import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/conta.dart';
import '../../../data/gorjeta.dart';
import '../../../data/pagamentos.dart';
import '../../../data/pedidos.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/estrelas.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../abas.dart';
import '../pagamento/pagamento_page.dart';
import 'gorjeta.dart';

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

  /// RN-141: gorjeta escolhida (nula = só a avaliação).
  double? _gorjeta;

  /// RN-141: só na primeira avaliação, depois do serviço concluído, e
  /// com um cartão para cobrar (RN-142).
  bool get _temGorjeta => _anterior == null && pagamentos.padrao != null;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  /// RN-226: gorjeta recusada no cartão: "Não deu para enviar a
  /// gorjeta. Tentar outro cartão?". O profissional não é avisado.
  Future<bool> _cartaoDaGorjeta() async {
    while (!pagamentos.reservar(pagamentos.padrao)) {
      final outro = await confirmar(
        context,
        titulo: 'Não deu para enviar a gorjeta',
        texto: 'Tentar outro cartão?',
        confirmar: 'Tentar outro cartão',
        cancelar: 'Agora não',
        iconeAviso: false,
      );
      if (!outro || !mounted) return false;
      final antes = pagamentos.padrao?.id;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PagamentoPage()),
      );
      if (!mounted || pagamentos.padrao?.id == antes) return false;
    }
    return true;
  }

  Future<void> _enviar() async {
    final p = widget.pedido;
    // RN-143: a gorjeta não entra na avaliação (nem na nota).
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
    // RN-142: a gorjeta é cobrada no cartão padrão, no mesmo toque.
    final valor = _gorjeta;
    final querGorjeta = valor != null && _temGorjeta;
    final aprovada = querGorjeta && await _cartaoDaGorjeta();
    if (!mounted) return;
    final cartao = pagamentos.padrao?.curto;
    final g = !aprovada
        ? null
        : gorjetas.cobrar(
            cliente: conta.nome,
            profissional: p.profissional,
            valor: valor,
            cartao: cartao,
            // PedidoConcluido: o serviço já terminou.
            servicoConcluido: true,
          );
    if (g != null) {
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => GorjetaEnviadaPage(
            nome: p.primeiroNome,
            feminino: p.feminino,
            valor: g.valor,
            cartao: g.cartao,
            onInicio: () => irParaAba(ctx, AbaCliente.inicio),
          ),
        ),
      );
      return;
    }
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
          if (_temGorjeta) ...[
            CartaoGorjeta(
              nome: p.primeiroNome,
              feminino: p.feminino,
              valor: _gorjeta,
              onValor: (v) => setState(() => _gorjeta = v),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
          ],
          Text(
            _gorjeta != null && _temGorjeta
                ? 'Cobrado no ${pagamentos.padrao!.curto} junto com a avaliação.'
                : '${p.feminino ? 'A' : 'O'} ${p.primeiroNome} também avalia você.',
            textAlign: TextAlign.center,
            style: TatuTexto.nota,
          ),
        ],
      ),
      rodape: FilledButton(
        onPressed: _nota == 0 ? null : _enviar,
        child: Text(
          _anterior != null
              ? 'Salvar avaliação'
              // RN-142: com gorjeta, o botão diz o valor.
              : _gorjeta != null && _temGorjeta
              ? 'Enviar avaliação e ${reaisInteiros(_gorjeta!)}'
              : 'Enviar avaliação',
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
