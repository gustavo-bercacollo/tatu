import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../data/sugestao_servico.dart';
import '../../shared/widgets/tatu_chip.dart';

/// Home do cliente: descreve o problema, escolhe (ou a IA marca) o serviço e chama.
class HomeClientePage extends StatefulWidget {
  const HomeClientePage({
    super.key,
    required this.nome,
    this.endereco = 'Rua das Flores, 120',
    this.ia = const SugestaoServicoMock(),
  });

  final String nome;
  final String endereco;
  final SugestaoServico ia;

  @override
  State<HomeClientePage> createState() => _HomeClientePageState();
}

class _HomeClientePageState extends State<HomeClientePage> {
  final _descricao = TextEditingController();
  Timer? _espera;

  /// Escolha da pessoa; nunca é trocada pela IA.
  String? _manual;

  /// Sugestão da IA pela descrição; só aparece sem escolha manual.
  String? _sugerido;

  String? get _servico => _manual ?? _sugerido;
  bool get _pelaIa => _manual == null && _sugerido != null;

  @override
  void dispose() {
    _espera?.cancel();
    _descricao.dispose();
    super.dispose();
  }

  void _descreveu(String texto) {
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _sugerido = widget.ia.sugerir(texto));
    });
  }

  void _tocouServico(String s) => setState(() {
    _manual = _servico == s && !_pelaIa ? null : s;
    if (_manual == null && _sugerido == s) _sugerido = null;
  });

  void _emBreve(String o) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$o: em breve')));
  }

  String get _iniciais {
    final partes = widget.nome.trim().split(RegExp(r'\s+'));
    return partes
        .take(2)
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final servico = _servico;
    return Scaffold(
      bottomNavigationBar: const _AbasCliente(),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _cabecalho(),
                        const SizedBox(height: 40),
                        Text(
                          'Oi, ${widget.nome.split(' ').first}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: TatuColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Do que você precisa?',
                          style: TextStyle(
                            fontSize: 30,
                            height: 36 / 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _caixaDescricao(),
                        const SizedBox(height: 22),
                        const Text(
                          'Serviço',
                          style: TextStyle(
                            fontSize: 13,
                            color: TatuColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in servicosHome)
                              TatuChip(
                                label: s,
                                selecionado: servico == s,
                                icone: _pelaIa ? TablerIcons.sparkles : null,
                                onTap: () => _tocouServico(s),
                              ),
                            TatuChip(
                              label: 'Outros',
                              onTap: () => _emBreve('Outros serviços'),
                            ),
                          ],
                        ),
                        if (_pelaIa) ...[
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(
                                TablerIcons.sparkles,
                                size: 14,
                                color: TatuColors.textSecondary,
                              ),
                              SizedBox(width: 6),
                              // Uma linha só, como no desenho; encolhe em telas estreitas.
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Sugerido pela descrição. Toque em outro para trocar.',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 13,
                                      letterSpacing: -0.1,
                                      color: TatuColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 8,
                            height: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: TatuColors.online,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Profissionais ativos perto de você',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: TatuColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: servico == null
                            ? null
                            : () => _emBreve('Procurar profissional'),
                        child: Text(
                          servico == null
                              ? 'Escolha um serviço'
                              : 'Chamar ${servico.toLowerCase()}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _emBreve('Endereço'),
            child: Row(
              children: [
                const Icon(TablerIcons.map_pin, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.endereco,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  TablerIcons.chevron_down,
                  size: 14,
                  color: TatuColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Perfil',
          child: GestureDetector(
            onTap: () => _emBreve('Perfil'),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: TatuColors.circle,
                shape: BoxShape.circle,
              ),
              child: Text(
                _iniciais,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _caixaDescricao() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 52),
              child: TextField(
                controller: _descricao,
                onChanged: _descreveu,
                maxLines: null,
                expands: true,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: TatuColors.textPrimary,
                style: const TextStyle(fontSize: 17, height: 24 / 17),
                decoration: const InputDecoration.collapsed(
                  hintText: 'O que está acontecendo?',
                  hintStyle: TextStyle(
                    fontSize: 17,
                    color: TatuColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Semantics(
              button: true,
              label: 'Enviar foto',
              child: GestureDetector(
                onTap: () => _emBreve('Foto'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: TatuColors.circle,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(TablerIcons.camera, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de abas do cliente: Início · Atividade · Mensagens.
class _AbasCliente extends StatelessWidget {
  const _AbasCliente();

  @override
  Widget build(BuildContext context) {
    void emBreve(String o) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$o: em breve')));

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TatuColors.tabBar,
        border: Border(
          top: BorderSide(color: TatuColors.tabBarLine, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 49,
          child: Row(
            children: [
              const _Aba(icone: TablerIcons.home, texto: 'Início', ativa: true),
              _Aba(
                icone: TablerIcons.clock,
                texto: 'Atividade',
                onTap: () => emBreve('Atividade'),
              ),
              _Aba(
                icone: TablerIcons.message_circle,
                texto: 'Mensagens',
                onTap: () => emBreve('Mensagens'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Aba extends StatelessWidget {
  const _Aba({
    required this.icone,
    required this.texto,
    this.ativa = false,
    this.onTap,
  });

  final IconData icone;
  final String texto;
  final bool ativa;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cor = ativa ? TatuColors.textPrimary : TatuColors.textSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: ativa,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 24, color: cor),
              const SizedBox(height: 3),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: ativa ? FontWeight.w600 : FontWeight.w500,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
