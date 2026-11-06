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
