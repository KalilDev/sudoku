import 'package:meta/meta.dart';
import 'state.dart';

@immutable
abstract class MainMenuEvent {}

class MainMenuErrorEvent extends MainMenuEvent {
  final MainMenuErrorState state;

  MainMenuErrorEvent(this.state);
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
