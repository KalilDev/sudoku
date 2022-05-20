// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

abstract class NavigationInformation
    with SudokuAppBoardChangeUndoable
    implements SumType {
  const NavigationInformation._();
  const factory NavigationInformation.unfocused() = Unfocused;
  const factory NavigationInformation.focusedOnBoard(SudokuBoardIndex index) =
      FocusedOnBoard;
  const factory NavigationInformation.focusedOnKeypad(int number) =
      FocusedOnKeypad;

  @override
  SumRuntimeType get runtimeType =>
      SumRuntimeType([Unfocused, FocusedOnBoard, FocusedOnKeypad]);

  R visit<R extends Object?>(
      {required R Function() unfocused,
      required R Function(SudokuBoardIndex index) focusedOnBoard,
      required R Function(int number) focusedOnKeypad});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
}

class Unfocused extends NavigationInformation {
  const Unfocused() : super._();

  @override
  int get hashCode => (Unfocused).hashCode;
  @override
  bool operator ==(other) =>
      identical(this, other) || (other is Unfocused && true);

  @override
  String toString() => "Unfocused";

  @override
  R visit<R extends Object?>(
          {required R Function() unfocused,
          required R Function(SudokuBoardIndex index) focusedOnBoard,
          required R Function(int number) focusedOnKeypad}) =>
      unfocused();
}

class FocusedOnBoard extends NavigationInformation {
  final SudokuBoardIndex index;

  const FocusedOnBoard(this.index) : super._();

  @override
  int get hashCode => Object.hash((FocusedOnBoard), index);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is FocusedOnBoard && true && this.index == other.index);

  @override
  String toString() => "FocusedOnBoard { $index }";

  @override
  R visit<R extends Object?>(
          {required R Function() unfocused,
          required R Function(SudokuBoardIndex index) focusedOnBoard,
          required R Function(int number) focusedOnKeypad}) =>
      focusedOnBoard(this.index);
}

class FocusedOnKeypad extends NavigationInformation {
  final int number;

  const FocusedOnKeypad(this.number) : super._();

  @override
  int get hashCode => Object.hash((FocusedOnKeypad), number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is FocusedOnKeypad && true && this.number == other.number);

  @override
  String toString() => "FocusedOnKeypad { $number }";

  @override
  R visit<R extends Object?>(
          {required R Function() unfocused,
          required R Function(SudokuBoardIndex index) focusedOnBoard,
          required R Function(int number) focusedOnKeypad}) =>
      focusedOnKeypad(this.number);
}
