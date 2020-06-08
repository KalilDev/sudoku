import 'package:sudoku_core/sudoku_core.dart';
import 'package:meta/meta.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:sudoku_presentation/errors.dart';

@immutable
abstract class MainMenuState {}

class LoadingMainMenu extends MainMenuState {}

enum StorageAknowledgment { supported, unsupported, unsupportedAknowledged }

class MainMenuSnap extends MainMenuState {
  final BidimensionalList<SudokuConfiguration> configurations;
  final int difficultyX;
  final int sideY;
  final StorageAknowledgment storage;

  MainMenuSnap(
      {this.configurations, this.difficultyX, this.sideY, this.storage});

  MainMenuState copyWith(
          {BidimensionalList<SudokuConfiguration> configurations,
          int difficultyX,
          int sideY,
          StorageAknowledgment storage}) =>
      MainMenuSnap(
          configurations: configurations ?? this.configurations,
          difficultyX: difficultyX ?? this.difficultyX,
          sideY: sideY ?? this.sideY,
          storage: storage ?? this.storage);
}

class MainMenuErrorState extends  MainMenuState {
  final MainMenuState previousState;
  final UserFriendly<Error> error;

  MainMenuErrorState({this.previousState, this.error});
}
