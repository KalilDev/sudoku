import 'package:sudoku/core/bidimensional_list.dart';
import 'package:meta/meta.dart';
import '../common.dart';

@immutable
class MainMenuState {
  final BidimensionalList<SudokuConfiguration> configurations;
  final int difficultyX;
  final int sideY;
  final bool isLoading;

  MainMenuState(this.configurations, this.difficultyX, this.sideY) : isLoading = false;
  MainMenuState.loading() : isLoading = true, configurations = null, difficultyX = null, sideY = null;

  MainMenuState copyWith({
      BidimensionalList<SudokuConfiguration> configurations,
      int difficultyX,
      int sideY}) => MainMenuState(configurations ?? this.configurations,
      difficultyX ?? this.difficultyX, sideY ?? this.sideY);
}