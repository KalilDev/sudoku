import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/repositories/cross_preferences_repository.dart';
import 'package:sudoku/repositories/localstorage_board_repository.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku/widgets/board/sudoku_board_view.dart';
import 'package:sudoku/widgets/main_menu_view.dart';
import 'package:sudoku_presentation/exception_handler_bloc.dart';
import 'package:sudoku_presentation/main_menu_bloc.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:sudoku_presentation/preferences_bloc.dart';
import 'package:sudoku_presentation/repositories.dart';
import 'package:sudoku_presentation/sudoku_bloc.dart';


void main() {
  runPlatformThemedApp(
    BlocProvider<ExceptionHandlerBloc>(
      create: (_) => ExceptionHandlerBloc(),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BoardRepository>(
              create: (_) => LocalStorageBoardRepository()),
          RepositoryProvider<PreferencesRepository>(
              create: (_) => CrossPreferencesRepository()),
        ],
        child: BlocProvider<PreferencesBloc>(
          create: (BuildContext context) => PreferencesBloc(
              preferencesRepository:
                  RepositoryProvider.of<PreferencesRepository>(context),
              onException:
                  BlocProvider.of<ExceptionHandlerBloc>(context).handler),
          child: RootView(),
        ),
      ),
    ),
    initialOrFallback: () => PlatformPalette.fallback(
      primaryColor: Color(0xFF0d6da5),
    ),
  );
}

class RootView extends StatelessWidget {
  static bool condition(PrefsState prev, PrefsState next) {
    if (prev is PrefsSnap && next is PrefsSnap) {
      return prev.theme != next.theme;
    }
    return true;
  }

  static Route<dynamic> onGeneratedRoute(RouteSettings routeSettings) {
    final name = routeSettings.name.split("/").single;
    SudokuConfiguration sudokuConfiguration;
    if (routeSettings.arguments != null) {
      sudokuConfiguration = routeSettings.arguments as SudokuConfiguration;
    } else {
      final numbers = name.split("x").map(int.parse).toList();
      sudokuConfiguration = SudokuConfiguration(numbers[0], numbers[1]);
    }
    return MaterialPageRoute<void>(
        builder: (context) => BlocProvider<SudokuBloc>(
              create: (BuildContext context) => SudokuBloc(
                sudokuConfiguration,
                RepositoryProvider.of<BoardRepository>(context),
              ),
              child: SudokuBoardView(),
            ));
  }

  static MonetTheme monetThemeFromSudokuTheme(SudokuTheme theme) =>
      generateTheme(
        theme.main,
        tertiarySeed: theme.secondary,
      ).override(
        // Only one will be used, so its ok to change both brightness
        light: (t) => t.copyWith(
          background: theme.background,
          surface: theme.background,
        ),
        dark: (t) => t.copyWith(
          background: theme.background,
          surface: theme.background,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PrefsState>(
      builder: (BuildContext context, PrefsState _state) {
        final state = _state is PrefsSnap ? _state : null;
        final availableTheme = state?.theme ?? AvailableTheme.monetAuto;
        final theme = SudokuTheme.availableThemeMap[availableTheme];

        final themeMode = availableTheme == AvailableTheme.monetAuto
            ? ThemeMode.system
            : availableTheme == AvailableTheme.monetDark ||
                    theme?.brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light;

        if (_state is PrefsErrorState) {
          return MaterialApp(
            home: Scaffold(
              appBar: MD3CenterAlignedAppBar(title: const Text('Erro')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_state.error.getText(kDebugMode)),
                    Text('Mensagem do erro: ' +
                        _state.error.getExtraText(kDebugMode))
                  ],
                ),
              ),
            ),
          );
        }

        final isMonet = availableTheme == AvailableTheme.monetAuto ||
            availableTheme == AvailableTheme.monetLight ||
            availableTheme == AvailableTheme.monetDark;

        return MD3Themes(
          monetThemeForFallbackPalette:
              isMonet ? null : monetThemeFromSudokuTheme(theme),
          usePlatformPalette: isMonet,
          builder: (context, light, dark) => MaterialApp(
            theme: light,
            darkTheme: dark,
            themeMode: themeMode,
            title: "Sudoku",
            builder: (context, home) => AnimatedMonetColorScheme(
              themeMode: themeMode,
              child: Provider<SudokuTheme>.value(
                value: sudokuThemeFromMonetScheme(context.colorScheme),
                child: home,
              ),
            ),
            home: BlocProvider<MainMenuBloc>(
              create: (BuildContext context) => MainMenuBloc(
                boardRepository:
                    RepositoryProvider.of<BoardRepository>(context),
                preferencesRepository:
                    RepositoryProvider.of<PreferencesRepository>(context),
                onException:
                    BlocProvider.of<ExceptionHandlerBloc>(context).handler,
              ),
              child: MainMenu(),
            ),
            onGenerateRoute: onGeneratedRoute,
          ),
        );
      },
      condition: condition,
    );
  }
}
