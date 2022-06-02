// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

abstract class SudokuTile implements SumType {
  const SudokuTile._();
  const factory SudokuTile.permanent(int number) = Permanent;
  const factory SudokuTile.number(int number, Validation validation) = Number;
  const factory SudokuTile.possibilities(List<int> possibilities) =
      Possibilities;

  @override
  SumRuntimeType get runtimeType =>
      SumRuntimeType([Permanent, Number, Possibilities]);

  R visit<R extends Object?>(
      {required R Function(int number) permanent,
      required R Function(int number, Validation validation) number,
      required R Function(List<int> possibilities) possibilities});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
}

class Permanent extends SudokuTile {
  final int number;

  const Permanent(this.number) : super._();

  @override
  int get hashCode => Object.hash((Permanent), number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is Permanent && true && this.number == other.number);

  @override
  String toString() => "Permanent { $number }";

  @override
  R visit<R extends Object?>(
          {required R Function(int number) permanent,
          required R Function(int number, Validation validation) number,
          required R Function(List<int> possibilities) possibilities}) =>
      permanent(this.number);
}

class Number extends SudokuTile {
  final int number;
  final Validation validation;

  const Number(this.number, this.validation) : super._();

  @override
  int get hashCode => Object.hash((Number), number, validation);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is Number &&
          true &&
          this.number == other.number &&
          this.validation == other.validation);

  @override
  String toString() => "Number { $number, $validation }";

  @override
  R visit<R extends Object?>(
          {required R Function(int number) permanent,
          required R Function(int number, Validation validation) number,
          required R Function(List<int> possibilities) possibilities}) =>
      number(this.number, this.validation);
}

class Possibilities extends SudokuTile {
  final List<int> possibilities;

  const Possibilities(this.possibilities) : super._();

  @override
  int get hashCode => Object.hash((Possibilities), possibilities);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is Possibilities &&
          true &&
          this.possibilities == other.possibilities);

  @override
  String toString() => "Possibilities { $possibilities }";

  @override
  R visit<R extends Object?>(
          {required R Function(int number) permanent,
          required R Function(int number, Validation validation) number,
          required R Function(List<int> possibilities) possibilities}) =>
      possibilities(this.possibilities);
}
