import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../data/enderecos.dart';

IconData iconeDoTipo(TipoEndereco t) => switch (t) {
  TipoEndereco.casa => TablerIcons.home,
  TipoEndereco.trabalho => TablerIcons.briefcase,
  TipoEndereco.outro => TablerIcons.map_pin,
};
