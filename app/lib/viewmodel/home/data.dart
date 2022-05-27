import 'package:app/sudoku_generation/sudoku_generation.dart';
import 'package:utils/utils.dart';
import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;

import 'home_db.dart';
part 'data.g.dart';

// type SideCanContinueMap = Map<SudokuDifficulty, Bool>
typedef SideCanContinueMap = Map<SudokuDifficulty, bool>;
SideCanContinueMap sudokuHomeItemFillRemaining(SideCanContinueMap withHoles) =>
    {
      for (final difficulty in SudokuDifficulty.values)
        difficulty: withHoles[difficulty] ?? false,
    };

// type SudokuHomeSidesInfo = Map<Int, SideCanContinueMap>
typedef SudokuHomeSidesInfo = Map<int, SideCanContinueMap>;

@data(#SudokuHomeViewData, [], adt.Tuple([T(#SidesInfo), T(#ActiveInfo)]))
const Type _sudokuHomeViewData = SudokuHomeViewData;
