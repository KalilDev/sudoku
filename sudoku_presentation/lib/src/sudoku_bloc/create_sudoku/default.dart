import 'dart:async';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_presentation/models.dart';

Future<ChunkedSudoku> genRandomSudoku(int side, SudokuDifficulty difficulty, NextFrameProvider frameProvider) =>
    Future.value(chunkedCreateRandomSudoku(
        side: side, maskRate: difficultyMaskMap[difficulty], frameProvider: frameProvider));
