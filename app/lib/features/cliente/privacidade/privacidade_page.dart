import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../data/documentos.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../../shared/widgets/tela_interna.dart';
import 'documento_page.dart';
import 'permissoes_page.dart';
import 'seus_dados_page.dart';

/// Privacidade e termos: documentos, permissões do aparelho e seus dados.
class PrivacidadePage extends StatelessWidget {
  const PrivacidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    void abrir(Widget tela) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
    return TelaInterna(
      titulo: 'Privacidade e termos',
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes + 4),
        children: [
          GrupoLista(
            titulo: 'Documentos',
            itens: [
              ItemLista(
                icone: TablerIcons.file_text,
                texto: 'Termos de uso',
                onTap: () => abrir(const DocumentoPage(documento: termosDeUso)),
              ),
              ItemLista(
                icone: TablerIcons.lock,
                texto: 'Política de privacidade',
                onTap: () => abrir(
                  const DocumentoPage(
                    documento: politicaDePrivacidade,
                    linkSeusDados: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          GrupoLista(
            titulo: 'No seu aparelho',
            itens: [
              ItemLista(
                icone: TablerIcons.phone,
                texto: 'Permissões',
                onTap: () => abrir(const PermissoesPage()),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          GrupoLista(
            titulo: 'Seus dados',
            nota: 'Você controla suas informações no Tatu.',
            itens: [
              ItemLista(
                icone: TablerIcons.shield_check,
                texto: 'Seus dados e direitos',
                onTap: () => abrir(const SeusDadosPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
