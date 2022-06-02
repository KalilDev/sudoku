import 'package:app/module/animation.dart';
import 'package:app/module/theme.dart';
import 'package:utils/utils.dart';

typedef PreferencesDialogAnimationResult = AnimationOptions;
typedef PreferencesDialogThemeResult = TupleN2<int, List<SudokuSeededTheme>>;
typedef PreferencesDialogResult
    = TupleN2<PreferencesDialogThemeResult, PreferencesDialogAnimationResult>;
