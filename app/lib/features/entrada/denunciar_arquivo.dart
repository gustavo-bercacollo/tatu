import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/arquivos_seguros.dart';
import '../../shared/widgets/folha.dart';
import '../../shared/widgets/opcao_selecionavel.dart';

/// C161/P58 · "Denunciar arquivo" (RN-123), ao segurar o dedo sobre um
/// arquivo recebido. Devolve o motivo (nulo se fechar).
Future<String?> denunciarArquivo(BuildContext context) =>
    mostrarFolha<String>(context, builder: (_) => const _FolhaDenuncia());

class _FolhaDenuncia extends StatefulWidget {
  const _FolhaDenuncia();

  @override
  State<_FolhaDenuncia> createState() => _FolhaDenunciaState();
}

class _FolhaDenunciaState extends State<_FolhaDenuncia> {
  String? _motivo;

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
            const SizedBox(height: 22),
            const Text('Denunciar arquivo', style: TatuTexto.tituloFolha),
            const SizedBox(height: 4),
            const Text(
              'O arquivo some do seu chat e o suporte analisa.',
              style: TatuTexto.nota,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            for (final m in motivosDenunciaArquivo) ...[
              OpcaoSelecionavel(
                selecionado: _motivo == m,
                rotulo: m,
                onTap: () => setState(() => _motivo = m),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
            const Text(
              'Se for grave, a conta de quem enviou é suspensa\n'
              'na hora e o caso vai para as autoridades.',
              style: TatuTexto.nota,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            FilledButton(
              onPressed: _motivo == null
                  ? null
                  : () => Navigator.of(context).pop(_motivo),
              child: const Text('Enviar denúncia'),
            ),
          ],
        ),
      ),
    );
  }
}

/// RN-120: aviso no lugar do arquivo barrado; só quem enviou vê.
class BalaoBloqueado extends StatelessWidget {
  const BalaoBloqueado({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TatuColors.surfaceGrouped,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            border: Border.all(color: TatuColors.chevron, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    TablerIcons.alert_triangle,
                    size: 18,
                    color: TatuColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Imagem bloqueada',
                    style: TatuTexto.corpo.copyWith(
                      fontWeight: FontWeight.w700,
                      color: TatuColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Não segue as regras do Tatu.\nSó você vê este aviso.',
                style: TatuTexto.nota,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
