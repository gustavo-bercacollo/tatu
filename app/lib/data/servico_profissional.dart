import 'anexos.dart';
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
    this.visita = 40,
    this.observacao = '',
    this.distanciaKm = 1.2,
    this.minutos = 6,
    this.feminino = true,
    this.bairro = 'Vila Mariana, São Paulo',
    this.celularCliente = '(11) 9••••-7777',
    this.pedido = 'TT-48213',
    this.distancia = false,
    this.sinal = 0,
  });

  /// RN-95: serviço à distância (sem visita, rota, "Cheguei" nem porta).
  final bool distancia;

  /// RN-102/RN-103: sinal pago pelo cliente (0 = sem sinal).
  final double sinal;

  /// Bairro e cidade (para ler ao 190).
  final String bairro;

  /// Celular do cliente, mascarado.
  final String celularCliente;

  /// Número do pedido (sem o "#").
  final String pedido;

  final String cliente;
  final double notaCliente;
  final String rua;

  /// Ponto de referência (ex.: "Casa com portão amarelo").
  final String referencia;
  final String descricao;
  /// Total combinado (visita + serviço).
  final double valor;

  /// Parte da visita: é cobrada mesmo se o serviço não acontecer.
  final double visita;

  /// Detalhe opcional do valor (vazio = não mostra).
  final String observacao;
  final double distanciaKm;
  final int minutos;
  final bool feminino;

  String get primeiroNome => cliente.split(' ').first;
}

/// Serviço de exemplo para a demonstração.
const servicoExemplo = ServicoAceito();

/// Serviço à distância de exemplo (RN-95).
const servicoDistanciaExemplo = ServicoAceito(
  cliente: 'Ana Martins',
  descricao: 'Logo para loja de bolos',
  valor: 250,
  visita: 0,
  rua: '',
  referencia: '',
  distanciaKm: 0,
  minutos: 0,
  distancia: true,
  sinal: 75,
);

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
    this.anexos = const [AnexoPedido('foto.jpg')],
    this.feminino = true,
    this.distancia = false,
  });

  final bool feminino;

  /// RN-93: chamado à distância (cliente de qualquer cidade, sem visita).
  final bool distancia;

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

  /// RN-139: fotos e arquivos que o cliente anexou à descrição.
  final List<AnexoPedido> anexos;
}

/// Chamado de exemplo para a demonstração.
const chamadoExemplo = ChamadoNovo();

/// Chamado à distância de exemplo (RN-93).
const chamadoDistanciaExemplo = ChamadoNovo(
  profissao: 'Designer',
  titulo: 'Logo para loja de bolos',
  descricao:
      'Preciso de um logo simples e colorido para a minha loja de bolos.',
  resumo: 'Logo para loja de bolos',
  distanciaKm: 0,
  minutos: 0,
  urgente: false,
  bairro: '',
  rua: '',
  complemento: '',
  cidade: '',
  estimativaMin: 150,
  estimativaMax: 600,
  anexos: [],
  distancia: true,
);

/// Segundos para aceitar um chamado (provisório: prazo em aberto).
const segundosParaAceitar = 30;
