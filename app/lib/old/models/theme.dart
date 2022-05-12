import 'enum_parser.dart';

AvailableTheme parseAvailableTheme(String s) =>
    enumFromString(AvailableTheme.values, s, orElse: AvailableTheme.monetAuto);

enum AvailableTheme {
  monetLight,
  monetDark,
  monetAuto,
  darkGreen,
  blackGreen,
  materialLight,
  materialDark,
  seasideLight,
  seasideDark,
  desertLight,
  desertDark,
  pixelBlue,
}
