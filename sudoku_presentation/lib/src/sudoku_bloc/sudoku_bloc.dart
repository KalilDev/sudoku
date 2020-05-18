import 'package:flutter/foundation.dart';
import 'package:sudoku/core/bidimensional_list.dart';
import 'package:sudoku/core/sudokuGenCppPort.dart';

import 'package:sudoku/core/sudoku_state.dart';
import 'package:sudoku/core/creator.dart';
import 'package:sudoku/presentation/repository/preferences_repository.dart';
import 'state.dart';
import 'event.dart';
import 'package:bloc/bloc.dart';
import 'package:sudoku/presentation/repository/board_repository.dart';
import '../common.dart';

class _IsolateSudokuParams {
  final int side;
  final double mask;
  final int errorCount;
  _IsolateSudokuParams incError() => _IsolateSudokuParams._(side, mask, errorCount + 1);

  _IsolateSudokuParams(this.side, this.mask) : errorCount = 0;
  _IsolateSudokuParams._(this.side, this.mask, this.errorCount);
}

List<int> isolateCreateSudoku(_IsolateSudokuParams param) {
  try {
    if (param.side == 9) {
      print("using the gud algorythim");
      return quickAndDartyGen(mask_rate: param.mask).flat(false);
    }
    return createRandomSudoku(maskRate: param.mask, side: param.side, maxTry: 1000*10).flat(false);
  } catch (e) {
    if (param.errorCount >= 10) {
      return null;
    }
    return isolateCreateSudoku(param.incError());
  }
}

Future<SudokuState> genRandomSudoku(int side, SudokuDifficulty difficulty, [int tryCount = 0]) async {
  await null;
  if (tryCount >= 1)
    throw StateError("Couldnt create board");
  final initialVals = await compute<_IsolateSudokuParams, List<int>>(isolateCreateSudoku, _IsolateSudokuParams(side, difficultyMaskMap[difficulty]));
  final initialState = BidimensionalList<int>.view(initialVals, side);
  final state = SudokuState.uint8list(side: side, initialState: initialState);
  return state;
}

class SudokuBloc extends Bloc<SudokuEvent, SudokuSnapshot> {
  SudokuBloc(this.definition, this.repository);
  final SudokuConfiguration definition;
  final BoardRepository repository;

  List<int> selectedSquare; // [x, y] or null in case none
  int selectedNum; // number or null
  SudokuState sudokuState; // will be the same across the lifetime of this bloc
  MarkType markType = MarkType.concrete;
  BidimensionalList<bool> validation;

  Future<void> scheduleSave(SudokuSnapshot snap) => repository.scheduleSave(definition.side, definition.difficulty, snap);
  Future<void> initialize() async {
    Future<SudokuState> futureState;
    switch (definition.source) {
      case StateSource.storage: futureState = repository.loadSudoku(definition.side, definition.difficulty);break;
      case StateSource.random: futureState = genRandomSudoku(definition.side, definition.difficulty); break;
    }
    final state = await futureState;
    add(LoadedEvent(state));
  }

  @override
  SudokuSnapshot get initialState {
    initialize();
    return SudokuSnapshot.loading();
  }

  Future<SudokuSnapshot> genSnapshot() async {
    await null;
    final squares = BidimensionalList<SquareInfo>(sudokuState.side);
    for (var x = 0; x < sudokuState.side; x++) {
      for (var y = 0; y < sudokuState.side; y++) {
        final isSelected = selectedSquare == null ? false : selectedSquare[0] == x && selectedSquare[1] == y; 
        final initialN = sudokuState.initialState != null ? sudokuState.initialState[y][x] : null;
        final isInitial = initialN != 0 && initialN != null;
        final number = isInitial ? initialN : sudokuState.state[y][x];
        final possibleValues = sudokuState.possibleValues == null ? null : sudokuState.possibleValues[y][x]?.toList();
        final isValid = validation == null || number == 0 || number == null ? null : isInitial ? true : validation[y][x];
        final square = SquareInfo(number: number, isInitial: isInitial,possibleNumbers: possibleValues, isSelected: isSelected, isValid: isValid);
        squares[y][x] = square;
      }
      await null;
    }
    final numbers = List<NumberInfo>(sudokuState.side + 1);
    for (var i = 0; i < sudokuState.side + 1; i++) {
      final number = NumberInfo(number: i, isSelected: i == selectedNum);
      numbers[i] = number;
    }
    final validationState = sudokuState.validateBoard();
    final snapshot = SudokuSnapshot(squares: squares, numbers: numbers, canRewind: false, markType: markType, validationState: validationState);
    return snapshot;
  }

  void squareMark(int n, int x, int y) {
  if (validation != null) {
    validation[y][x] = null; // reset validation status for this square
  }
  sudokuState.possibleValues ??= BidimensionalList<List<int>>(sudokuState.side);
  switch (markType) {
      case MarkType.possible:
        sudokuState.possibleValues[y][x] ??= <int>[];
        final list = sudokuState.possibleValues[y][x];
        if (list.contains(n)) {
          list.remove(n);
        } else {
          list.add(n);
        }
        sudokuState[y][x] = 0;
        break;
      case MarkType.concrete:
        if (sudokuState[y][x] == n) {
          sudokuState[y][x] = 0;
        } else {
          sudokuState[y][x] = n;
        }
        sudokuState.possibleValues[y][x]?.clear();
        break;
    }
  }

  void squareTap(int x, int y) {
    if (validation != null) {
      validation[y][x] = null; // reset validation status for this square
    }
    final info = state.squares[y][x];
    if (info.isSelected) {
      // deselect
      selectedSquare = null;
      return;
    }
    if (info.isInitial) {
      return;
    }
    if (selectedNum != null) {
      // set this num to the selected num
      squareMark(selectedNum, x, y);
    } else {
      // select this square
      selectedSquare = [x, y];
    }
  }

  void numberTap(int n) {
    if (n != selectedNum) {
      selectedNum = n;
    } else {
      selectedNum = null;
    }
    if (selectedSquare != null) {
      squareMark(n, selectedSquare[0], selectedSquare[1]);
      selectedNum = null;
    }
  }
  @override
  Future<void> close() async {
    if (state.validationState == Validation.valid) {
      await repository.deleteSudoku(definition.side, definition.difficulty);
    }
    repository.freeSudoku(definition.side, definition.difficulty);
    return super.close();
  }

  @override
  Stream<SudokuSnapshot> mapEventToState(SudokuEvent event) async* {
    if (event is LoadedEvent) {
      sudokuState = event.state;
    }
    if (event is ActionReset) {
      sudokuState.reset();
    }
    if (event is ActionUndo) {
      // todo
    }
    if (event is ActionSetMark) {
      markType = event.type;
    }
    if (event is ActionValidate) {
      validation = sudokuState.validateWithInfo();
    }
    if (event is SquareTap) {
      squareTap(event.x, event.y);
    }
    if (event is NumberTap) {
      numberTap(event.number);
    }
    final snapshot = await genSnapshot();
    yield snapshot;
    scheduleSave(snapshot);
  }
}