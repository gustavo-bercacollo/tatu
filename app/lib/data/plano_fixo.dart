import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'canal_tatu.dart';
import 'profissional.dart' as pro;

/// RN-144 a RN-149: plano fixo (cliente "torna" um profissional fixo).

/// RN-144: período do plano.
enum FrequenciaPlano { semanal, mensal }

/// RN-144/RN-148: situação do plano.
enum StatusPlano {
  /// Pedido feito; esperando o valor do profissional ou o aceite do
  /// cliente.
  pendente,
  ativo,
  pausado,
  cancelado,
}

/// O que aconteceu com uma visita do plano.
enum SituacaoVisita {
  agendada,

  /// RN-206: a profissional saiu para a visita.
  aCaminho,

  /// RN-206: a visita começou (código na porta).
  emServico,
  feita,

  /// RN-147: o profissional avisou "Não vou nesta semana" (sem
  /// penalidade, não cobrada).
  naoVai,

  /// RN-147: faltou sem avisar (abandono, RN-76 a RN-79; não cobrada).
  faltou,
}

const _diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
const _diasLongos = [
  'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo',
];
const _meses = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

/// "Seg" a "Sáb" para escolher o dia (1 = segunda).
String diaCurto(int weekday) => _diasSemana[weekday - 1];

/// "terça".
String diaLongo(int weekday) => _diasLongos[weekday - 1];

/// "25 nov".
String diaMes(DateTime d) => '${d.day} ${_meses[d.month - 1]}';

/// "9h" ou "9h30".
String horaCurta(String horario) {
  final p = horario.split(':');
  return p.length < 2 || p[1] == '00' ? '${p[0]}h' : '${p[0]}h${p[1]}';
}

abstract final class RegrasPlanoFixo {
  /// RN-145: a mesma profissional vai no máximo isso por semana ao mesmo
  /// endereço pelo Tatu, somando plano e pedidos avulsos (Lei
  /// Complementar 150: acima disso, carteira assinada).
  static const maxVisitasSemana = 2;

  /// Semanas de um período mensal (exemplo: 4 visitas por mês com 1 por
  /// semana).
  static const semanasPorMes = 4;

  /// RN-145: aviso da 3ª visita na semana.
  static const avisoLimite =
      'Pelo Tatu, a mesma profissional pode vir até 2 vezes por semana. '
      'Para mais que isso, a lei exige contratação com carteira assinada.';

  /// Visitas previstas num período.
  static int visitasNoPeriodo(FrequenciaPlano f, int porSemana) =>
      f == FrequenciaPlano.semanal ? porSemana : porSemana * semanasPorMes;

  /// RN-146: valor por visita × visitas feitas.
  static double cobranca(double porVisita, int feitas) => porVisita * feitas;

  /// RN-146: comissão normal do Tatu em cada cobrança.
  static double comissao(double total) => total * pro.taxaTatu;
}

/// RN-205: estado do plano, do jeito que o selo e a barra mostram.
enum EstadoPlano {
  aguardandoValor,
  valorEnviado,
  ativo,
  semVisitaNaSemana,
  pausado,
  cancelado,
  encerrado,
}

/// RN-202/RN-205: barra fixa no chat ("Plano fixo · toda terça, 9h ·
/// Próxima: 25 nov ›"). [laranja] só quando o cliente precisa agir.
@immutable
class BarraPlano {
  const BarraPlano(this.texto, {this.direita, this.laranja = false});

  final String texto;
  final String? direita;
  final bool laranja;
}

/// Uma visita do plano.
class VisitaPlano {
  VisitaPlano(this.dia);

  final DateTime dia;
  SituacaoVisita situacao = SituacaoVisita.agendada;

  /// RN-206: minutos até chegar (pílula escura "8 min").
  int minutosParaChegar = 8;

  /// Visita de hoje ainda acontecendo (agendada, a caminho ou em serviço).
  bool get emAberto =>
      situacao == SituacaoVisita.agendada ||
      situacao == SituacaoVisita.aCaminho ||
      situacao == SituacaoVisita.emServico;
}

