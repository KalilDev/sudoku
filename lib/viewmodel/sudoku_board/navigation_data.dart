import 'package:kalil_adt_annotation/kalil_adt_annotation.dart'
    show data, T, Tp, NoMixin;
import 'package:kalil_adt_annotation/kalil_adt_annotation.dart' as adt;
import 'package:app/module/base.dart';
import 'package:kalil_utils/utils.dart';

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
