import 'package:flutter/material.dart'
    show Brightness, Color, Colors, MaterialColor;
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:meta/meta.dart';
import 'package:sudoku_presentation/models.dart';

MonetTheme monetThemeFromSudokuTheme(SudokuTheme theme) => theme.theme;

@immutable
class SudokuTheme {
  final MonetTheme theme;
  final ThemeMode themeMode;

  factory SudokuTheme({
    @required Color mainSeed,
    Color secondarySeed,
    Color background,
    bool mixMainBg = false,
    ThemeMode themeMode,
  }) {
    if (background != null) {
      if (themeMode == ThemeMode.system) {
        throw StateError(
            'Only one themeMode is allowed when specifying an background!');
      }
    }
    final isDark = themeMode == ThemeMode.dark;
    final _materialBg =
        isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final _background = mixMainBg
        ? Color.alphaBlend(
            mainSeed.withAlpha(isDark ? 20 : 40), background ?? _materialBg)
        : background ?? _materialBg;
    final monetTheme = generateTheme(
      mainSeed,
      tertiarySeed: secondarySeed,
    ).override(
      // Only one will be used, so its ok to change on both brightness
      light: (t) => t.copyWith(
        background: background,
        surface: background,
      ),
      dark: (t) => t.copyWith(
        background: background,
        surface: background,
      ),
    );
    return SudokuTheme.raw(theme: monetTheme, themeMode: themeMode);
  }

  const SudokuTheme.raw({this.theme, this.themeMode});

  factory SudokuTheme.light({
    @required Color main,
    Color secondary,
    Color background,
    bool mixMainBg = false,
  }) {
    return SudokuTheme(
        mainSeed: main,
        secondarySeed: secondary,
        mixMainBg: mixMainBg,
        background: background,
        themeMode: ThemeMode.light);
  }
  factory SudokuTheme.dark({
    @required Color main,
    Color secondary,
    Color background,
    bool mixMainBg = false,
  }) {
    return SudokuTheme(
        mainSeed: main,
        secondarySeed: secondary,
        mixMainBg: mixMainBg,
        background: background,
        themeMode: ThemeMode.dark);
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
    AvailableTheme.monetAuto: monetAuto,
    AvailableTheme.monetLight: monetLight,
    AvailableTheme.monetDark: monetDark,
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
  static const SudokuTheme monetAuto =
      SudokuTheme.raw(themeMode: ThemeMode.system);
  static const SudokuTheme monetLight =
      SudokuTheme.raw(themeMode: ThemeMode.light);
  static const SudokuTheme monetDark =
      SudokuTheme.raw(themeMode: ThemeMode.dark);
  static const SudokuTheme defaultTheme = monetAuto;
}
