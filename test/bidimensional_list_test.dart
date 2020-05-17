import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/bidimensional_list.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/core/solver.dart';
import 'package:sudoku/core/sudoku_state.dart';

final _listEquality = ListEquality();
final _iterEquality = IterableEquality();
final _deepEquality = DeepCollectionEquality();

Iterable<T> flatten<T>(Iterable<Iterable<T>> iter) {
  if (iter is List<Iterable<T>>) {
    var val = Iterable<T>.empty();
    iter.forEach((sublist) => val = val.followedBy(sublist));
    return val;
  }
  return iter.reduce((a, b) => a.followedBy(b));
}

void main() {
  test("Test 2d array creation and access", () {
    final arr = [
      [0, 1, 2, 3],
      [4, 5, 6, 7],
      [8, 9, 10, 11]
    ];
    final twoD = BidimensionalList.view2d(arr);
    expect(twoD[0][0], 0);
    expect(twoD[0][3], 3);
    expect(twoD[2][0], 8);
    expect(twoD[2][3], 11);
    expect(_iterEquality.equals(flatten(arr), twoD.flat()), true);
    expect(_listEquality.equals(twoD.flat(), twoD.flat(false)), true);
    expect(_deepEquality.equals(BidimensionalList.view(flatten(arr).toList(), 4, height: 3), twoD), true);
  });
  test("Test SudokuState basics", () {
    final board = BidimensionalList.view2d([
      [3, 1, 2, 4],
      [2, 4, 1, 3],
      [1, 3, 4, 2],
      [4, 2, 3, 1],
    ]);
    final squares = BidimensionalList.view2d([
      [[[3, 1],
      [2, 4]],
      [[2, 4],
      [1, 3]]],
      [[[1, 3],
      [4, 2]],
      [[4, 2],
      [3, 1]]],
    ]);
    final state = SudokuState.uint8list(side: 4, initialState: board);
    expect(state.validateBoard(), Validation.valid);
    expect(state.validateWithInfo().anyInner((e) => e == false), false);
    expect(_deepEquality.equals(state.squares(), squares), true);
  });
  test("Test invalid sudokuState", () {
    final board = BidimensionalList.view2d([
      [3, 1, 2, 4],
      [2, 4, 4, 3],
      [1, 3, 4, 2],
      [4, 2, 3, 0],
    ]);
    final state = SudokuState.uint8list(side: 4, initialState: board);
    expect(state.validateBoard(), Validation.invalid);
    final info = state.validateWithInfo();
    final invalidIndices = [[0,3],[1,1],[1,2],[2,2]];
    var invalidCounter = 0;
    var didReachZero = false;
    info.forEachIndexed((element, x, y) {
      final isInvalid = invalidIndices.any((i) => i[0] == y && i[1] == x);
      if (isInvalid) {
        invalidCounter++;
        expect(element, false);
      } else {
        if (x == y && y == 3) {
          expect(didReachZero, false); // in case i change this test to include more zeroes. idk, unneeded tbh
          didReachZero = true;
          expect(element, null);
        } else {
          expect(element, true);
        }
      }
    });
    expect(invalidCounter, invalidIndices.length);
    expect(didReachZero, true);

  });
  test("Test sudoku completion", () {
    final board = BidimensionalList.view2d([
      [3, 1, 2, 4],
      [2, 4, 1, 3],
      [1, 3, 4, 2],
      [4, 2, 3, 1],
    ]);
    final boardMissing = BidimensionalList.view2d([
      [0, 1, 2, 0],
      [2, 4, 0, 3],
      [1, 0, 4, 2],
      [0, 2, 3, 1],
    ]);
    expect(_deepEquality.equals(solve(SudokuState.uint8list(side: 4, initialState: boardMissing)), board),true);
  });
}