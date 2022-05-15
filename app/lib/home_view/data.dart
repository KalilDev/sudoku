import 'package:app/generation/impl/data.dart';
import 'package:hive/hive.dart';
import 'package:utils/utils.dart';

// type SudokuHomeItemInfo = Map<SudokuDifficulty, Bool>
typedef SudokuHomeItemInfo = Map<SudokuDifficulty, bool>;
SudokuHomeItemInfo sudokuHomeItemFillRemaining(SudokuHomeItemInfo withHoles) =>
    {
      for (final difficulty in SudokuDifficulty.values)
        difficulty: withHoles[difficulty] ?? false,
    };

// type SudokuHomeItem = Int SudokuHomeItemInfo
typedef SudokuHomeItem = Tuple<int, SudokuHomeItemInfo>;

// type SudokuHomeSideInfo = Map<Int, SudokuHomeItem>
typedef SudokuHomeSideInfo = Map<int, SudokuHomeItem>;

// data SudokuHomeDbInfo = SideInfo SudokuHomeSideInfo
//                       | OtherInfo SudokuDifficulty Int
typedef OtherInfo = Tuple<int, SudokuDifficulty>;
typedef SudokuHomeInfo = Either<SudokuHomeSideInfo, OtherInfo>;
typedef SudokuHomeDb = Box<SudokuHomeInfo>;

typedef SudokuHomeViewData = Tuple<SudokuHomeSideInfo, OtherInfo>;
