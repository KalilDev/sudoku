import 'package:sudoku/core/sudoku_state.dart';
import 'package:sudoku/presentation/sudoku_bloc/state.dart';
import '../common.dart';

abstract class BoardRepository {
  Future<SudokuState> loadSudoku(int side, SudokuDifficulty difficulty);
  Future<void> deleteSudoku(int side, SudokuDifficulty difficulty);
  Future<void> freeSudoku(int side, SudokuDifficulty difficulty);
  Future<void> scheduleSave(int side, SudokuDifficulty difficulty, SudokuSnapshot snap);
  Future<bool> hasConfiguration(int side, SudokuDifficulty difficulty);
}