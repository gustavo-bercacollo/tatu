import 'package:flutter/services.dart';

/// Formata só dígitos num molde, ex.: '#### #### #### ####' ou '###.###.###-##'.
/// Use depois de `FilteringTextInputFormatter.digitsOnly`.
class MascaraFormatter extends TextInputFormatter {
  MascaraFormatter(this.molde);

  final String molde;

  int get maxDigitos => '#'.allMatches(molde).length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = newValue.text.length > maxDigitos
        ? newValue.text.substring(0, maxDigitos)
        : newValue.text;
    final b = StringBuffer();
    var i = 0;
    for (final ch in molde.split('')) {
      if (i >= d.length) break;
      if (ch == '#') {
        b.write(d[i++]);
      } else {
        b.write(ch);
      }
    }
    final texto = b.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

String soDigitos(String s) => s.replaceAll(RegExp(r'\D'), '');

/// Molde do celular brasileiro com DDD: (11) 98888-7777.
const moldeCelular = '(##) #####-####';

/// Formata 11 dígitos como (11) 98888-7777.
String formatarCelular(String digitos) => MascaraFormatter(moldeCelular)
    .formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: soDigitos(digitos)),
    )
    .text;

/// E-mail com cara de válido (algo@algo.algo).
bool emailValido(String e) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e.trim());

/// 150 → "R$ 150,00"; 1234.5 → "R$ 1.234,50".
String reais(num valor) {
  final centavos = (valor * 100).round();
  final inteiro = (centavos ~/ 100).toString();
  final b = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    if (i > 0 && (inteiro.length - i) % 3 == 0) b.write('.');
    b.write(inteiro[i]);
  }
  final cent = (centavos % 100).toString().padLeft(2, '0');
  return 'R\$ $b,$cent';
}

/// Digitação de reais inteiros: "150" vira "R$ 150".
class ReaisFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = soDigitos(newValue.text);
    if (d.length > 5) d = d.substring(0, 5);
    final n = int.tryParse(d) ?? 0;
    final texto = n == 0 ? '' : 'R\$ $n';
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// "R$ 1.200,00" → 1200 (texto sem número → 0).
double lerReais(String s) {
  final limpo = s.replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.');
  return double.tryParse(limpo) ?? 0;
}

/// 40 → "R$ 40" (sem centavos quando o valor é redondo).
String reaisInteiros(num v) => v == v.roundToDouble()
    ? reais(v).replaceFirst(RegExp(r',00$'), '')
    : reais(v);

/// RN-169: tempo de serviço. Até 59 → "25 min"; depois, "1 h 05 min"
/// (hora cheia: "2 h").
String duracaoTrabalho(int minutos) {
  if (minutos < 60) return '$minutos min';
  final h = minutos ~/ 60;
  final m = minutos % 60;
  return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')} min';
}
