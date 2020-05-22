import 'package:sudoku_core/sudoku_core.dart';
import 'package:meta/meta.dart';
import '../sudoku_configuration.dart';

abstract class MainMenuState {}

class LoadingMainMenu extends MainMenuState {}

@immutable
class MainMenuSnap extends MainMenuState {
  final BidimensionalList<SudokuConfiguration> configurations;
  final int difficultyX;
  final int sideY;

  MainMenuSnap(this.configurations, this.difficultyX, this.sideY);

  MainMenuState copyWith({
      BidimensionalList<SudokuConfiguration> configurations,
      int difficultyX,
      int sideY}) => MainMenuSnap(configurations ?? this.configurations,
      difficultyX ?? this.difficultyX, sideY ?? this.sideY);
}