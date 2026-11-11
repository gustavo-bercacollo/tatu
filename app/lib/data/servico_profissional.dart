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

/// Chamado que chega para o profissional aceitar ou recusar.
/// O endereço exato só aparece depois do valor confirmado.
@immutable
class ChamadoNovo {
  const ChamadoNovo({
    this.profissao = 'Encanador',
    this.titulo = 'Vazamento na pia',
    this.descricao = 'o cano da minha casa quebrou',
    this.resumo = 'Vazamento na pia da cozinha',
    this.distanciaKm = 1.2,
    this.minutos = 6,
    this.urgente = true,
    this.bairro = 'Vila Mariana',
    this.cliente = 'Ana Martins',
    this.rua = 'Rua das Flores, 120',
    this.complemento = 'apto 32',
    this.cidade = 'São Paulo',
    this.notaCliente = 4.8,
    this.estimativaMin = 80,
    this.estimativaMax = 250,
    this.temFoto = true,
  });

  final String profissao;
  final String titulo;
  final String descricao;

  /// Uma linha, para o cartão do pedido no chat.
  final String resumo;
  final double distanciaKm;
  final int minutos;
  final bool urgente;
  final String bairro;
  final String cliente;

  /// Endereço exato: só aparece depois do valor combinado.
  final String rua;
  final String complemento;
  final String cidade;

  String get primeiroNome => cliente.split(' ').first;
  final double notaCliente;

  /// Estimativa da plataforma (região + serviço), nunca o preço final.
  final int estimativaMin;
  final int estimativaMax;
  final bool temFoto;
}

/// Chamado de exemplo para a demonstração.
const chamadoExemplo = ChamadoNovo();

/// Segundos para aceitar um chamado (provisório: prazo em aberto).
const segundosParaAceitar = 30;
