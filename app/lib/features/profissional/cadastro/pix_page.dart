import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tatu_field.dart';
import 'taxas_sheet.dart';
import 'verificacao_page.dart';

enum _Fase { normal, confirmando, salva }

/// P08 · Passo 3: chave Pix para receber pelo app.
/// Com [doPerfil], vem do Perfil ou da Home: sem passo e volta ao salvar.
class PixPage extends StatefulWidget {
  const PixPage({super.key, this.doPerfil = false});

  final bool doPerfil;

  @override
  State<PixPage> createState() => _PixPageState();
}

class _PixPageState extends State<PixPage> {
  TipoPix _tipo = profissional.pixTipo ?? TipoPix.cpf;
  late final _chave = TextEditingController(
    text: profissional.pixTipo == null || profissional.pixTipo == TipoPix.cpf
        ? ''
        : profissional.pixChave,
  );
  String? _erro;
  _Fase _fase = _Fase.normal;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _chave.dispose();
    super.dispose();
  }

  bool get _temChave => _tipo == TipoPix.cpf || _chave.text.trim().isNotEmpty;

  void _escolher(TipoPix t) => setState(() {
    _tipo = t;
    _erro = null;
    _chave.clear();
  });

  void _salvar() {
    FocusScope.of(context).unfocus();
    setState(() {
      _erro = null;
      _fase = _Fase.confirmando;
    });
    // Simula a consulta do nome do dono da chave.
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final erro = profissional.conferirPix(_tipo, _chave.text);
      if (erro != null) {
        setState(() {
          _erro = erro;
          _fase = _Fase.normal;
        });
        return;
      }
      profissional.salvarPix(_tipo, _chave.text);
      setState(() => _fase = _Fase.salva);
      _timer = Timer(const Duration(seconds: 1), _seguir);
    });
  }

  void _seguir() {
    if (!mounted) return;
    if (widget.doPerfil) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const VerificacaoIntroPage()));
    }
  }

  Future<void> _depois() async {
    final agora = await perguntar(
      context,
      icone: TablerIcons.wallet,
      iconeAviso: false,
      esquerda: true,
      titulo: 'Deixar para depois?',
      texto:
          'Sem uma chave Pix, você não recebe pelos serviços. '
          'Todo pagamento passa pelo app.',
      nota: 'Você cadastra quando quiser, em Perfil.',
      confirmar: 'Cadastrar agora',
      cancelar: 'Fazer depois',
    );
    if (agora == false && mounted) _seguir();
  }

  Widget _campo() {
    final rotulo = 'Sua chave (${_tipo.rotulo})';
    final erro = _erro == null ? null : '';
    return switch (_tipo) {
      TipoPix.cpf => TatuField(
        key: const ValueKey('pix-cpf'),
        label: rotulo,
        controller: TextEditingController(text: profissional.cpfMascarado),
        readOnly: true,
      ),
      TipoPix.celular => TatuField(
        key: const ValueKey('pix-celular'),
        label: rotulo,
        hintText: '(00) 00000-0000',
        controller: _chave,
        errorText: erro,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          MascaraFormatter(moldeCelular),
        ],
        onChanged: (_) => setState(() => _erro = null),
      ),
      TipoPix.email => TatuField(
        key: const ValueKey('pix-email'),
        label: rotulo,
        hintText: 'nome@email.com',
        controller: _chave,
        errorText: erro,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => setState(() => _erro = null),
      ),
      TipoPix.aleatoria => TatuField(
        key: const ValueKey('pix-aleatoria'),
        label: rotulo,
        hintText: 'Cole a chave aqui',
        controller: _chave,
        errorText: erro,
        onChanged: (_) => setState(() => _erro = null),
      ),
    };
  }

  Widget? get _conteudoBotao => switch (_fase) {
    _Fase.normal => null,
    _Fase.confirmando => const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: TatuColors.textPrimary,
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          child: Text(
            'Confirmando sua chave…',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    _Fase.salva => const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(TablerIcons.check, size: 20),
        SizedBox(width: 8),
        Flexible(child: Text('Chave salva')),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final nome = profissional.nome;
    final ocupado = _fase != _Fase.normal;
    return CadastroScaffold(
      passo: widget.doPerfil ? null : 3,
      titulo: 'Onde você quer receber?',
      subtitulo: 'Cadastre uma vez. O que o cliente pagar pelo app cai aqui.',
      botao: 'Salvar e continuar',
      botaoConteudo: _conteudoBotao,
      botaoEstilo: _fase == _Fase.confirmando ? tatuBotaoSecundario() : null,
      onBotao: ocupado ? () {} : (_temChave ? _salvar : null),
      link: widget.doPerfil ? null : 'Fazer isso depois',
      onLink: ocupado ? null : _depois,
      children: [
        const Text(
          'Chave Pix',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final t in TipoPix.values)
              TatuChip(
                label: t.nome,
                selecionado: t == _tipo,
                onTap: () => ocupado ? null : _escolher(t),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _campo(),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        if (_erro != null)
          NotaIcone(
            icone: TablerIcons.alert_circle,
            texto: _erro!,
            cor: TatuColors.danger,
          )
        else
          NotaIcone(
            icone: TablerIcons.info_circle,
            texto: _tipo == TipoPix.cpf
                ? 'Usamos o CPF que você informou. '
                      'A chave precisa estar no nome de $nome.'
                : 'A chave precisa estar no nome de $nome.',
          ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        Align(
          alignment: Alignment.centerLeft,
          child: LinkAzul(
            'Ver taxas do Tatu',
            onTap: () => mostrarTaxas(context),
          ),
        ),
      ],
    );
  }
}
