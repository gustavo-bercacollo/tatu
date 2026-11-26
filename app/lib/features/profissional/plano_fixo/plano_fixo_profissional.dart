import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/plano_fixo.dart';
import '../../../data/profissional.dart' show taxaTatu;
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../cliente/plano_fixo/plano_fixo.dart';

String _maiuscula(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// P130 · RN-144: o pedido de plano do cliente chega no chat.
class CartaoPedidoPlano extends StatelessWidget {
  const CartaoPedidoPlano({
    super.key,
    required this.plano,
    required this.onEnviarValor,
  });

  final PlanoFixo plano;
  final VoidCallback onEnviarValor;

  @override
  Widget build(BuildContext context) {
    final p = plano;
    final vezes = p.visitasPorSemana == 1 ? '1 vez' : '2 vezes';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${p.primeiroCliente} quer você fix${p.feminino ? 'a' : 'o'}',
          textAlign: TextAlign.center,
          style: TatuTexto.legenda,
        ),
        const SizedBox(height: 10),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.91,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
              border: Border.all(color: TatuColors.action, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Plano fixo · ${p.mensal ? 'Mensal' : 'Semanal'}',
                  style: TatuTexto.nota,
                ),
                const SizedBox(height: 6),
                Text(
                  _maiuscula(p.quando),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$vezes por semana · ${p.visitasNoPeriodo} visitas por '
                  '${p.periodo}',
                  style: TatuTexto.detalhe,
                ),
                const SizedBox(height: 8),
                Text(p.endereco, style: TatuTexto.nota),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                SizedBox(
                  height: TatuMedidas.alturaBotaoCartao + 4,
                  child: FilledButton(
                    onPressed: onEnviarValor,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        TatuMedidas.alturaBotaoCartao + 4,
                      ),
                    ),
                    child: const Text('Enviar valor do plano'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// P131 · RN-144/RN-146/RN-210: o profissional define o valor por visita
/// (1ª proposta) ou envia o último ([ultimo], 3ª). Devolve o valor.
Future<double?> pedirValorPlano(
  BuildContext context,
  PlanoFixo plano, {
  bool ultimo = false,
}) => mostrarFolha<double>(
  context,
  builder: (_) => _FolhaValorPlano(plano, ultimo: ultimo),
);

class _FolhaValorPlano extends StatefulWidget {
  const _FolhaValorPlano(this.plano, {this.ultimo = false});

  final PlanoFixo plano;
  final bool ultimo;

  @override
  State<_FolhaValorPlano> createState() => _FolhaValorPlanoState();
}

class _FolhaValorPlanoState extends State<_FolhaValorPlano> {
  final _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plano;
    final porVisita = double.tryParse(_campo.text) ?? 0;
    final total = porVisita * p.visitasNoPeriodo;
    final taxa = RegrasPlanoFixo.comissao(total);
    Widget linha(String a, String b, {bool forte = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              a,
              style: forte
                  ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)
                  : TatuTexto.nota.copyWith(fontSize: 14),
            ),
          ),
          Text(
            b,
            style: forte
                ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)
                : TatuTexto.nota.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
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
              const Text('Valor do plano', style: TatuTexto.tituloFolha),
              const SizedBox(height: 4),
              Text(
                widget.ultimo
                    ? 'É o seu último valor '
                          '(${RegrasPlanoFixo.maxPropostas} de '
                          '${RegrasPlanoFixo.maxPropostas}).'
                    : 'Vale todo ${p.periodo}.',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              TatuField(
                label: 'Por visita',
                controller: _campo,
                autofocus: true,
                hintText: 'R\$ 0',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: TatuMedidas.entreItens),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: BoxDecoration(
                  color: TatuColors.surfaceGrouped,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
                ),
                child: Column(
                  children: [
                    linha(
                      '${p.visitasNoPeriodo} visitas por ${p.periodo}',
                      reais(total),
                    ),
                    // RN-146: comissão normal do Tatu.
                    linha(
                      'Taxa do Tatu (${(taxaTatu * 100).round()}%)',
                      '− ${reais(taxa)}',
                    ),
                    linha(
                      'No seu Pix, por ${p.periodo}',
                      reais(total - taxa),
                      forte: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              const Text(
                // RN-146/RN-147.
                'Visita que você não for não é cobrada.',
                style: TatuTexto.legenda,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              FilledButton(
                onPressed: porVisita > 0
                    ? () => Navigator.of(context).pop(porVisita)
                    : null,
                child: Text('Enviar para ${p.primeiroCliente}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// P132 · RN-146 a RN-148: plano fixo do lado do profissional.
class PlanoFixoProfissionalPage extends StatelessWidget {
  const PlanoFixoProfissionalPage({super.key, required this.plano});

  final PlanoFixo plano;

  /// RN-147: avisar que não vai, sem penalidade.
  Future<void> _naoVou(BuildContext context, VisitaPlano v) async {
    final p = plano;
    final sim = await confirmar(
      context,
      titulo: 'Não vai nesta semana?',
      texto:
          'A visita de ${visitaTexto(p, v).toLowerCase()} não é cobrada '
          '${p.clienteFeminina ? 'da' : 'do'} ${p.primeiroCliente} e o Tatu '
          '${p.clienteFeminina ? 'a' : 'o'} avisa.',
      confirmar: 'Não vou nesta semana',
      cancelar: 'Voltar',
      iconeAviso: false,
    );
    if (!sim || !context.mounted) return;
    planosFixos.naoVou(p, v);
    mostrarAvisoTopo(
      context,
      titulo: 'Aviso enviado',
      texto: '${p.primeiroCliente} já sabe que você não vai.',
    );
  }

  Future<void> _cancelar(BuildContext context) async {
    final p = plano;
    final sim = await confirmar(
      context,
      titulo: 'Cancelar o plano?',
      texto: 'Vale a partir do próximo ${p.periodo}.',
      confirmar: 'Cancelar plano',
      cancelar: 'Voltar',
      perigo: true,
      destacarCancelar: true,
    );
    if (!sim || !context.mounted) return;
    planosFixos.cancelar(p);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: planosFixos,
    builder: (context, _) {
      final p = plano;
      final porVisita = p.valorPorVisita ?? 0;
      final total = porVisita * p.visitasNoPeriodo;
      final pix = total - RegrasPlanoFixo.comissao(total);
      final proxima = p.proximas.firstOrNull;
      final rua = p.endereco.split(',').first;
      return TelaInterna(
        titulo: 'Plano fixo',
        fundoCinza: true,
        corpo: ListView(
          padding: const EdgeInsets.only(top: TatuMedidas.entreItens),
          children: [
            TopoPlano(
              plano: p,
              nome: p.cliente,
              detalhe: '${_maiuscula(p.quando)} · $rua',
              rodape:
                  '${reaisInteiros(porVisita)} por visita · '
                  '${reaisInteiros(pix)} por ${p.periodo} no Pix',
            ),
            if (proxima != null) ...[
              const SizedBox(height: TatuMedidas.entreSecoes),
              const Text('PRÓXIMA VISITA', style: TatuTexto.secao),
              const SizedBox(height: TatuMedidas.tituloSecao),
              CartaoPlano(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitaTexto(p, proxima),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(p.endereco, style: TatuTexto.nota),
                    const SizedBox(height: TatuMedidas.entreItens),
                    GestureDetector(
                      onTap: () => _naoVou(context, proxima),
                      child: const Text(
                        'Não vou nesta semana',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TatuColors.verified,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TatuMedidas.entreItens),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  // RN-147.
                  'Avisar que não vai não tem penalidade:\n'
                  'a visita só não é cobrada '
                  '${p.clienteFeminina ? 'da' : 'do'} ${p.primeiroCliente}.',
                  style: TatuTexto.nota,
                ),
              ),
            ],
            const SizedBox(height: 200),
            if (p.status != StatusPlano.cancelado &&
                p.noProximoPeriodo != StatusPlano.cancelado) ...[
              Center(
                child: TextButton(
                  onPressed: () => _cancelar(context),
                  child: const Text(
                    'Cancelar plano',
                    style: TextStyle(fontSize: 17, color: TatuColors.danger),
                  ),
                ),
              ),
              Text(
                // RN-148.
                'Vale a partir do próximo ${p.periodo}.',
                textAlign: TextAlign.center,
                style: TatuTexto.legenda,
              ),
            ],
          ],
        ),
      );
    },
  );
}
