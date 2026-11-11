import 'dart:async';

import 'package:flutter/foundation.dart';

/// No máximo 12 fotos de trabalhos no perfil.
const maxFotosTrabalho = 12;

/// Fotos passam por revisão antes de aparecer para os clientes.
enum RevisaoFoto { aprovada, emAnalise, recusada }

class FotoTrabalho {
  FotoTrabalho({
    this.imagem,
    this.legenda = '',
    this.servico = '',
    this.revisao = RevisaoFoto.aprovada,
    this.motivo,
  });

  /// Null nas fotos de exemplo (mostra um ícone).
  final Uint8List? imagem;
  final String legenda;
  final String servico;
  RevisaoFoto revisao;

  /// Por que foi recusada (ex.: "Aparece o rosto de uma pessoa.").
  String? motivo;
}

/// Fotos de trabalhos do profissional. Versão simulada (sem backend):
/// toda foto nova é aprovada sozinha depois de [revisao].
class FotosTrabalhoRepo extends ChangeNotifier {
  FotosTrabalhoRepo() {
    restaurar();
  }

  final fotos = <FotoTrabalho>[];
  Duration revisao = const Duration(seconds: 4);
  final _timers = <Timer>[];

  bool get cheio => fotos.length >= maxFotosTrabalho;

  /// Só as aprovadas aparecem para os clientes.
  List<FotoTrabalho> get aprovadas => [
    for (final f in fotos)
      if (f.revisao == RevisaoFoto.aprovada) f,
  ];

  void restaurar() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    fotos
      ..clear()
      ..addAll([
        FotoTrabalho(legenda: 'Troca de chuveiro', servico: 'Eletricista'),
        FotoTrabalho(legenda: 'Vazamento', servico: 'Encanador'),
        FotoTrabalho(legenda: 'Quadro de luz', servico: 'Eletricista'),
      ]);
    revisao = const Duration(seconds: 4);
    notifyListeners();
  }

  void limpar() {
    fotos.clear();
    notifyListeners();
  }

  /// Sem [revisar], a foto fica em análise (demonstração e testes).
  void adicionar(FotoTrabalho foto, {bool revisar = true}) {
    foto.revisao = RevisaoFoto.emAnalise;
    fotos.add(foto);
    notifyListeners();
    if (!revisar) return;
    _timers.add(
      Timer(revisao, () {
        if (!fotos.contains(foto)) return;
        foto.revisao = RevisaoFoto.aprovada;
        notifyListeners();
      }),
    );
  }

  /// Simula a revisão recusando a foto (demonstração e testes).
  void recusar(FotoTrabalho foto, String motivo) {
    foto
      ..revisao = RevisaoFoto.recusada
      ..motivo = motivo;
    notifyListeners();
  }

  void remover(FotoTrabalho foto) {
    fotos.remove(foto);
    notifyListeners();
  }

  void trocar(FotoTrabalho antiga, FotoTrabalho nova) {
    final i = fotos.indexOf(antiga);
    if (i < 0) return;
    fotos.removeAt(i);
    nova.revisao = RevisaoFoto.emAnalise;
    fotos.insert(i, nova);
    notifyListeners();
    _timers.add(
      Timer(revisao, () {
        if (!fotos.contains(nova)) return;
        nova.revisao = RevisaoFoto.aprovada;
        notifyListeners();
      }),
    );
  }

  /// Arrastar para reordenar: a foto [de] vai para a posição [para].
  void mover(int de, int para) {
    if (de == para) return;
    final f = fotos.removeAt(de);
    fotos.insert(para, f);
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final fotosTrabalho = FotosTrabalhoRepo();
