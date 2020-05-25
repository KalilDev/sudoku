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
  incorrect,
  /// All the sudoku is filled, and every single element is valid.
  correct,
  /// The sudoku is valid for now, but it is incomplete.
  missing,
  notValidated
}


class SudokuState {
  final int side;
  final BidimensionalList<int> initialState; // Isn't final JUST for random generation. DO NOT CHANGE IT
  BidimensionalList<int> state;
  BidimensionalList<List<int>> possibleValues;
  BidimensionalList<int> solution;

  factory SudokuState({int side, BidimensionalList<int> initialState, BidimensionalList<List<int>> possibleValues, BidimensionalList<int> state, BidimensionalList<int> solution}) {
    final sideSqrt = sqrt(side).round();
    assert(sideSqrt * sideSqrt == side);
    initialState ??= BidimensionalList.view(Uint8List(side*side), side);
    possibleValues ??= BidimensionalList.generate(side, (_, __) => <int>[]);
    state ??= initialState.toList();
    return SudokuState.raw(side: side, initialState: initialState, state: state, possibleValues: possibleValues, solution: solution);
  }

  SudokuState.raw({
    @required
    this.side,
    @required
    this.initialState,
    @required
    this.state,
    @required
    this.possibleValues,
    @required
    this.solution
  }) : sideSqrt = sqrt(side).round();
  
  SudokuState copy() => SudokuState(side: side, possibleValues: possibleValues.toList(), initialState: initialState, state: state.toList());
  
  final int sideSqrt;
  List<List<int>> get rows => state.rows;
  List<List<int>> get columns => state.columns;
  BidimensionalList<BidimensionalList<int>> squares() => BidimensionalList.generate(sideSqrt, square);
  BidimensionalList<List<int>> flatSquares() => BidimensionalList.generate(sideSqrt, flatSquare);

  List<int> flatSquare(int x, int y) => SquareViewer(this.state, sideSqrt, x, y);
  BidimensionalList<int> square(int x, int y) => BidimensionalList.view(flatSquare(x, y), sideSqrt);

  void reset() {
    state = initialState.toList();
    possibleValues = BidimensionalList<List<int>>.generate(side, (_, __) => <int>[]);
  }

  Validation validateBoard() {
    // We will use the old method that is lazy
    // TODO: use the solution?
    int returnValue = 1;
    bool validateSingle(List<int> list) {
      final result = isValid(list);
      if (result == 0) {
        return true; // result was that there was an invalid val.
      }
      if (returnValue < result) { // will set to 2 if result is 2
        returnValue = result;
      }
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
      return Validation.incorrect;
    }
    return Validation.values[returnValue];
  }

  // May take a while
  BidimensionalList<Validation> validateWithInfo() {
    if (solution == null) {
      // We will solve the board, and then do this again
      solve();
      return validateWithInfo();
    }
    final list = BidimensionalList<Validation>.generate(side, (x, y) {
      final current = state.getValue(x, y);
      if (current == 0) {
        return Validation.missing;
      }
      final correct = solution.getValue(x, y);
      return correct == current ? Validation.correct : Validation.incorrect;
    });
    return list;
  }

  List<int> row(int y) => state.getRow(y);
  List<int> column(int x) => state.getColumn(x);

  void operator []=(int y, List<int> v) => state[y] = v;
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

  void solve() {
    switch (validateBoard()) {
      case Validation.correct:
        // already solved
        solution = state.toList(growable: false);
        return;
        break;
      default:
    }

    final rand = Random();
    var tries = 0;
    final validValues = List<int>.generate(side, (i) => i+1);
    final guessNums = validValues..shuffle(rand);
    
    for (;;) {
      bool failed = false;
      // Start with an fresh state
      solution = initialState.toList(growable: false);
      guessNums.shuffle(rand);
      for (var x = 0; x < side && !failed; x++) {
        guessNums.shuffle(rand);
        for (var y = 0; y < side && !failed; y++) {
          if(solution.getValue(x, y) != 0) {
            // this value is solved already.
            continue;
          }
          failed = true;
          for (final guess in guessNums) {
            if (isSafe(solution, y, x, sideSqrt, guess)) {
              solution.setValue(x, y, guess);
              failed = false;
              break;
            }
          }
        }
      }
      tries++;
      if (failed) {
        continue;
      }
      break;
    }
    print(tries);
  }
}


bool isSafe(BidimensionalList<int> grid, int row/*y*/, int col/*x*/, int boxSize, int n)
{
  final side = grid.length;
  // RowSafe
  for (int x = 0; x < side; x++)
  {
      if (grid.getValue(x, row) == n) {
          return false;
      }
  }
  // Col safe
  for (int y = 0; y < side; y++)
  {
      if (grid.getValue(col, y) == n) {
          return false;
      }
  }
  // BoxSafe
  final boxStartRow = row - row%boxSize;
  final boxStartCol = col - col%boxSize;
  for (int y = 0; y < boxSize; y++)
  {
      for (int x = 0; x < boxSize; x++)
      {
          if (grid.getValue(x+boxStartCol, y+boxStartRow) == n) {
              return false;
          }
      }
  }

  return true;
}

class SquareViewer extends ListBase<int> {
  final List<List<int>> state;
  final int sideSqrt;
  final int i;
  final int j;
  SquareViewer(this.state, this.sideSqrt, this.i, this.j);

  @override
  int get length => sideSqrt*sideSqrt;

  @override
  set length(int _) => throw Exception("You can't change the size of the sudoku board with an viewer");

  List<int> _getIndexOnState(int index) {
    if (index >= length) {
      throw StateError("Index out of bounds");
    }
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