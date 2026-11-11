/// Medidas padrão do Tatu. Toda tela usa estes valores; nada de números
/// soltos de margem, raio ou altura nas telas.
class TatuMedidas {
  TatuMedidas._();

  // Margens laterais
  static const margem = 20.0; // telas internas, Home, Perfil, folhas
  static const margemCadastro = 24.0; // entrada e cadastro (guia de design)

  // Respiro vertical das telas
  static const topo = 20.0; // acima do botão de voltar / topo
  static const base = 24.0; // abaixo do último botão

  // Espaços entre blocos
  static const entreItens = 12.0; // campos e cartões seguidos
  static const entreSecoes = 24.0; // seções (ex.: lista → botão tracejado)
  static const tituloSecao = 8.0; // título em maiúsculas → cartão

  // Raios
  static const raioCartao = 18.0; // cartões, listas agrupadas, caixas
  static const raioCampo = 16.0; // campos de texto e busca
  static const raioOpcao = 22.0; // cartões grandes de escolha (Boas-vindas)
  static const raioFolha = 30.0; // topo das folhas
  static const raioCodigo = 14.0; // caixinhas do código
  static const raioSegmento = 12.0; // seletor Recebidas/Enviadas

  // Alturas
  static const alturaBotao = 56.0;
  static const alturaCampo = 62.0;
  static const alturaBusca = 48.0;
  static const alturaChip = 38.0;
  static const alturaChipPequeno = 34.0; // botões dentro de cartões
  static const alturaLinha = 52.0;
  static const alturaSegmento = 36.0;

  /// Largura máxima do conteúdo (no computador a tela não estica).
  static const larguraMax = 430.0;

  // Avatares e foto do perfil
  static const avatarPerfil = 76.0; // topo do Perfil
  static const avatarGrande = 124.0; // prévia em "Escolha um avatar"
  static const avatarOpcao = 80.0; // cada avatar para escolher (3 por fileira)
  static const aroAvatar = 3.0; // aro preto do avatar escolhido
  static const circuloRecorte = 300.0; // círculo de "Ajustar foto"
}
