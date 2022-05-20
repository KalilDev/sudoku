import 'package:utils/utils.dart';

import '../base/sudoku_data.dart';
import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
part 'navigation_data.g.dart';

// data NavigationInformation = Unfocused
//                            | FocusedOnKeypad Int
//                            | FocusedOnBoard Index
@data(
  #NavigationInformation,
  [],
  adt.Union(
    {
      #Unfocused: {},
      #FocusedOnBoard: {
        #index: T(#SudokuBoardIndex),
      },
      #FocusedOnKeypad: {
        #number: T(#int),
      },
    },
  ),
  mixin: [
    T(#SudokuAppBoardChangeUndoable),
  ],
)
const Type _navigationInformation = NavigationInformation;
