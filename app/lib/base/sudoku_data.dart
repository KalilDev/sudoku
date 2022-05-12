import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:utils/event_sourcing.dart';
import 'package:utils/utils.dart';

// An list of rows
typedef SudokuBoard = List<Uint8List>;

// left is the x coordinate and right is the y coordinate
typedef SudokuBoardIndex = Tuple<int, int>;

int sudokuBoardGetAt(SudokuBoard board, SudokuBoardIndex index) =>
    board[index.right][index.left];
void sudokuBoardSetAt(SudokuBoard board, SudokuBoardIndex index, int value) =>
    board[index.right][index.left] = value;

SudokuBoard emptySudokuBoard(int side) =>
    List.generate(side, (_) => Uint8List(side), growable: false);
SudokuBoard cloneSudokuBoard(SudokuBoard board) =>
    board.map(Uint8List.fromList).toList(growable: false);

// An list of rows
typedef Matrix<T> = List<List<T>>;

// left is the x coordinate and right is the y coordinate
typedef MatrixIndex = Tuple<int, int>;

T matrixGetAt<T>(Matrix<T> m, MatrixIndex index) => m[index.right][index.left];
void matrixSetAt<T>(Matrix<T> m, MatrixIndex index, T value) =>
    m[index.right][index.left] = value;

typedef PossibilitiesMatrix = Matrix<List<int>>;

PossibilitiesMatrix emptyPossibilitiesMatrix(int side) =>
    List.generate(side, (_) => List.generate(side, (_) => [], growable: false),
        growable: false);
PossibilitiesMatrix clonePossibilitiesMatrix(PossibilitiesMatrix m) => m
    .map((r) => r.map((e) => e.toList()).toList(growable: false))
    .toList(growable: false);

typedef SudokuAppBoardModel = DoublyLinkedEventSourcedModel<SudokuAppBoardState,
    SudokuAppBoardStateBuilder, SudokuAppBoardChange>;

extension AA on SudokuAppBoardModel {
  // todo: return SudokuAppBoardModel or SudokuAppBoardState
  SudokuAppBoardModel addE(SudokuAppBoardChange e) => this..add(e);
  SudokuAppBoardModel changeNumber(SudokuBoardIndex index, int to) =>
      addE(snapshot.changeNumberE(index, to));
  SudokuAppBoardModel addPossibility(SudokuBoardIndex index, int number) =>
      addE(snapshot.addPossibilityE(index, number));
  SudokuAppBoardModel removePossibility(SudokuBoardIndex index, int number) =>
      addE(snapshot.removePossibilityE(index, number));
  SudokuAppBoardModel commitNumber(SudokuBoardIndex index, int number) =>
      addE(snapshot.commitNumberE(index, number));
  SudokuAppBoardModel clearTile(SudokuBoardIndex index) =>
      addE(snapshot.clearTileE(index));
}

extension AAA on SudokuAppBoardState {
  ChangeNumber changeNumberE(SudokuBoardIndex index, int to) =>
      ChangeNumber(index, sudokuBoardGetAt(currentNumbers, index), to);
  AddPossibility addPossibilityE(SudokuBoardIndex index, int number) =>
      AddPossibility(index, number);
  RemovePossibility removePossibilityE(SudokuBoardIndex index, int number) =>
      RemovePossibility(index, number);
  CommitNumber commitNumberE(SudokuBoardIndex index, int number) =>
      CommitNumber(index, matrixGetAt(currentPossibilities, index), number);
  ClearTile clearTileE(SudokuBoardIndex index) => ClearTile(
        index,
        matrixGetAt(currentPossibilities, index),
        sudokuBoardGetAt(currentNumbers, index),
      );
}

