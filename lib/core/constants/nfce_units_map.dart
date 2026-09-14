import 'app_units.dart';

const _nfceUnitMap = <String, AppUnit>{
  'UN': AppUnit.un,
  'UND': AppUnit.un,
  'UNI': AppUnit.un,
  'PC': AppUnit.un,
  'PÇ': AppUnit.un,
  'PEC': AppUnit.un,
  'KG': AppUnit.kg,
  'KGS': AppUnit.kg,
  'QUI': AppUnit.kg,
  'G': AppUnit.g,
  'GR': AppUnit.g,
  'GRAMA': AppUnit.g,
  'GRA': AppUnit.g,
  'L': AppUnit.l,
  'LT': AppUnit.l,
  'LTS': AppUnit.l,
  'LIT': AppUnit.l,
  'ML': AppUnit.ml,
  'MLT': AppUnit.ml,
  'PCT': AppUnit.pack,
  'PAC': AppUnit.pack,
  'PACO': AppUnit.pack,
  'PACT': AppUnit.pack,
  'CX': AppUnit.box,
  'CXA': AppUnit.box,
  'CAI': AppUnit.box,
  'LAT': AppUnit.can,
  'LT.': AppUnit.can,
};

AppUnit nfceUnitFromRaw(String raw) {
  final key = raw.trim().toUpperCase();
  return _nfceUnitMap[key] ?? AppUnit.un;
}
