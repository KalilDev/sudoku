// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

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
