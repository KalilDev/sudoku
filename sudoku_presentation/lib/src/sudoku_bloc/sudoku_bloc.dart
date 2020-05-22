
import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_presentation/src/repository/board_repository.dart';
import 'state.dart';
import 'event.dart';
import 'package:bloc/bloc.dart';
import '../sudoku_configuration.dart';
import 'create_sudoku.dart';

class SudokuBloc extends Bloc<SudokuEvent, SudokuBlocState> {
  SudokuBloc(this.definition, this.repository, [this.computeImpl]);
  final SudokuConfiguration definition;
  final BoardRepository repository;
  final ComputeImpl computeImpl;

  final Queue<SquareDelta> deltas = DoubleLinkedQueue();
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
      case StateSource.random: futureState = genRandomSudoku(definition.side, definition.difficulty, compute: computeImpl); break;
    }
    final state = await futureState;
    add(LoadedEvent(state));
  }

  @override
  SudokuBlocState get initialState {
    validation = BidimensionalList.filled(definition.side, true);
    initialize();
    return SudokuLoadingState();
  }

  Future<SudokuSnapshot> genSnapshot() async {
    await null;
    final squares = BidimensionalList<SquareInfo>.generate(sudokuState.side, (int x, int y) {
        final isSelected = selectedSquare == null ? false : selectedSquare[0] == x && selectedSquare[1] == y; 
        final initialN = sudokuState.initialState[y][x];
        final isInitial = initialN != 0;
        final number = isInitial ? initialN : sudokuState.state[y][x];
        final possibleValues = sudokuState.possibleValues[y][x].toList();
        final isValid = isInitial ? true : validation[y][x];
        final square = SquareInfo(number: number, isInitial: isInitial,possibleNumbers: possibleValues, isSelected: isSelected, isValid: isValid);
        return square;
    });
    final numbers = List<NumberInfo>.generate(sudokuState.side + 1, (i) => NumberInfo(number: i, isSelected: i == selectedNum));
    final validationState = sudokuState.validateBoard();
    final canRewind = deltas.isNotEmpty;
    final snapshot = SudokuSnapshot(squares: squares, numbers: numbers, canRewind: canRewind, markType: markType, validationState: validationState);
    return snapshot;
  }

  void squareMark(int n, int x, int y) {
    validation[y][x] = true; // reset validation status for this square
    switch (markType) {
        case MarkType.possible:
          final list = sudokuState.possibleValues[y][x];
          if (n == 0) {
            if (list.isNotEmpty) {
              deltas.add(PossibleCleared(x,y,list.toList()));
              list.clear();
            }
          } else if (list.contains(n)) {
            deltas.add(PossibleRemoved(x, y, n));
            list.remove(n);
          } else {
            deltas.add(PossibleAdded(x, y, n));
            list.add(n);
          }
          final currentNum = sudokuState[y][x];
          if (currentNum != 0) {
            deltas.add(NumChanged(x, y, currentNum));
            sudokuState[y][x] = 0;
          }
          break;
        case MarkType.concrete:
          final possible = sudokuState.possibleValues[y][x];
          final current = sudokuState[y][x];
          if (current == 0) {
            deltas.add(PossibleCleared(x, y, possible.toList()));
            possible.clear();
            sudokuState[y][x] = n;
          } else {
            final next = current == n ? 0 : n;
            sudokuState[y][x] = next;
            deltas.add(NumChanged(x, y, current));
          }
          break;
    }
  }

  void squareTap(int x, int y) {
    validation[y][x] = true; // reset validation status for this square
    final snap = state as SudokuSnapshot;
    final info = snap.squares[y][x];
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

  void undo() {
    if (deltas.isEmpty) {
      return;
    }
    final delta = deltas.removeLast();
    final x = delta.x;
    final y = delta.y;
    final currentPossible = sudokuState.possibleValues[y][x];
    if (delta is PossibleAdded) {
      currentPossible.remove(delta.number);
    }
    if (delta is PossibleRemoved) {
      currentPossible.add(delta.number);
    }
    if (delta is NumChanged) {
      sudokuState[y][x] = delta.number;
    }
    if (delta is PossibleCleared) {
      sudokuState[y][x] = 0;
      sudokuState.possibleValues[y][x] = delta.possibleValues;
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
    if (state is SudokuSnapshot && ! (state as SudokuSnapshot).wasDeleted) {
      await repository.freeSudoku(definition.side, definition.difficulty);
    }
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
      undo();
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
    if (event is DeleteSudoku) {
      if (!(state as SudokuSnapshot).wasDeleted) {
        repository.deleteSudoku(definition.side, definition.difficulty);
        yield (state as SudokuSnapshot).deleted();
      }
    } else {
      final snapshot = await genSnapshot();
      //debugger();
      yield snapshot;
      scheduleSave(snapshot);
    }
  }
}