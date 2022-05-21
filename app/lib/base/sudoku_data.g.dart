// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

class MatrixIndex
    with _MatrixIndexUtils
    implements ProductType, TupleN2<int, int> {
  final int e0;
  final int e1;

  const MatrixIndex(this.e0, this.e1) : super();

  factory MatrixIndex.fromTupleN(TupleN2<int, int> tpl) =>
      MatrixIndex(tpl.e0, tpl.e1);

  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType([int, int]);

  @override
  int get hashCode => Object.hash((MatrixIndex), e0, e1);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is MatrixIndex &&
          true &&
          this.e0 == other.e0 &&
          this.e1 == other.e1);

  @override
  String toString() => "MatrixIndex ($e0, $e1)";
}

abstract class TileState implements SumType {
  const TileState._();
  const factory TileState.constTileState(int number) = ConstTileState;
  const factory TileState.possibilitiesTileState(List<int> possibilities) =
      PossibilitiesTileState;
  const factory TileState.numberTileState(int number) = NumberTileState;

  @override
  SumRuntimeType get runtimeType =>
      SumRuntimeType([ConstTileState, PossibilitiesTileState, NumberTileState]);

  R visit<R extends Object?>(
      {required R Function(int number) constTileState,
      required R Function(List<int> possibilities) possibilitiesTileState,
      required R Function(int number) numberTileState});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
}

class ConstTileState extends TileState {
  final int number;

  const ConstTileState(this.number) : super._();

  @override
  int get hashCode => Object.hash((ConstTileState), number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is ConstTileState && true && this.number == other.number);

  @override
  String toString() => "ConstTileState { $number }";

  @override
  R visit<R extends Object?>(
          {required R Function(int number) constTileState,
          required R Function(List<int> possibilities) possibilitiesTileState,
          required R Function(int number) numberTileState}) =>
      constTileState(this.number);
}

class PossibilitiesTileState extends TileState {
  final List<int> possibilities;

  const PossibilitiesTileState(this.possibilities) : super._();

  @override
  int get hashCode => Object.hash((PossibilitiesTileState), possibilities);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is PossibilitiesTileState &&
          true &&
          this.possibilities == other.possibilities);

  @override
  String toString() => "PossibilitiesTileState { $possibilities }";

  @override
  R visit<R extends Object?>(
          {required R Function(int number) constTileState,
          required R Function(List<int> possibilities) possibilitiesTileState,
          required R Function(int number) numberTileState}) =>
      possibilitiesTileState(this.possibilities);
}

class NumberTileState extends TileState {
  final int number;

  const NumberTileState(this.number) : super._();

  @override
  int get hashCode => Object.hash((NumberTileState), number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is NumberTileState && true && this.number == other.number);

  @override
  String toString() => "NumberTileState { $number }";

  @override
  R visit<R extends Object?>(
          {required R Function(int number) constTileState,
          required R Function(List<int> possibilities) possibilitiesTileState,
          required R Function(int number) numberTileState}) =>
      numberTileState(this.number);
}

R visitSudokuAppBoardChange<R extends Object?>(
        SudokuAppBoardChange union,
        R Function(ChangeNumber) changeNumber,
        R Function(AddPossibility) addPossibility,
        R Function(RemovePossibility) removePossibility,
        R Function(CommitNumber) commitNumber,
        R Function(ClearTile) clearTile) =>
    union.visit(
        changeNumber: changeNumber,
        addPossibility: addPossibility,
        removePossibility: removePossibility,
        commitNumber: commitNumber,
        clearTile: clearTile);

abstract class SudokuAppBoardChange
    with SudokuAppBoardChangeUndoable
    implements SumType {
  const SudokuAppBoardChange._();
  const factory SudokuAppBoardChange.changeNumber(
      SudokuBoardIndex index, int from, int to) = ChangeNumber;
  const factory SudokuAppBoardChange.addPossibility(
      SudokuBoardIndex index, int number) = AddPossibility;
  const factory SudokuAppBoardChange.removePossibility(
      SudokuBoardIndex index, int number) = RemovePossibility;
  const factory SudokuAppBoardChange.commitNumber(
          SudokuBoardIndex index, List<int> oldPossibilities, int number) =
      CommitNumber;
  const factory SudokuAppBoardChange.clearTile(
          SudokuBoardIndex index, List<int> oldPossibilities, int oldNumber) =
      ClearTile;

  @override
  SumRuntimeType get runtimeType => SumRuntimeType([
        ChangeNumber,
        AddPossibility,
        RemovePossibility,
        CommitNumber,
        ClearTile
      ]);

  R visit<R extends Object?>(
      {required R Function(ChangeNumber) changeNumber,
      required R Function(AddPossibility) addPossibility,
      required R Function(RemovePossibility) removePossibility,
      required R Function(CommitNumber) commitNumber,
      required R Function(ClearTile) clearTile});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
}

