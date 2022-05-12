import 'package:collection/collection.dart';
import 'package:utils/utils.dart';

import '../base/sudoku_data.dart';

typedef TileMatrix = Matrix<SudokuTile>;
TileMatrix emptyTileMatrix(int side) => List.generate(
      side,
      (_) => List.filled(
        side,
        const Possibilities([]),
        growable: false,
      ),
      growable: false,
    );

printMatrix(Matrix<Object> m) => m.map((l) => l.toString()).join('\n');

TileMatrix tileMatrixFromState(SudokuAppBoardState state) {
  final side = state.side;
  final m = emptyTileMatrix(side);
  for (int j = 0; j < side; j++) {
    for (int i = 0; i < side; i++) {
      final index = SudokuBoardIndex(i, j);
      {
        final permanent = sudokuBoardGetAt(state.fixedNumbers, index);
        if (permanent != 0) {
          matrixSetAt<SudokuTile>(m, index, Permanent(permanent));
          continue;
        }
      }
      {
        final current = sudokuBoardGetAt(state.currentNumbers, index);
        if (current != 0) {
          matrixSetAt<SudokuTile>(
              m, index, Number(current, Validation.unknown));
          continue;
        }
      }
      final ps = matrixGetAt(state.currentPossibilities, index);
      matrixSetAt<SudokuTile>(m, index, Possibilities(ps));
    }
    // lock the current row
    m[j] = UnmodifiableListView(m[j]);
  }
  // lock the matrix
  return UnmodifiableListView(m);
}

typedef IndexedTile = Tuple<SudokuBoardIndex, SudokuTile>;

enum SudokuPlacementMode {
  possibility,
  number,
}

SudokuPlacementMode invertPlacementMode(SudokuPlacementMode mode) {
  switch (mode) {
    case SudokuPlacementMode.possibility:
      return SudokuPlacementMode.number;
    case SudokuPlacementMode.number:
      return SudokuPlacementMode.possibility;
  }
}

enum Validation {
  unknown,
  valid,
  invalid,
}

// TODO: loading????????
// ig an SudokuTile + an inherited widget would be the best option, no
// additional complexity on the data

// data SudokuTile = Permanent Int
//                 | Number Int Validation
//                 | Possibilities List<Int>
abstract class SudokuTile implements SumType {
  const SudokuTile._();

  R visit<R>({
    required R Function(int) permanent,
    required R Function(int, Validation) number,
    required R Function(List<int>) possibilities,
  });

  SumRuntimeType get runtimeType =>
      const SumRuntimeType([Permanent, Number, Possibilities]);

  int get hashCode =>
      throw UnimplementedError('Every case has an hashCode override');
  bool operator ==(other) =>
      throw UnimplementedError('Every case has an equality override');
  String toString() =>
      throw UnimplementedError('Every case has an toString override');
}

class Permanent extends SudokuTile {
  final int number;

  const Permanent(this.number)
      : assert(number != 0),
        super._();

  R visit<R>({
    required R Function(int) permanent,
    required R Function(int, Validation) number,
    required R Function(List<int>) possibilities,
  }) =>
      permanent(this.number);

  int get hashCode => number.hashCode;
  bool operator ==(other) => other is Permanent && other.number == number;

  @override
  String toString() => "Permanent $number";
}

class Number extends SudokuTile {
  final int number;
  final Validation validation;

  const Number(this.number, this.validation) : super._();

  R visit<R>({
    required R Function(int) permanent,
    required R Function(int, Validation) number,
    required R Function(List<int>) possibilities,
  }) =>
      number(this.number, validation);

  int get hashCode => Object.hash(number, validation);
  bool operator ==(other) =>
      other is Number &&
      other.number == number &&
      other.validation == validation;

  @override
  String toString() => "Number $number $validation";
}

class Possibilities extends SudokuTile {
  final List<int> possibilities;

  const Possibilities(this.possibilities) : super._();

  R visit<R>({
    required R Function(int) permanent,
    required R Function(int, Validation) number,
    required R Function(List<int>) possibilities,
  }) =>
      possibilities(this.possibilities);

  static const _possibilitiesEq = ListEquality<int>();
  int get hashCode => _possibilitiesEq.hash(possibilities);
  bool operator ==(other) =>
      other is Possibilities &&
      _possibilitiesEq.equals(other.possibilities, possibilities);

  @override
  String toString() => "Possibilities $possibilities";
}
