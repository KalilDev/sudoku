import 'dart:async';
import 'package:sudoku_core/sudoku_core.dart';
import '../sudoku_configuration.dart';

const Map<SudokuDifficulty, double> difficultyMaskMap = {
  SudokuDifficulty.begginer: 0.7,
  SudokuDifficulty.easy: 0.55,
  SudokuDifficulty.medium: 0.45,
  SudokuDifficulty.hard: 0.32,
  SudokuDifficulty.extreme: 0.38,
  SudokuDifficulty.impossible: 0.24
};

typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);

// The signature of [compute].
typedef ComputeImpl = Future<R> Function<Q, R>(ComputeCallback<Q, R> callback, Q message, { String debugLabel });

class _IsolateSudokuParams {
  final int side;
  final double mask;

  _IsolateSudokuParams(this.side, this.mask);
}

SudokuState isolateCreateSudoku(_IsolateSudokuParams param) {
  if (param.side > 9) {
    throw Error();
  }
  return createRandomSudoku(maskRate: param.mask, side: param.side);
}
Future<R> asyncCompute<Q, R>(ComputeCallback<Q, R> callback, Q message, {String debugLabel}) async {
  await null;
  return callback(message);
}

Future<SudokuState> genRandomSudoku(int side, SudokuDifficulty difficulty, {ComputeImpl compute}) async {
  compute ??= asyncCompute;
  await null;
  final state = await compute<_IsolateSudokuParams, SudokuState>(isolateCreateSudoku, _IsolateSudokuParams(side, difficultyMaskMap[difficulty]));
  return state;
}