import 'package:app/generation/impl/data.dart';
import 'package:hive/hive.dart';
import 'package:utils/utils.dart';
import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
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
typedef SudokuHomeSideInfo = Map<int, SudokuHomeItem>;

// data SudokuHomeDbInfo = SideInfo SudokuHomeSideInfo
//                       | OtherInfo SudokuDifficulty Int
@data(
  #SudokuHomeInfo,
  [],
  adt.Union(
    {
      #SideInfo: {
        #info: T(#SudokuHomeSideInfo),
      },
      #OtherInfo: {
        #difficulty: T(#SudokuDifficulty),
        #activeSideSqrt: T(#int),
      }
    },
    deriveMode: adt.UnionVisitDeriveMode.data,
  ),
)
const Type _sudokuDbHomeInfo = SudokuHomeInfo;

typedef SudokuHomeDb = Box<SudokuHomeInfo>;

typedef SudokuHomeViewData = Tuple<SudokuHomeSideInfo, OtherInfo>;
