
import 'bidimensional_list.dart';

class SudokuVec {
  final int x;
  final int y;

  const SudokuVec(this.y, this.x);

  @override
  String toString() => '[$x, $y]';
}

SudokuVec /*?*/ findUnassignedLocation(BidimensionalList<int> grid) {
  final side = grid.length;
  for (var y = 0; y < side; y++) {
    for (var x = 0; x < side; x++) {
      if (grid.getValue(x, y) == 0) {
        final unassigned = SudokuVec(y, x);
        return unassigned;
      }
    }
  }

  return null;
}

bool isSafe(BidimensionalList<int> grid, int row /*y*/, int col /*x*/,
    int boxSize, int n) {
  final side = grid.length;
  // RowSafe
  for (int x = 0; x < side; x++) {
    if (grid.getValue(x, row) == n) {
      return false;
    }
  }
  // Col safe
  for (int y = 0; y < side; y++) {
    if (grid.getValue(col, y) == n) {
      return false;
    }
  }
  // BoxSafe
  final boxStartRow = row - row % boxSize;
  final boxStartCol = col - col % boxSize;
  for (int y = 0; y < boxSize; y++) {
    for (int x = 0; x < boxSize; x++) {
      if (grid.getValue(x + boxStartCol, y + boxStartRow) == n) {
        return false;
      }
    }
  }

  return true;
}
