import 'package:sudoku_presentation/errors.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:meta/meta.dart';

import 'state.dart';

@immutable
abstract class PrefsEvent {}

class PrefsLoadedEvent extends PrefsEvent{
  final PrefsSnap state;

  PrefsLoadedEvent(this.state);
}

class ThemeUpdatedEvent extends PrefsEvent {
  final AvailableTheme newTheme;

  ThemeUpdatedEvent(this.newTheme);
}

class AnimationOptionsUpdatedEvent extends PrefsEvent {
  final AnimationOptions animationOptions;

  AnimationOptionsUpdatedEvent(this.animationOptions);
}

class PrefsErrorEvent extends PrefsEvent {
  final UserFriendly<Error> error;

  PrefsErrorEvent(this.error);
}
