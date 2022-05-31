import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
import 'package:app/module/base.dart';
import 'package:utils/utils.dart';

part 'data.g.dart';

enum SudokuDifficulty {
  begginer,
  easy,
  medium,
  hard,
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
    // Tween from medium to impossible
    case SudokuDifficulty.hard:
      return ((20 / 81) * sideSquared).toInt();
    // Tween from medium to impossible
    case SudokuDifficulty.extreme:
      return ((19 / 81) * sideSquared).toInt();
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
@data(
  #SudokuGenerationEvent,
  [],
  adt.Union(
    {
      #SudokuGenerationFoundSolution: {
        #solvedState: T(#SudokuBoard),
      },
      #SudokuGenerationFoundSquare: {
        #index: T(#SudokuBoardIndex),
        #number: T(#int),
      },
      #SudokuGenerationFinished: {
        #solvedState: T(#SudokuBoard),
        #challengeState: T(#SudokuBoard),
      },
    },
    deriveMode: adt.UnionVisitDeriveMode.data,
  ),
)
const Type _sudokuGenerationEvent = SudokuGenerationEvent;

// the left one is the solved state and the right one is the challenge state
typedef SolvedAndChallengeBoard = Tuple<SudokuBoard, SudokuBoard>;
