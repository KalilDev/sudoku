import 'dart:async';
import 'dart:isolate';
import 'package:sudoku_core/sudoku_core.dart';
import '../../sudoku_configuration.dart';

Future<ChunkedSudoku> genRandomSudoku(int side, SudokuDifficulty difficulty) => Future.value(chunkedCreateRandomSudoku(side: side, maskRate: difficultyMaskMap[difficulty]));