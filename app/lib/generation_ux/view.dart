import 'package:app/base/controller.dart';
import 'package:app/generation/impl/data.dart';
import 'package:app/generation_ux/controller.dart';
import 'package:app/monadic.dart';
import 'package:app/ui/view.dart';
import 'package:app/view/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import '../base/sudoku_data.dart';
import '../ui/src/actions.dart';
import '../ui/src/board.dart';
import '../ui/src/keypad.dart';
import '../ui/src/layout.dart';
import '../view/data.dart';
import '../widgets/memo.dart';

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
    TileMatrix challengeBoard,
  ) =>
      _LoadingGenerationView(
        progress: progress,
        board: challengeBoard,
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
    return generatedBoard
        .map(
          (maybeGeneratedBoard) => maybeGeneratedBoard == null
              ? (_loadingView.curry(context).asValueListenable >>
                      progress >>
                      challengeBoard.map(_tileMatrixFromSudokuBoard))
                  .build()
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
    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        Expanded(
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
