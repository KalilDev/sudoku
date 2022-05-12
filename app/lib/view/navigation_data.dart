import 'package:utils/utils.dart';

import '../base/sudoku_data.dart';

// data NavigationInformation = Unfocused
//                            | FocusedOnKeypad Int
//                            | FocusedOnBoard Index
abstract class NavigationInformation implements SumType {
  const NavigationInformation._();

  R visit<R>({
    required R Function() unfocused,
    required R Function(int) focusedOnKeypad,
    required R Function(SudokuBoardIndex) focusedOnBoard,
  });

  SumRuntimeType get runtimeType =>
      const SumRuntimeType([Unfocused, FocusedOnKeypad, FocusedOnBoard]);

  int get hashCode =>
      throw UnimplementedError('Every case has an hashCode override');
  bool operator ==(other) =>
      throw UnimplementedError('Every case has an equality override');
  String toString() =>
      throw UnimplementedError('Every case has an toString override');
}

class Unfocused extends NavigationInformation {
  const Unfocused() : super._();

  R visit<R>({
    required R Function() unfocused,
    required R Function(int) focusedOnKeypad,
    required R Function(SudokuBoardIndex) focusedOnBoard,
  }) =>
      unfocused();

  int get hashCode => identityHashCode(Unfocused);
  bool operator ==(other) => other is Unfocused;

  @override
  String toString() => "Unfocused";
}

class FocusedOnKeypad extends NavigationInformation {
  final int number;

  const FocusedOnKeypad(this.number) : super._();

  R visit<R>({
    required R Function() unfocused,
    required R Function(int) focusedOnKeypad,
    required R Function(SudokuBoardIndex) focusedOnBoard,
  }) =>
      focusedOnKeypad(number);

  int get hashCode => number.hashCode;
  bool operator ==(other) => other is FocusedOnKeypad && other.number == number;

  @override
  String toString() => "FocusedOnKeypad $number";
}

class FocusedOnBoard extends NavigationInformation {
  final SudokuBoardIndex index;

  const FocusedOnBoard(this.index) : super._();

  R visit<R>({
    required R Function() unfocused,
    required R Function(int) focusedOnKeypad,
    required R Function(SudokuBoardIndex) focusedOnBoard,
  }) =>
      focusedOnBoard(index);

  int get hashCode => index.hashCode;
  bool operator ==(other) => other is FocusedOnBoard && other.index == index;

  @override
  String toString() => "FocusedOnBoard $index";
}
