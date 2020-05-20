import 'package:flutter/material.dart' show Brightness, Color, Colors, MaterialColor;
import 'package:meta/meta.dart';
import 'package:sudoku_presentation/common.dart';

@immutable
class SudokuTheme {
  final Color main;
  final Color secondary;
  final Color secondaryDarkened;
  final Color mainDarkened;
  final Color background;
  final Color invalid;
  final Brightness brightness;
  SudokuTheme.raw({@required Color main, Color? secondary,  @required Color mainDarkened, Color? secondaryDarkened, @required this.background, @required this.invalid,
      @required this.brightness}) : secondary = secondary ?? main, main = main, secondaryDarkened = secondaryDarkened ?? mainDarkened, mainDarkened = mainDarkened;
  factory SudokuTheme({@required Color main, Color? secondary, Color? mainDarkened, Color? secondaryDarkened, Color? background, Color? invalid, bool? mixMainBg, Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    mixMainBg ??= isDark;
    if (main is MaterialColor && isDark) {
      main = main[200];
    }
    if (secondary is MaterialColor && isDark) {
      secondary = secondary[200];
    }
    invalid ??= isDark ? Colors.redAccent : Colors.red;
    final _materialBg = isDark ? Color(0xFF121212) : Color(0xFFFAFAFA);
    final _background = mixMainBg ? Color.alphaBlend(main.withAlpha(isDark ? 20 : 40), background ?? _materialBg) : background ?? _materialBg;
    mainDarkened ??= Color.alphaBlend(main.withAlpha(isDark ? 90 : 120), _background);
    secondary ??= main;
    secondaryDarkened ??= Color.alphaBlend(secondary.withAlpha(isDark ? 90 : 120), _background);
    return SudokuTheme(main: main, secondary: secondary, mainDarkened: mainDarkened, secondaryDarkened: secondaryDarkened, background: _background, invalid: invalid, brightness: brightness);
  }

  factory SudokuTheme.light({@required Color main, Color secondary, Color mainDarkened, Color secondaryDarkened, Color background, Color invalid, bool? mixMainBg}) {
    return SudokuTheme(main: main, secondary: secondary, mainDarkened: mainDarkened, secondaryDarkened: secondaryDarkened, background: background, invalid: invalid, mixMainBg: mixMainBg, brightness: Brightness.light);
  }
  factory SudokuTheme.dark({@required Color main, Color secondary, Color mainDarkened, Color secondaryDarkened, Color background, Color invalid, bool? mixMainBg}) {
    return SudokuTheme(main: main, secondary: secondary, mainDarkened: mainDarkened, secondaryDarkened: secondaryDarkened, background: background, invalid: invalid, mixMainBg: mixMainBg, brightness: Brightness.dark);
  }

  static final Map<AvailableTheme, SudokuTheme> availableThemeMap = {
    AvailableTheme.darkGreen: darkGreen,
    AvailableTheme.blackGreen: blackGreen,
    AvailableTheme.materialLight: materialLight,
    AvailableTheme.materialDark: materialDark,
    AvailableTheme.seasideLight: seasideLight,
    AvailableTheme.seasideDark: seasideDark,
    AvailableTheme.desertLight: desertLight,
    AvailableTheme.desertDark: desertDark,
    AvailableTheme.pixelBlue: pixelBlue,
  };
  static final darkGreen = SudokuTheme.dark(main: Colors.green);
  static final blackGreen = SudokuTheme.dark(main: Colors.green[500], background: Color(0xFF0A0A0A));
  static final materialLight = SudokuTheme.light(main: Colors.teal, secondary: Colors.blue);
  static final materialDark = SudokuTheme.dark(main: Colors.teal, secondary: Colors.deepPurple);
  static final seasideLight = SudokuTheme.light(main: Colors.indigo, secondary: Colors.deepPurple, background: Color(0xffdfe2f0));
  static final seasideDark = SudokuTheme.dark(main: Colors.indigo, secondary: Colors.deepPurple, background: Color(0xFF25262d));
  static final desertLight = SudokuTheme.light(main: Color(0xffc0b15c), secondary: Color(0xffc07f5c), mixMainBg: true);
  static final desertDark = SudokuTheme.dark(main: Color(0xfff8f2a4), secondary: Color(0xfff8c8a4));
  static final pixelBlue = SudokuTheme.light(main: Colors.blue);
  static final SudokuTheme defaultTheme = seasideDark;
}
