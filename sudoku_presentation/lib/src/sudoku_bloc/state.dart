import 'package:meta/meta.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:collection/collection.dart';

@immutable
abstract class SquareDelta {
  final int x;
  final int y;
  const SquareDelta(this.x, this.y);
}

class PossibleAdded extends SquareDelta {
  const PossibleAdded(int x, int y, this.number) : super(x, y);
  // The number that got added
  final int number;
}

class PossibleRemoved extends SquareDelta {
  const PossibleRemoved(int x, int y, this.number) : super(x, y);
  // The number that got removed
  final int number;
}

class NumChanged extends SquareDelta {
  const NumChanged(int x, int y, this.number) : super(x, y);
  // The number that was there before being replaced by the new one
  final int number;
}

class PossibleCleared extends SquareDelta {
  const PossibleCleared(int x, int y, this.possibleValues) : super(x, y);
  // The possible values that were cleared when the number was added
  final List<int> possibleValues;
}

@immutable
class SquareInfo {
  final int number; // non nullable (0 when unassigned)
  final List<int> possibleNumbers; // non-nullable (empty when none)
  final bool isInitial; // non nullable
  final bool isSelected; // non nullable
  final Validation validation; // non-nullable

  static const _listEquality = ListEquality<int>();

  const SquareInfo(
      {this.number,
      this.possibleNumbers,
      this.isInitial,
      this.isSelected,
      this.validation});
  static const SquareInfo empty = SquareInfo(
      isInitial: false,
      isSelected: false,
      validation: Validation.notValidated,
      possibleNumbers: <int>[],
      number: 0);

  bool hasSameContentAs(SquareInfo other) =>
      number == other.number &&
      _listEquality.equals(possibleNumbers, other.possibleNumbers) &&
      isInitial == other.isInitial &&
      isSelected == other.isSelected &&
      validation == other.validation;

  SquareInfo copyWith(
          {int number,
          List<int> possibleNumbers,
          bool isInitial,
          bool isSelected,
          Validation validation}) =>
      SquareInfo(
          number: number ?? this.number,
          possibleNumbers: possibleNumbers ?? this.possibleNumbers,
          isInitial: isInitial ?? this.isInitial,
          isSelected: isSelected ?? this.isSelected,
          validation: validation ?? this.validation);
}

@immutable
class NumberInfo {
  final int number; // non nullable
  final bool isSelected; // non nullable

  const NumberInfo({this.number, this.isSelected}); // non nullable
}

@immutable
abstract class SudokuBlocState {}

class SudokuBlocStateWithInfo extends SudokuBlocState {
  final BidimensionalList<SquareInfo> squares; // non nullable
  final List<NumberInfo> numbers; // non nullable
  int get side => squares.length;

  SudokuBlocStateWithInfo(this.squares, this.numbers);
}

@immutable
class SudokuLoadingState extends SudokuBlocStateWithInfo {
  SudokuLoadingState(BidimensionalList<SquareInfo> placeholderSquares,
      List<NumberInfo> numbers)
      : super(placeholderSquares, numbers);
}

class SudokuErrorState extends SudokuBlocState {
  final String message;
  final String userFriendlyMessage;

  SudokuErrorState({this.message, this.userFriendlyMessage});
}

@immutable
class SudokuSnapshot extends SudokuBlocStateWithInfo {
  final MarkType markType; // non nullable
  final bool canRewind; // non nullable

  final Validation validationState; // non nullable
  final bool wasDeleted; // non-nullable

  SudokuSnapshot(
      {@required BidimensionalList<SquareInfo> squares,
      @required List<NumberInfo> numbers,
      @required this.canRewind,
      @required this.markType,
      @required this.validationState,
      this.wasDeleted = false})
      : super(squares, numbers);

  SudokuSnapshot deleted() => SudokuSnapshot(
      squares: squares,
      numbers: numbers,
      canRewind: canRewind,
      markType: markType,
      validationState: validationState,
      wasDeleted: true);
}

enum MarkType { possible, concrete }
