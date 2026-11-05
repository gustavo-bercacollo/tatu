import 'package:flutter/foundation.dart';

enum TipoEndereco {
  casa('Casa'),
  trabalho('Trabalho'),
  outro('Outro');

  const TipoEndereco(this.rotulo);
  final String rotulo;
}

@immutable
class Endereco {
  const Endereco({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.rua,
    required this.bairro,
    this.complemento = '',
  });

  final String id;
  final String nome;
  final TipoEndereco tipo;

  /// Rua e número, ex.: Rua Bruno Lobo, 29.
  final String rua;
  final String bairro;
  final String complemento;

  Endereco copyWith({
    String? nome,
    TipoEndereco? tipo,
    String? rua,
    String? bairro,
    String? complemento,
  }) => Endereco(
    id: id,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    rua: rua ?? this.rua,
    bairro: bairro ?? this.bairro,
    complemento: complemento ?? this.complemento,
  );
}

/// Resultado da busca de endereço.
@immutable
class ResultadoEndereco {
  const ResultadoEndereco(this.rua, this.bairro, this.cidade);
  final String rua;
  final String bairro;
  final String cidade;
}

/// Endereços do cliente. Versão simulada (sem backend): dados em memória,
/// busca numa lista fixa e localização atual fixa.
class EnderecosRepo extends ChangeNotifier {
  EnderecosRepo() {
    restaurar();
  }

  late List<Endereco> _salvos;
  late Endereco _atual;

  /// Simula a permissão de localização do celular.
  bool localizacaoPermitida = true;

  List<Endereco> get salvos => List.unmodifiable(_salvos);

  /// Endereço em uso no pedido (mostrado no topo da Home).
  Endereco get atual => _atual;

  static const _base = [
    ResultadoEndereco('Rua Bruno Lobo, 29', 'Centro', 'São Paulo'),
    ResultadoEndereco('Rua Bruno Lobo, 120', 'Centro', 'São Paulo'),
    ResultadoEndereco('Rua Bruno Lobo, 300', 'Vila Nova', 'São Paulo'),
    ResultadoEndereco('Rua das Flores, 120', 'Jardim Primavera', 'São Paulo'),
    ResultadoEndereco('Rua das Flores, 45', 'Centro', 'São Paulo'),
    ResultadoEndereco('Av. Paulista, 1000', 'Bela Vista', 'São Paulo'),
    ResultadoEndereco('Av. Paulista, 1500', 'Bela Vista', 'São Paulo'),
  ];

  static const localAtual = ResultadoEndereco(
    'Rua Bruno Lobo, 29',
    'Centro',
    'São Paulo',
  );

  /// Volta aos dados de exemplo (usado nos testes).
  void restaurar() {
    _salvos = const [
      Endereco(
        id: 'casa',
        nome: 'Casa',
        tipo: TipoEndereco.casa,
        rua: 'Rua Bruno Lobo, 29',
        bairro: 'Centro',
        complemento: 'Apto 4',
      ),
      Endereco(
        id: 'trabalho',
        nome: 'Trabalho',
        tipo: TipoEndereco.trabalho,
        rua: 'Av. Paulista, 1000',
        bairro: 'Bela Vista',
        complemento: '12º andar',
      ),
    ].toList();
    _atual = _salvos.first;
    localizacaoPermitida = true;
    notifyListeners();
  }

  static String _sem(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áàâã]'), 'a')
      .replaceAll(RegExp('[éê]'), 'e')
      .replaceAll('í', 'i')
      .replaceAll(RegExp('[óôõ]'), 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c');

  List<ResultadoEndereco> buscar(String texto) {
    final q = _sem(texto.trim());
    if (q.length < 3) return const [];
    return _base.where((r) => _sem(r.rua).contains(q)).take(3).toList();
  }

  void usar(Endereco e) {
    _atual = e;
    notifyListeners();
  }

  /// Usa a localização atual; `false` se a permissão estiver negada.
  bool usarLocalizacao() {
    if (!localizacaoPermitida) return false;
    final salvo = _salvos.where((e) => e.rua == localAtual.rua);
    _atual = salvo.isNotEmpty
        ? salvo.first
        : Endereco(
            id: 'local',
            nome: 'Localização atual',
            tipo: TipoEndereco.outro,
            rua: localAtual.rua,
            bairro: localAtual.bairro,
          );
    notifyListeners();
    return true;
  }

  /// Salva um endereço novo. Casa e Trabalho substituem o anterior do mesmo tipo.
  Endereco salvarNovo({
    required ResultadoEndereco resultado,
    required String complemento,
    required TipoEndereco tipo,
  }) {
    final existente = tipo == TipoEndereco.outro
        ? null
        : _salvos.where((e) => e.tipo == tipo).firstOrNull;
    final novo = Endereco(
      id: existente?.id ?? 'end-${DateTime.now().microsecondsSinceEpoch}',
      nome: tipo.rotulo,
      tipo: tipo,
      rua: resultado.rua,
      bairro: resultado.bairro,
      complemento: complemento.trim(),
    );
    if (existente != null) {
      _salvos[_salvos.indexOf(existente)] = novo;
    } else {
      _salvos.add(novo);
    }
    _atual = novo;
    notifyListeners();
    return novo;
  }

  void atualizar(Endereco e) {
    final i = _salvos.indexWhere((x) => x.id == e.id);
    if (i < 0) return;
    _salvos[i] = e;
    if (_atual.id == e.id) _atual = e;
    notifyListeners();
  }

  void excluir(String id) {
    _salvos.removeWhere((e) => e.id == id);
    // Excluiu o endereço em uso: passa a usar o primeiro que sobrou.
    if (_atual.id == id && _salvos.isNotEmpty) _atual = _salvos.first;
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final enderecos = EnderecosRepo();
