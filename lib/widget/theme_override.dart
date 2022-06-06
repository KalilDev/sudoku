import 'package:app/main.dart';
import 'package:app/module/theme.dart';
import 'package:app/view/sudoku_board/layout.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';

MonetTheme seededThemeToMonetTheme(SudokuSeededTheme theme) {
  final monetTheme = generateTheme(
    theme.seed,
    tertiarySeed: theme.secondarySeed,
  );
  if (theme.background == null) {
    return monetTheme;
  }
  // We use surface as the background, so override it too
  switch (theme.brightness) {
    case Brightness.dark:
      return monetTheme.copyWith(
        dark: monetTheme.dark.copyWith(
          background: theme.background,
          surface: theme.background,
        ),
      );
    case Brightness.light:
      return monetTheme.copyWith(
        light: monetTheme.light.copyWith(
          background: theme.background,
          surface: theme.background,
        ),
      );
  }
}

class ThemeOverride extends StatelessWidget {
  const ThemeOverride({
    Key? key,
    required this.theme,
    required this.child,
  }) : super(key: key);
  final SudokuTheme theme;
  final Widget child;

  static ThemeMode _concreteThemeModeFromSudokuTheme(
    SudokuTheme sudokuTheme,
    Brightness platformBrightness,
  ) =>
      sudokuTheme.visit(
        sudokuMaterialYouTheme: (mu) {
          switch (mu.themeMode) {
            case ThemeMode.system:
              return platformBrightness == Brightness.light
                  ? ThemeMode.light
                  : ThemeMode.dark;
            case ThemeMode.light:
              return ThemeMode.light;
            case ThemeMode.dark:
              return ThemeMode.dark;
          }
        },
        sudokuSeededTheme: (seeded) {
          switch (seeded.brightness) {
            case Brightness.dark:
              return ThemeMode.dark;
            case Brightness.light:
              return ThemeMode.light;
          }
        },
      );

  @override
  Widget build(BuildContext context) => MD3Themes(
        monetThemeForFallbackPalette: theme.visit(
          sudokuMaterialYouTheme: (_) => MonetTheme.baseline3p,
          sudokuSeededTheme: (seeded) => seededThemeToMonetTheme(seeded),
        ),
        usePlatformPalette: theme.visit(
          sudokuMaterialYouTheme: (_) => true,
          sudokuSeededTheme: (_) => false,
        ),
        builder: (context, light, dark) {
          final concreteThemeMode = _concreteThemeModeFromSudokuTheme(
            theme,
            mediaQuery(context).platformBrightness,
          );
          return AnimatedMonetColorSchemes<NoAppScheme, NoAppTheme>(
            themeMode: concreteThemeMode,
            child: AnimatedTheme(
              data: concreteThemeMode == ThemeMode.light ? light : dark,
              child: child,
            ),
          );
        },
      );
}