class SudokuAppBoardState
    implements
        EventSourcedSnapshot<SudokuAppBoardState, SudokuAppBoardStateBuilder,
            SudokuAppBoardChange> {
  final SudokuBoard solvedBoard;
  final SudokuBoard fixedNumbers;
  final int side;
  final SudokuBoard currentNumbers;
  final PossibilitiesMatrix currentPossibilities;

  const SudokuAppBoardState(
    this.solvedBoard,
    this.fixedNumbers,
    this.side,
    this.currentNumbers,
    this.currentPossibilities,
  );

  @override
  SudokuAppBoardState rebuild(
    void Function(SudokuAppBoardStateBuilder) updates,
  ) =>
      (toBuilder()..update(updates)).build();

  @override
  SudokuAppBoardStateBuilder toBuilder() =>
      SudokuAppBoardStateBuilder(side)..replace(this);
}

SudokuBoard sudokuBoardCopyLocked(SudokuBoard b) => UnmodifiableListView(b
    .map((r) => UnmodifiableUint8ListView(Uint8List.fromList(r)))
    .toList(growable: false));

PossibilitiesMatrix possibilitiesMatrixCopyLocked(PossibilitiesMatrix m) =>
    UnmodifiableListView(m
        .map((r) => UnmodifiableListView(
              r.map((e) => e.toList()).toList(growable: false),
            ))
        .toList(growable: false));

class SudokuAppBoardStateBuilder
    implements
        EventSourcedSnapshotBuilder<SudokuAppBoardState,
            SudokuAppBoardStateBuilder, SudokuAppBoardChange> {
  final int side;
  SudokuAppBoardStateBuilder(this.side);

  SudokuBoard? _solvedBoard;
  SudokuBoard get solvedBoard => _solvedBoard ??= emptySudokuBoard(side);
  set solvedBoard(SudokuBoard value) => _solvedBoard = cloneSudokuBoard(value);

  SudokuBoard? _fixedNumbers;
  SudokuBoard get fixedNumbers => _fixedNumbers ??= emptySudokuBoard(side);
  set fixedNumbers(SudokuBoard value) =>
      _fixedNumbers = cloneSudokuBoard(value);

  SudokuBoard? _currentNumbers;
  SudokuBoard get currentNumbers => _currentNumbers ??= emptySudokuBoard(side);
  set currentNumbers(SudokuBoard value) =>
      _currentNumbers = cloneSudokuBoard(value);

  PossibilitiesMatrix? _currentPossibilities;
  PossibilitiesMatrix get currentPossibilities =>
      _currentPossibilities ??= emptyPossibilitiesMatrix(side);
  set currentPossibilities(PossibilitiesMatrix value) =>
      _currentPossibilities = clonePossibilitiesMatrix(value);

  SudokuAppBoardState build() => SudokuAppBoardState(
        sudokuBoardCopyLocked(solvedBoard),
        sudokuBoardCopyLocked(fixedNumbers),
        side,
        sudokuBoardCopyLocked(currentNumbers),
        possibilitiesMatrixCopyLocked(currentPossibilities),
      );

  @override
  void replace(SudokuAppBoardState other) {
    assert(other.side == side);
    this
      ..solvedBoard = other.solvedBoard
      ..fixedNumbers = other.fixedNumbers
      ..currentNumbers = other.currentNumbers
      ..currentPossibilities = other.currentPossibilities;
  }

  @override
  void update(void Function(SudokuAppBoardStateBuilder) updates) =>
      updates(this);
}

// data SudokuAppBoardChange = ChangeNumber SudokuBoardIndex Int Int
//                           | AddPossibility SudokuBoardIndex Int
//                           | RemovePossibility SudokuBoardIndex Int
//                           | CommitNumber SudokuBoardIndex List<Int> Int
//                           | ClearTile Int List<Int>
abstract class SudokuAppBoardChange
    implements
        SumType,
        UndoableEventSourcedEvent<SudokuAppBoardState,
            SudokuAppBoardStateBuilder, SudokuAppBoardChange> {
  const SudokuAppBoardChange._();

  R visit<R>({
    required R Function(ChangeNumber) changeNumber,
    required R Function(AddPossibility) addPossibility,
    required R Function(RemovePossibility) removePossibility,
    required R Function(CommitNumber) commitNumber,
    required R Function(ClearTile) clearTile,
  });

  SumRuntimeType get runtimeType => const SumRuntimeType([
        ChangeNumber,
        AddPossibility,
        RemovePossibility,
        CommitNumber,
        ClearTile,
      ]);

  int get hashCode =>
      throw UnimplementedError('Every case has an hashCode override');
  bool operator ==(other) =>
      throw UnimplementedError('Every case has an equality override');
  String toString() =>
      throw UnimplementedError('Every case has an toString override');
}

