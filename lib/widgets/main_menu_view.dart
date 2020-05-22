import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_presentation/common.dart';
import 'package:sudoku_presentation/main_menu_bloc.dart';
import 'prefs_sheet.dart';
import 'package:sudoku/theme.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/widgets/board/board.dart';
import 'sudoku_button.dart';

String difficultyToString(SudokuDifficulty difficulty) {
  switch (difficulty) {
    case SudokuDifficulty.begginer: return 'Iniciante';
    case SudokuDifficulty.easy: return 'Fácil';
    case SudokuDifficulty.medium: return 'Média';
    case SudokuDifficulty.hard: return 'Difícil';
    case SudokuDifficulty.extreme: return 'Extrema';
    case SudokuDifficulty.impossible: return 'Impossível';
    default: return 'Desconhecida';
  }
}

class MainMenu extends StatelessWidget {
  void setSide(int side, BuildContext context) {
    BlocProvider.of<MainMenuBloc>(context).add(ChangeY(side));
  }

  void setDifficulty(int difficulty, BuildContext context) {
    BlocProvider.of<MainMenuBloc>(context).add(ChangeX(difficulty));
  }

  void launch(SudokuConfiguration config, BuildContext context) {
    final difficultyIndex = SudokuDifficulty.values.indexOf(config.difficulty);
    Navigator.of(context).pushNamed("${config.side}x$difficultyIndex", arguments: config).then((_) => BlocProvider.of<MainMenuBloc>(context).add(ReloadConfigurations()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainMenuBloc, MainMenuState>(
        builder: (BuildContext context, MainMenuState _state) {
      if (_state is LoadingMainMenu) {
        return Center(child: CircularProgressIndicator());
      }
      final state = _state as MainMenuSnap;
      final configs = state.configurations;
      final theme = Provider.of<SudokuTheme>(context);
      final sideCounts = configs.map((row) => row.first.side).toList();
      final config = state.configurations[state.sideY][state.difficultyX];
      final widthConstraints = BoxConstraints(maxWidth: 450);
      final boardWidget = 
                Flexible(
                  child: Center(
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Hero(
              tag: "SudokuBG",
                child: CustomPaint(
                painter: SudokuBgPainter(
                    sideCounts[state.sideY], theme.main, Colors.transparent),
              ),
                        )),
                  ),
                );
      final sliderTheme = Theme.of(context).sliderTheme.copyWith(activeTrackColor: theme.secondary, thumbColor: theme.secondary);
      final optionsWidgets = [
                  Text("Lado: " + sideCounts[state.sideY].toString()),
                Slider(
                  divisions: sideCounts.length - 1,
                  value: state.sideY.toDouble(),
                  onChanged: (v) => setSide(v.round(), context),
                  max: sideCounts.length - 1.0,
                ),
                Text("Dificuldade: " +
                    difficultyToString(SudokuDifficulty.values[state.difficultyX])),
                Slider(
                  divisions: configs.width - 1,
                  value: state.difficultyX.toDouble(),
                  onChanged: (v) => setDifficulty(v.round(), context),
                  max: configs.width - 1.0,
                ),
                SudokuButton(
                  onPressed: () => launch(config.newSudoku(), context),
                  child: Text("Novo jogo"),
                  filled: true,
                ),
                SudokuButton(
                  onPressed: config.source == StateSource.storage
                      ? () => launch(config, context)
                      : null,
                  filled: true,
                  child: Text("Continuar"),
                )
      ];
      return SliderTheme(
        data: sliderTheme,
              child: Scaffold(
            appBar: AppBar(
              title: Text("Sudoku"),
              actions: [
                IconButton(icon: Icon(Icons.settings), onPressed: () => openPrefs(context))
              ],
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: widthConstraints,
                          child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    boardWidget,
                  Flexible(child: Column(mainAxisSize: MainAxisSize.min, children: optionsWidgets),),
                    ],
                  ),
              ),
            )),
      );
    });
  }
}
