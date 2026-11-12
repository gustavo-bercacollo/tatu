import 'som_nativo.dart' if (dart.library.js_interop) 'som_web.dart' as impl;

/// Sons do app (arquivos em `assets/sons/`). No navegador do celular o som
/// só toca depois de um toque na tela, então [destravarSons] roda no
/// primeiro toque (em `TatuApp`) e prepara os sons para tocarem sozinhos
/// depois (chamado novo, profissional encontrado).
const sonsDoApp = [
  'sons/encontrado.wav',
  'sons/chamado.wav',
  'sons/sino.wav',
  'sons/buzina.wav',
  'sons/padrao.wav',
];

/// Chamar dentro de um toque (é o que libera o som no navegador).
void destravarSons() => impl.destravar(sonsDoApp);

/// Toca [arquivo] (ex.: `sons/encontrado.wav`); com [repetir], em loop
/// até [pararSom].
Future<void> tocarSom(String arquivo, {bool repetir = false}) =>
    impl.tocar(arquivo, repetir: repetir);

Future<void> pararSom(String arquivo) => impl.parar(arquivo);
