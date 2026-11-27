import 'package:flutter/foundation.dart';

import 'package:clock/clock.dart';

import 'codigo_porta.dart';
import 'base_tecnica.dart';
import 'limites.dart';
import 'regras_distancia.dart';
import 'servico_profissional.dart';
import 'suspensao.dart';

/// Em que ponto está o chamado que o profissional aceitou.
enum EtapaAtendimento { combinando, aCaminho, noLocal, emServico }

extension EtapaAtendimentoTexto on EtapaAtendimento {
  /// Selo do cartão na Atividade.
  String get selo => switch (this) {
    EtapaAtendimento.combinando => 'Combinando',
    EtapaAtendimento.aCaminho => 'A caminho',
    EtapaAtendimento.noLocal => 'No local',
    EtapaAtendimento.emServico => 'Em serviço',
  };

  /// Quantas de [etapasAtendimento] já aconteceram.
  int get feitas => switch (this) {
    EtapaAtendimento.combinando => 1,
    EtapaAtendimento.aCaminho => 3,
    EtapaAtendimento.noLocal => 3,
    EtapaAtendimento.emServico => 4,
  };
}

/// Etapas na linha do tempo do cartão (profissional).
const etapasAtendimento = [
  'Aceito',
  'Combinado',
  'A caminho',
  'Serviço',
  'Pagamento',
];

/// Chamado em andamento do profissional (um por vez). Versão simulada.
class AtendimentoProfissionalRepo extends ChangeNotifier {
  ChamadoNovo? chamado;
  ServicoAceito? servico;
  EtapaAtendimento etapa = EtapaAtendimento.combinando;
  DateTime? inicio;

  /// RN-101: entregas enviadas neste valor (à distância).
  int entregas = 0;

  /// RN-99: prévias protegidas enviadas (sem limite).
  int previas = 0;

  /// RN-240: novo valor durante o serviço esperando o cliente (só um por
  /// vez) e quantos o cliente já recusou neste atendimento.
  bool novoValorPendente = false;
  int novosValoresRecusados = 0;

  /// RN-240: "Novo valor" ativo? (Não vale para serviço novo depois de
  /// concluído, RN-181: esse começa outro atendimento.)
  bool get podeEnviarNovoValor =>
      !novoValorPendente &&
      novosValoresRecusados < Limites.novosValoresRecusados;

  /// RN-240: texto do "Novo valor" desativado (nulo = ativo ou só
  /// esperando a resposta).
  String? avisoNovoValor({required String cliente, required bool feminino}) =>
      novosValoresRecusados < Limites.novosValoresRecusados
      ? null
      : '${feminino ? 'A' : 'O'} $cliente recusou '
            '$novosValoresRecusados valores. Conclua o combinado ou encerre '
            'cobrando a visita.';

  /// RN-32/RN-240: manda um novo valor no meio do serviço.
  bool enviarNovoValor() {
    if (!podeEnviarNovoValor) return false;
    novoValorPendente = true;
    registroAtendimentos.registrar(
      servico?.cliente ?? chamado?.cliente ?? '',
      'novo valor',
      quem: 'profissional',
    );
    notifyListeners();
    return true;
  }

  /// RN-32/RN-240: o cliente respondeu o novo valor.
  void respostaNovoValor({required bool aceito}) {
    if (!novoValorPendente) return;
    novoValorPendente = false;
    if (!aceito) novosValoresRecusados++;
    notifyListeners();
  }

  /// RN-101: ainda pode mandar entrega?
  bool get podeEntregar => entregas < RegrasDistancia.maxEntregas;

  /// RN-103: o sinal é liberado na 1ª entrega.
  bool get sinalLiberado => entregas > 0;

  bool get ativo => chamado != null || servico != null;

  /// RN-39/RN-167: conferência do código na porta (nula à distância).
  ConferenciaCodigo? codigo;

  /// RN-166: a posição só é enviada entre "Estou a caminho" e o código
  /// digitado (ou "Cliente não apareceu", que encerra o atendimento).
  bool get enviandoLocalizacao {
    final s = servico;
    if (s == null || s.distancia) return false;
    return etapa == EtapaAtendimento.aCaminho ||
        etapa == EtapaAtendimento.noLocal;
  }

  /// Quantas posições foram enviadas ao cliente (protótipo).
  int posicoesEnviadas = 0;

  /// RN-166: manda a posição ao cliente; fora do trecho permitido, não
  /// manda nada (devolve false).
  bool enviarPosicao() {
    if (!enviandoLocalizacao) return false;
    posicoesEnviadas++;
    return true;
  }

