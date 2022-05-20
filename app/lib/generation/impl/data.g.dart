// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

abstract class SudokuGenerationEvent implements SumType {
  const SudokuGenerationEvent._();
  const factory SudokuGenerationEvent.sudokuGenerationFoundSolution(
      SudokuBoard solvedState) = SudokuGenerationFoundSolution;
  const factory SudokuGenerationEvent.sudokuGenerationFoundSquare(
      SudokuBoardIndex index, int number) = SudokuGenerationFoundSquare;
  const factory SudokuGenerationEvent.sudokuGenerationFinished(
          SudokuBoard solvedState, SudokuBoard challengeState) =
      SudokuGenerationFinished;

  @override
  SumRuntimeType get runtimeType => SumRuntimeType([
        SudokuGenerationFoundSolution,
        SudokuGenerationFoundSquare,
        SudokuGenerationFinished
      ]);

  R visit<R extends Object?>(
      {required R Function(SudokuGenerationFoundSolution)
          sudokuGenerationFoundSolution,
      required R Function(SudokuGenerationFoundSquare)
          sudokuGenerationFoundSquare,
      required R Function(SudokuGenerationFinished) sudokuGenerationFinished});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
}

class SudokuGenerationFoundSolution extends SudokuGenerationEvent {
  final SudokuBoard solvedState;

  const SudokuGenerationFoundSolution(this.solvedState) : super._();

  @override
  int get hashCode => Object.hash((SudokuGenerationFoundSolution), solvedState);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuGenerationFoundSolution &&
          true &&
          this.solvedState == other.solvedState);

  @override
  String toString() => "SudokuGenerationFoundSolution { $solvedState }";

  @override
  R visit<R extends Object?>(
          {required R Function(SudokuGenerationFoundSolution)
              sudokuGenerationFoundSolution,
          required R Function(SudokuGenerationFoundSquare)
              sudokuGenerationFoundSquare,
          required R Function(SudokuGenerationFinished)
              sudokuGenerationFinished}) =>
      sudokuGenerationFoundSolution(this);
}

class SudokuGenerationFoundSquare extends SudokuGenerationEvent {
  final SudokuBoardIndex index;
  final int number;

  const SudokuGenerationFoundSquare(this.index, this.number) : super._();

  @override
  int get hashCode => Object.hash((SudokuGenerationFoundSquare), index, number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuGenerationFoundSquare &&
          true &&
          this.index == other.index &&
          this.number == other.number);

  @override
  String toString() => "SudokuGenerationFoundSquare { $index, $number }";

  @override
  R visit<R extends Object?>(
          {required R Function(SudokuGenerationFoundSolution)
              sudokuGenerationFoundSolution,
          required R Function(SudokuGenerationFoundSquare)
              sudokuGenerationFoundSquare,
          required R Function(SudokuGenerationFinished)
              sudokuGenerationFinished}) =>
      sudokuGenerationFoundSquare(this);
}

class SudokuGenerationFinished extends SudokuGenerationEvent {
  final SudokuBoard solvedState;
  final SudokuBoard challengeState;

  const SudokuGenerationFinished(this.solvedState, this.challengeState)
      : super._();

  @override
  int get hashCode =>
      Object.hash((SudokuGenerationFinished), solvedState, challengeState);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuGenerationFinished &&
          true &&
          this.solvedState == other.solvedState &&
          this.challengeState == other.challengeState);

  @override
  String toString() =>
      "SudokuGenerationFinished { $solvedState, $challengeState }";

  @override
  R visit<R extends Object?>(
          {required R Function(SudokuGenerationFoundSolution)
              sudokuGenerationFoundSolution,
          required R Function(SudokuGenerationFoundSquare)
              sudokuGenerationFoundSquare,
          required R Function(SudokuGenerationFinished)
              sudokuGenerationFinished}) =>
      sudokuGenerationFinished(this);
}
