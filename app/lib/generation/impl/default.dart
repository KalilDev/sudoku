import 'data.dart';
import 'isolate_local.dart';

Stream<SudokuGenerationEvent> generateSudokuStreaming(
  int sideSqrt,
  SudokuDifficulty difficulty,
) =>
    generateSudokuStreamingIsolateLocal(sideSqrt, difficulty);

Future<SolvedAndChallengeBoard> generateSudoku(
  int sideSqrt,
  SudokuDifficulty difficulty,
) =>
    generateSudokuIsolateLocal(sideSqrt, difficulty);
