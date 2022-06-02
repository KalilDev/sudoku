// An streaming sudoku generation function that can block the current isolate.
import 'dart:async';
import 'dart:math';

import 'package:app/module/base.dart';

import 'data.dart';
import 'extern/exposed_extern_api.dart';

Stream<SudokuGenerationEvent> generateSudokuStreamingIsolateLocal(
  int sideSqrt,
  SudokuDifficulty difficulty,
) {
  final side = sideSqrt * sideSqrt;
  final targetFilledCells =
      filledSudokuCellCountFromDifficulty(difficulty, side);
  return rawGenerateSudokuStreamingIsolateLocal(side, targetFilledCells);
}

// An sudoku generation function that can block the current isolate.
Future<SolvedAndChallengeBoard> generateSudokuIsolateLocal(
  int sideSqrt,
  SudokuDifficulty difficulty,
) async {
  final finishEvent =
      await generateSudokuStreamingIsolateLocal(sideSqrt, difficulty)
          .last
          .then((e) => e as SudokuGenerationFinished);
  return SolvedAndChallengeBoard(
    finishEvent.solvedState,
    finishEvent.challengeState,
  );
}

// An primitive streaming sudoku generation function that can block the current
// isolate.
Stream<SudokuGenerationEvent> rawGenerateSudokuStreamingIsolateLocal(
  int side,
  int targetFilledCellCount,
) =>
    _SudokuGenerationStream(side, targetFilledCellCount);

class _SudokuGenerationStream extends Stream<SudokuGenerationEvent> {
  final int side;
  final int targetFilledCellCount;

  _SudokuGenerationStream(this.side, this.targetFilledCellCount);
  @override
  StreamSubscription<SudokuGenerationEvent> listen(
    void Function(SudokuGenerationEvent event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Only two boards that will be allocated
    final solvedBoard = generateExternSudokuBlocking(side);
    final workingBoard = cloneExternSudokuBoard(solvedBoard);
    void _onDone() {
      print("Gonna cleanup after stream controller");
      externSudokuFree(solvedBoard);
      externSudokuFree(workingBoard);
      onDone?.call();
    }

    return () async* {
      yield SudokuGenerationFoundSolution(sudokuBoardFromExtern(solvedBoard));
      final rand = Random();
      final targetEmptyCellCount = side * side - targetFilledCellCount;
      // Indices which we will try to remove
      final indices = List<SudokuBoardIndex>.generate(
        side * side,
        (i) => SudokuBoardIndex(i % side, i ~/ side),
        growable: false,
      )..shuffle(rand);
      int emptyCellCount = 0;
      for (final index in indices) {
        // If we already reached the empty cell target, the remaining values are the
        // solved values, which are already in the working board. Therefore, we can
        // stop trying to zero out other cells
        if (emptyCellCount >= targetEmptyCellCount) {
          break;
        }
        // try zeroing out this index on the working board and checking if it still
        // has only one sol
        final solvedValue = externSudokuBoardGetAt(solvedBoard, index);
        // zero out
        externSudokuBoardSetAt(workingBoard, index, 0);
        // check if there still is only one sol
        final hasOnlyOneSolWhenZero =
            externSudokuHasOneSolBlocking(workingBoard);
        if (hasOnlyOneSolWhenZero) {
          emptyCellCount++;
        } else {
          // reset the value at index to be the solved value, in order for the
          // sudoku to have only one sol
          externSudokuBoardSetAt(workingBoard, index, solvedValue);
          // yield the event signaling that the value at index is the solved value
          yield SudokuGenerationFoundSquare(index, solvedValue);
        }
      }
      // We either could not zero out any more cells, or we reached the zeroed out
      // cell target.
      print("Gonna yield final event");
      yield SudokuGenerationFinished(
        sudokuBoardFromExtern(solvedBoard),
        sudokuBoardFromExtern(workingBoard),
      );
    }()
        .listen(
      onData,
      onError: onError,
      onDone: _onDone,
      cancelOnError: cancelOnError,
    );
  }
}