class ChangeNumber extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final int from;
  final int to;

  const ChangeNumber(this.index, this.from, this.to)
      :
        // todo: can [to] be 0? i guess only if possibilities are empty
        // (assert), but this would be unexpected behavior or ensured by the
        // logic of the program, which is the exact usecase of an assert?
        // i guess i feel weird about this data type having this sorta control.
        assert(from != 0),
        super._();

  R visit<R>({
    required R Function(ChangeNumber) changeNumber,
    required R Function(AddPossibility) addPossibility,
    required R Function(RemovePossibility) removePossibility,
    required R Function(CommitNumber) commitNumber,
    required R Function(ClearTile) clearTile,
  }) =>
      changeNumber(this);

  int get hashCode => Object.hash(index, from, to);
  bool operator ==(other) =>
      other is ChangeNumber &&
      other.index == index &&
      other.from == from &&
      other.to == to;

  @override
  String toString() => "ChangeNumber $index $from $to";

  @override
  void applyTo(SudokuAppBoardStateBuilder bdr) {
    assert(sudokuBoardGetAt(bdr.currentNumbers, index) == from);
    if (to == 0) {
      assert(matrixGetAt(bdr.currentPossibilities, index).isEmpty);
    }
    sudokuBoardSetAt(bdr.currentNumbers, index, to);
  }

  @override
  void undoTo(SudokuAppBoardStateBuilder bdr) {
    assert(sudokuBoardGetAt(bdr.currentNumbers, index) == to);
    if (to == 0) {
      assert(matrixGetAt(bdr.currentPossibilities, index).isEmpty);
    }
    sudokuBoardSetAt(bdr.currentNumbers, index, from);
  }
}

class AddPossibility extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final int number;

  const AddPossibility(this.index, this.number) : super._();

  R visit<R>({
    required R Function(ChangeNumber) changeNumber,
    required R Function(AddPossibility) addPossibility,
    required R Function(RemovePossibility) removePossibility,
    required R Function(CommitNumber) commitNumber,
    required R Function(ClearTile) clearTile,
  }) =>
      addPossibility(this);

  int get hashCode => Object.hash(index, number);
  bool operator ==(other) =>
      other is AddPossibility && other.index == index && other.number == number;
  @override
  String toString() => "AddPossibility $index $number";

  @override
  void applyTo(SudokuAppBoardStateBuilder bdr) {
    final ps = matrixGetAt(bdr.currentPossibilities, index);
    assert(!ps.contains(number));
    ps.add(number);
  }

  @override
  void undoTo(SudokuAppBoardStateBuilder bdr) {
    final ps = matrixGetAt(bdr.currentPossibilities, index);
    assert(ps.contains(number));
    ps.remove(number);
  }
}

class RemovePossibility extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final int number;

  const RemovePossibility(this.index, this.number) : super._();

  R visit<R>({
    required R Function(ChangeNumber) changeNumber,
    required R Function(AddPossibility) addPossibility,
    required R Function(RemovePossibility) removePossibility,
    required R Function(CommitNumber) commitNumber,
    required R Function(ClearTile) clearTile,
  }) =>
      removePossibility(this);

  int get hashCode => Object.hash(index, number);
  bool operator ==(other) =>
      other is RemovePossibility &&
      other.index == index &&
      other.number == number;
  @override
  String toString() => "RemovePossibility $index $number";

  @override
  void applyTo(SudokuAppBoardStateBuilder bdr) {
    final ps = matrixGetAt(bdr.currentPossibilities, index);
    assert(ps.contains(number));
    ps.remove(number);
  }

  @override
  void undoTo(SudokuAppBoardStateBuilder bdr) {
    final ps = matrixGetAt(bdr.currentPossibilities, index);
    assert(!ps.contains(number));
    ps.add(number);
  }
}

