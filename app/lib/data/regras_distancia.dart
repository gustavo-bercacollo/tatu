/// Números da entrega à distância que ainda são exemplo (ver "Números do
/// serviço à distância" em docs/regras-de-negocio.md). Mudou um, muda só
/// aqui.
abstract final class RegrasDistancia {
  /// RN-102: o sinal pode ser de até 30% do valor.
  static const sinalMaximo = 0.30;

  /// RN-99: a prévia protegida expira depois disso.
  static const validadePrevia = Duration(hours: 24);

  /// RN-100: sem resposta do cliente, a entrega é aprovada sozinha.
  static const aprovacaoAutomatica = Duration(hours: 48);

  /// RN-101: no máximo 2 entregas por valor.
  static const maxEntregas = 2;

  /// RN-104 e RN-105: prazo do suporte para decidir.
  static const diasUteisSuporte = 2;

  /// RN-106: sinais sem entrega que pausam a conta dentro da janela.
  static const sinaisParaPausar = 3;
  static const janelaSinais = Duration(days: 30);

  /// RN-102: sinal máximo para um valor (arredondado em reais).
  static double sinalDe(double valor) =>
      (valor * sinalMaximo).roundToDouble();

  /// RN-99: a prévia enviada em [enviadaEm] ainda abre?
  static bool previaValida(DateTime enviadaEm, DateTime agora) =>
      agora.difference(enviadaEm) < validadePrevia;

  /// RN-100: a entrega enviada em [enviadaEm] já foi aprovada sozinha?
  static bool aprovadaSozinha(DateTime enviadaEm, DateTime agora) =>
      agora.difference(enviadaEm) >= aprovacaoAutomatica;
}