/// RN-206: etapas da visita do plano (sem Pagamento: a cobrança é no fim
/// do mês).
const etapasVisitaPlano = ['Agendada', 'A caminho', 'Serviço', 'Feita'];

const _mesesLongos = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

/// "novembro".
String mesLongo(DateTime d) => _mesesLongos[d.month - 1];

/// RN-146: cobrança automática no fim de um período.
@immutable
class CobrancaPlano {
  const CobrancaPlano({
    required this.visitasFeitas,
    required this.total,
    required this.comissao,
  });

  final int visitasFeitas;
  final double total;
  final double comissao;

  /// O que vai para o Pix do profissional.
  double get repasse => total - comissao;
}

/// RN-144: plano fixo entre um cliente e um profissional, num endereço.
class PlanoFixo {
  PlanoFixo({
    required this.cliente,
    required this.profissional,
    required this.endereco,
    required this.frequencia,
    required this.visitasPorSemana,
    required this.dias,
    required this.horario,
    this.profissao = 'Encanadora',
    this.feminino = true,
    this.clienteFeminina = true,
  });

  final String cliente;

  /// Para "da Ana" / "do Carlos".
  final bool clienteFeminina;
  final String profissional;
  final String profissao;
  final bool feminino;
  final String endereco;
  FrequenciaPlano frequencia;

  /// 1 ou 2 (RN-145).
  int visitasPorSemana;

  /// Dias da semana (1 = segunda … 6 = sábado).
  List<int> dias;

  /// "9:00".
  String horario;

  /// RN-144: valor por visita que o profissional enviou (nulo = ainda não).
  double? valorPorVisita;
  StatusPlano status = StatusPlano.pendente;

  /// Cartão onde é cobrado (o padrão, ao confirmar).
  String? cartao;

  /// RN-149: quando o cliente aceitou os Termos do plano fixo (ao
  /// confirmar: serviço autônomo, o Tatu intermedia, até 2 visitas por
  /// semana).
  DateTime? aceitouTermosEm;

  /// RN-148: o que muda a partir do próximo período (pausar, cancelar).
  StatusPlano? noProximoPeriodo;

  /// RN-148: novo valor proposto pelo profissional, esperando o aceite.
  double? valorProposto;

  /// Visitas do período atual.
  final visitas = <VisitaPlano>[];

  /// Começo do período atual.
  DateTime? inicioPeriodo;

  /// RN-146: cobrança automática no fim do período (último dia do mês ou
  /// domingo da semana).
  DateTime? get proximaCobranca {
    final i = inicioPeriodo;
    if (i == null) return null;
    if (mensal) return DateTime(i.year, i.month + 1, 0);
    return DateTime(i.year, i.month, i.day + (7 - i.weekday));
  }

  /// Cobranças já feitas (RN-146).
  final cobrancas = <CobrancaPlano>[];

  /// RN-205: quando o plano acabou de vez (cancelado e fora do período).
  DateTime? encerradoEm;

  /// RN-205: estado para o selo e a barra.
  EstadoPlano estado([DateTime? agora]) {
    final hoje = agora ?? clock.now();
    switch (status) {
      case StatusPlano.pendente:
        return valorPorVisita == null
            ? EstadoPlano.aguardandoValor
            : EstadoPlano.valorEnviado;
      case StatusPlano.pausado:
        return EstadoPlano.pausado;
      case StatusPlano.cancelado:
        return EstadoPlano.encerrado;
      case StatusPlano.ativo:
        if (noProximoPeriodo == StatusPlano.cancelado) {
          return EstadoPlano.cancelado;
        }
        final semana = visitas.where((v) => _mesmaSemanaDe(v.dia, hoje));
        final temNaSemana = semana.any(
          (v) => v.emAberto || v.situacao == SituacaoVisita.feita,
        );
        return temNaSemana ? EstadoPlano.ativo : EstadoPlano.semVisitaNaSemana;
    }
  }

  static bool _mesmaSemanaDe(DateTime a, DateTime b) {
    DateTime inicio(DateTime d) =>
        DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
    return inicio(a) == inicio(b);
  }

