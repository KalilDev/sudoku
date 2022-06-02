import 'package:flutter/material.dart';

import 'game_route/data.dart';
import 'game_route/generation_view.dart';
import 'game_route/resume_view.dart';
import 'home_view.dart';

abstract class SudokuNavigation {
  static const gameRouteName = 'name';
  static Future<GameRouteResult?> pushGameRoute(
          BuildContext context, GameRouteArguments args) =>
      Navigator.of(context).pushNamed(gameRouteName, arguments: args);
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case gameRouteName:
        final args = settings.arguments as GameRouteArguments;
        return MaterialPageRoute<GameRouteResult>(
          builder: (context) => args.visit(
            left: (createSudoku) => SudokuGenerationView(
              sideSqrt: createSudoku.sideSqrt,
              difficulty: createSudoku.difficulty,
              db: createSudoku.db,
            ),
            right: (resumeSudoku) => SudokuResumeView(
              sideSqrt: resumeSudoku.sideSqrt,
              difficulty: resumeSudoku.difficulty,
              db: resumeSudoku.db,
            ),
          ),
        );
      default:
        throw StateError('Unknown route');
    }
  }

  static const Widget homeView = SudokuHomeView();
}
