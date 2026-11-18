import 'package:flutter/foundation.dart';

/// Situações que valem na hora de chamar um profissional. Versão simulada
/// (sem backend): servem para a demo mostrar cada caso.
class ChamadoRepo extends ChangeNotifier {
  ChamadoRepo() {
    restaurar();
  }

  /// O endereço do pedido fica numa região atendida pelo Tatu.
  late bool regiaoAtendida;

  /// A pessoa pediu para ser avisada quando o Tatu chegar à região.
  late bool avisarQuandoChegar;

  void restaurar() {
    regiaoAtendida = true;
    avisarQuandoChegar = false;
    notifyListeners();
  }

  void definirRegiaoAtendida(bool valor) {
    regiaoAtendida = valor;
    notifyListeners();
  }

  void pedirAviso() {
    avisarQuandoChegar = true;
    notifyListeners();
  }
}


/// Instância única usada pelo app enquanto não há backend.
final chamado = ChamadoRepo();