  /// RN-200/RN-205: texto do selo (nulo = sem selo).
  String? selo([DateTime? agora]) => switch (estado(agora)) {
    EstadoPlano.ativo || EstadoPlano.semVisitaNaSemana => 'Plano fixo',
    EstadoPlano.pausado => 'Plano pausado',
    EstadoPlano.cancelado =>
      'Plano até ${diaMes(proximaCobranca ?? clock.now())}',
    _ => null,
  };

  /// RN-205: "Plano pausado" fica cinza apagado.
  bool get seloApagado => status == StatusPlano.pausado;

  /// Próxima visita marcada (nula se não houver).
  VisitaPlano? get proximaVisita => proximas.firstOrNull;

  /// RN-203: "visita 3 de 4" (posição no período).
  int numeroDa(VisitaPlano v) => visitas.indexOf(v) + 1;

  /// RN-204: visita marcada para hoje (nula se não houver).
  VisitaPlano? visitaDeHoje([DateTime? agora]) {
    final hoje = agora ?? clock.now();
    if (status != StatusPlano.ativo) return null;
    return visitas
        .where(
          (v) =>
              v.emAberto &&
              v.dia.year == hoje.year &&
              v.dia.month == hoje.month &&
              v.dia.day == hoje.day,
        )
        .firstOrNull;
  }

  /// RN-202/RN-205: barra do chat para quem está vendo ([cliente] ou
  /// profissional). Nula quando o plano está encerrado.
  BarraPlano? barra({required bool cliente, DateTime? agora}) {
    final proxima = proximaVisita;
    final prox = proxima == null ? null : 'Próxima: ${diaMes(proxima.dia)}';
    return switch (estado(agora)) {
      EstadoPlano.aguardandoValor => BarraPlano(
        cliente
            ? 'Plano fixo · aguardando o valor ${feminino ? 'da' : 'do'} '
                  '$primeiroNome'
            : 'Plano fixo · envie o valor por visita',
      ),
      EstadoPlano.valorEnviado => cliente
          ? BarraPlano(
              'Plano fixo · confirme o valor',
              direita: 'R\$ ${valorPorVisita!.round()}/visita',
              laranja: true,
            )
          : BarraPlano(
              'Plano fixo · aguardando ${clienteFeminina ? 'a' : 'o'} '
              '$primeiroCliente confirmar',
            ),
      EstadoPlano.ativo => BarraPlano('Plano fixo · $quando', direita: prox),
      EstadoPlano.semVisitaNaSemana => BarraPlano(
        'Sem visita nesta semana',
        direita: prox,
      ),
      EstadoPlano.pausado => const BarraPlano(
        'Plano pausado · volta quando quiser',
      ),
      EstadoPlano.cancelado => BarraPlano(
        'Plano termina em ${diaMes(proximaCobranca ?? clock.now())}',
      ),
      EstadoPlano.encerrado => null,
    };
  }

  String get primeiroNome => profissional.split(' ').first;
  String get primeiroCliente => cliente.split(' ').first;
  bool get mensal => frequencia == FrequenciaPlano.mensal;
  int get visitasNoPeriodo =>
      RegrasPlanoFixo.visitasNoPeriodo(frequencia, visitasPorSemana);

  /// "R$ 600 por mês" antes das faltas: valor × visitas previstas.
  double get valorDoPeriodo => (valorPorVisita ?? 0) * visitasNoPeriodo;

  int get feitas =>
      visitas.where((v) => v.situacao == SituacaoVisita.feita).length;

  Iterable<VisitaPlano> get proximas =>
      visitas.where((v) => v.situacao == SituacaoVisita.agendada);

  /// "toda terça, 9h" / "toda terça e quinta, 9h".
  String get quando =>
      'toda ${dias.map(diaLongo).join(' e ')}, ${horaCurta(horario)}';

  String get periodo => mensal ? 'mês' : 'semana';
}

/// Planos fixos e pedidos avulsos. Versão simulada (sem backend).
class PlanosFixosRepo extends ChangeNotifier {
  final planos = <PlanoFixo>[];

  /// RN-145: pedidos avulsos (profissional, endereço, dia).
  final _avulsos = <(String, String, DateTime)>[];

