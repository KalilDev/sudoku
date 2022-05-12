import 'package:utils/utils.dart';

import '../../base/sudoku_data.dart';

enum SudokuDifficulty {
  begginer,
  easy,
  medium,
  extreme,
  impossible,
}

// todo: better metric for sudoku difficulty.
int filledSudokuCellCountFromDifficulty(SudokuDifficulty difficulty, int side) {
  int sideSquared = side * side;
  switch (difficulty) {
    case SudokuDifficulty.begginer:
      // Extrapolation from https://www.sudoku-solutions.com/
      return ((28 / 81) * sideSquared).toInt();
    case SudokuDifficulty.easy:
      return ((24 / 81) * sideSquared).toInt();
    case SudokuDifficulty.medium:
      return ((22 / 81) * sideSquared).toInt();
    case SudokuDifficulty.extreme:
      return ((20 / 81) * sideSquared).toInt();
    case SudokuDifficulty.impossible:
      // The least amount of filled cells for an sudoku with a single solution
      // is 17 for an sudoku with the side 9. Therefore, we extrapolate it to
      // the side
      return ((17 / 81) * sideSquared).toInt();
  }
}

// data SudokuGenerationEvent = SudokuGenerationFoundSolution SudokuBoard
//                            | SudokuGenerationFoundSquare SudokuBoardIndex Int
//                            | SudokuGenerationFinished SudokuBoard SudokuBoard
abstract class SudokuGenerationEvent {
  const SudokuGenerationEvent();
}

class SudokuGenerationFoundSolution extends SudokuGenerationEvent {
  final SudokuBoard solvedState;
  const SudokuGenerationFoundSolution(
    this.solvedState,
  );
}

class SudokuGenerationFoundSquare extends SudokuGenerationEvent {
  final SudokuBoardIndex index;
  final int number;
  const SudokuGenerationFoundSquare(this.index, this.number)
      : assert(number != 0);
}

class SudokuGenerationFinished extends SudokuGenerationEvent {
  final SudokuBoard solvedState;
  final SudokuBoard challengeState;
  const SudokuGenerationFinished(
    this.solvedState,
    this.challengeState,
  );
}

// the left one is the solved state and the right one is the challenge state
typedef SolvedAndChallengeBoard = Tuple<SudokuBoard, SudokuBoard>;
