import 'package:flutter/material.dart' show Brightness, Color, Colors, MaterialColor;
import 'package:meta/meta.dart';


E enumFromString<E>(List<E> values, String s) => values
    .singleWhere((v) => v.toString().split('.').last == s, orElse: () => null);

@immutable
class SudokuTheme {
  final Color main;
  final Color secondary;
  final Color secondaryDarkened;
  final Color mainDarkened;
  final Color background;
  final Color invalid;
  final Brightness brightness;
  SudokuTheme({@required Color main, Color secondary,  @required Color mainDarkened, Color secondaryDarkened, @required this.background, @required this.invalid,
      @required this.brightness}) : secondary = secondary ?? main, main = main, secondaryDarkened = secondaryDarkened ?? mainDarkened, mainDarkened = mainDarkened;
  factory SudokuTheme._dark({@required Color main, Color secondary, Color mainDarkened, Color secondaryDarkened, Color background, Color invalid, bool mixMainBg = true}) {
    if (main is MaterialColor) {
      main = (main as MaterialColor)[200];
    }
    if (secondary is MaterialColor) {
      secondary = (secondary as MaterialColor)[200];
    }
    invalid ??= Colors.redAccent;
    final _materialBg = Color(0xFF121212);
    final _background = mixMainBg ? Color.alphaBlend(main.withAlpha(20), background ?? _materialBg) : background ?? _materialBg;
    mainDarkened ??= Color.alphaBlend(main.withAlpha(90), _background);
    secondary ??= main;
    secondaryDarkened ??= Color.alphaBlend(secondary.withAlpha(90), _background);
    return SudokuTheme(main: main, secondary: secondary, mainDarkened: mainDarkened, secondaryDarkened: secondaryDarkened, background: _background, invalid: invalid, brightness: Brightness.dark);
  }

  factory SudokuTheme._light({@required Color main, Color secondary, Color mainDarkened, Color secondaryDarkened, Color background, Color invalid, bool mixMainBg = false}) {
    invalid ??= Colors.red;
    final _materialBg = Color(0xFFFAFAFA);
    final _background = mixMainBg ? Color.alphaBlend(main.withAlpha(40), background ?? _materialBg) : background ?? _materialBg;
    mainDarkened ??= Color.alphaBlend(main.withAlpha(120), _background);
    secondary ??= main;
    secondaryDarkened ??= Color.alphaBlend(secondary.withAlpha(120), _background);
    return SudokuTheme(main: main, secondary: secondary, mainDarkened: mainDarkened, secondaryDarkened: secondaryDarkened, background: _background, invalid: invalid, brightness: Brightness.light);
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
  static SudokuTheme parse(String name) {
    final availableTheme =
        enumFromString<AvailableTheme>(AvailableTheme.values, name);
    if (availableTheme == null) {
      return defaultTheme;
    }
    return availableThemeMap[availableTheme];
  }
  static final darkGreen = SudokuTheme._dark(main: Colors.green);
  static final blackGreen = SudokuTheme._dark(main: Colors.green[500], background: Color(0xFF0A0A0A));
  static final materialLight = SudokuTheme._light(main: Colors.teal, secondary: Colors.blue);
  static final materialDark = SudokuTheme._dark(main: Colors.teal, secondary: Colors.deepPurple);
  static final seasideLight = SudokuTheme._light(main: Colors.indigo, secondary: Colors.deepPurple, background: Color(0xffdfe2f0));
  static final seasideDark = SudokuTheme._dark(main: Colors.indigo, secondary: Colors.deepPurple, background: Color(0xFF25262d));
  static final desertLight = SudokuTheme._light(main: Color(0xffc0b15c), secondary: Color(0xffc07f5c), mixMainBg: true);
  static final desertDark = SudokuTheme._dark(main: Color(0xfff8f2a4), secondary: Color(0xfff8c8a4));
  static final pixelBlue = SudokuTheme._light(main: Colors.blue);
  static final SudokuTheme defaultTheme = seasideDark;
}
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
