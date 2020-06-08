import 'package:meta/meta.dart';
import 'package:sudoku_presentation/errors.dart';
import 'state.dart';

@immutable
abstract class MainMenuEvent {}

class MainMenuErrorEvent extends MainMenuEvent {
  final UserFriendly<Error> error;

  MainMenuErrorEvent(this.error);
}

class AknowledgeStorageEvent extends MainMenuEvent {}

class LoadedEvent extends MainMenuEvent {
  final MainMenuState state;

  LoadedEvent(this.state);
}

class ChangeX extends MainMenuEvent {
  final int x;

  ChangeX(this.x);
}

class ChangeY extends MainMenuEvent {
  final int y;

  ChangeY(this.y);
}

class ReloadConfigurations extends MainMenuEvent {}
