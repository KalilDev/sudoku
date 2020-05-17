import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/presentation/common.dart';
import 'package:sudoku/presentation/main_menu_bloc/main_menu_bloc.dart';
import 'package:sudoku/presentation/preferences_bloc.dart';
import 'package:sudoku/presentation/repository/localstorage_board_repository.dart';
import 'package:sudoku/presentation/repository/mock_repositories.dart';
import 'package:sudoku/presentation/repository/board_repository.dart';
import 'package:sudoku/presentation/repository/preferences_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/presentation/repository/cross_preferences_repository.dart';
import 'package:sudoku/presentation/sudoku_bloc/sudoku_bloc.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku/widgets/board/sudoku_board_view.dart';
import 'package:sudoku/widgets/main_menu_view.dart';
import 'package:provider/provider.dart';

void main() {
  BlocSupervisor.delegate = CustomBlocDelegate();
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
  static bool condition(PrefsState prev, PrefsState next) => prev.theme != next.theme;

  static Route<dynamic> onGeneratedRoute(
      RouteSettings routeSettings) {
    final name = routeSettings.name.split("/").single;
    SudokuConfiguration sudokuConfiguration;
    if (routeSettings.arguments != null) {
      sudokuConfiguration = routeSettings.arguments;
    } else {
      final numbers = name.split("x").map(int.parse).toList();
      sudokuConfiguration = SudokuConfiguration(numbers[0], numbers[1]); // TODO
    }
    return MaterialPageRoute(
        builder: (context) => BlocProvider<SudokuBloc>(
              create: (BuildContext context) => SudokuBloc(sudokuConfiguration,
                  RepositoryProvider.of<BoardRepository>(context),
                  ),
              child: SudokuBoardView(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PrefsState>(builder: (BuildContext context, PrefsState state) {

      final theme = state.theme ?? SudokuTheme.defaultTheme;
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




class CustomBlocDelegate extends BlocDelegate {
  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    debugger();
    super.onError(bloc, error, stackTrace);
  }
}