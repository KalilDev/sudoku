import 'package:sudoku_presentation/errors.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PrefsState {}

class LoadingPrefsState extends PrefsState {}

class PrefsSnap extends PrefsState {
  final AvailableTheme theme;
  final AnimationOptions animationOptions;

  PrefsSnap(this.theme, this.animationOptions);

  PrefsSnap copyWith(
          {AvailableTheme theme, AnimationOptions animationOptions}) =>
      PrefsSnap(theme ?? this.theme, animationOptions ?? this.animationOptions);
}

@immutable
class PrefsErrorState extends PrefsState {
  final PrefsState previousState;
  final UserFriendly<Error> error;

  PrefsErrorState({@required this.previousState, @required this.error});
}