import 'dart:math';

import 'package:app/module/base.dart';
import 'package:sudoku_core/src/sudoku_utils.dart' as old;
import 'package:sudoku_core/sudoku_core.dart' as old;

typedef ExternSudokuBoard = old.SudokuState;

ExternSudokuBoard externSudokuBoardFrom(SudokuBoard board) {
  final side = board.length;
  final result = emptyExternSudokuBoard(side);
  for (int y = 0; y < side; y++) {
    for (int x = 0; x < side; x++) {
      result.initialState[x][y] =
          sudokuBoardGetAt(board, SudokuBoardIndex(x, y));
    }
  }
  return result;
}

ExternSudokuBoard emptyExternSudokuBoard(int side) {
  return ExternSudokuBoard(side: side);
}

ExternSudokuBoard cloneExternSudokuBoard(ExternSudokuBoard other) {
  final result = emptyExternSudokuBoard(externSudokuSide(other));
  for (var y = 0; y < result.side; y++) {
    for (var x = 0; x < result.side; x++) {
      result.initialState.setValue(
          x, y, externSudokuBoardGetAt(other, SudokuBoardIndex(x, y)));
    }
  }
  return result;
}

int externSudokuBoardGetAt(ExternSudokuBoard board, SudokuBoardIndex index) =>
    board.initialState.getValue(index.x, index.y);
void externSudokuBoardSetAt(
        ExternSudokuBoard board, SudokuBoardIndex index, int value) =>
    board.initialState.setValue(index.x, index.y, value);
int externSudokuSide(ExternSudokuBoard board) => board.side;
SudokuBoard sudokuBoardFromExtern(ExternSudokuBoard extern) {
  final result = emptySudokuBoard(extern.side);
  for (var y = 0; y < extern.side; y++) {
    for (var x = 0; x < extern.side; x++) {
      sudokuBoardSetAt(
          result, SudokuBoardIndex(x, y), extern.initialState.getValue(x, y));
    }
  }
  return result;
}

ExternSudokuBoard generateExternSudokuBlocking(int side) {
  final rand = Random();
  final state = emptyExternSudokuBoard(side);
  final validValues = List<int>.generate(side, (i) => i + 1);
  // Create an seed and set it to the first row of the initialState
  final seed = validValues.toList(growable: false)..shuffle(rand);
  state.initialState[0] = seed;
  // Solve the sudoku for this unique seed
  return _solveSudokuBlocking(state);
}

ExternSudokuBoard _solveSudokuBlocking(ExternSudokuBoard board) {
  final result = emptyExternSudokuBoard(externSudokuSide(board));
  for (var y = 0; y < result.side; y++) {
    for (var x = 0; x < result.side; x++) {
      result.initialState.setValue(
          x, y, externSudokuBoardGetAt(board, SudokuBoardIndex(x, y)));
    }
  }
  result.solve();
  // Set the initial state to be the solved state because the other fns use
  // the initial state only
  for (var r = 0; r < board.side; r++) {
    result.initialState[r] = result.solution[r];
  }
  return result;
}

bool externSudokuHasOneSolBlocking(ExternSudokuBoard board) {
  final rand = Random();
  final validValues = List<int>.generate(board.side, (i) => i + 1);
  final guessNums = validValues.toList()..shuffle(rand);
  // If now more than 1 solution, replace the removed cell back.
  final hasManySol =
      _oldCountSoln(board.initialState, board.sideSqrt, guessNums) > 1;
  return !hasManySol;
}

void externSudokuFree(ExternSudokuBoard board) {
  // nothing
}

// Count the amount of solutions for an given sudoku
int _oldCountSoln(
  old.BidimensionalList<int> state,
  int sideSqrt,
  List<int> guessNums, {
  int initialSolnCount = 0,
}) {
  var solnCount = initialSolnCount;
  final unassignedLoc = old.findUnassignedLocation(state) as old.SudokuVec?;
  if (unassignedLoc == null) {
    return solnCount + 1;
  }

  for (var i = 0; i < guessNums.length && solnCount < 2; i++) {
    final safe = old.isSafe(
        state, unassignedLoc.y, unassignedLoc.x, sideSqrt, guessNums[i]);
    if (safe) {
      state.setValue(unassignedLoc.x, unassignedLoc.y, guessNums[i]);
      solnCount = _oldCountSoln(state, sideSqrt, guessNums,
          initialSolnCount: solnCount);
    }

    state.setValue(unassignedLoc.x, unassignedLoc.y, 0);
  }
  return solnCount;
}
