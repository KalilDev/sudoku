// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

abstract class SudokuHomeInfo implements SumType {
  const SudokuHomeInfo._();
  const factory SudokuHomeInfo.sideInfo(SudokuHomeSideInfo info) = SideInfo;
  const factory SudokuHomeInfo.otherInfo(
      SudokuDifficulty difficulty, int activeSideSqrt) = OtherInfo;

  @override
  SumRuntimeType get runtimeType => SumRuntimeType([SideInfo, OtherInfo]);

  R visit<R extends Object?>(
      {required R Function(SideInfo) sideInfo,
      required R Function(OtherInfo) otherInfo});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
}

class SideInfo extends SudokuHomeInfo {
  final SudokuHomeSideInfo info;

  const SideInfo(this.info) : super._();

  @override
  int get hashCode => Object.hash((SideInfo), info);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SideInfo && true && this.info == other.info);

  @override
  String toString() => "SideInfo { $info }";

  @override
  R visit<R extends Object?>(
          {required R Function(SideInfo) sideInfo,
          required R Function(OtherInfo) otherInfo}) =>
      sideInfo(this);
}

class OtherInfo extends SudokuHomeInfo {
  final SudokuDifficulty difficulty;
  final int activeSideSqrt;

  const OtherInfo(this.difficulty, this.activeSideSqrt) : super._();

  @override
  int get hashCode => Object.hash((OtherInfo), difficulty, activeSideSqrt);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is OtherInfo &&
          true &&
          this.difficulty == other.difficulty &&
          this.activeSideSqrt == other.activeSideSqrt);

  @override
  String toString() => "OtherInfo { $difficulty, $activeSideSqrt }";

  @override
  R visit<R extends Object?>(
          {required R Function(SideInfo) sideInfo,
          required R Function(OtherInfo) otherInfo}) =>
      otherInfo(this);
}
