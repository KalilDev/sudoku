import 'dart:async';
import 'dart:math';

import 'bidimensional_list.dart';
import 'sudoku_state.dart';
import 'sudoku_utils.dart';

typedef NextFrameProvider = Future<void> Function();

class TimedStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration frameQuota;
  final NextFrameProvider frameProvider;
  final Stopwatch timer = Stopwatch();
  StreamSubscription<T> subs;
  StreamController<T> controller = StreamController<T>();
  bool pausedOrStopped = false;

  static Future<void> defaultFrameProvider() => Future<void>.delayed(const Duration(milliseconds: 14));
  static const Duration defaultFrameQuota = Duration(milliseconds: 5);

  TimedStreamTransformer({this.frameQuota = defaultFrameQuota, this.frameProvider = defaultFrameProvider});

  Future<void> maybeResumeLater() => frameProvider().then((_) => maybeResume());

  void onDone() {
    controller.close();
    pausedOrStopped = true;
  }

  void onData(T data) {
    controller.add(data);
    if (timer.elapsed >= frameQuota) {
      subs.pause();
      maybeResumeLater();
      timer.stop();
    }
  }

  void maybeResume() {
    if (!pausedOrStopped) {
      timer..reset()..start();
      subs.resume();
    }
  }

  @override
  Stream<T> bind(Stream<T> stream) {
    // check this
    timer.start();
    subs = stream.listen(onData, onError: controller.addError, onDone: onDone);
    controller.onCancel = onDone;
    controller.onPause = () {subs.pause(); pausedOrStopped = true; timer.stop();};
    controller.onResume = () {pausedOrStopped = false;maybeResume();};
    return controller.stream;
  }
}

class ChunkedSudoku {
  final StreamController<ChunkedSudokuSquare> _squaresController;
  final Future<SudokuState> onComplete;
  final StreamSubscription<ChunkedSudokuPiece> _subscription;

  Stream<ChunkedSudokuSquare> get squares => _squaresController.stream;

  Future<void> cancel() async {
    await _squaresController.close();
    await _subscription.cancel();
  }

  const ChunkedSudoku._(
      this._squaresController, this.onComplete, this._subscription);
}

abstract class ChunkedSudokuPiece {
  const ChunkedSudokuPiece();
}

class ChunkedSudokuResult extends ChunkedSudokuPiece {
  final SudokuState state;
  const ChunkedSudokuResult(this.state);
}

class ChunkedSudokuSquare extends ChunkedSudokuPiece {
  final int x;
  final int y;
  final int n;
  const ChunkedSudokuSquare(this.x, this.y, this.n);
}

ChunkedSudoku chunkedCreateRandomSudoku({int side = 9, double maskRate = 0.5, NextFrameProvider frameProvider = TimedStreamTransformer.defaultFrameProvider}) {
  final completer = Completer<SudokuState>();
  // ignore: close_sinks
  final squaresController = StreamController<ChunkedSudokuSquare>();
  var chunkedStream = rawCreateRandomSudoku(side: side, maskRate: maskRate);
  if (frameProvider != null) {
    chunkedStream = chunkedStream.transform(TimedStreamTransformer<ChunkedSudokuPiece>(frameProvider: frameProvider));
  }
  // ignore: cancel_subscriptions
  final subscription =
      chunkedStream.listen((piece) {
    if (piece is ChunkedSudokuSquare) {
      squaresController.add(piece);
    }
    if (piece is ChunkedSudokuResult) {
      completer.complete(piece.state);
    }
  });
  return ChunkedSudoku._(squaresController, completer.future, subscription);
}

Future<SudokuState> asyncCreateRandomSudoku({int side = 9, double maskRate = 0.5, NextFrameProvider frameProvider = TimedStreamTransformer.defaultFrameProvider}) {
  final completer = Completer<SudokuState>();
  var chunkedStream = rawCreateRandomSudoku(side: side, maskRate: maskRate);
  if (frameProvider != null) {
    chunkedStream = chunkedStream.transform(TimedStreamTransformer<ChunkedSudokuPiece>(frameProvider: frameProvider));
  }
  chunkedStream.last.then(
      (value) => completer.complete((value as ChunkedSudokuResult).state));
  return completer.future;
}

Stream<ChunkedSudokuPiece> rawCreateRandomSudoku(
    {int side = 9, double maskRate = 0.5}) async* {
  final rand = Random();

  final state = SudokuState(side: side);
  final validValues = List<int>.generate(side, (i) => i + 1);
  final guessNums = validValues.toList()..shuffle(rand);
  // Create an seed and set it to the first row of the initialState
  final seed = validValues.toList(growable: false)..shuffle(rand);
  state.initialState[0] = seed;
  // Solve the sudoku for this unique seed
  state.solve();
  // The initialState now is now the solution to the sudoku,
  // but this is no fun, so we will remove all the numbers that we can
  state.initialState.setAll(0, state.solution);
  // Indices which we will try to remove
  final gridPos = List<int>.generate(side * side, (i) => i)..shuffle(rand);
  for (final pos in gridPos) {
    final y = pos ~/ side;
    final x = pos % side;
    final temp = state.initialState.getValue(x, y);
    state.initialState.setValue(x, y, 0);

    // If now more than 1 solution , replace the removed cell back.
    final check = countSoln(state.initialState, state.sideSqrt, guessNums);
    if (check != 1) {
      state.initialState.setValue(x, y, temp);
      yield ChunkedSudokuSquare(x, y, temp);
    } else {
      yield ChunkedSudokuSquare(x, y, 0);
    }
  }
  // Ok, now initial state contains the ABSOLUTE minimum amount of values
  // for it to have an unique solution.
  final count = state.initialState.whereInner((n) => n != 0).length;
  var toBeAdded = (side * side * maskRate).round() - count;
  if (toBeAdded < 0) {
    yield ChunkedSudokuResult(state..reset());
  } else {
    while (toBeAdded > 0) {
      final x = rand.nextInt(side);
      final y = rand.nextInt(side);
      final onGrid = state.initialState[y][x];
      if (onGrid != 0) {
        continue;
      }
      state.initialState[y][x] = state.solution[y][x];
      toBeAdded--;
    }
    // Finally, we have an Sudoku with an single solution on the [solution]
    // field, an initial state with side*side*maskRate elements and an state
    // equal to the initialState
    yield ChunkedSudokuResult(state..reset());
  }
}

int countSoln(BidimensionalList<int> state, int sideSqrt, List<int> guessNums,
    {int initialSolnCount = 0}) {
  var solnCount = initialSolnCount;
  final unassignedLoc = findUnassignedLocation(state);
  if (unassignedLoc == null) {
    return solnCount + 1;
  }

  for (var i = 0; i < guessNums.length && solnCount < 2; i++) {
    final safe =
        isSafe(state, unassignedLoc.y, unassignedLoc.x, sideSqrt, guessNums[i]);
    if (safe) {
      state.setValue(unassignedLoc.x, unassignedLoc.y, guessNums[i]);
      solnCount =
          countSoln(state, sideSqrt, guessNums, initialSolnCount: solnCount);
    }

    state.setValue(unassignedLoc.x, unassignedLoc.y, 0);
  }
  return solnCount;
}

/*Future<void> main() async {
  final sudoku = await createRandomSudoku(side: 9);
  print("Solution:");
  print(sudoku.solution);
  print("InitialState:");
  print(sudoku.initialState);
  print("State:");
  print(sudoku.state);
}*/
