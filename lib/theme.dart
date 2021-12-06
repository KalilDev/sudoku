import 'package:flutter/material.dart'
    show Brightness, Color, Colors, MaterialColor;
import 'package:material_widgets/material_widgets.dart';
import 'package:meta/meta.dart';
import 'package:sudoku_presentation/models.dart';

SudokuTheme sudokuThemeFromMonetScheme(MonetColorScheme scheme) =>
    SudokuTheme.raw(
      main: scheme.primary,
      mainDarkened: scheme.primary,
      secondary: scheme.tertiaryContainer,
      secondaryDarkened: scheme.tertiary,
      background: scheme.background,
      invalid: scheme.surfaceVariant,
      brightness: scheme.brightness,
    );

@immutable
class SudokuTheme {
  final Color main;
  final Color secondary;
  final Color secondaryDarkened;
  final Color mainDarkened;
  final Color background;
  final Color invalid;
  final Brightness brightness;

  factory SudokuTheme(
      {@required Color main,
      Color secondary,
      Color mainDarkened,
      Color secondaryDarkened,
      Color background,
      Color invalid,
      bool mixMainBg,
      Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    mixMainBg ??= isDark;
    if (main is MaterialColor && isDark) {
      main = (main as MaterialColor)[200];
    }
    if (secondary is MaterialColor && isDark) {
      secondary = (secondary as MaterialColor)[200];
    }
    invalid ??= isDark ? Colors.redAccent : Colors.red;
    final _materialBg =
        isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final _background = mixMainBg
        ? Color.alphaBlend(
            main.withAlpha(isDark ? 20 : 40), background ?? _materialBg)
        : background ?? _materialBg;
    mainDarkened ??=
        Color.alphaBlend(main.withAlpha(isDark ? 90 : 120), _background);
    secondary ??= main;
    secondaryDarkened ??=
        Color.alphaBlend(secondary.withAlpha(isDark ? 90 : 120), _background);
    return SudokuTheme.raw(
        main: main,
        secondary: secondary,
        mainDarkened: mainDarkened,
        secondaryDarkened: secondaryDarkened,
        background: _background,
        invalid: invalid,
        brightness: brightness);
  }

  const SudokuTheme.raw(
      {@required this.main,
      @required this.secondary,
      @required this.mainDarkened,
      this.secondaryDarkened,
      @required this.background,
      @required this.invalid,
      @required this.brightness});

  factory SudokuTheme.light(
      {@required Color main,
      Color secondary,
      Color mainDarkened,
      Color secondaryDarkened,
      Color background,
      Color invalid,
      bool mixMainBg}) {
    return SudokuTheme(
        main: main,
        secondary: secondary,
        mainDarkened: mainDarkened,
        secondaryDarkened: secondaryDarkened,
        background: background,
        invalid: invalid,
        mixMainBg: mixMainBg,
        brightness: Brightness.light);
  }
  factory SudokuTheme.dark(
      {@required Color main,
      Color secondary,
      Color mainDarkened,
      Color secondaryDarkened,
      Color background,
      Color invalid,
      bool mixMainBg}) {
    return SudokuTheme(
        main: main,
        secondary: secondary,
        mainDarkened: mainDarkened,
        secondaryDarkened: secondaryDarkened,
        background: background,
        invalid: invalid,
        mixMainBg: mixMainBg,
        brightness: Brightness.dark);
  }

  SudokuTheme copyWith({
    Color main,
    Color secondary,
    Color secondaryDarkened,
    Color mainDarkened,
    Color background,
    Color invalid,
    Brightness brightness,
  }) =>
      SudokuTheme.raw(
          main: main ?? this.main,
          secondary: secondary ?? this.secondary,
          mainDarkened: mainDarkened ?? this.mainDarkened,
          secondaryDarkened: secondaryDarkened ?? this.secondaryDarkened,
          background: background ?? this.background,
          invalid: invalid ?? this.invalid,
          brightness: brightness ?? this.brightness);

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
  static final SudokuTheme darkGreen = SudokuTheme.dark(main: Colors.green);
  static final SudokuTheme blackGreen = SudokuTheme.dark(
      main: Colors.green[500], background: const Color(0xFF0A0A0A));
  static final SudokuTheme materialLight =
      SudokuTheme.light(main: Colors.teal, secondary: Colors.blue);
  static final SudokuTheme materialDark =
      SudokuTheme.dark(main: Colors.teal, secondary: Colors.deepPurple);
  static final SudokuTheme seasideLight = SudokuTheme.light(
      main: Colors.indigo,
      secondary: Colors.deepPurple,
      background: const Color(0xffdfe2f0));
  static final SudokuTheme seasideDark = SudokuTheme.dark(
      main: Colors.indigo,
      secondary: Colors.deepPurple,
      background: const Color(0xFF25262d));
  static final SudokuTheme desertLight = SudokuTheme.light(
      main: const Color(0xffc0b15c),
      secondary: const Color(0xffc07f5c),
      mixMainBg: true);
  static final SudokuTheme desertDark = SudokuTheme.dark(
      main: const Color(0xfff8f2a4), secondary: const Color(0xfff8c8a4));
  static final SudokuTheme pixelBlue = SudokuTheme.light(main: Colors.blue);
  static final SudokuTheme defaultTheme = seasideDark;
}
