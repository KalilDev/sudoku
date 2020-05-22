import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku/widgets/board/board.dart';
import 'package:sudoku_presentation/common.dart';
import 'package:sudoku_presentation/main_menu_bloc.dart';

import 'prefs_sheet.dart';
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

  Future<void> launch(SudokuConfiguration config, StorageAknowledgment aknowledgment, BuildContext context) async {
    final needsResponse = aknowledgment == StorageAknowledgment.unsupported;
    if (needsResponse) {
      final didAccept = await showDialog<bool>(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Aviso"),
          content: Text("Você está usando uma plataforma que ainda não suporta salvar Sudokus. Caso você saia, todo o seu progresso será perdido."),
          actions: [
            FlatButton(onPressed: ()=>Navigator.of(context).pop(true), child: Text("Aceitar"))
          ],
        );
      });
      if (!didAccept) {
        return;
      }
      BlocProvider.of<MainMenuBloc>(context).add(AknowledgeStorageEvent());
    }
    final difficultyIndex = SudokuDifficulty.values.indexOf(config.difficulty);
    return Navigator.of(context).pushNamed("${config.side}x$difficultyIndex", arguments: config).then((_) => BlocProvider.of<MainMenuBloc>(context).add(ReloadConfigurations()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainMenuBloc, MainMenuState>(
        builder: (BuildContext context, MainMenuState _state) {
      if (_state is LoadingMainMenu) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_state is MainMenuErrorState) {
        return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min,children: [
          Text(_state.userFriendlyMessage),
          Text("Mensagem do erro: ${_state.message}")
        ],),),);
      }
      final state = _state as MainMenuSnap;
      final configs = state.configurations;
      final theme = Provider.of<SudokuTheme>(context);
      final sideCounts = configs.map((row) => row.first.side).toList();
      final config = state.configurations[state.sideY][state.difficultyX];
      const widthConstraints = BoxConstraints(maxWidth: 450);
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
                  onPressed: () => launch(config.newSudoku(), state.storage, context),
                  child: Text("Novo jogo"),
                  filled: true,
                ),
                if (state.storage == StorageAknowledgment.supported)
                  SudokuButton(
                    onPressed: config.source == StateSource.storage
                        ? () => launch(config, state.storage, context)
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
