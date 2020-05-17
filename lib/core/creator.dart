import 'bidimensional_list.dart';
import 'dart:typed_data';
import 'dart:math';
import 'sudoku_state.dart';

BidimensionalList<int> createRandomSudoku({int side = 9, double maskRate = 0.5, int maxTry = 1000}) {
  final sectorSize = sqrt(side).toInt();
  final rand = Random();

  var tries = 0;
  final state = BidimensionalList<int>.view(Uint8List(side*side), side);
  final validValues = List<int>.generate(side, (i) => i+1);
  final seed = validValues.toList(growable: false)..shuffle(rand);
  state.rows[0] = seed;

  
  while (tries < maxTry) {
    bool failed = false;
    for (var y = 1; y < side && !failed; y++) {
      final row = state.row(y);
      for (var x = 0; x < side; x++) {
        final col = state.column(x).take(y);
        final rowColAvailable = setDiff1d(validValues, union1d(col, row.take(x)));
        if (rowColAvailable.isEmpty) {
          failed = true; // welp, this random solution did not work
          break;
        }
        final sectorI = [x ~/ sectorSize, y ~/ sectorSize];
        final sector = SquareViewer(state, sectorSize, sectorI[0], sectorI[1]); // Reuse code from SudokuState
        final sectorCount = x - (sectorI[0] * sectorSize) + (y - (sectorI[1]*sectorSize))*sectorSize;
        final sectorAvailable = setDiff1d(validValues, sector.take(sectorCount));
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
  if (tries == maxTry) {
    throw StateError("woops, couldn\'t create an sudoku");
  }
  // TODO: 
  //  To remove numbers, use this algorithm:
  //
  //  Pick a random number you haven't tried removing before
  //  Remove the number, run your solver with the added condition that it cannot use the removed number here
  //  If the solver finds a solution, you can't remove the number
  //  Repeat, until you have removed enough numbers (or you can't remove any more)

  for (var x = 0; x < side; x++)
    for (var y = 0; y < side; y++)
      if (rand.nextDouble() < maskRate)
        state[x][y] = 0;
  return state;
}
