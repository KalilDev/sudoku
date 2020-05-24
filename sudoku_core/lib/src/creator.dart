import 'bidimensional_list.dart';
import 'dart:math';
import 'sudoku_state.dart';

SudokuState createRandomSudoku({int side = 9, double maskRate = 0.5}) {
  final rand = Random();

  final state = SudokuState(side: side);
  final validValues = List<int>.generate(side, (i) => i+1);
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
  List<int> gridPos = List<int>.generate(side*side, (i) => i)..shuffle(rand);
  for(var i=0;i<gridPos.length;i++)
  {
    final gridI = gridPos[i];
    int y = gridI~/side;
    int x = gridI%side;
    int temp = state.initialState[y][x];
    state.initialState[x][y] = 0;

    // If now more than 1 solution , replace the removed cell back.
    final check = countSoln(state.initialState, state.sideSqrt, guessNums);
    if(check != 1)
    {
      state.initialState[x][y] = temp;
    }
  }
  // Ok, now initial state contains the ABSOLUTE minimum amount of values
  // for it to have an unique solution.
  final count = state.initialState.whereInner((n) => n != 0).length;
  var toBeAdded = (side*side*maskRate).round() - count;
  if (toBeAdded < 0) {
    return state..reset();
  }
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
  return state..reset();
}

bool isSafe(BidimensionalList<int> grid, int row, int col, int boxSize, int n)
{
  final side = grid.length;
  // RowSafe
  for (int x = 0; x < side; x++)
  {
      if (grid.getValue(x, row) == n)
          return false;
  }
  // Col safe
  for (int y = 0; y < side; y++)
  {
      if (grid.getValue(col, y) == n)
          return false;
  }
  // BoxSafe
  final boxStartRow = row - row%boxSize;
  final boxStartCol = col - col%boxSize;
  for (int y = 0; y < boxSize; y++)
  {
      for (int x = 0; x < boxSize; x++)
      {
          if (grid.getValue(x+boxStartCol, y+boxStartRow) == n)
              return false;
      }
  }

  return true;
}

int countSoln(BidimensionalList<int> state, int sideSqrt, List<int> guessNums, {int solnCount = 0})
  {
    final unassignedLoc = findUnassignedLocation(state);
    if(unassignedLoc == null)
    {
      return solnCount + 1;
    }

    for(var i=0;i<guessNums.length && solnCount<2;i++)
    {
        final safe = isSafe(state, unassignedLoc.y, unassignedLoc.x, sideSqrt, guessNums[i]);
        if(safe)
        {
          state.setValue(unassignedLoc.x, unassignedLoc.y, guessNums[i]);
          solnCount = countSoln(state, sideSqrt, guessNums, solnCount: solnCount);
        }

        state.setValue(unassignedLoc.x, unassignedLoc.y, 0);
    }
    return solnCount;

  }

class SudokuVec {
  final int x;
  final int y;

  const SudokuVec(this.y, this.x);

  @override
  String toString() => '[$x, $y]';
}

SudokuVec/*?*/ findUnassignedLocation(BidimensionalList<int> grid)
{
  final side = grid.length;
    for (var y = 0; y < side; y++)
    {
        for (var x = 0; x < side; x++)
        {
            if (grid.getValue(x, y) == 0) {
                final unassigned = SudokuVec(y,x);
                return unassigned;
            }
        }
    }

    return null;
}

void main() {

  final sudoku = createRandomSudoku(side: 9);
  print("Solution:");
  print(sudoku.solution);
  print("InitialState:");
  print(sudoku.initialState);
  print("State:");
  print(sudoku.state);
}