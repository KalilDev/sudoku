import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'package:meta/meta.dart';

import 'bidimensional_list.dart';

Iterable<T> setDiff1d<T>(Iterable<T> a, Iterable<T> b) => a.where((e) => !b.contains(e));
Iterable<T> intersect1d<T>(Iterable<T> a, Iterable<T> b) => a.where((e) => b.contains(e));
Iterable<T> union1d<T>(Iterable<T> a, Iterable<T> b) => a.followedBy(b);

enum Validation {
  /// At least one element is invalid. The sudoku may or may not be filled.
  invalid,
  /// All the sudoku is filled, and every single element is valid.
  valid,
  /// The sudoku is valid for now, but it is incomplete.
  incomplete
}


class SudokuState {
  final int side;
  final BidimensionalList<int> initialState;
  BidimensionalList<int> state;
  BidimensionalList<List<int>> possibleValues;

  SudokuState.raw({
    @required
    this.side,
    @required
    this.initialState,
    @required
    this.state,
    @required
    this.possibleValues
  });

  factory SudokuState({int side, BidimensionalList<int>? initialState, BidimensionalList<List<int>>? possibleValues, BidimensionalList<int>? state}) {
    final sideSqrt = sqrt(side).round();
    assert(sideSqrt * sideSqrt == side);
    initialState ??= BidimensionalList.view(Uint8List(side*side), side);
    possibleValues ??= BidimensionalList.generate(side, (_, __) => <int>[]);
    state ??= initialState.toList();
    return SudokuState.raw(side: side, initialState: initialState, state: state, possibleValues: possibleValues);
  }
  
  SudokuState copy() => SudokuState(side: side, possibleValues: possibleValues.toList(), initialState: initialState, state: state.toList());
  
  int get sideSqrt => sqrt(side).round();
  List<List<int>> get rows => state.rows;
  List<List<int>> get columns => state.columns;
  BidimensionalList<BidimensionalList<int>> squares() => BidimensionalList.generate(sideSqrt, square);
  BidimensionalList<List<int>> flatSquares() => BidimensionalList.generate(sideSqrt, flatSquare);

  List<int> flatSquare(int x, int y) => SquareViewer(this.state, sideSqrt, x, y);
  BidimensionalList<int> square(int x, int y) => BidimensionalList.view(flatSquare(x, y), sideSqrt);

  void reset() {
    state = BidimensionalList<int>.filled(0, side);
    possibleValues = BidimensionalList<List<int>>.generate(side, (_, __) => <int>[]);
  }

  Validation validateBoard() {
    int returnValue = 1;
    bool validateSingle(List<int> list) {
      final result = isValid(list);
      if (result == 0) {
        return true; // result was that there was an invalid val.
      }
      if (returnValue < result) // will set to 2 if result is 2
        returnValue = result;
      return false;
    }
    final validations = [
      columns.any(validateSingle),
      rows.any(validateSingle),
      flatSquares().anyInner(validateSingle)
    ];
    if (validations.any((e) => e)) {
      // an result was zero, therefore even if the board is
      // incomplete, it is invalid.
      return Validation.invalid;
    }
    return Validation.values[returnValue];
  }
  BidimensionalList<bool> validateWithInfo() {
    final list = BidimensionalList<bool>.filled(side, true);
    final columns = this.columns;
    final rows = this.rows;
    final squares = flatSquares();
    // validate columns
    for (var x = 0; x < side; x++) {
      final column = columns[x];
      invalidIndices(column).forEach((invalid) =>list[invalid][x] = false);
    }
    // validate rows
    for (var y = 0; y < side; y++) {
      final row = rows[y];
      invalidIndices(row).forEach((invalid) =>list[y][invalid] = false);
    }
    // validate squares
    squares.forEachIndexed((square, x, y) {
      invalidIndices(square).forEach((invalid) {
        final i = invalid % sideSqrt;
        final j = (invalid / sideSqrt).floor();
        list[y*sideSqrt + j][x * sideSqrt + i] = false;
      });
    });
    return list;
  }

  List<int> row(int y) => state.getRow(y);
  List<int> column(int x) => state.getColumn(x);

  operator []=(int y, v) => state[y] = v;
  List<int> operator [](int y) => state[y];

  // Returns a list of the indices which failed the validation.
  // it contains at least 2 when it is not empty.
  // if none fail it will return an empty list.
  static Set<int> validate(List<int> toValidate) {
    final failed = <int>{};
    final walked = <int, int>{};
    for (var i = 0; i < toValidate.length; i++) {
      final value = toValidate[i];
      if (walked.containsKey(value)) {
        failed.add(i);
        failed.add(walked[value]); // add the first occurence also
        continue;
      }
      walked[value] = i;
    }
    return failed;
  }
  // Returns a list of the indices which failed the validation.
  // it contains at least 2 when it is not empty.
  // if none fail it will return an empty list.
  static Set<int> invalidIndices(List<int> toValidate) {
    final failed = <int>{};
    final walked = <int, int>{};
    for (var i = 0; i < toValidate.length; i++) {
      final value = toValidate[i];
      if (walked.containsKey(value)) {
        failed.add(i);
        failed.add(walked[value]); // add the first occurence also
        continue;
      }
      walked[value] = i;
    }
    return failed;
  }
  static int isValid(List<int> toValidate) {
    final walked = <int>[];
    for (var i = 0; i < toValidate.length; i++) {
      final value = toValidate[i];
      if (value == 0) {
        return 2;
      }
      if (walked.contains(value)) {
        return 0;
      }
      walked.add(value);
    }
    return 1;
  }
}

class SquareViewer extends ListBase<int> {
  final List<List<int>> state;
  final int sideSqrt;
  final int i;
  final int j;
  SquareViewer(this.state, this.sideSqrt, this.i, this.j);

  @override
  int get length => sideSqrt*sideSqrt;

  set length(int _) => throw Exception("You can't change the size of the sudoku board with an viewer");

  List<int> _getIndexOnState(int index) {
    if (index >= length)
      throw StateError("Index out of bounds");
    final x = index % sideSqrt + i*sideSqrt;
    final y = index ~/ sideSqrt + j*sideSqrt;
    return [y, x];
  }

  @override
  int operator [](int i) {
    final index = _getIndexOnState(i);
    return state[index[0]][index[1]];
  }
  
  @override
  void operator []=(int i, int value) {
    final index = _getIndexOnState(i);
    state[index[0]][index[1]] = value;
  }
}