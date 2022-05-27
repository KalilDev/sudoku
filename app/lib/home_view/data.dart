import 'package:app/generation/impl/data.dart';
import 'package:hive/hive.dart';
import 'package:utils/utils.dart';
import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;

import 'home_db.dart';
part 'data.g.dart';

// type SudokuHomeItemInfo = Map<SudokuDifficulty, Bool>
typedef SudokuHomeItemInfo = Map<SudokuDifficulty, bool>;
SudokuHomeItemInfo sudokuHomeItemFillRemaining(SudokuHomeItemInfo withHoles) =>
    {
      for (final difficulty in SudokuDifficulty.values)
        difficulty: withHoles[difficulty] ?? false,
    };

// data SudokuHomeItem = Int SudokuHomeItemInfo
@data(#SudokuHomeItem, [], adt.Tuple([T(#int), T(#SudokuHomeItemInfo)]))
const Type _sudokuHomeItem = SudokuHomeItem;

// type SudokuHomeSideInfo = Map<Int, SudokuHomeItem>
typedef SudokuHomeSidesInfo = Map<int, SudokuHomeItem>;

@data(#SudokuHomeViewData, [], adt.Tuple([T(#SidesInfo), T(#ActiveInfo)]))
const Type _sudokuHomeViewData = SudokuHomeViewData;
