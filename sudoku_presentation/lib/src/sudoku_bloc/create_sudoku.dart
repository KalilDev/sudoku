import 'dart:async';
import 'package:sudoku_core/sudoku_core.dart';
import '../sudoku_configuration.dart';

const Map<SudokuDifficulty, double> difficultyMaskMap = {
  SudokuDifficulty.begginer: 1 - 0.7,
  SudokuDifficulty.easy: 1 - 0.55,
  SudokuDifficulty.medium: 1 - 0.45,
  SudokuDifficulty.hard: 1 - 0.32,
  SudokuDifficulty.extreme: 1 - 0.38,
  SudokuDifficulty.impossible: 1 - 0.24
};

typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);

// The signature of [compute].
typedef ComputeImpl = Future<R> Function<Q, R>(ComputeCallback<Q, R> callback, Q message, { String debugLabel });

class _IsolateSudokuParams {
  final int side;
  final double mask;
  final int errorCount;
  _IsolateSudokuParams incError() => _IsolateSudokuParams._(side, mask, errorCount + 1);

  _IsolateSudokuParams(this.side, this.mask) : errorCount = 0;
  _IsolateSudokuParams._(this.side, this.mask, this.errorCount);
}

List<int> isolateCreateSudoku(_IsolateSudokuParams param) {
  try {
    if (param.side == 9) {
      return quickAndDartyGen(mask_rate: param.mask).flat(false);
    }
    return createRandomSudoku(maskRate: param.mask, side: param.side, maxTry: 1000*10).flat(false);
  } catch (e) {
    return isolateCreateSudoku(param.incError());
  }
}
Future<R> asyncCompute<Q, R>(ComputeCallback<Q, R> callback, Q message, {String debugLabel}) async {
  await null;
  return callback(message);
}

Future<SudokuState> genRandomSudoku(int side, SudokuDifficulty difficulty, {int tryCount = 0, ComputeImpl compute}) async {
  compute ??= asyncCompute;
  await null;
  if (tryCount >= 1)
    throw StateError("Couldnt create board");
  final initialVals = await compute<_IsolateSudokuParams, List<int>>(isolateCreateSudoku, _IsolateSudokuParams(side, difficultyMaskMap[difficulty]));
  final initialState = BidimensionalList<int>.view(initialVals, side);
  final state = SudokuState(side: side, initialState: initialState);
  return state;
}