  void restaurar() {
    planos.clear();
    _avulsos.clear();
    notifyListeners();
  }

  static DateTime _inicioDaSemana(DateTime d) {
    final dia = DateTime(d.year, d.month, d.day);
    return dia.subtract(Duration(days: dia.weekday - 1));
  }

  static bool _mesmaSemana(DateTime a, DateTime b) =>
      _inicioDaSemana(a) == _inicioDaSemana(b);

  /// RN-145: visitas da [pessoa] em [endereco] na semana de [dia],
  /// somando plano (exceto as que não vão acontecer) e avulsos.
  int visitasNaSemana(String pessoa, String endereco, DateTime dia) {
    var n = 0;
    for (final p in planos) {
      if (p.profissional != pessoa || p.endereco != endereco) continue;
      if (p.status != StatusPlano.ativo) continue;
      n += p.visitas
          .where(
            (v) =>
                _mesmaSemana(v.dia, dia) &&
                v.situacao != SituacaoVisita.naoVai &&
                v.situacao != SituacaoVisita.faltou,
          )
          .length;
    }
    n += _avulsos
        .where((a) => a.$1 == pessoa && a.$2 == endereco && _mesmaSemana(a.$3, dia))
        .length;
    return n;
  }

  /// RN-145: ainda cabe mais uma visita nessa semana?
  bool cabeVisita(String pessoa, String endereco, DateTime dia) =>
      visitasNaSemana(pessoa, endereco, dia) < RegrasPlanoFixo.maxVisitasSemana;

  /// RN-145: pedido avulso com a mesma profissional. Devolve falso (e não
  /// registra) se seria a 3ª visita na semana.
  bool pedirAvulso(String pessoa, String endereco, DateTime dia) {
    if (!cabeVisita(pessoa, endereco, dia)) return false;
    _avulsos.add((pessoa, endereco, dia));
    notifyListeners();
    return true;
  }

  /// RN-205: o plano mais recente com [profissional] (cliente) ou com
  /// [cliente] (profissional), mesmo encerrado (para o divisor no chat).
  PlanoFixo? ultimoCom({String? profissional, String? cliente}) => planos
      .where(
        (p) =>
            (profissional == null || p.profissional == profissional) &&
            (cliente == null || p.cliente == cliente),
      )
      .lastOrNull;

  /// Plano (não cancelado) de [cliente], do lado do profissional.
  PlanoFixo? planoDoCliente(String cliente) => planos
      .where((p) => p.cliente == cliente && p.status != StatusPlano.cancelado)
      .firstOrNull;

  PlanoFixo? planoCom(String pessoa) => planos
      .where((p) => p.profissional == pessoa && p.status != StatusPlano.cancelado)
      .firstOrNull;

  /// RN-144/RN-145: "Tornar [nome] fixa". Nulo se passaria do limite de
  /// visitas na semana (somando os avulsos).
  PlanoFixo? pedir({
    required String cliente,
    required String profissional,
    required String endereco,
    required FrequenciaPlano frequencia,
    required int visitasPorSemana,
    required List<int> dias,
    required String horario,
    String profissao = 'Encanadora',
    bool feminino = true,
    bool clienteFeminina = true,
    DateTime? agora,
  }) {
    if (visitasPorSemana < 1 ||
        visitasPorSemana > RegrasPlanoFixo.maxVisitasSemana ||
        dias.length != visitasPorSemana) {
      return null;
    }
    final hoje = agora ?? clock.now();
    final avulsos = _avulsos
        .where(
          (a) =>
              a.$1 == profissional && a.$2 == endereco && _mesmaSemana(a.$3, hoje),
        )
        .length;
    if (avulsos + visitasPorSemana > RegrasPlanoFixo.maxVisitasSemana) {
      return null;
    }
    final p = PlanoFixo(
      cliente: cliente,
      profissional: profissional,
      endereco: endereco,
      frequencia: frequencia,
      visitasPorSemana: visitasPorSemana,
      dias: [...dias]..sort(),
      horario: horario,
      profissao: profissao,
      feminino: feminino,
      clienteFeminina: clienteFeminina,
    );
    planos.add(p);
    notifyListeners();
    return p;
  }

