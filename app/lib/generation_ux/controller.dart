import 'dart:math';

import 'package:app/base/sudoku_data.dart';
import 'package:app/generation/generation.dart';
import 'package:app/generation/impl/default.dart';
import 'package:flutter/foundation.dart';
import 'package:value_notifier/value_notifier.dart';

class GenerationController extends ControllerBase<GenerationController> {
  final int sideSqrt;
  final SudokuDifficulty difficulty;

  late final ValueListenable<SudokuGenerationEvent?> _generationEvents;
  GenerationController.generate(
    this.sideSqrt,
    this.difficulty,
  ) {
    _generationEvents = generateSudokuStreaming(sideSqrt, difficulty)
        .toValueListenable(eager: true)
        .map((snap) => snap.hasData ? snap.data : null);
    _currentChallengeBoard = generationEvents.fold(
      null,
      (e, currentBoard) {
        if (e is! SudokuGenerationFoundSquare) {
          return currentBoard;
        }
        final nextBoard = currentBoard == null
            ? emptySudokuBoard(sideSqrt * sideSqrt)
            : cloneSudokuBoard(currentBoard);
        sudokuBoardSetAt(nextBoard, e.index, e.number);
        return nextBoard;
      },
    );
  }

  GenerationController.generated(
    this.difficulty,
    SolvedAndChallengeBoard result,
  ) : sideSqrt = sqrt(result.left.length).toInt() {
    _generationEvents =
        SudokuGenerationFinished(result.left, result.right).asValueListenable;
    _currentChallengeBoard = result.right.asValueListenable;
  }

  int get side => sideSqrt * sideSqrt;

  int get targetFilledTiles =>
      filledSudokuCellCountFromDifficulty(difficulty, side);

  late final ValueListenable<SolvedAndChallengeBoard?> _generatedBoard =
      generationEvents.map(
    (e) => e is SudokuGenerationFinished
        ? SolvedAndChallengeBoard(e.solvedState, e.challengeState)
        : null,
  );

  late final ValueListenable<SudokuBoard?> _currentChallengeBoard;

  ValueListenable<double?> get generationProgress =>
      _currentChallengeBoard.view().bind<double?>(
            (currentBoard) => currentBoard != null
                ? 1.0.asValueListenable.cast()
                : _filledTiles.map((filledTiles) => filledTiles == null
                    ? null
                    : filledTiles / targetFilledTiles),
          );
  ValueListenable<SudokuGenerationEvent?> get generationEvents =>
      _generationEvents.view();
  ValueListenable<SolvedAndChallengeBoard?> get generatedBoard =>
      _generatedBoard.view();
  ValueListenable<int?> get _filledTiles => generationEvents.fold(
        null,
        (e, filled) =>
            filled ??
            0 + ((e is SudokuGenerationFoundSquare && e.number != 0) ? 1 : 0),
      );
}
