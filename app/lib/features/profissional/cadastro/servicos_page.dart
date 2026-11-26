import 'package:flutter/material.dart';

import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../cliente/outros/outros_servicos_sheet.dart';
import 'especialidades_page.dart';

/// P04 · Passo 2: quais serviços a pessoa faz (até 3).
/// Com [adicionar], escolhe só uma profissão a mais (vem do resumo).
class ServicosProfissionalPage extends StatefulWidget {
  const ServicosProfissionalPage({super.key, this.adicionar = false});

  final bool adicionar;

  @override
  State<ServicosProfissionalPage> createState() =>
      _ServicosProfissionalPageState();
}

class _ServicosProfissionalPageState extends State<ServicosProfissionalPage> {
  late final List<String> _escolhidas = widget.adicionar
      ? []
      : [for (final p in profissional.profissoes) p.nome];
  late final List<String> _extras = [
    for (final n in _escolhidas)
      if (!profissoesPrincipais.contains(n)) n,
  ];

  List<String> get _jaTem => widget.adicionar
      ? [for (final p in profissional.profissoes) p.nome]
      : const [];

  bool get _cheio => !widget.adicionar && _escolhidas.length >= maxProfissoes;

  void _alternar(String nome) {
    setState(() {
      if (_escolhidas.contains(nome)) {
        _escolhidas.remove(nome);
      } else if (widget.adicionar) {
        _escolhidas
          ..clear()
          ..add(nome);
      } else if (!_cheio) {
        _escolhidas.add(nome);
      }
    });
  }

  Future<void> _outros() async {
    final nome = await escolherOutroServico(context, profissional: true);
    if (nome == null || !mounted) return;
    setState(() {
      if (!profissoesPrincipais.contains(nome) && !_extras.contains(nome)) {
        _extras.add(nome);
      }
    });
    if (!_escolhidas.contains(nome)) _alternar(nome);
  }

  void _continuar() {
    if (widget.adicionar) {
      profissional.adicionarProfissao(ProfissaoEscolhida(_escolhidas.single));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EspecialidadesPage(
            indice: profissional.profissoes.length - 1,
            edicao: true,
            nova: true,
          ),
        ),
      );
      return;
    }
    final antigas = {for (final p in profissional.profissoes) p.nome: p};
    profissional.definirProfissoes([
      for (final n in _escolhidas) antigas[n] ?? ProfissaoEscolhida(n),
    ]);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EspecialidadesPage(indice: 0)),
    );
  }

  String? get _contagem {
    if (widget.adicionar) return null;
    final n = _escolhidas.length;
    if (n == 0) return 'Escolha até $maxProfissoes';
    return n == 1 ? '1 selecionado' : '$n selecionados';
  }

  @override
  Widget build(BuildContext context) {
    final opcoes = [
      for (final n in [...profissoesPrincipais, ..._extras])
        if (!_jaTem.contains(n)) n,
    ];
    return CadastroScaffold(
      passo: 2,
      titulo: widget.adicionar
          ? 'Qual é a sua profissão?'
          : 'Quais serviços você faz?',
      subtitulo: widget.adicionar
          ? 'Você só recebe chamados das profissões que adicionar.'
          : 'Você só recebe chamados dos serviços que escolher.',
      notaAcimaBotao: _contagem,
      botao: 'Continuar',
      onBotao: _escolhidas.isEmpty ? null : _continuar,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final nome in opcoes)
              TatuChip(
                label: nome,
                // RN-227: o ícone da profissão (branco se escolhida).
                profissao: nome,
                selecionado: _escolhidas.contains(nome),
                desabilitado: _cheio && !_escolhidas.contains(nome),
                onTap: () => _alternar(nome),
              ),
            // C04 · RN-161: "Outros" não é profissão: nunca fica
            // selecionado nem conta no limite; só abre a lista.
            TatuChip(
              label: 'Outros',
              seletor: true,
              iconeOutros: true,
              desabilitado: _cheio,
              onTap: _outros,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          _cheio
              ? 'Para trocar, desmarque um dos escolhidos.'
              : 'Dá para mudar depois, no seu perfil.',
          style: TatuTexto.nota,
        ),
      ],
    );
  }
}
