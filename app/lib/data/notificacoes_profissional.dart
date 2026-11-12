import 'package:flutter/foundation.dart';

import 'notificacoes.dart';

/// Avisos sobre os chamados (o "novo chamado" pede confirmação para
/// desligar).
const avisosDeChamado = [
  TipoAviso(
    'novo',
    'Novo chamado',
    'Quando um cliente perto chamar',
    dePedido: true,
  ),
  TipoAviso('respondeu', 'Cliente respondeu', 'Mensagens no chat'),
  TipoAviso(
    'valor',
    'Valor aceito ou nova proposta',
    'Andamento da negociação',
  ),
];

const avisosDeGanhos = [
  TipoAviso(
    'pagamento',
    'Pagamento recebido',
    'Quando o Pix cair na sua conta',
  ),
];

const avisosExtrasProfissional = [
  TipoAviso('resumo', 'Resumo semanal de ganhos', 'Toda segunda-feira'),
  TipoAviso('dicas', 'Dicas e novidades', 'Como receber mais chamados'),
];

/// Som que toca quando chega um chamado.
enum SomChamado { alerta, sino, buzina, padrao }

extension SomChamadoTexto on SomChamado {
  String get nome => switch (this) {
    SomChamado.alerta => 'Alerta Tatu',
    SomChamado.sino => 'Sino',
    SomChamado.buzina => 'Buzina',
    SomChamado.padrao => 'Padrão do celular',
  };

  /// Arquivo em assets/sons/.
  String get arquivo => switch (this) {
    SomChamado.alerta => 'sons/chamado.wav',
    SomChamado.sino => 'sons/sino.wav',
    SomChamado.buzina => 'sons/buzina.wav',
    SomChamado.padrao => 'sons/padrao.wav',
  };
}

/// Notificações do profissional. Versão simulada (sem a permissão real
/// do celular).
class NotificacoesProfissionalRepo extends ChangeNotifier {
  NotificacoesProfissionalRepo() {
    restaurar();
  }

  late Map<String, bool> _ligado;

  /// Já mostramos o pedido de permissão ("Não perca nenhum chamado").
  bool perguntado = false;

  /// Permissão de notificação no celular (Ajustes do sistema).
  bool permitidoNoCelular = true;

  SomChamado som = SomChamado.alerta;
  bool vibrar = true;

  bool ligado(String id) => permitidoNoCelular && (_ligado[id] ?? false);

  /// Resumo para o Perfil.
  bool get ativas => permitidoNoCelular && ligado('novo');

  void restaurar() {
    _ligado = {
      for (final a in [...avisosDeChamado, ...avisosDeGanhos]) a.id: true,
      for (final a in avisosExtrasProfissional) a.id: false,
    };
    perguntado = false;
    permitidoNoCelular = true;
    som = SomChamado.alerta;
    vibrar = true;
    notifyListeners();
  }

  void definir(String id, bool valor) {
    _ligado[id] = valor;
    notifyListeners();
  }

  void ativarTodas() {
    _ligado.updateAll((_, _) => true);
    notifyListeners();
  }

  /// Resposta ao pedido de permissão.
  void responderPermissao({required bool permitiu}) {
    perguntado = true;
    permitidoNoCelular = permitiu;
    notifyListeners();
  }

  /// Simula a pessoa negar notificações nos Ajustes do celular.
  void negarNoCelular() {
    perguntado = true;
    permitidoNoCelular = false;
    notifyListeners();
  }

  void escolherSom(SomChamado s) {
    som = s;
    notifyListeners();
  }

  void definirVibrar(bool v) {
    vibrar = v;
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final notificacoesProfissional = NotificacoesProfissionalRepo();
