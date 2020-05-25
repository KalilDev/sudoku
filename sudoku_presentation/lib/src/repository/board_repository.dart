import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_presentation/src/sudoku_configuration.dart';
import 'package:sudoku_presentation/src/sudoku_bloc/state.dart';

enum StorageStatusType { unawaited, ready, unsupported, error }

class StorageStatus {
  const StorageStatus(this.type, this.message);
  final String message;
  final StorageStatusType type;
}

abstract class BoardRepository {
  StorageStatus currentStatus();
  Future<StorageStatus> prepareStorage();
  Future<SudokuState> loadSudoku(int side, SudokuDifficulty difficulty);
  Future<void> deleteSudoku(int side, SudokuDifficulty difficulty);
  Future<void> freeSudoku(int side, SudokuDifficulty difficulty);
  Future<void> scheduleSave(
      int side, SudokuDifficulty difficulty, SudokuSnapshot snap);
  Future<bool> hasConfiguration(int side, SudokuDifficulty difficulty);
}
