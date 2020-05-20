import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_presentation/common.dart';
import 'package:sudoku_presentation/preferences_bloc.dart';
import 'package:sudoku_presentation/main_menu_bloc.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';
import 'package:sudoku/repositories/localstorage_board_repository.dart';
import 'package:sudoku_presentation/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/repositories/cross_preferences_repository.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku/widgets/board/sudoku_board_view.dart';
import 'package:sudoku/widgets/main_menu_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BoardRepository>(
            create: (_) {
              final supported = true;
              if (supported) {
                return LocalStorageBoardRepository();
              }
              return MockBoardRepository();
            }),
        RepositoryProvider<PreferencesRepository>(
            create: (_) {
              final supported = true;
              if (supported) {
                return CrossPreferencesRepository();
              }
              return MockPreferencesRepository();
            }),
      ],
      child: BlocProvider<PreferencesBloc>(
        create: (BuildContext context) => PreferencesBloc(RepositoryProvider.of<PreferencesRepository>(context)),
              child: RootView(),
      )));
}


class RootView extends StatelessWidget {
  static bool condition(PrefsState prev, PrefsState next) {
    if (prev is PrefsSnap && next is PrefsSnap) {
      return prev.theme != next.theme;
    }
    return true;
  }

  static Route<dynamic> onGeneratedRoute(
      RouteSettings routeSettings) {
    final name = routeSettings.name.split("/").single;
    SudokuConfiguration sudokuConfiguration;
    if (routeSettings.arguments != null) {
      sudokuConfiguration = routeSettings.arguments as SudokuConfiguration;
    } else {
      final numbers = name.split("x").map(int.parse).toList();
      sudokuConfiguration = SudokuConfiguration(numbers[0], numbers[1]); // TODO
    }
    return MaterialPageRoute<void>(
        builder: (context) => BlocProvider<SudokuBloc>(
              create: (BuildContext context) => SudokuBloc(sudokuConfiguration,
                  RepositoryProvider.of<BoardRepository>(context),
                  ),
              child: SudokuBoardView(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PrefsState>(builder: (BuildContext context, PrefsState _state) {
      final state = _state is PrefsSnap ? _state : null;

      final availableTheme = state?.theme ?? AvailableTheme.materialLight;
      final theme = SudokuTheme.availableThemeMap[availableTheme];
      final colorScheme = theme.brightness == Brightness.light
          ? ColorScheme.light(
              primary: theme.main, secondary: theme.secondary, primaryVariant: theme.mainDarkened, secondaryVariant: theme.secondaryDarkened)
          : ColorScheme.dark(
              primary: theme.main, secondary: theme.secondary, primaryVariant: theme.mainDarkened, secondaryVariant: theme.secondaryDarkened);
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
      final isDark = theme.brightness == Brightness.dark;
      final overlayStyle = SystemUiOverlayStyle(
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarColor: theme.background,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark
      );
      final themeData = ThemeData.from(
                  colorScheme:
                      colorScheme.copyWith(background: theme.background, surface: theme.background));
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
              child: Provider<SudokuTheme>.value(value: theme,
                child: MaterialApp(
              theme: themeData.copyWith(buttonTheme: themeData.buttonTheme.copyWith(buttonColor: theme.secondary, textTheme: ButtonTextTheme.primary)),
              title: "Sudoku",
              home: BlocProvider<MainMenuBloc>(
                create: (BuildContext context) => MainMenuBloc(
                    RepositoryProvider.of<BoardRepository>(context),
                    RepositoryProvider.of<PreferencesRepository>(context)),child: MainMenu()),
              onGenerateRoute: onGeneratedRoute,
          ),
        ),
      );
    }, condition: condition,);
  }
}
