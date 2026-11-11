import 'package:flutter/foundation.dart';

/// Serviço aceito pelo profissional (endereço já revelado, valor
/// confirmado). Versão simulada (sem backend).
@immutable
class ServicoAceito {
  const ServicoAceito({
    this.cliente = 'Ana Julia',
    this.notaCliente = 4.8,
    this.rua = 'Rua Bruno Lobo, 29',
    this.referencia = 'Casa com portão amarelo',
    this.descricao = 'Conserto do cano da pia',
    this.valor = 150,
    this.observacao = 'Material incluso',
    this.distanciaKm = 1.2,
    this.minutos = 6,
    this.feminino = true,
  });

  final String cliente;
  final double notaCliente;
  final String rua;

  /// Ponto de referência (ex.: "Casa com portão amarelo").
  final String referencia;
  final String descricao;
  final double valor;

  /// Detalhe do valor (ex.: "Material incluso").
  final String observacao;
  final double distanciaKm;
  final int minutos;
  final bool feminino;

  String get primeiroNome => cliente.split(' ').first;
}

/// Serviço de exemplo para a demonstração.
const servicoExemplo = ServicoAceito();
