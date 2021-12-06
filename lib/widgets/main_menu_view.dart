import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/theme.dart';
import 'package:sudoku/widgets/board/board.dart';
import 'package:sudoku/widgets/exception_snackbar.dart';
import 'package:sudoku_presentation/errors.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:sudoku_presentation/main_menu_bloc.dart';
import 'package:sudoku_presentation/exception_handler_bloc.dart';

import 'prefs_fullscreen_dialog.dart';

String difficultyToString(SudokuDifficulty difficulty) {
  switch (difficulty) {
    case SudokuDifficulty.begginer:
      return 'Iniciante';
    case SudokuDifficulty.easy:
      return 'Fácil';
    case SudokuDifficulty.medium:
      return 'Média';
    case SudokuDifficulty.hard:
      return 'Difícil';
    case SudokuDifficulty.extreme:
      return 'Extrema';
    case SudokuDifficulty.impossible:
      return 'Impossível';
    default:
      return 'Desconhecida';
  }
}

class MainMenu extends StatelessWidget {
  void setSide(int side, BuildContext context) {
    BlocProvider.of<MainMenuBloc>(context).add(ChangeY(side));
  }

  void setDifficulty(int difficulty, BuildContext context) {
    BlocProvider.of<MainMenuBloc>(context).add(ChangeX(difficulty));
  }

  Future<void> launch(SudokuConfiguration config,
      StorageAknowledgment aknowledgment, BuildContext context) async {
    final needsResponse = aknowledgment == StorageAknowledgment.unsupported;
    if (needsResponse) {
      final didAccept = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return MD3BasicDialog(
              title: const Text("Aviso"),
              content: const Text(
                  "Você está usando uma plataforma que ainda não suporta salvar Sudokus. Caso você saia, todo o seu progresso será perdido."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Aceitar"),
                )
              ],
            );
          });
      if (!didAccept) {
        return;
      }
      BlocProvider.of<MainMenuBloc>(context).add(AknowledgeStorageEvent());
    }
    final difficultyIndex = SudokuDifficulty.values.indexOf(config.difficulty);
    return Navigator.of(context)
        .pushNamed("${config.side}x$difficultyIndex", arguments: config)
        .then((_) =>
            BlocProvider.of<MainMenuBloc>(context).add(ReloadConfigurations()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainMenuBloc, MainMenuState>(
        builder: (BuildContext context, MainMenuState _state) {
      if (_state is LoadingMainMenu) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_state is MainMenuErrorState) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_state.error.getText(kDebugMode)),
                Text(
                    "Mensagem do erro: ${_state.error.getExtraText(kDebugMode)}")
              ],
            ),
          ),
        );
      }
      final state = _state as MainMenuSnap;
      final configs = state.configurations;
      final theme = Provider.of<SudokuTheme>(context);
      final sideCounts = configs.map((row) => row.first.side).toList();
      final config = state.configurations[state.sideY][state.difficultyX];
      const widthConstraints = BoxConstraints(maxWidth: 450);
      final boardWidget = AspectRatio(
          aspectRatio: 1,
          child: Hero(
            tag: "SudokuBG",
            child: CustomPaint(
              painter: SudokuBgPainter(
                  sideCounts[state.sideY], theme.main, Colors.transparent),
            ),
          ));
      final optionsWidgets = [
        Text("Lado: " + sideCounts[state.sideY].toString()),
        MD3Slider(
          divisions: sideCounts.length - 1,
          value: state.sideY.toDouble(),
          onChanged: (v) => setSide(v.round(), context),
          max: sideCounts.length - 1.0,
        ),
        Text("Dificuldade: " +
            difficultyToString(SudokuDifficulty.values[state.difficultyX])),
        MD3Slider(
          divisions: configs.width - 1,
          value: state.difficultyX.toDouble(),
          onChanged: (v) => setDifficulty(v.round(), context),
          max: configs.width - 1.0,
        ),
        FilledButton(
          onPressed: () => launch(config.newSudoku(), state.storage, context),
          child: const Text("Novo jogo"),
        ),
        SizedBox(height: 8.0),
        if (state.storage == StorageAknowledgment.supported)
          FilledTonalButton(
            onPressed: config.source == StateSource.storage
                ? () => launch(config, state.storage, context)
                : null,
            child: const Text("Continuar"),
          )
      ];
      return Scaffold(
          appBar: MD3CenterAlignedAppBar(
            title: const Text("Sudoku"),
            trailing: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => openPrefs(context),
            ),
          ),
          body: BlocListener<ExceptionHandlerBloc, UserFriendly<Object>>(
            listener: showExceptionSnackbar,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(context.minMargin),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: widthConstraints,
                      child: boardWidget,
                    ),
                  ),
                  SizedBox(height: context.minMargin / 2),
                  Center(
                    child: ConstrainedBox(
                      constraints: widthConstraints,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: optionsWidgets,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
    });
  }
}
