import 'sudoku_state.dart';
import 'bidimensional_list.dart';
import 'dart:typed_data';
import 'dart:math';
BidimensionalList<int> solve(SudokuState toBeSolved, {bool inPlace = true, int maxTry = 1000}) {
  switch (toBeSolved.validateBoard()) {
    case Validation.invalid: throw StateError("We can't solve an broken sudoku. unfuck it first please."); break;
    case Validation.valid: return toBeSolved.state; break; // already solved
    default: break;
  }

  final sectorSize = toBeSolved.sideSqrt;
  final side = toBeSolved.side;
  final rand = Random();
  var tries = 0;
  final validValues = List<int>.generate(toBeSolved.side, (i) => i+1);

  BidimensionalList<int> state;
  
  while (tries < maxTry) {
    bool failed = false;
    state = BidimensionalList<int>.view(Uint8List.fromList(toBeSolved.state.flat(false)), side);
    for (var x = 0; x < side && !failed; x++) {
      final col = state.column(x);
      for (var y = 0; y < side; y++) {
        if(col[y] != 0 && col[y] != null) {
          // this value is solved already.
          continue;
        }
        final row = state.row(y);
        final rowColAvailable = setDiff1d(validValues, union1d(col, row));
        if (rowColAvailable.isEmpty) {
          failed = true; // welp, this random solution did not work
          break;
        }
        final sectorI = [x ~/ sectorSize, y ~/ sectorSize];
        final sector = SquareViewer(state, sectorSize, sectorI[0], sectorI[1]);
        final sectorAvailable = setDiff1d(validValues, sector);
        final available = intersect1d(rowColAvailable, sectorAvailable).toList(growable: false);
        if (available.isEmpty) {
          failed = true; // welp, this random solution did not work
          break;
        }
        state[y][x] = available[rand.nextInt(available.length)];
      }
    }
    tries++;
    if (failed) {
      continue;
    }
    break;
  }
  return state;
}