  /// RN-144: o profissional responde com o valor por visita (uma vez).
  bool enviarValor(PlanoFixo p, double porVisita) {
    if (p.status != StatusPlano.pendente || p.valorPorVisita != null) {
      return false;
    }
    if (porVisita <= 0) return false;
    p.valorPorVisita = porVisita;
    notifyListeners();
    return true;
  }

  /// Cliente: "Pedir outro valor" (o profissional responde de novo).
  void pedirOutroValor(PlanoFixo p) {
    if (p.status != StatusPlano.pendente) return;
    p.valorPorVisita = null;
    notifyListeners();
  }

  /// RN-144: o cliente confirma no cartão padrão; o plano fica ativo e
  /// as visitas do período são marcadas a partir de [inicio].
  void confirmar(PlanoFixo p, {required String cartao, DateTime? inicio}) {
    if (p.status != StatusPlano.pendente || p.valorPorVisita == null) return;
    p
      ..cartao = cartao
      ..aceitouTermosEm = clock.now()
      ..status = StatusPlano.ativo;
    _agendar(p, inicio ?? clock.now());
    notifyListeners();
  }

  /// Marca as visitas do período: os dias escolhidos, semana a semana.
  void _agendar(PlanoFixo p, DateTime inicio) {
    p.visitas.clear();
    p.inicioPeriodo = inicio;
    final semanas = p.mensal ? RegrasPlanoFixo.semanasPorMes : 1;
    final base = _inicioDaSemana(inicio);
    final partes = p.horario.split(':');
    final h = int.tryParse(partes.first) ?? 9;
    final m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    // Começa na semana em que ainda dá tempo da primeira visita.
    var s = 0;
    while (p.visitas.length < p.visitasNoPeriodo) {
      for (final d in p.dias) {
        final dia = base.add(Duration(days: 7 * s + d - 1, hours: h, minutes: m));
        if (dia.isBefore(inicio) && s == 0) continue;
        if (p.visitas.length < p.visitasNoPeriodo) p.visitas.add(VisitaPlano(dia));
      }
      s++;
      if (s > semanas + 1) break;
    }
  }

  /// RN-206: a profissional saiu para a visita do plano.
  void saiuParaVisita(VisitaPlano v, {int minutos = 8}) {
    if (v.situacao != SituacaoVisita.agendada) return;
    v
      ..situacao = SituacaoVisita.aCaminho
      ..minutosParaChegar = minutos;
    notifyListeners();
  }

  /// RN-206: a visita começou (código na porta).
  void comecouVisita(VisitaPlano v) {
    if (v.situacao != SituacaoVisita.aCaminho) return;
    v.situacao = SituacaoVisita.emServico;
    notifyListeners();
  }

  void visitaFeita(VisitaPlano v) {
    v.situacao = SituacaoVisita.feita;
    notifyListeners();
  }

