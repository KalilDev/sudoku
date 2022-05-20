import 'dart:convert';
import 'dart:typed_data';
import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
import 'package:collection/collection.dart';
import 'package:utils/event_sourcing.dart';
import 'package:utils/utils.dart';
part 'sudoku_data.g.dart';

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
//                           | ClearTile SudokuBoardIndex Int List<Int>
@data(
  #SudokuAppBoardChange,
  [],
  adt.Union(
    {
      #ChangeNumber: {
        #index: T(#SudokuBoardIndex),
        #from: T(#int),
        #to: T(#int),
      },
      #AddPossibility: {
        #index: T(#SudokuBoardIndex),
        #number: T(#int),
      },
      #RemovePossibility: {
        #index: T(#SudokuBoardIndex),
        #number: T(#int),
      },
      #CommitNumber: {
        #index: T(#SudokuBoardIndex),
        #oldPossibilities: T(#List, [T(#int)]),
        #number: T(#int),
      },
      #ClearTile: {
        #index: T(#SudokuBoardIndex),
        #oldPossibilities: T(#List, [T(#int)]),
        #oldNumber: T(#int),
      }
    },
    deriveMode: adt.UnionVisitDeriveMode.data,
    topLevel: true,
  ),
  mixin: [T(#SudokuAppBoardChangeUndoable)],
)
const Type _sudokuAppBoardChange = SudokuAppBoardChange;

const _possibilitiesEquality = ListEquality<int>();

mixin SudokuAppBoardChangeUndoable
    implements
        UndoableEventSourcedEvent<SudokuAppBoardState,
            SudokuAppBoardStateBuilder, SudokuAppBoardChange> {
  @override
  void applyTo(SudokuAppBoardStateBuilder bdr) => visitSudokuAppBoardChange(
        this as SudokuAppBoardChange,
        (changeNumber) {
          assert(sudokuBoardGetAt(bdr.currentNumbers, changeNumber.index) ==
              changeNumber.from);
          if (changeNumber.to == 0) {
            assert(matrixGetAt(bdr.currentPossibilities, changeNumber.index)
                .isEmpty);
          }
          sudokuBoardSetAt(
              bdr.currentNumbers, changeNumber.index, changeNumber.to);
        },
        (addPossibility) {
          final ps =
              matrixGetAt(bdr.currentPossibilities, addPossibility.index);
          assert(!ps.contains(addPossibility.number));
          ps.add(addPossibility.number);
        },
        (removePossibility) {
          final ps =
              matrixGetAt(bdr.currentPossibilities, removePossibility.index);
          assert(ps.contains(removePossibility.number));
          ps.remove(removePossibility.number);
        },
        (commitNumber) {
          final ps = matrixGetAt(bdr.currentPossibilities, commitNumber.index);
          assert(
              _possibilitiesEquality.equals(ps, commitNumber.oldPossibilities));
          ps.clear();
          sudokuBoardSetAt(
              bdr.currentNumbers, commitNumber.index, commitNumber.number);
        },
        (clearTile) {
          final ps = matrixGetAt(bdr.currentPossibilities, clearTile.index);
          assert(_possibilitiesEquality.equals(ps, clearTile.oldPossibilities));
          assert(sudokuBoardGetAt(bdr.currentNumbers, clearTile.index) ==
              clearTile.oldNumber);
          ps.clear();
          sudokuBoardSetAt(bdr.currentNumbers, clearTile.index, 0);
        },
      );

  @override
  void undoTo(SudokuAppBoardStateBuilder bdr) => visitSudokuAppBoardChange(
        this as SudokuAppBoardChange,
        (changeNumber) {
          assert(sudokuBoardGetAt(bdr.currentNumbers, changeNumber.index) ==
              changeNumber.to);
          if (changeNumber.to == 0) {
            assert(matrixGetAt(bdr.currentPossibilities, changeNumber.index)
                .isEmpty);
          }
          sudokuBoardSetAt(
              bdr.currentNumbers, changeNumber.index, changeNumber.from);
        },
        (addPossibility) {
          final ps =
              matrixGetAt(bdr.currentPossibilities, addPossibility.index);
          assert(ps.contains(addPossibility.number));
          ps.remove(addPossibility.number);
        },
        (removePossibility) {
          final ps =
              matrixGetAt(bdr.currentPossibilities, removePossibility.index);
          assert(!ps.contains(removePossibility.number));
          ps.add(removePossibility.number);
        },
        (commitNumber) {
          assert(sudokuBoardGetAt(bdr.currentNumbers, commitNumber.index) ==
              commitNumber.number);
          matrixSetAt(bdr.currentPossibilities, commitNumber.index,
              commitNumber.oldPossibilities);
          sudokuBoardSetAt(bdr.currentNumbers, commitNumber.index, 0);
        },
        (clearTile) {
          final ps = matrixGetAt(bdr.currentPossibilities, clearTile.index);
          assert(ps.isEmpty);
          assert(sudokuBoardGetAt(bdr.currentNumbers, clearTile.index) == 0);
          matrixSetAt(bdr.currentPossibilities, clearTile.index,
              clearTile.oldPossibilities);
          sudokuBoardSetAt(
              bdr.currentNumbers, clearTile.index, clearTile.oldNumber);
        },
      );
}
