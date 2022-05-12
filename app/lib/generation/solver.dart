import 'dart:math';

import 'package:app/view/data.dart';
import 'package:utils/utils.dart';

import '../base/sudoku_data.dart';
import 'dart:typed_data';
/*
typedef IntMatrix = Matrix<int>;
IntMatrix emptyIntMatrix(int side) => List.generate(
      side,
      (_) => List.generate(
        side,
        (_) => 0,
        growable: false,
      ),
      growable: false,
    );

int indexFromCoords(int r, int c, int side) => c * side + r;
int indexFromIndex(SudokuBoardIndex index, int side) =>
    indexFromCoords(index.left, index.right, side);

SudokuBoardIndex indexFromI(int i, int side) =>
    SudokuBoardIndex(i % side, i ~/ side);

Iterable<Iterable<SudokuBoardIndex>> boardRows(int side) => Iterable.generate(
    side,
    (r) => Iterable.generate(
          side,
          (c) => SudokuBoardIndex(c, r),
        ));

Iterable<Iterable<SudokuBoardIndex>> boardColumns(int side) =>
    Iterable.generate(
        side,
        (c) => Iterable.generate(
              side,
              (r) => SudokuBoardIndex(c, r),
            ));
Iterable<Iterable<SudokuBoardIndex>> boardSquares(int side) sync* {
  final sideSqrt = sideSqrtFromSide(side);
  for (var si = 0; si < side; si++) {
    final sc = (si % sideSqrt) * sideSqrt;
    final sr = (si ~/ sideSqrt) * sideSqrt;
    yield Iterable.generate(side, (i) {
      final ic = i % sideSqrt;
      final ir = i ~/ sideSqrt;
      return SudokuBoardIndex(sc + ic, sr + ir);
    });
  }
}

Iterable<Tuple<T, T>> permutations<T>(Iterable<T> iterable) sync* {
  for (final l in iterable) {
    for (final r in iterable) {
      yield Tuple(l, r);
    }
  }
}

int sideSqrtFromSide(int side) {
  final result = sqrt(side).round();
  assert(result * result == side);
  return result;
}

IntMatrix triangularAdjacencyMatrixWithSide(int side) {
  final sideSquared = side * side;
  final adjacencyMatrix = emptyIntMatrix(sideSquared);
  for (final r in boardRows(side)) {
    for (final p in permutations(r)) {
      final iL = indexFromIndex(p.left, side);
      final iR = indexFromIndex(p.right, side);
      adjacencyMatrix[iL][iR] = 1;
      adjacencyMatrix[iR][iL] = 1;
    }
  }
  for (final r in boardColumns(side)) {
    for (final p in permutations(r)) {
      final iL = indexFromIndex(p.left, side);
      final iR = indexFromIndex(p.right, side);
      adjacencyMatrix[iL][iR] = 1;
      adjacencyMatrix[iR][iL] = 1;
    }
  }
  for (final r in boardSquares(side)) {
    for (final p in permutations(r)) {
      final iL = indexFromIndex(p.left, side);
      final iR = indexFromIndex(p.right, side);
      adjacencyMatrix[iL][iR] = 1;
      adjacencyMatrix[iR][iL] = 1;
    }
  }
  for (var i = 0; i < sideSquared; i++) {
    adjacencyMatrix[i][i] = 0;
  }
  return adjacencyMatrix;
}

final Map<int, IntMatrix> _triangularAdjacencyMatrixCache = {};

Maybe<SudokuBoard> solveSudokuBoard(SudokuBoard input) {
  final side = input.length;
  final sideSquared = side * side;
  // 1. Find all the symmetric edges in one representation of each edge
  final adjacencyMatrix = _triangularAdjacencyMatrixCache.putIfAbsent(
    side,
    () => triangularAdjacencyMatrixWithSide(input.length),
  );
  printMatrix(adjacencyMatrix);
  // 2. Give each vertex an color for initialization
  final result = emptySudokuBoard(side);
  for (var i = 0; i < side; i++) {
    for (var j = 0; j < side; j++) {
      result[i][j] = input[i][j];
    }
  }
  printMatrix(result);
  // 3. For graph coloring check each (V, E) edge, and if they are connected,
  // and the color of each vertex is the same. If same, iterate again with a new
  // color.
  SudokuBoard iterate(SudokuBoard result) {
    for (var i = 0; i < sideSquared; i++) {
      for (var j = 0; j < i; j++) {
        final hasEdge = adjacencyMatrix[i][j] == 1;
        if (!hasEdge) {
          continue;
        }
        final indexI = indexFromI(i, side);
        final vertexI = sudokuBoardGetAt(result, indexI);
        final indexJ = indexFromI(j, side);
        final vertexJ = sudokuBoardGetAt(result, indexJ);
        if (vertexI == vertexJ) {
          final newResult = emptySudokuBoard(side);
          for (var i = 0; i < side; i++) {
            for (var j = 0; j < side; j++) {
              newResult[i][j] = result[i][j];
            }
          }
          sudokuBoardSetAt(newResult, indexI, vertexI + 1);
          // todo: new state? is it needed or not ffs
          return iterate(result);
        }
      }
    }
    return result;
  }

  return Just(iterate(result));
}
*/