  /// RN-147: "Não vou nesta semana": sem penalidade, não cobrada; o
  /// Tatu avisa o cliente pelo canal oficial.
  void naoVou(PlanoFixo p, VisitaPlano v) {
    if (v.situacao != SituacaoVisita.agendada) return;
    v.situacao = SituacaoVisita.naoVai;
    final proxima = p.proximas.firstOrNull;
    final artigo = p.feminino ? 'A' : 'O';
    final texto =
        '$artigo ${p.primeiroNome} avisou que não vem na '
        '${diaLongo(v.dia.weekday)}, ${diaMes(v.dia)}. Essa visita não será '
        'cobrada.${proxima == null ? '' : ' A próxima é '
                  '${diaLongo(proxima.dia.weekday)}, ${diaMes(proxima.dia)}, '
                  'às ${horaCurta(p.horario)}.'}';
    canalTatu.cliente.receber(
      MensagemTatu(
        id: 'fixo-nao-vai-${v.dia.toIso8601String()}',
        em: clock.now(),
        resumo: '$artigo ${p.primeiroNome} não vem nesta semana',
        texto: texto,
      ),
    );
    notifyListeners();
  }

  /// RN-147: faltou sem avisar: vale a regra de abandono (RN-76 a RN-79).
  void faltou(VisitaPlano v) {
    if (v.situacao != SituacaoVisita.agendada) return;
    v.situacao = SituacaoVisita.faltou;
    pro.profissional.registrarAbandono();
    notifyListeners();
  }

  /// RN-146: fim do período: cobra só as visitas feitas, com a comissão
  /// normal; depois vale o que foi pedido para o próximo período (RN-148).
  CobrancaPlano? fecharPeriodo(PlanoFixo p, {DateTime? proximoInicio}) {
    if (p.status != StatusPlano.ativo || p.valorPorVisita == null) return null;
    final total = RegrasPlanoFixo.cobranca(p.valorPorVisita!, p.feitas);
    final c = CobrancaPlano(
      visitasFeitas: p.feitas,
      total: total,
      comissao: RegrasPlanoFixo.comissao(total),
    );
    p.cobrancas.add(c);
    // RN-148: novo valor aceito vale do próximo período em diante.
    final muda = p.noProximoPeriodo;
    if (muda != null) {
      p
        ..status = muda
        ..noProximoPeriodo = null;
      // RN-205: cancelado no fim do período vira "encerrado".
      if (muda == StatusPlano.cancelado) {
        p.encerradoEm = p.proximaCobranca ?? clock.now();
      }
    }
    if (p.status == StatusPlano.ativo) {
      _agendar(
        p,
        proximoInicio ??
            (p.visitas.isEmpty
                ? clock.now()
                : p.visitas.last.dia.add(const Duration(days: 1))),
      );
    } else {
      p.visitas.clear();
    }
    notifyListeners();
    return c;
  }

  /// RN-148: pausar vale a partir do próximo período (os dois lados).
  void pausar(PlanoFixo p) {
    if (p.status != StatusPlano.ativo) return;
    p.noProximoPeriodo = StatusPlano.pausado;
    notifyListeners();
  }

  /// RN-148: cancelar vale a partir do próximo período (os dois lados).
  /// Pendente ainda não tem período: cancela na hora.
  void cancelar(PlanoFixo p) {
    if (p.status == StatusPlano.pendente || p.status == StatusPlano.pausado) {
      // RN-205: sem período em andamento, encerra na hora.
      p
        ..status = StatusPlano.cancelado
        ..encerradoEm = clock.now();
    } else {
      p.noProximoPeriodo = StatusPlano.cancelado;
    }
    notifyListeners();
  }

  /// Volta um plano pausado (no próximo período).
  void retomar(PlanoFixo p, {DateTime? inicio}) {
    if (p.status != StatusPlano.pausado) return;
    p.status = StatusPlano.ativo;
    _agendar(p, inicio ?? clock.now());
    notifyListeners();
  }

  /// RN-148: mudar o valor é uma nova proposta do profissional…
  void proporNovoValor(PlanoFixo p, double porVisita) {
    if (p.status != StatusPlano.ativo || porVisita <= 0) return;
    p.valorProposto = porVisita;
    notifyListeners();
  }

  /// …que só vale com o aceite do cliente.
  void aceitarNovoValor(PlanoFixo p) {
    final v = p.valorProposto;
    if (v == null) return;
    p
      ..valorPorVisita = v
      ..valorProposto = null;
    notifyListeners();
  }

  /// Demonstração: plano mensal da Luiza toda terça, 9h, com 2 de 4
  /// visitas feitas (C197/P132).
  PlanoFixo demo({DateTime? inicio}) {
    final p = pedir(
      cliente: 'Ana Martins',
      profissional: 'Luiza Souza',
      endereco: 'Rua das Flores, 120',
      frequencia: FrequenciaPlano.mensal,
      visitasPorSemana: 1,
      dias: const [2],
      horario: '9:00',
    )!;
    enviarValor(p, 150);
    confirmar(p, cartao: 'Visa 4242', inicio: inicio ?? DateTime(2026, 11, 10));
    for (final v in p.visitas.take(2)) {
      v.situacao = SituacaoVisita.feita;
    }
    notifyListeners();
    return p;
  }
}

/// Instância única usada pelo app enquanto não há backend.
final planosFixos = PlanosFixosRepo();
