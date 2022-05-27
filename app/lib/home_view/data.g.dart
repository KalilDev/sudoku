// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

class SudokuHomeItem implements ProductType, TupleN2<int, SudokuHomeItemInfo> {
  final int e0;
  final SudokuHomeItemInfo e1;

  const SudokuHomeItem(this.e0, this.e1) : super();

  factory SudokuHomeItem.fromTupleN(TupleN2<int, SudokuHomeItemInfo> tpl) =>
      SudokuHomeItem(tpl.e0, tpl.e1);

  @override
  ProductRuntimeType get runtimeType =>
      ProductRuntimeType([int, SudokuHomeItemInfo]);

  @override
  int get hashCode => Object.hash((SudokuHomeItem), e0, e1);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuHomeItem &&
          true &&
          this.e0 == other.e0 &&
          this.e1 == other.e1);

  @override
  String toString() => "SudokuHomeItem ($e0, $e1)";
}

class SudokuHomeViewData
    implements ProductType, TupleN2<SidesInfo, ActiveInfo> {
  final SidesInfo e0;
  final ActiveInfo e1;

  const SudokuHomeViewData(this.e0, this.e1) : super();

  factory SudokuHomeViewData.fromTupleN(TupleN2<SidesInfo, ActiveInfo> tpl) =>
      SudokuHomeViewData(tpl.e0, tpl.e1);

  @override
  ProductRuntimeType get runtimeType =>
      ProductRuntimeType([SidesInfo, ActiveInfo]);

  @override
  int get hashCode => Object.hash((SudokuHomeViewData), e0, e1);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuHomeViewData &&
          true &&
          this.e0 == other.e0 &&
          this.e1 == other.e1);

  @override
  String toString() => "SudokuHomeViewData ($e0, $e1)";
}
