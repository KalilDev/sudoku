import 'package:meta/meta.dart';
import 'state.dart';

@immutable
abstract class MainMenuEvent {}

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