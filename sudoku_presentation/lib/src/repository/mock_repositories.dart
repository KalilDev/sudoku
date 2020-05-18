import 'package:sudoku/presentation/sudoku_bloc/state.dart';

import 'package:sudoku/presentation/common.dart';

import 'package:sudoku/core/sudoku_state.dart';

import 'board_repository.dart';
import 'preferences_repository.dart';

class MockBoardRepository extends BoardRepository {
  @override
  Future<bool> hasConfiguration(int side, SudokuDifficulty difficulty) => Future.value(false);
  
  @override
  Future<SudokuState> loadSudoku(int side, SudokuDifficulty difficulty) => throw UnimplementedError();
  
  @override
  Future<void> scheduleSave(int side, SudokuDifficulty difficulty, SudokuSnapshot snap) => null;

  @override
  Future<void> deleteSudoku(int side, SudokuDifficulty difficulty) => null;
  
  @override
  Future<void> freeSudoku(int side, SudokuDifficulty difficulty) => null;
}

class MockPreferencesRepository extends PreferencesRepository {
  @override
  Future<String> getCurrentTheme() => Future.value("darkGreen");

  @override
  Future<void> updateTheme(String theme) => null;

  @override
  Future<AnimationOptions> getAnimationOptions() => Future.value(AnimationOptions.defaultOptions);

  @override
  Future<void> updateAnimationOptions(AnimationOptions options) => null;

  @override
  Future<int> getMainMenuX() => Future.value(3);

  @override
  Future<int> getMainMenuY() => Future.value(1);

  @override
  Future<void> updateMainMenuX(int x) => null;
  
  @override
  Future<void> updateMainMenuY(int x) => null;
}