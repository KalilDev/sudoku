import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku_presentation/common.dart';
import 'package:sudoku_presentation/main_menu_bloc.dart';
import 'prefs_sheet.dart';
import 'package:sudoku/theme.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/widgets/board/board.dart';

class MainMenu extends StatelessWidget {
  void setSide(int side, BuildContext context) {
    BlocProvider.of<MainMenuBloc>(context).add(ChangeY(side));
  }

  void setDifficulty(int difficulty, BuildContext context) {
    BlocProvider.of<MainMenuBloc>(context).add(ChangeX(difficulty));
  }

  void launch(SudokuConfiguration config, BuildContext context) {
    final difficultyIndex = SudokuDifficulty.values.indexOf(config.difficulty);
    Navigator.of(context).pushNamed("${config.side}x$difficultyIndex", arguments: config).then((_) => 
      Future.delayed(Duration(milliseconds: 500), ()=>BlocProvider.of<MainMenuBloc>(context).add(ReloadConfigurations())));
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
      //debugger();
      final theme = Provider.of<SudokuTheme>(context);
      final sideCounts = configs.map((row) => row.first.side).toList();
      final config = state.configurations[state.sideY][state.difficultyX];
      return Scaffold(
          appBar: AppBar(
            title: Text("Sudoku"),
            actions: [
              IconButton(icon: Icon(Icons.settings), onPressed: () => openPrefs(context))
            ],
          ),
          body: Center(
            child: FractionallySizedBox(
              widthFactor: 0.6,
              alignment: Alignment.center,
                        child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Spacer(),
              Flexible(
                flex: 2,
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
              ),
              Flexible(flex: 2,child: Center(
                child: Column(children: [
                  Text("Lado: " + sideCounts[state.sideY].toString()),
                FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Slider(
                      divisions: sideCounts.length - 1,
                      value: state.sideY.toDouble(),
                      onChanged: (v) => setSide(v.round(), context),
                      max: sideCounts.length - 1.0,
                    )),
                Text("Dificuldade: " +
                    SudokuDifficulty.values[state.difficultyX].toString()),
                FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Slider(
                      divisions: configs.width - 1,
                      value: state.difficultyX.toDouble(),
                      onChanged: (v) => setDifficulty(v.round(), context),
                      max: configs.width - 1.0,
                    )),
                RaisedButton(
                  onPressed: () => launch(config.newSudoku(), context),
                  child: Text("Novo jogo"),
                ),
                RaisedButton(
                  onPressed: config.source == StateSource.storage
                      ? () => launch(config, context)
                      : null,
                  child: Text("Continuar"),
                )
                ]),
              ),),
              Spacer()
                ],
              ),
            ),
          ));
    });
  }
}
