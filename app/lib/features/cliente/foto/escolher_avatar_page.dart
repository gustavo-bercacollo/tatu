import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/perfil.dart';
import '../../../shared/widgets/avatar_usuario.dart';
import '../../../shared/widgets/tela_interna.dart';

/// Escolha um avatar: prévia grande, os avatares prontos e "Salvar avatar".
/// Devolve `true` ao salvar.
class EscolherAvatarPage extends StatefulWidget {
  const EscolherAvatarPage({super.key});

  @override
  State<EscolherAvatarPage> createState() => _EscolherAvatarPageState();
}

class _EscolherAvatarPageState extends State<EscolherAvatarPage> {
  late String _escolhido = perfil.avatar ?? avataresProntos.first;

  void _salvar() {
    perfil.usarAvatar(_escolhido);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: 'Escolha um avatar',
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes + 4),
        children: [
          Center(
            child: AvatarComAro(
              imagem: AssetImage(_escolhido),
              tamanho: TatuMedidas.avatarGrande,
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          const Text(
            'Toque em um avatar para trocar',
            textAlign: TextAlign.center,
            style: TatuTexto.detalhe,
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (i, a) in avataresProntos.indexed)
                Semantics(
                  button: true,
                  selected: a == _escolhido,
                  label: 'Avatar ${i + 1}',
                  child: GestureDetector(
                    onTap: () => setState(() => _escolhido = a),
                    child: AvatarComAro(
                      imagem: AssetImage(a),
                      tamanho: TatuMedidas.avatarOpcao,
                      escolhido: a == _escolhido,
                      selo: true,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes * 2),
          const Text(
            'Mais avatares em breve',
            textAlign: TextAlign.center,
            style: TatuTexto.detalhe,
          ),
        ],
      ),
      rodape: FilledButton(
        onPressed: _salvar,
        child: const Text('Salvar avatar'),
      ),
    );
  }
}
