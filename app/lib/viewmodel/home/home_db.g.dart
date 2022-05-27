// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_db.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

abstract class _SudokuHomeDbValues implements SumType {
  const _SudokuHomeDbValues._();
  const factory _SudokuHomeDbValues.sidesInfo(SudokuHomeSidesInfo info) =
      SidesInfo;
  const factory _SudokuHomeDbValues.activeInfo(
      SudokuDifficulty difficulty, int sideSqrt) = ActiveInfo;

  @override
  SumRuntimeType get runtimeType => SumRuntimeType([SidesInfo, ActiveInfo]);

  R visit<R extends Object?>(
      {required R Function(SidesInfo) sidesInfo,
      required R Function(ActiveInfo) activeInfo});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
}

class SidesInfo extends _SudokuHomeDbValues {
  final SudokuHomeSidesInfo info;

  const SidesInfo(this.info) : super._();

  @override
  int get hashCode => Object.hash((SidesInfo), info);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SidesInfo && true && this.info == other.info);

  @override
  String toString() => "SidesInfo { $info }";

  @override
  R visit<R extends Object?>(
          {required R Function(SidesInfo) sidesInfo,
          required R Function(ActiveInfo) activeInfo}) =>
      sidesInfo(this);
}

class ActiveInfo extends _SudokuHomeDbValues {
  final SudokuDifficulty difficulty;
  final int sideSqrt;

  const ActiveInfo(this.difficulty, this.sideSqrt) : super._();

  @override
  int get hashCode => Object.hash((ActiveInfo), difficulty, sideSqrt);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is ActiveInfo &&
          true &&
          this.difficulty == other.difficulty &&
          this.sideSqrt == other.sideSqrt);

  @override
  String toString() => "ActiveInfo { $difficulty, $sideSqrt }";

  @override
  R visit<R extends Object?>(
          {required R Function(SidesInfo) sidesInfo,
          required R Function(ActiveInfo) activeInfo}) =>
      activeInfo(this);
}

class SudokuHomeDb implements ProductType {
  final Box<_SudokuHomeDbValues> _unwrap;

  const SudokuHomeDb._(this._unwrap);

  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType([SudokuHomeDb]);

  @override
  int get hashCode => Object.hash((SudokuHomeDb), _unwrap);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuHomeDb && true && this._unwrap == other._unwrap);

  @override
  String toString() => "SudokuHomeDb { $_unwrap }";
}
