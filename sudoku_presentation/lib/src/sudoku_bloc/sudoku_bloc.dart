
import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_presentation/src/repository/board_repository.dart';

import '../sudoku_configuration.dart';
import 'create_sudoku/create_sudoku.dart';
import 'event.dart';
import 'state.dart';

class SudokuBloc extends Bloc<SudokuEvent, SudokuBlocState> {
  SudokuBloc(this.definition, this.repository);
  final SudokuConfiguration definition;
  final BoardRepository repository;

  final Queue<SquareDelta> deltas = DoubleLinkedQueue();
  List<int> selectedSquare; // [x, y] or null in case none
  int selectedNum; // number or null
  SudokuState sudokuState; // will be the same across the lifetime of this bloc
  MarkType markType = MarkType.concrete;
  BidimensionalList<Validation> validation;
  ChunkedSudoku chunked;
  StreamSubscription<ChunkedSudokuSquare> chunkedSubs;
  bool closed = false;

  Future<void> scheduleSave(SudokuSnapshot snap) async {
    if (repository.currentStatus().type == StorageStatusType.ready) {
      //debugger();
      await catchFuture(repository.scheduleSave(definition.side, definition.difficulty, snap), "Houve um erro inesperado ao salvar o Sudoku");
    }
  }
  
  Future<T> catchFuture<T>(Future<T> future, String userFriendlyMessage) => future.catchError((dynamic e){
    emitError(msg: e.toString(), userFriendlyMsg: userFriendlyMessage);
    return null;
  });

  void emitError({String msg, String userFriendlyMsg}) => add(SudokuErrorEvent(SudokuErrorState(
          message: msg,
          userFriendlyMessage: userFriendlyMsg
        )));
  
  @override
  void onError(Object error, StackTrace stackTrace) {
    if (closed) {
      print(error.toString());
    } else {
      emitError(msg: error.toString(), userFriendlyMsg: "Houve um erro inesperado, o desenvolvedor é burro");
    }
    super.onError(error, stackTrace);
  }

  Future<void> initialize(StateSource source) async {
    SudokuState state;
    switch (source) {
      case StateSource.storage:
        var status = repository.currentStatus();
        if (status.type == StorageStatusType.unawaited) {
          status = await repository.prepareStorage();
        }
        if (status.type != StorageStatusType.ready) {
          emitError(msg: status.message, userFriendlyMsg: "Ao tentar carregar o estado armazenado do Sudoku, o armazenamento não pode ser preparado, ao invés, ele ficou com o status ${status.type}");
          return;
        }
        state = await catchFuture(repository.loadSudoku(definition.side, definition.difficulty), "Ao tentar carregar o Sudoku armazenado, ocorreu um erro inesperado.");
        break;
      case StateSource.random:
        chunked = await catchFuture(genRandomSudoku(definition.side, definition.difficulty), "Ao tentar criar um Sudoku, ocorreu um erro inesperado.");
        chunkedSubs = chunked.squares.listen((square) => add(PieceLoadedEvent(square)));
        state = await chunked.onComplete;
        await chunkedSubs.cancel();
        await chunked.cancel();
        chunked = null;
        chunkedSubs = null;
        break;
      case StateSource.storageIfPossible:
        var status = repository.currentStatus();
        if (status.type == StorageStatusType.unawaited) {
          status = await repository.prepareStorage();
        }
        if (status.type != StorageStatusType.ready) {
          return initialize(StateSource.random);
        }
        final hasState = await catchFuture(repository.hasConfiguration(definition.side, definition.difficulty), "Ao tentar checar se há esta configuração de Sudoku no armazenamento, houve um erro inesperado");
        // Error
        if (hasState == null) {
          return;
        }
        return initialize(hasState ? StateSource.storage : StateSource.random);
      break;
    }
    // State is only null in case errors happened
    if (state != null) {
      add(LoadedEvent(state));
    }
  }

  @override
  SudokuBlocState get initialState {
    validation = BidimensionalList<Validation>.filled(definition.side, Validation.notValidated);
    initialize(definition.source).catchError(onError);
    final numbers = List<NumberInfo>.generate(definition.side + 1, (i) => NumberInfo(number: i, isSelected: false));
    return SudokuLoadingState(BidimensionalList<SquareInfo>.filled(definition.side, SquareInfo.empty), numbers);
  }

  Future<SudokuSnapshot> genSnapshot() async {
    await null;
    final squares = BidimensionalList<SquareInfo>.generate(sudokuState.side, (int x, int y) {
        final isSelected = selectedSquare == null ? false : selectedSquare[0] == x && selectedSquare[1] == y; 
        final initialN = sudokuState.initialState[y][x];
        final isInitial = initialN != 0;
        final number = isInitial ? initialN : sudokuState.state[y][x];
        final possibleValues = sudokuState.possibleValues[y][x].toList();
        final validation = isInitial ? Validation.correct : this.validation[y][x];
        final square = SquareInfo(number: number, isInitial: isInitial,possibleNumbers: possibleValues, isSelected: isSelected, validation: validation);
        return square;
    });
    final numbers = List<NumberInfo>.generate(sudokuState.side + 1, (i) => NumberInfo(number: i, isSelected: i == selectedNum));
    final validationState = sudokuState.validateBoard();
    final canRewind = deltas.isNotEmpty;
    final snapshot = SudokuSnapshot(squares: squares, numbers: numbers, canRewind: canRewind, markType: markType, validationState: validationState);
    return snapshot;
  }

  void squareMark(int n, int x, int y) {
    validation[y][x] = Validation.notValidated; // reset validation status for this square
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
    validation[y][x] = Validation.notValidated; // reset validation status for this square
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
    if (state is SudokuSnapshot && !(state as SudokuSnapshot).wasDeleted && repository.currentStatus().type == StorageStatusType.ready) {
      await repository.freeSudoku(definition.side, definition.difficulty);
    }
    await chunkedSubs?.cancel();
    await chunked?.cancel();
    closed = true;
    return super.close();
  }

  @override
  Stream<SudokuBlocState> mapEventToState(SudokuEvent event) async* {
    if (state is! SudokuErrorState && !closed) {
      if (event is LoadedEvent) {
        sudokuState = event.state;
      }
      if (sudokuState != null) {
        if (event is ActionReset) {
          sudokuState.reset();
          deltas.clear();
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
      }
      if (event is PieceLoadedEvent) {
        if (event.piece.n != 0) {
          final currentState = state as SudokuBlocStateWithInfo;
          final newSquares = currentState.squares.toList();
          final prevInfo = newSquares[event.piece.y][event.piece.x];
          newSquares[event.piece.y][event.piece.x] = prevInfo.copyWith(number: event.piece.n, isInitial: true);
          yield SudokuLoadingState(newSquares, currentState.numbers);
        }
      } else if (event is DeleteSudoku) {
        if (!(state as SudokuSnapshot).wasDeleted) {
          if (repository.currentStatus().type == StorageStatusType.ready) {
            await catchFuture(repository.deleteSudoku(definition.side, definition.difficulty), "Houve um erro inesperado ao deletar o Sudoku armazenado");
          }
          yield (state as SudokuSnapshot).deleted();
        }
      } else if (event is SudokuErrorEvent) {
        yield event.state;
      } else {
        final snapshot = await catchFuture(genSnapshot(), "Houve um erro inesperado ao gerar o estado atual do Sudoku");
        // only null on error
        if (snapshot != null) {
          yield snapshot;
          await scheduleSave(snapshot);
        }
      }
    }
  }
}