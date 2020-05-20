import 'package:sudoku_presentation/src/animation_options.dart';
import 'package:sudoku_presentation/src/sudoku_configuration.dart';
import 'package:sudoku_presentation/src/sudoku_bloc/state.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'board_repository.dart';
import 'preferences_repository.dart';

class MockBoardRepository extends BoardRepository {
  @override
  Future<bool> hasConfiguration(int side, SudokuDifficulty difficulty) => Future.value(false);
  
  @override
  Future<SudokuState> loadSudoku(int side, SudokuDifficulty difficulty) => throw UnimplementedError();
  
  @override
  Future<void> scheduleSave(int side, SudokuDifficulty difficulty, SudokuSnapshot snap) => Future.value(null);

  @override
  Future<void> deleteSudoku(int side, SudokuDifficulty difficulty) => Future.value(null);
  
  @override
  Future<void> freeSudoku(int side, SudokuDifficulty difficulty) => Future.value(null);
}

class MockPreferencesRepository extends PreferencesRepository {
  @override
  Future<String> getCurrentTheme() => Future.value("darkGreen");

  @override
  Future<void> updateTheme(String theme) => Future.value(null);

  @override
  Future<AnimationOptions> getAnimationOptions() => Future.value(AnimationOptions.defaultOptions);

  @override
  Future<void> updateAnimationOptions(AnimationOptions options) => Future.value(null);

  @override
  Future<int> getMainMenuX() => Future.value(3);

  @override
  Future<int> getMainMenuY() => Future.value(1);

  @override
  Future<void> updateMainMenuX(int x) => Future.value(null);
  
  @override
  Future<void> updateMainMenuY(int x) => Future.value(null);
}