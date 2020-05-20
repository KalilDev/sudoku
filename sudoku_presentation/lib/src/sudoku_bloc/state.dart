import 'package:meta/meta.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:collection/collection.dart';
import 'bloc.dart';
import '../sudoku_configuration.dart';
import '../common.dart';

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
      SquareInfo(isInitial: false, isSelected: false);

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
