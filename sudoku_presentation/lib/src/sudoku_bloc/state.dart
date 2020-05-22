import 'package:meta/meta.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:collection/collection.dart';

@immutable
abstract class SquareDelta {
  final int x;
  final int y;
  SquareDelta(this.x, this.y);
}

class PossibleAdded extends SquareDelta {
  PossibleAdded(int x, int y, this.number) : super(x, y);
  // The number that got added
  final int number;
}
class PossibleRemoved extends SquareDelta {
  PossibleRemoved(int x, int y, this.number) : super(x, y);
  // The number that got removed
  final int number;
}
class NumChanged extends SquareDelta {
  NumChanged(int x, int y, this.number) : super(x, y);
  // The number that was there before being replaced by the new one
  final int number;
}
class PossibleCleared extends SquareDelta {
  PossibleCleared(int x, int y, this.possibleValues) : super(x, y);
  // The possible values that were cleared when the number was added
  final List<int> possibleValues;
}

@immutable
class SquareInfo {
  final int number; // non nullable (0 when unassigned)
  final List<int> possibleNumbers; // non-nullable (empty when none)
  final bool isInitial; // non nullable
  final bool isSelected; // non nullable
  final bool isValid; // non-nullable (true when unassigned)
  
  static final _listEquality = ListEquality<int>();

  SquareInfo(
      {this.number,
      this.possibleNumbers,
      this.isInitial,
      this.isSelected,
      this.isValid});
  static final SquareInfo empty =
      SquareInfo(isInitial: false, isSelected: false, isValid: true, possibleNumbers: <int>[], number: 0);

  bool hasSameContentAs(SquareInfo other) =>
      number == other.number &&
      _listEquality.equals(possibleNumbers, other.possibleNumbers) &&
      isInitial == other.isInitial &&
      isSelected == other.isSelected &&
      isValid == other.isValid;
}

@immutable
class NumberInfo {
  final int number; // non nullable
  final bool isSelected; // non nullable

  NumberInfo({this.number, this.isSelected}); // non nullable
}

@immutable
abstract class SudokuBlocState {}

class SudokuLoadingState extends SudokuBlocState {}

@immutable
class SudokuSnapshot extends SudokuBlocState {
  final BidimensionalList<SquareInfo> squares; // non nullable
  final List<NumberInfo> numbers; // non nullable
  int get side => squares.length;

  final MarkType markType; // non nullable
  final bool canRewind; // non nullable

  final Validation validationState; // non nullable
  final bool wasDeleted; // non-nullable

  SudokuSnapshot(
      {
        @required this.squares,
      @required this.numbers,
      @required this.canRewind,
      @required this.markType,
      @required this.validationState,
      bool wasDeleted = false}) : wasDeleted = wasDeleted;

  SudokuSnapshot deleted() => SudokuSnapshot(squares: squares, numbers: numbers, canRewind: canRewind, markType: markType, validationState: validationState, wasDeleted: true);

}

enum MarkType { possible, concrete }
