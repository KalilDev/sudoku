export 'old_sudoku.dart' if (dart.library.ffi) 'ffi.dart'
    show
        ExternSudokuBoard,
        externSudokuBoardFrom,
        emptyExternSudokuBoard,
        cloneExternSudokuBoard,
        externSudokuBoardGetAt,
        externSudokuBoardSetAt,
        externSudokuSide,
        sudokuBoardFromExtern,
        generateExternSudokuBlocking,
        solveExternSudokuBlocking,
        externSudokuHasOneSolBlocking,
        externSudokuFree;