class ChangeNumber extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final int from;
  final int to;

  const ChangeNumber(this.index, this.from, this.to) : super._();

  @override
  int get hashCode => Object.hash((ChangeNumber), index, from, to);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is ChangeNumber &&
          true &&
          this.index == other.index &&
          this.from == other.from &&
          this.to == other.to);

  @override
  String toString() => "ChangeNumber { $index, $from, $to }";

  @override
  R visit<R extends Object?>(
          {required R Function(ChangeNumber) changeNumber,
          required R Function(AddPossibility) addPossibility,
          required R Function(RemovePossibility) removePossibility,
          required R Function(CommitNumber) commitNumber,
          required R Function(ClearTile) clearTile}) =>
      changeNumber(this);
}

class AddPossibility extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final int number;

  const AddPossibility(this.index, this.number) : super._();

  @override
  int get hashCode => Object.hash((AddPossibility), index, number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is AddPossibility &&
          true &&
          this.index == other.index &&
          this.number == other.number);

  @override
  String toString() => "AddPossibility { $index, $number }";

  @override
  R visit<R extends Object?>(
          {required R Function(ChangeNumber) changeNumber,
          required R Function(AddPossibility) addPossibility,
          required R Function(RemovePossibility) removePossibility,
          required R Function(CommitNumber) commitNumber,
          required R Function(ClearTile) clearTile}) =>
      addPossibility(this);
}

class RemovePossibility extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final int number;

  const RemovePossibility(this.index, this.number) : super._();

  @override
  int get hashCode => Object.hash((RemovePossibility), index, number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is RemovePossibility &&
          true &&
          this.index == other.index &&
          this.number == other.number);

  @override
  String toString() => "RemovePossibility { $index, $number }";

  @override
  R visit<R extends Object?>(
          {required R Function(ChangeNumber) changeNumber,
          required R Function(AddPossibility) addPossibility,
          required R Function(RemovePossibility) removePossibility,
          required R Function(CommitNumber) commitNumber,
          required R Function(ClearTile) clearTile}) =>
      removePossibility(this);
}

class CommitNumber extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final List<int> oldPossibilities;
  final int number;

  const CommitNumber(this.index, this.oldPossibilities, this.number)
      : super._();

  @override
  int get hashCode =>
      Object.hash((CommitNumber), index, oldPossibilities, number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is CommitNumber &&
          true &&
          this.index == other.index &&
          this.oldPossibilities == other.oldPossibilities &&
          this.number == other.number);

  @override
  String toString() => "CommitNumber { $index, $oldPossibilities, $number }";

  @override
  R visit<R extends Object?>(
          {required R Function(ChangeNumber) changeNumber,
          required R Function(AddPossibility) addPossibility,
          required R Function(RemovePossibility) removePossibility,
          required R Function(CommitNumber) commitNumber,
          required R Function(ClearTile) clearTile}) =>
      commitNumber(this);
}

class ClearTile extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final List<int> oldPossibilities;
  final int oldNumber;

  const ClearTile(this.index, this.oldPossibilities, this.oldNumber)
      : super._();

  @override
  int get hashCode =>
      Object.hash((ClearTile), index, oldPossibilities, oldNumber);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is ClearTile &&
          true &&
          this.index == other.index &&
          this.oldPossibilities == other.oldPossibilities &&
          this.oldNumber == other.oldNumber);

  @override
  String toString() => "ClearTile { $index, $oldPossibilities, $oldNumber }";

  @override
  R visit<R extends Object?>(
          {required R Function(ChangeNumber) changeNumber,
          required R Function(AddPossibility) addPossibility,
          required R Function(RemovePossibility) removePossibility,
          required R Function(CommitNumber) commitNumber,
          required R Function(ClearTile) clearTile}) =>
      clearTile(this);
}
