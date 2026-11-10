import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../data/enderecos.dart';
import '../../../data/notificacoes.dart';
import '../../../data/perfil.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../../shared/widgets/tela_interna.dart';

/// Permissões do aparelho: como estão localização, câmera, fotos e
/// notificações. Para mudar, a pessoa vai aos Ajustes do celular.
class PermissoesPage extends StatelessWidget {
  const PermissoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    void ajustes() => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Abrir Ajustes: em breve')));
    final aparelho = defaultTargetPlatform == TargetPlatform.iOS
        ? 'do iPhone'
        : 'do celular';
    return ListenableBuilder(
      listenable: Listenable.merge([enderecos, notificacoes, perfil]),
      builder: (context, _) => TelaInterna(
        titulo: 'Permissões',
        fundoCinza: true,
        corpo: ListView(
          padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
          children: [
            GrupoLista(
              nota:
                  'Para mudar uma permissão, abra os Ajustes\n$aparelho e procure o Tatu.',
              itens: [
                ItemLista(
                  icone: TablerIcons.map_pin,
                  texto: 'Localização',
                  valor: enderecos.localizacaoPermitida
                      ? 'Ao usar o app'
                      : 'Negada',
                  onTap: ajustes,
                ),
                ItemLista(
                  icone: TablerIcons.camera,
                  texto: 'Câmera',
                  valor: perfil.cameraPermitida ? 'Permitida' : 'Negada',
                  onTap: ajustes,
                ),
                ItemLista(
                  icone: TablerIcons.photo,
                  texto: 'Fotos',
                  valor: perfil.fotosPermitidas ? 'Permitida' : 'Negada',
                  onTap: ajustes,
                ),
                ItemLista(
                  icone: TablerIcons.bell,
                  texto: 'Notificações',
                  valor: notificacoes.permitidoNoCelular
                      ? 'Ativadas'
                      : 'Desativadas',
                  onTap: ajustes,
                ),
              ],
            ),
          ],
        ),
        rodape: FilledButton(
          onPressed: ajustes,
          child: const Text('Abrir Ajustes'),
        ),
      ),
    );
  }
}
