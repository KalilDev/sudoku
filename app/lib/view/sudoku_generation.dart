library app.view.sudoku_generation;

import 'package:app/module/base.dart';
import 'package:app/sudoku_generation/sudoku_generation.dart';
import 'package:app/util/monadic.dart';
import 'package:app/view/sudoku_board.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:app/viewmodel/sudoku_generation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import 'sudoku_board/actions.dart';
import 'sudoku_board/board.dart';
import 'sudoku_board/keypad.dart';
import 'sudoku_board/layout.dart';
import 'sudoku_board/locking.dart';

final ContextfulAction<ScaffoldMessengerState> scaffoldMessenger =
    readC.map(ScaffoldMessenger.of);
ContextfulAction<void> showSnackbar(SnackBar snackBar) =>
    scaffoldMessenger.map((messenger) => messenger.showSnackBar(snackBar));

class GenerationView extends ControllerWidget<GenerationController> {
  final SudokuViewController Function(SolvedAndChallengeBoard)
      createBoardControllerFromGenerated;
  const GenerationView({
    Key? key,
    required this.createBoardControllerFromGenerated,
    required ControllerHandle<GenerationController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  static Widget _loadingView(
    BuildContext context,
    double? progress,
    SudokuBoard challengeBoard,
  ) =>
      _LoadingGenerationView(
        progress: progress,
        board: _tileMatrixFromSudokuBoard(challengeBoard),
        side: challengeBoard.length,
      );

  static TileMatrix _tileMatrixFromSudokuBoard(SudokuBoard board) {
    final side = board.length;
    final result = emptyTileMatrix(side);
    for (var y = 0; y < side; y++) {
      for (var x = 0; x < side; x++) {
        final i = SudokuBoardIndex(x, y);
        final atI = sudokuBoardGetAt(board, i);
        matrixSetAt<SudokuTile>(
          result,
          i,
          atI == 0
              ? const SudokuTile.possibilities([])
              : SudokuTile.permanent(atI),
        );
      }
      // lock the row
      result[y] = UnmodifiableListView(result[y]);
    }
    // lock the matrix
    return UnmodifiableListView(result);
  }

  @override
  Widget build(ControllerContext<GenerationController> context) {
    final generatedBoard = context.use(controller.generatedBoard);
    void _onGenerationEvent(SudokuGenerationEvent? event) {
      if (event == null) {
        return;
      }
      //showSnackbar(SnackBar(content: Text(event.toString())))(context);
    }

    context.useEventHandler(controller.generationEvents, _onGenerationEvent);
    final progress = context.use(controller.generationProgress);
    final challengeBoard = context.use(controller.challengeBoard);
    // needs to be outside the map because otherwise the progress and challenge
    // board would be used more than once, violating the ownership contract
    final loadingViewW = (_loadingView.curry(context).asValueListenable >>
            progress >>
            challengeBoard)
        .build();
    return generatedBoard
        .map(
          (maybeGeneratedBoard) => maybeGeneratedBoard == null
              ? loadingViewW
              : ControllerInjectorBuilder<SudokuViewController>(
                  factory: (context) =>
                      createBoardControllerFromGenerated(maybeGeneratedBoard),
                  builder: (context, controller) =>
                      SudokuView(controller: controller),
                  key: ValueKey(maybeGeneratedBoard),
                ),
        )
        .build();
  }
}

class _LoadingGenerationView extends StatelessWidget {
  const _LoadingGenerationView({
    Key? key,
    required this.progress,
    required this.board,
    required this.side,
  }) : super(key: key);
  final double? progress;
  final TileMatrix board;
  final int side;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(value: progress),
        ),
        Positioned.fill(
          child: Actions(
            actions: SudokuView.emptyActions,
            child: SudokuBoardIsLocked(
              isLocked: true,
              child: SudokuViewLayout(
                board: SudokuViewBoardWidget(
                  board: board.asValueListenable,
                  selectedIndex: null.asValueListenable,
                  side: side,
                ),
                keypad: SudokuBoardKeypadWidget(
                  selectedNumber: null.asValueListenable,
                  side: side,
                ),
                actions: SudokuBoardActionsWidget(
                  canUndo: false.asValueListenable,
                  placementMode: SudokuPlacementMode.number.asValueListenable,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
