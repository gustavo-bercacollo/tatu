import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/arquivos_seguros.dart';
import '../../../data/regras_distancia.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/segmento.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tatu_field.dart';

/// O que o profissional escolheu entregar: link do site ou arquivo.
@immutable
class EntregaEscolhida {
  const EntregaEscolhida.link(String this.link) : arquivo = null;
  const EntregaEscolhida.arquivo(ArquivoEnviado this.arquivo) : link = null;

  final String? link;
  final ArquivoEnviado? arquivo;
}

/// Arquivos de exemplo do protótipo (no app de verdade, o seletor do
/// celular).
const arquivosDeExemplo = [
  ArquivoEnviado('entrega-final.zip', mb: 8),
  ArquivoEnviado('entrega-final.pdf', mb: 2),
  ArquivoEnviado('app-padaria.apk', mb: 32),
  ArquivoEnviado('instalar.sh', mb: 0.01),
];

/// P119 · "Entrega 1 de 2 · Escolha como entregar" (RN-125): Link do site
/// (qualquer serviço à distância) ou Arquivo (programa e script só em
/// profissão de tecnologia).
Future<EntregaEscolhida?> escolherEntrega(
  BuildContext context, {
  required int numero,
  required String cliente,
  required bool tecnologia,
}) => mostrarFolha<EntregaEscolhida>(
  context,
  builder: (_) => _FolhaEntrega(
    numero: numero,
    cliente: cliente,
    tecnologia: tecnologia,
  ),
);

class _FolhaEntrega extends StatefulWidget {
  const _FolhaEntrega({
    required this.numero,
    required this.cliente,
    required this.tecnologia,
  });

  final int numero;
  final String cliente;
  final bool tecnologia;

  @override
  State<_FolhaEntrega> createState() => _FolhaEntregaState();
}

class _FolhaEntregaState extends State<_FolhaEntrega> {
  bool _porLink = true;
  final _link = TextEditingController();
  ArquivoEnviado? _arquivo;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  bool get _linkOk {
    final t = _link.text.trim();
    return t.contains('.') && !t.contains(' ');
  }

  /// RN-125: programa e script só em profissão de tecnologia.
  String? get _erroArquivo {
    final a = _arquivo;
    if (a == null) return null;
    if (!RegrasArquivo.permitidoNaEntrega(a.nome, tecnologia: widget.tecnologia)) {
      return 'Programa e código só em profissões de tecnologia.';
    }
    if (!RegrasArquivo.cabeNaEntrega(a.mb)) {
      return 'Até ${RegrasArquivo.limiteEntregaMb} MB por arquivo.';
    }
    return null;
  }

  bool get _pronto => _porLink
      ? _linkOk
      : _arquivo != null && _erroArquivo == null;

  void _enviar() {
    if (!_pronto) return;
    Navigator.of(context).pop(
      _porLink
          ? EntregaEscolhida.link(_link.text.trim())
          : EntregaEscolhida.arquivo(_arquivo!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final max = RegrasDistancia.maxEntregas;
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
              Text(
                'Entrega ${widget.numero} de $max',
                style: TatuTexto.tituloFolha,
              ),
              const SizedBox(height: 4),
              const Text('Escolha como entregar.', style: TatuTexto.nota),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              Segmento(
                opcoes: const ['Link do site', 'Arquivo'],
                selecionada: _porLink ? 0 : 1,
                onMudar: (i) => setState(() => _porLink = i == 0),
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              if (_porLink) ...[
                TatuField(
                  label: 'Link',
                  hintText: 'seusite.com.br',
                  controller: _link,
                  autofocus: true,
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                // RN-126: todo link é verificado antes de chegar.
                Text(
                  'Verificamos o link antes de chegar à ${widget.cliente}.\n'
                  'No chat, links não são permitidos.',
                  style: TatuTexto.nota,
                ),
              ] else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in arquivosDeExemplo)
                      TatuChip(
                        label: a.nome,
                        selecionado: _arquivo == a,
                        onTap: () => setState(() => _arquivo = a),
                      ),
                  ],
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                if (_erroArquivo != null)
                  Text(
                    _erroArquivo!,
                    style: TatuTexto.nota.copyWith(color: TatuColors.danger),
                  )
                else
                  // RN-126: antivírus em todo arquivo.
                  Text(
                    'Até ${RegrasArquivo.limiteEntregaMb} MB. Passamos '
                    'antivírus antes de chegar à ${widget.cliente}.',
                    style: TatuTexto.nota,
                  ),
              ],
              const SizedBox(height: TatuMedidas.entreSecoes),
              FilledButton(
                onPressed: _pronto ? _enviar : null,
                child: const Text('Enviar entrega'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
