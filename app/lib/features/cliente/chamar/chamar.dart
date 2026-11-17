import 'package:flutter/material.dart';

import '../../../data/chamado.dart';
import '../../../data/conta.dart';
import '../../../data/enderecos.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/folha.dart';
import '../atividade/pedido_andamento_page.dart';
import '../endereco/onde_sheet.dart';
import 'confirmar_celular_sheet.dart';
import 'fora_da_area_page.dart';
import 'localizacao_chamar_page.dart';
import 'procurando_page.dart';

/// "Chamar (serviço)": antes de procurar, confere localização, região,
/// celular para contato e se já há um pedido igual a caminho.
/// Com [distancia] (RN-93), endereço e localização não contam.
Future<void> chamarProfissional(
  BuildContext context,
  String servico, {
  bool distancia = false,
}) async {
  final nav = Navigator.of(context);

  // 1. Sem localização não achamos profissionais perto.
  if (!distancia && !enderecos.localizacaoPermitida) {
    final usarSalvo = await nav.push<bool>(
      MaterialPageRoute(builder: (_) => const LocalizacaoChamarPage()),
    );
    if (usarSalvo == true && context.mounted) await abrirOndeServico(context);
    return;
  }

  // 2. Região ainda não atendida.
  if (!distancia && !chamado.regiaoAtendida) {
    final mudar = await nav.push<bool>(
      MaterialPageRoute(builder: (_) => const ForaDaAreaPage()),
    );
    if (mudar == true && context.mounted) await abrirOndeServico(context);
    return;
  }

  // 3. Cadastro pelo e-mail: pedimos o celular uma vez.
  if (conta.celular == null) {
    if (!context.mounted) return;
    final confirmou = await confirmarCelular(context);
    if (confirmou != true) return;
  }

  // 4. Já existe um pedido do mesmo serviço a caminho.
  final atual = pedidos.andamento;
  if (atual != null && atual.servico == servico && context.mounted) {
    final chamarOutro = await perguntar(
      context,
      titulo: atual.distancia
          ? 'Já tem um ${servico.toLowerCase()} atendendo'
          : 'Já tem um ${servico.toLowerCase()} a caminho',
      texto: atual.distancia
          ? '${atual.artigoNome} está com o seu pedido.\nQuer chamar outro mesmo assim?'
          : 'A ${atual.primeiroNome} chega em ${atual.chegaEm}.\nQuer chamar outro mesmo assim?',
      confirmar: 'Chamar outro',
      cancelar: 'Ver pedido atual',
      destacarCancelar: true,
    );
    if (chamarOutro == null) return;
    if (!chamarOutro) {
      nav.push(MaterialPageRoute(builder: (_) => const PedidoAndamentoPage()));
      return;
    }
  }

  // 5. Procura: pedido vai a todos os ativos por perto.
  nav.push(
    MaterialPageRoute(
      builder: (_) => ProcurandoPage(
        servico: servico,
        endereco: distancia ? 'À distância' : enderecos.atual.rua,
        distancia: distancia,
      ),
    ),
  );
}
