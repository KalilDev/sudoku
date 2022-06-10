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

typedef ValidationMatrix = Matrix<Validation>;

TileMatrix? validatedFromValidationAndNotValidated(
  SudokuBoard? validation,
  TileStateMatrix? notValidated,
) {
  if (validation == null || notValidated == null) {
    return null;
  }
  final side = notValidated.length;
  return matrixGenerate(
      side,
      (index) => matrixGetAt(notValidated, index).visit(
            constTileState: Permanent.new,
            possibilitiesTileState: Possibilities.new,
            numberTileState: (n) {
              final Validation result;
              final validatedNumber = sudokuBoardGetAt(validation, index);
              if (validatedNumber == 0) {
                result = Validation.unknown;
              } else {
                result = validatedNumber == n
                    ? Validation.valid
                    : Validation.invalid;
              }
              return Number(n, result);
            },
          ));
}

TileMatrix tileMatrixFromTileStateAndValidation(
  TileStateMatrix tileStates,
  ValidationMatrix validation,
) {
  final side = tileStates.length;
  return matrixGenerate(
      side,
      (index) => matrixGetAt(tileStates, index).visit(
            constTileState: Permanent.new,
            possibilitiesTileState: Possibilities.new,
            numberTileState: (n) => Number(n, matrixGetAt(validation, index)),
          ));
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
