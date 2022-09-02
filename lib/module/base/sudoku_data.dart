import 'dart:typed_data';

import 'package:kalil_adt_annotation/kalil_adt_annotation.dart'
    show data, T, Tp, NoMixin;
import 'package:kalil_adt_annotation/kalil_adt_annotation.dart' as adt;
import 'package:collection/collection.dart';
import 'package:kalil_utils/utils.dart';

part 'sudoku_data.g.dart';

// An list of rows
typedef SudokuBoard = List<Uint8List>;

typedef LoadingModel = Maybe<ModelOrError>;
typedef ModelOrError = Either<Object, SudokuAppBoardModel>;

// left is the x coordinate and right is the y coordinate
@data(
  #MatrixIndex,
  [],
  adt.Tuple([T(#int), T(#int)]),
  mixin: [T(#_MatrixIndexUtils)],
)
const Type _matrixIndex = MatrixIndex;
mixin _MatrixIndexUtils {
  TupleN2<int, int> get _self => this as TupleN2<int, int>;
  int get x => _self.e0;
  int get y => _self.e1;
}

typedef SudokuBoardIndex = MatrixIndex;

int sudokuBoardGetAt(SudokuBoard board, SudokuBoardIndex index) =>
    board[index.y][index.x];
void sudokuBoardSetAt(SudokuBoard board, SudokuBoardIndex index, int value) =>
    board[index.y][index.x] = value;
bool sudokuBoardEquals(SudokuBoard? a, SudokuBoard? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var r = 0; r < a.length; r++) {
    for (var c = 0; c < a.length; c++) {
      final index = SudokuBoardIndex(r, c);
      if (sudokuBoardGetAt(a, index) != sudokuBoardGetAt(b, index)) {
        return false;
      }
    }
  }
  return true;
}

SudokuBoard emptySudokuBoard(int side) =>
    List.generate(side, (_) => Uint8List(side), growable: false);
SudokuBoard cloneSudokuBoard(SudokuBoard board) =>
    board.map(Uint8List.fromList).toList(growable: false);

// An list of rows
typedef Matrix<T> = List<List<T>>;
Matrix<T> matrixGenerate<T>(int side, T Function(MatrixIndex) fn) =>
    UnmodifiableListView(
      List.generate(
        side,
        (j) => UnmodifiableListView(
          List.generate(
            side,
            (i) => fn(
              MatrixIndex(i, j),
            ),
          ),
        ),
      ),
    );
T matrixGetAt<T>(Matrix<T> m, MatrixIndex index) => m[index.y][index.x];
void matrixSetAt<T>(Matrix<T> m, MatrixIndex index, T value) =>
    m[index.y][index.x] = value;

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
  Maybe<SudokuAppBoardModel> maybeAddE(Maybe<SudokuAppBoardChange> e) =>
      e.fmap((e) => this..add(e));
}

extension AAA on SudokuAppBoardState {
// number -> ChangeNumber -> number
  Maybe<ChangeNumber> changeNumberE(
    SudokuBoardIndex index,
    int to,
  ) =>
      tileStateAt(index).visit(
        constTileState: (_) => const None(),
        possibilitiesTileState: (_) => const None(),
        numberTileState: (n) => n == to
            ? const None()
            : Just(
                ChangeNumber(index, n, to),
              ),
      );
// possibilities -> AddPossibility -> possibilities
  Maybe<AddPossibility> addPossibilityE(
    SudokuBoardIndex index,
    int number,
  ) =>
      tileStateAt(index).visit(
        constTileState: (_) => const None(),
        possibilitiesTileState: (ps) => ps.contains(number)
            ? const None()
            : Just(AddPossibility(index, number)),
        numberTileState: (_) => const None(),
      );

// possibilities -> RemovePossibility -> possibilities
  Maybe<RemovePossibility> removePossibilityE(
    SudokuBoardIndex index,
    int number,
  ) =>
      tileStateAt(index).visit(
        constTileState: (_) => const None(),
        possibilitiesTileState: (ps) => !ps.contains(number)
            ? const None()
            : Just(RemovePossibility(index, number)),
        numberTileState: (_) => const None(),
      );

// possibilities -> CommitNumber -> number
  Maybe<CommitNumber> commitNumberE(
    SudokuBoardIndex index,
    int number,
  ) =>
      tileStateAt(index).visit(
        constTileState: (_) => const None(),
        possibilitiesTileState: (ps) => Just(CommitNumber(
          index,
          ps,
          number,
        )),
        numberTileState: (_) => const None(),
      );

// possibilities -> ClearTile -> possiblities
// number -> ClearTile -> possibilities
  Maybe<ClearTile> clearTileE(SudokuBoardIndex index) =>
      tileStateAt(index).visit(
        constTileState: (_) => const None(),
        possibilitiesTileState: (ps) => Just(ClearTile(
          index,
          ps,
          0,
        )),
        numberTileState: (n) => Just(ClearTile(
          index,
          const [],
          n,
        )),
      );

// number -> ChangeFromNumberToPossibility -> possibilities
  Maybe<ChangeFromNumberToPossibility> changeFromNumberToPossibilityE(
          SudokuBoardIndex index, int possibility) =>
      tileStateAt(index).visit(
        constTileState: (_) => const None(),
        possibilitiesTileState: (ps) => None(),
        numberTileState: (n) => Just(ChangeFromNumberToPossibility(
          index,
          n,
          possibility,
        )),
      );
// boardState -> boardState
  Maybe<ClearBoard> clearBoardE() => isEmpty ? None() : Just(ClearBoard(this));
}

TileState tileStateAtWith(
  SudokuBoard fixedNumbers,
  SudokuBoard currentNumbers,
  PossibilitiesMatrix currentPossibilities,
  MatrixIndex index,
) {
  final constNumber = matrixGetAt(fixedNumbers, index);
  if (constNumber != 0) {
    return constTileState(constNumber);
  }
  final number = matrixGetAt(currentNumbers, index);
  if (number == 0) {
    return PossibilitiesTileState(matrixGetAt(currentPossibilities, index));
  }
  return NumberTileState(number);
}

TileStateMatrix tileStatesWith(
  SudokuBoard fixedNumbers,
  SudokuBoard currentNumbers,
  PossibilitiesMatrix currentPossibilities,
) =>
    matrixGenerate(
      fixedNumbers.length,
      tileStateAtWith.curry(fixedNumbers)(currentNumbers)(currentPossibilities),
    );

class SudokuAppBoardState
    implements
        EventSourcedSnapshot<SudokuAppBoardState, SudokuAppBoardStateBuilder,
            SudokuAppBoardChange> {
  final SudokuBoard solvedBoard;
  final SudokuBoard fixedNumbers;
  final int side;
  final SudokuBoard currentNumbers;
  final PossibilitiesMatrix currentPossibilities;

  TileState tileStateAt(MatrixIndex index) => tileStateAtWith(
        fixedNumbers,
        currentNumbers,
        currentPossibilities,
        index,
      );

  TileStateMatrix get tileStates => tileStatesWith(
        fixedNumbers,
        currentNumbers,
        currentPossibilities,
      );

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

  bool get isEmpty =>
      currentNumbers.every((r) => r.every((e) => e == 0)) &&
      currentPossibilities.every((r) => r.every((e) => e.isEmpty));
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

  void clear() {
    _currentNumbers = null;
    _currentPossibilities = null;
  }

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

  void changeTileStateAt(MatrixIndex index, TileState newState) {
    newState.visit(
      constTileState: (number) {
        assert(sudokuBoardGetAt(solvedBoard, index) == number);
        fixedNumbers[index.y][index.x] = number;
        currentNumbers[index.y][index.x] = 0;
        currentPossibilities[index.y][index.x] = const [];
      },
      possibilitiesTileState: (possibilities) {
        fixedNumbers[index.y][index.x] = 0;
        currentNumbers[index.y][index.x] = 0;
        currentPossibilities[index.y][index.x] = possibilities;
      },
      numberTileState: (number) {
        fixedNumbers[index.y][index.x] = 0;
        currentNumbers[index.y][index.x] = number;
        currentPossibilities[index.y][index.x] = const [];
      },
    );
  }

  TileState tileStateAt(MatrixIndex index) => tileStateAtWith(
        fixedNumbers,
        currentNumbers,
        currentPossibilities,
        index,
      );

  TileStateMatrix get tileStates => tileStatesWith(
        fixedNumbers,
        currentNumbers,
        currentPossibilities,
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

// States:
// const
// possibilities -> AddPossibility|RemovePossibility -> possibilities
// possibilities -> CommitNumber -> number
// possibilities -> ClearTile -> possiblities
// number -> ChangeNumber -> number
// number -> ClearTile -> possibilities
// number -> ChangeFromNumberToPossibilities -> possibilities
@data(
  #TileState,
  [],
  adt.Union({
    #ConstTileState: {#number: T(#int)},
    #PossibilitiesTileState: {
      #possibilities: T(#List, args: [T(#int)])
    },
    #NumberTileState: {#number: T(#int)},
  }),
)
const Type _tileState = TileState;

TileState constTileState(int number) => ConstTileState(number);
TileState initialTileState() => const PossibilitiesTileState([]);

typedef TileStateMatrix = Matrix<TileState>;

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
        #from: T(#int, asserts: ['{} != to', '{} != 0']),
        #to: T(#int, asserts: ['{} != from', '{} != 0']),
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
        #oldPossibilities: T(#List, args: [T(#int)]),
        #number: T(#int),
      },
      #ClearTile: {
        #index: T(#SudokuBoardIndex),
        #oldPossibilities: T(#List,
            args: [T(#int)], asserts: ['{}.length != 0 || oldNumber != 0']),
        #oldNumber:
            T(#int, asserts: ['{} != 0 || oldPossibilities.length != 0']),
      },
      #ChangeFromNumberToPossibility: {
        #index: T(#SudokuBoardIndex),
        #oldNumber: T(#int),
        #possibility: T(#int),
      },
      #ClearBoard: {
        #oldState: T(#SudokuAppBoardState),
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
// number -> ChangeNumber -> number
        (changeNumber) {
          final currentState = bdr.tileStateAt(changeNumber.index);
          assert(currentState is NumberTileState);
          assert((currentState as NumberTileState).number == changeNumber.from);
          final newTileState = NumberTileState(changeNumber.to);
          bdr.changeTileStateAt(changeNumber.index, newTileState);
        },
// possibilities -> AddPossibility -> possibilities
        (addPossibility) {
          final currentState = bdr.tileStateAt(addPossibility.index);
          assert(currentState is PossibilitiesTileState);
          assert(!(currentState as PossibilitiesTileState)
              .possibilities
              .contains(addPossibility.number));
          final newTileState = PossibilitiesTileState(
              (currentState as PossibilitiesTileState).possibilities.toList()
                ..add(addPossibility.number));
          bdr.changeTileStateAt(addPossibility.index, newTileState);
        },
// possibilities -> RemovePossibility -> possibilities
        (removePossibility) {
          final currentState = bdr.tileStateAt(removePossibility.index);
          assert(currentState is PossibilitiesTileState);
          assert((currentState as PossibilitiesTileState)
              .possibilities
              .contains(removePossibility.number));
          final newTileState = PossibilitiesTileState(
              (currentState as PossibilitiesTileState).possibilities.toList()
                ..remove(removePossibility.number));
          bdr.changeTileStateAt(removePossibility.index, newTileState);
        },
// possibilities -> CommitNumber -> number
        (commitNumber) {
          final currentState = bdr.tileStateAt(commitNumber.index);
          assert(currentState is PossibilitiesTileState);
          assert(_possibilitiesEquality.equals(commitNumber.oldPossibilities,
              (currentState as PossibilitiesTileState).possibilities));
          final newTileState = NumberTileState(commitNumber.number);
          bdr.changeTileStateAt(commitNumber.index, newTileState);
        },
// possibilities -> ClearTile -> possiblities
// number -> ClearTile -> possibilities
        (clearTile) {
          final currentState = bdr.tileStateAt(clearTile.index);
          assert(currentState is PossibilitiesTileState ||
              currentState is NumberTileState);
          if (currentState is PossibilitiesTileState) {
            assert(clearTile.oldNumber == 0);
            assert(_possibilitiesEquality.equals(
                clearTile.oldPossibilities, currentState.possibilities));
          } else if (currentState is NumberTileState) {
            assert(clearTile.oldNumber == currentState.number);
            assert(clearTile.oldPossibilities.isEmpty);
          } else {
            throw TypeError();
          }
          const newTileState = PossibilitiesTileState([]);
          bdr.changeTileStateAt(clearTile.index, newTileState);
        },
// number -> ChangeFromNumberToPossibilities -> possibilities
        (changeFromNumberToPossibility) {
          final currentState =
              bdr.tileStateAt(changeFromNumberToPossibility.index);
          assert(currentState is NumberTileState);
          assert((currentState as NumberTileState).number ==
              changeFromNumberToPossibility.oldNumber);
          final newTileState = PossibilitiesTileState(
              [changeFromNumberToPossibility.possibility]);
          bdr.changeTileStateAt(
              changeFromNumberToPossibility.index, newTileState);
        },
        // boardState -> boardState
        (clearBoard) {
          bdr.clear();
        },
      );

  @override
  void undoTo(SudokuAppBoardStateBuilder bdr) => visitSudokuAppBoardChange(
        this as SudokuAppBoardChange,
// number <- ChangeNumber <- number
        (changeNumber) {
          final currentState = bdr.tileStateAt(changeNumber.index);
          assert(currentState is NumberTileState);
          assert((currentState as NumberTileState).number == changeNumber.to);
          final newTileState = NumberTileState(changeNumber.from);
          bdr.changeTileStateAt(changeNumber.index, newTileState);
        },
// possibilities <- AddPossibility <- possibilities
        (addPossibility) {
          final currentState = bdr.tileStateAt(addPossibility.index);
          assert(currentState is PossibilitiesTileState);
          assert((currentState as PossibilitiesTileState)
              .possibilities
              .contains(addPossibility.number));
          final newTileState = PossibilitiesTileState(
              (currentState as PossibilitiesTileState).possibilities.toList()
                ..remove(addPossibility.number));
          bdr.changeTileStateAt(addPossibility.index, newTileState);
        },
// possibilities <- RemovePossibility <- possibilities
        (removePossibility) {
          final currentState = bdr.tileStateAt(removePossibility.index);
          assert(currentState is PossibilitiesTileState);
          assert(!(currentState as PossibilitiesTileState)
              .possibilities
              .contains(removePossibility.number));
          final newTileState = PossibilitiesTileState(
              (currentState as PossibilitiesTileState).possibilities.toList()
                ..add(removePossibility.number));
          bdr.changeTileStateAt(removePossibility.index, newTileState);
        },
// possibilities <- CommitNumber <- number
        (commitNumber) {
          final currentState = bdr.tileStateAt(commitNumber.index);
          assert(currentState is NumberTileState);
          assert(
              (currentState as NumberTileState).number == commitNumber.number);
          final newTileState =
              PossibilitiesTileState(commitNumber.oldPossibilities);
          bdr.changeTileStateAt(commitNumber.index, newTileState);
        },
// possibilities <- ClearTile <- possiblities
// number <- ClearTile <- possibilities
        (clearTile) {
          final currentState = bdr.tileStateAt(clearTile.index);
          assert(currentState is PossibilitiesTileState);
          final TileState newTileState;
          if (clearTile.oldNumber == 0) {
            newTileState = PossibilitiesTileState(clearTile.oldPossibilities);
          } else {
            newTileState = NumberTileState(clearTile.oldNumber);
          }
          bdr.changeTileStateAt(clearTile.index, newTileState);
          ;
        },
// number <- ChangeFromNumberToPossibilities <- possibilities
        (changeFromNumberToPossibility) {
          final currentState =
              bdr.tileStateAt(changeFromNumberToPossibility.index);
          assert(currentState is PossibilitiesTileState);
          assert(
              (currentState as PossibilitiesTileState).possibilities.single ==
                  changeFromNumberToPossibility.possibility);
          final newTileState =
              NumberTileState(changeFromNumberToPossibility.oldNumber);
          bdr.changeTileStateAt(
              changeFromNumberToPossibility.index, newTileState);
        },
        // boardState -> boardState
        (clearBoard) {
          bdr.replace(clearBoard.oldState);
        },
      );
}