class CommitNumber extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final List<int> oldPossibilities;
  final int number;

  const CommitNumber(this.index, this.oldPossibilities, this.number)
      : super._();

  R visit<R>({
    required R Function(ChangeNumber) changeNumber,
    required R Function(AddPossibility) addPossibility,
    required R Function(RemovePossibility) removePossibility,
    required R Function(CommitNumber) commitNumber,
    required R Function(ClearTile) clearTile,
  }) =>
      commitNumber(this);

  static const _possibilitiesEquality = ListEquality<int>();

  int get hashCode =>
      Object.hash(index, _possibilitiesEquality.hash(oldPossibilities), number);

  bool operator ==(other) =>
      other is CommitNumber &&
      other.index == index &&
      _possibilitiesEquality.equals(other.oldPossibilities, oldPossibilities) &&
      other.number == number;

  @override
  String toString() => "CommitNumber $index $oldPossibilities $number";

  @override
  void applyTo(SudokuAppBoardStateBuilder bdr) {
    final ps = matrixGetAt(bdr.currentPossibilities, index);
    assert(_possibilitiesEquality.equals(ps, oldPossibilities));
    ps.clear();
    sudokuBoardSetAt(bdr.currentNumbers, index, number);
  }

  @override
  void undoTo(SudokuAppBoardStateBuilder bdr) {
    assert(sudokuBoardGetAt(bdr.currentNumbers, index) == number);
    matrixSetAt(bdr.currentPossibilities, index, oldPossibilities);
    sudokuBoardSetAt(bdr.currentNumbers, index, 0);
  }
}

class ClearTile extends SudokuAppBoardChange {
  final SudokuBoardIndex index;
  final List<int> oldPossibilities;
  final int oldNumber;

  const ClearTile(this.index, this.oldPossibilities, this.oldNumber)
      : super._();

  R visit<R>({
    required R Function(ChangeNumber) changeNumber,
    required R Function(AddPossibility) addPossibility,
    required R Function(RemovePossibility) removePossibility,
    required R Function(CommitNumber) commitNumber,
    required R Function(ClearTile) clearTile,
  }) =>
      clearTile(this);

  static const _possibilitiesEquality = ListEquality<int>();

  int get hashCode => Object.hash(
      index, _possibilitiesEquality.hash(oldPossibilities), oldNumber);

  bool operator ==(other) =>
      other is ClearTile &&
      other.index == index &&
      _possibilitiesEquality.equals(other.oldPossibilities, oldPossibilities) &&
      other.oldNumber == oldNumber;

  @override
  String toString() => "CommitNumber $index $oldPossibilities $oldNumber";

  @override
  void applyTo(SudokuAppBoardStateBuilder bdr) {
    final ps = matrixGetAt(bdr.currentPossibilities, index);
    assert(_possibilitiesEquality.equals(ps, oldPossibilities));
    assert(sudokuBoardGetAt(bdr.currentNumbers, index) == oldNumber);
    ps.clear();
    sudokuBoardSetAt(bdr.currentNumbers, index, 0);
  }

  @override
  void undoTo(SudokuAppBoardStateBuilder bdr) {
    final ps = matrixGetAt(bdr.currentPossibilities, index);
    assert(ps.isEmpty);
    assert(sudokuBoardGetAt(bdr.currentNumbers, index) == 0);
    matrixSetAt(bdr.currentPossibilities, index, oldPossibilities);
    sudokuBoardSetAt(bdr.currentNumbers, index, oldNumber);
  }
}
