import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
import 'package:app/module/base.dart';
import 'package:collection/collection.dart';
import 'package:utils/utils.dart';

part 'data.g.dart';

typedef TileMatrix = Matrix<SudokuTile>;
TileMatrix emptyTileMatrix(int side) => List.generate(
      side,
      (_) => List.filled(
        side,
        const Possibilities([]),
        growable: false,
      ),
      growable: false,
    );

printMatrix(Matrix<Object> m) => m.map((l) => l.toString()).join('\n');

TileMatrix tileMatrixFromState(SudokuAppBoardState state) {
  final side = state.side;
  final m = emptyTileMatrix(side);
  for (int j = 0; j < side; j++) {
    for (int i = 0; i < side; i++) {
      final index = SudokuBoardIndex(i, j);
      {
        final permanent = sudokuBoardGetAt(state.fixedNumbers, index);
        if (permanent != 0) {
          matrixSetAt<SudokuTile>(m, index, Permanent(permanent));
          continue;
        }
      }
      {
        final current = sudokuBoardGetAt(state.currentNumbers, index);
        if (current != 0) {
          matrixSetAt<SudokuTile>(
              m, index, Number(current, Validation.unknown));
          continue;
        }
      }
      final ps = matrixGetAt(state.currentPossibilities, index);
      matrixSetAt<SudokuTile>(m, index, Possibilities(ps));
    }
    // lock the current row
    m[j] = UnmodifiableListView(m[j]);
  }
  // lock the matrix
  return UnmodifiableListView(m);
}

typedef IndexedTile = Tuple<SudokuBoardIndex, SudokuTile>;

enum SudokuPlacementMode {
  possibility,
  number,
}

SudokuPlacementMode invertPlacementMode(SudokuPlacementMode mode) {
  switch (mode) {
    case SudokuPlacementMode.possibility:
      return SudokuPlacementMode.number;
    case SudokuPlacementMode.number:
      return SudokuPlacementMode.possibility;
  }
}

enum Validation {
  unknown,
  valid,
  invalid,
}

// TODO: loading????????
// ig an SudokuTile + an inherited widget would be the best option, no
// additional complexity on the data

// data SudokuTile = Permanent Int
//                 | Number Int Validation
//                 | Possibilities List<Int>
@data(
  #SudokuTile,
  [],
  adt.Union(
    {
      #Permanent: {
        #number: T(#int),
      },
      #Number: {
        #number: T(#int),
        #validation: T(#Validation),
      },
      #Possibilities: {
        #possibilities: T(#List, args: [T(#int)]),
      }
    },
    deriveMode: adt.UnionVisitDeriveMode.cata,
    topLevel: false,
  ),
)
const Type _sudokuTile = SudokuTile;
