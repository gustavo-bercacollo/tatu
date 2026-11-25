import 'prazos.dart';
import 'profissional.dart' show taxaTatu;

/// RN-150: pontos curtos mostrados no aceite. São frases de tela, não
/// texto legal: cada uma resume um item de "O essencial em 1 minuto" dos
/// Termos de Uso ([item] é a posição na lista do `.md`; [chaves] são as
/// palavras que o item precisa ter). Um teste confere que batem.
class PontoResumo {
  const PontoResumo(this.texto, {required this.item, required this.chaves});

  final String texto;
  final int item;
  final List<String> chaves;
}

/// C09 · "O essencial do Tatu" no cadastro do cliente.
const resumoCliente = [
  PontoResumo(
    'O Tatu conecta, não presta o serviço.',
    item: 0,
    chaves: ['conecta', 'não presta'],
  ),
  PontoResumo(
    'Pagamento só pelo app. Nada por fora.',
    item: 2,
    chaves: ['pelo app', 'por fora'],
  ),
  PontoResumo(
    'Cobrado só quando o serviço termina.',
    item: 3,
    chaves: ['cobrado quando o serviço é concluído'],
  ),
  PontoResumo(
    // RN-108: nunca dizer que a garantia acaba em 24 horas.
    'Algo errado? Pagamento protegido por 24 horas e retorno sem custo.',
    item: 5,
    chaves: ['24 horas', 'retorno sem custo'],
  ),
];

/// Um ponto do aceite do profissional (P15), com ícone.
class PontoProfissional {
  const PontoProfissional(
    this.titulo,
    this.texto, {
    required this.item,
    required this.chaves,
  });

  final String titulo;
  final String texto;
  final int item;
  final List<String> chaves;
}

/// P15 · "Antes de enviar": autônomo, taxa, Pix em 24 h, só pelo app. A
/// taxa vem da mesma constante da comissão ([taxaTatu]).
List<PontoProfissional> resumoProfissional() => [
  const PontoProfissional(
    'Você é autônomo',
    'Sem vínculo de emprego. Você escolhe quando trabalha.',
    item: 0,
    chaves: ['autônomos', 'não é empregador'],
  ),
  PontoProfissional(
    'Taxa de ${porcento(taxaTatu)} por pagamento',
    'Já descontada. Gorjeta é 100% sua.',
    item: 4,
    chaves: const ['taxa de intermediação', '100%'],
  ),
  PontoProfissional(
    'Recebe no Pix em ${Prazos.repasse.inHours} horas',
    'Depois do serviço concluído, na chave do seu CPF.',
    item: 3,
    chaves: const ['concluído'],
  ),
  const PontoProfissional(
    'Pagamento só pelo app',
    'Cobrar por fora pode suspender sua conta.',
    item: 2,
    chaves: ['pelo app', 'por fora'],
  ),
];

/// "10%".
String porcento(double fracao) {
  final p = fracao * 100;
  return p == p.roundToDouble()
      ? '${p.round()}%'
      : '${p.toStringAsFixed(1).replaceAll('.', ',')}%';
}
