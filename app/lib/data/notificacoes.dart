import 'package:flutter/foundation.dart';

/// Um tipo de aviso que a pessoa pode ligar ou desligar.
@immutable
class TipoAviso {
  const TipoAviso(this.id, this.titulo, this.detalhe, {this.dePedido = false});

  final String id;
  final String titulo;
  final String detalhe;

  /// Aviso sobre o pedido em andamento: desligar pede confirmação.
  final bool dePedido;
}

const avisosDePedido = [
  TipoAviso(
    'aceitou',
    'Profissional aceitou',
    'Quando alguém aceitar seu pedido',
    dePedido: true,
  ),
  TipoAviso(
    'caminho',
    'A caminho e chegada',
    'Quando o profissional sair e chegar',
    dePedido: true,
  ),
  TipoAviso(
    'mensagens',
    'Mensagens',
    'Novas mensagens no chat',
    dePedido: true,
  ),
  TipoAviso(
    'pagamento',
    'Valor e pagamento',
    'Propostas, cobranças e recibos',
    dePedido: true,
  ),
];

const avisosExtras = [
  TipoAviso('novidades', 'Novidades do Tatu', 'Dicas e promoções'),
  TipoAviso('avaliar', 'Lembrete para avaliar', 'Depois de cada serviço'),
];

/// Preferências de notificação. Versão simulada (sem backend nem a
/// permissão real do celular).
class NotificacoesRepo extends ChangeNotifier {
  NotificacoesRepo() {
    restaurar();
  }

  late Map<String, bool> _ligado;

  /// Permissão de notificação no celular (Ajustes do sistema).
  bool permitidoNoCelular = true;

  bool ligado(String id) => permitidoNoCelular && (_ligado[id] ?? false);

  /// Resumo para o Perfil.
  bool get ativas =>
      permitidoNoCelular && avisosDePedido.any((a) => _ligado[a.id] ?? false);

  void restaurar() {
    _ligado = {
      for (final a in avisosDePedido) a.id: true,
      'novidades': false,
      'avaliar': true,
    };
    permitidoNoCelular = true;
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

  /// Simula a pessoa negar notificações nos Ajustes do celular.
  void negarNoCelular() {
    permitidoNoCelular = false;
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final notificacoes = NotificacoesRepo();