  /// RN-39/RN-167: o profissional digitou o código. Certo: o serviço
  /// começa sozinho ("Em andamento"). Errado 3 vezes: bloqueia.
  ResultadoCodigo digitarCodigo(String digitado, {DateTime? agora}) {
    final c = codigo;
    if (c == null) return ResultadoCodigo.bloqueado;
    final r = c.conferir(digitado);
    if (r == ResultadoCodigo.certo) {
      iniciar(agora ?? clock.now());
      // RN-246: o código na porta entra na linha do tempo.
      registroAtendimentos.registrar(
        servico?.cliente ?? chamado?.cliente ?? '',
        'código',
        quem: 'profissional',
      );
    }
    notifyListeners();
    return r;
  }

  /// RN-131/RN-132: chats encerrados pelo Tatu porque o cliente foi
  /// suspenso, pelo nome do cliente. Só leitura; o histórico fica.
  final encerrados = <String, Encerramento>{};

  /// Ponto do atendimento atual (RN-131: a visita conta a partir do "a
  /// caminho").
  PontoAtendimento get ponto => switch (etapa) {
    EtapaAtendimento.combinando =>
      servico == null
          ? PontoAtendimento.combinando
          : PontoAtendimento.confirmado,
    EtapaAtendimento.aCaminho => PontoAtendimento.aCaminho,
    EtapaAtendimento.noLocal => PontoAtendimento.noLocal,
    EtapaAtendimento.emServico => PontoAtendimento.emServico,
  };

  AtendimentoAberto get _aberto {
    final s = servico;
    return AtendimentoAberto(
      ponto: ponto,
      visita: s?.visita ?? 0,
      servico: s?.valor ?? 0,
      sinal: s?.sinal ?? 0,
      entregas: entregas,
    );
  }

  /// RN-129/RN-131: o cliente deste atendimento foi suspenso. O Tatu
  /// encerra o atendimento; o profissional recebe pelo que já fez e pode
  /// ficar online de novo.
  Encerramento? clienteSuspenso() {
    final cliente = chamado?.cliente ?? servico?.cliente;
    if (cliente == null) return null;
    final e = RegrasSuspensao.clienteSuspenso(_aberto);
    _limpar();
    encerrados[cliente] = e;
    notifyListeners();
    return e;
  }

  /// RN-56/RN-129: [cliente] ficou suspenso por uma denúncia de assédio
  /// ou discriminação. Se é o atendimento atual, vale a RN-131; se não,
  /// a conversa só fica encerrada (nada a cobrar).
  Encerramento clienteSuspensoNo(String cliente) {
    if ((chamado?.cliente ?? servico?.cliente) == cliente) {
      return clienteSuspenso()!;
    }
    final e = RegrasSuspensao.clienteSuspenso(
      const AtendimentoAberto(ponto: PontoAtendimento.combinando),
    );
    encerrados[cliente] = e;
    notifyListeners();
    return e;
  }

  /// RN-129/RN-130: a conta deste profissional foi suspensa: o
  /// atendimento acaba na hora (reserva liberada, sinal sem entrega
  /// devolvido ao cliente).
  Encerramento? profissionalSuspenso({DateTime? agora}) {
    if (!ativo) return null;
    final e = RegrasSuspensao.profissionalSuspenso(
      _aberto,
      agora ?? clock.now(),
    );
    restaurar();
    return e;
  }

  void restaurar() {
    encerrados.clear();
    _limpar();
    notifyListeners();
  }

  /// Sem atendimento em andamento (os encerrados ficam).
  void _limpar() {
    chamado = null;
    servico = null;
    etapa = EtapaAtendimento.combinando;
    inicio = null;
    entregas = 0;
    previas = 0;
    novoValorPendente = false;
    novosValoresRecusados = 0;
    codigo = null;
    posicoesEnviadas = 0;
  }

  /// RN-99: mandou uma prévia protegida.
  void enviarPrevia() {
    previas++;
    notifyListeners();
  }

  /// RN-101: mandou uma entrega (no máximo 2).
  void enviarEntrega() {
    if (!podeEntregar) return;
    entregas++;
    notifyListeners();
  }

  /// Aceitou o chamado: começa a combinar o valor no chat.
  void aceitar(ChamadoNovo c) {
    chamado = c;
    servico = null;
    etapa = EtapaAtendimento.combinando;
    inicio = null;
    entregas = 0;
    previas = 0;
    notifyListeners();
  }

  /// Valor combinado: indo até o cliente.
  void irAteCliente(ServicoAceito s) {
    servico = s;
    etapa = EtapaAtendimento.aCaminho;
    // RN-95: à distância não tem código.
    codigo = s.distancia ? null : ConferenciaCodigo(s.codigo);
    notifyListeners();
  }

  void chegou() {
    etapa = EtapaAtendimento.noLocal;
    notifyListeners();
  }

  void iniciar(DateTime quando) {
    etapa = EtapaAtendimento.emServico;
    inicio = quando;
    notifyListeners();
  }

  /// Cancelou, saiu, não houve acordo ou terminou.
  void encerrar() {
    if (!ativo) return;
    _limpar();
    notifyListeners();
  }
}

final atendimentoProfissional = AtendimentoProfissionalRepo();
