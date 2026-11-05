import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/enderecos.dart';
import '../../data/sugestao_servico.dart';
import '../../shared/widgets/abas_cliente.dart';
import '../../shared/widgets/avatar_usuario.dart';
import '../../shared/widgets/tatu_chip.dart';
import 'endereco/onde_sheet.dart';
import 'perfil_page.dart';

/// Home do cliente: descreve o problema, escolhe (ou a IA marca) o serviço e chama.
class HomeClientePage extends StatefulWidget {
  const HomeClientePage({
    super.key,
    required this.nome,
    this.ia = const SugestaoServicoMock(),
  });

  final String nome;
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

  @override
  Widget build(BuildContext context) {
    final servico = _servico;
    return Scaffold(
      bottomNavigationBar: const AbasCliente(),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      14,
                      TatuMedidas.margem,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _cabecalho(),
                        const SizedBox(height: 40),
                        Text(
                          'Oi, ${widget.nome.split(' ').first}',
                          style: TatuTexto.detalhe,
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
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    0,
                    TatuMedidas.margem,
                    17,
                  ),
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
            onTap: () => abrirOndeServico(context),
            child: Row(
              children: [
                const Icon(TablerIcons.map_pin, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: ListenableBuilder(
                    listenable: enderecos,
                    builder: (context, _) => Text(
                      enderecos.atual.rua,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PerfilClientePage(nome: widget.nome),
              ),
            ),
            child: AvatarUsuario(nome: widget.nome),
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
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
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
