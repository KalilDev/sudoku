import 'enum_parser.dart';

AvailableTheme parseAvailableTheme(String s) =>
    enumFromString(AvailableTheme.values, s,
        orElse: AvailableTheme.materialLight);

enum AvailableTheme {
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
