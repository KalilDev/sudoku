// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flutter_intents.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

abstract class PressNumberIntent with IntentMixin, Diagnosticable {
  const PressNumberIntent._();
  const factory PressNumberIntent.pressNumberOnBoardIntent(
      SudokuBoardIndex index, int number) = PressNumberOnBoardIntent;
  const factory PressNumberIntent.pressNumberOnBoardAltIntent(
      SudokuBoardIndex index, int number) = PressNumberOnBoardAltIntent;
  const factory PressNumberIntent.pressFreeNumber(int number) = PressFreeNumber;

  R visit<R extends Object?>(
      {required R Function(SudokuBoardIndex index, int number)
          pressNumberOnBoardIntent,
      required R Function(SudokuBoardIndex index, int number)
          pressNumberOnBoardAltIntent,
      required R Function(int number) pressFreeNumber});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');
}

class PressNumberOnBoardIntent extends PressNumberIntent {
  final SudokuBoardIndex index;
  final int number;

  const PressNumberOnBoardIntent(this.index, this.number) : super._();

  @override
  int get hashCode => Object.hash((PressNumberOnBoardIntent), index, number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is PressNumberOnBoardIntent &&
          true &&
          this.index == other.index &&
          this.number == other.number);

  @override
  R visit<R extends Object?>(
          {required R Function(SudokuBoardIndex index, int number)
              pressNumberOnBoardIntent,
          required R Function(SudokuBoardIndex index, int number)
              pressNumberOnBoardAltIntent,
          required R Function(int number) pressFreeNumber}) =>
      pressNumberOnBoardIntent(this.index, this.number);
}

class PressNumberOnBoardAltIntent extends PressNumberIntent {
  final SudokuBoardIndex index;
  final int number;

  const PressNumberOnBoardAltIntent(this.index, this.number) : super._();

  @override
  int get hashCode => Object.hash((PressNumberOnBoardAltIntent), index, number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is PressNumberOnBoardAltIntent &&
          true &&
          this.index == other.index &&
          this.number == other.number);

  @override
  R visit<R extends Object?>(
          {required R Function(SudokuBoardIndex index, int number)
              pressNumberOnBoardIntent,
          required R Function(SudokuBoardIndex index, int number)
              pressNumberOnBoardAltIntent,
          required R Function(int number) pressFreeNumber}) =>
      pressNumberOnBoardAltIntent(this.index, this.number);
}

class PressFreeNumber extends PressNumberIntent {
  final int number;

  const PressFreeNumber(this.number) : super._();

  @override
  int get hashCode => Object.hash((PressFreeNumber), number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is PressFreeNumber && true && this.number == other.number);

  @override
  R visit<R extends Object?>(
          {required R Function(SudokuBoardIndex index, int number)
              pressNumberOnBoardIntent,
          required R Function(SudokuBoardIndex index, int number)
              pressNumberOnBoardAltIntent,
          required R Function(int number) pressFreeNumber}) =>
      pressFreeNumber(this.number);
}
