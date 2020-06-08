import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:sudoku_core/sudoku_core.dart';

import 'package:sudoku_presentation/repositories.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:sudoku_presentation/errors.dart';
import 'create_sudoku/create_sudoku.dart';
import 'event.dart';
import 'state.dart';

class SudokuBloc extends Bloc<SudokuEvent, SudokuBlocState> {
  SudokuBloc({this.definition, this.repository, this.onException});
  final SudokuConfiguration definition;
  final BoardRepository repository;
  final ExceptionHandler onException;

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
      await repository.scheduleSave(definition.side, definition.difficulty, snap).withErrorMessage("Houve um erro inesperado ao salvar o Sudoku");
    }
  }

  Future<void> cleanupChunked() async {
    await chunkedSubs.cancel();
    await chunked.cancel();
    chunked = null;
    chunkedSubs = null;
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (closed || error is! Error) {
      if (onException == null) {
        debugger();
      } else {
        onException(error);
      }
    } else {
      add(SudokuErrorEvent((error as Error).withMessage('Erro inesperado no gerenciador de preferencias.')));
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
          throw StateError(status.message).withMessage("Ao tentar carregar o estado armazenado do Sudoku, o armazenamento não pode ser preparado, ao invés, ele ficou com o status ${status.type}");
        }
        state = await repository.loadSudoku(definition.side, definition.difficulty).withErrorMessage(
            "Ao tentar carregar o Sudoku armazenado, ocorreu um erro inesperado.");
        break;
      case StateSource.random:
        chunked = await genRandomSudoku(definition.side, definition.difficulty).withErrorMessage(
            "Ao tentar criar um Sudoku, ocorreu um erro inesperado.");
        chunkedSubs =
            chunked.squares.listen((square) => add(PieceLoadedEvent(square)));
        state = await chunked.onComplete;
        await cleanupChunked();
        break;
      // We will access the repository again to get which [source] we want, and
      // call [initialize] again with the desired source, which will be
      // guaranteed not to be storageIfPossible
      case StateSource.storageIfPossible:
        var status = repository.currentStatus();
        if (status.type == StorageStatusType.unawaited) {
          status = await repository.prepareStorage();
        }
        if (status.type != StorageStatusType.ready) {
          return initialize(StateSource.random);
        }
        final hasState = await repository.hasConfiguration(definition.side, definition.difficulty).withErrorMessage(
            "Ao tentar checar se há esta configuração de Sudoku no armazenamento, houve um erro inesperado");
        return initialize(hasState ? StateSource.storage : StateSource.random);
        break;
    }
    add(LoadedEvent(state));
  }

  @override
  SudokuBlocState get initialState {
    validation = BidimensionalList<Validation>.filled(
        definition.side, Validation.notValidated);

    initialize(definition.source).withErrorMessage('Erro na inicialização do sudoku', onError: onError);

    final numbers = List<NumberInfo>.generate(
        definition.side + 1, (i) => NumberInfo(number: i, isSelected: false));

    return SudokuLoadingState(
        BidimensionalList<SquareInfo>.filled(definition.side, SquareInfo.empty),
        numbers);
  }

  Future<SudokuSnapshot> genSnapshot() async {
    await null;
    final squares = BidimensionalList<SquareInfo>.generate(sudokuState.side,
        (int x, int y) {
      final isSelected = selectedSquare == null
          ? false
          : selectedSquare[0] == x && selectedSquare[1] == y;
      final initialN = sudokuState.initialState[y][x];
      final isInitial = initialN != 0;
      final number = isInitial ? initialN : sudokuState.state[y][x];
      final possibleValues = sudokuState.possibleValues[y][x].toList();
      final validation = isInitial ? Validation.correct : this.validation[y][x];
      final square = SquareInfo(
          number: number,
          isInitial: isInitial,
          possibleNumbers: possibleValues,
          isSelected: isSelected,
          validation: validation);
      return square;
    });
    final numbers = List<NumberInfo>.generate(sudokuState.side + 1,
        (i) => NumberInfo(number: i, isSelected: i == selectedNum));
    final validationState = sudokuState.validateBoard();
    final canRewind = deltas.isNotEmpty;
    final snapshot = SudokuSnapshot(
        squares: squares,
        numbers: numbers,
        canRewind: canRewind,
        markType: markType,
        validationState: validationState);
    return snapshot;
  }

  void squareMark(int n, int x, int y) {
    validation[y][x] =
        Validation.notValidated; // reset validation status for this square
    switch (markType) {
      case MarkType.possible:
        final list = sudokuState.possibleValues[y][x];
        if (n == 0) {
          if (list.isNotEmpty) {
            deltas.add(PossibleCleared(x, y, list.toList()));
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
    validation[y][x] =
        Validation.notValidated; // reset validation status for this square
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
    if (n > sudokuState.side || n < 0) {
      return;
    }
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
    if (state is SudokuSnapshot &&
        !(state as SudokuSnapshot).wasDeleted &&
        repository.currentStatus().type == StorageStatusType.ready) {
      await repository.freeSudoku(definition.side, definition.difficulty);
    }
    if (chunkedSubs != null) {
      await cleanupChunked();
    }
    closed = true;
    return super.close();
  }

  @override
  Stream<SudokuBlocState> mapEventToState(SudokuEvent event) async* {
    var handled = false;
    // Ignore events if we are in an error state. This will help me to debug.
    handled = state is SudokuErrorState;

    if (event is SudokuErrorEvent && !handled) {
      handled = true;
      yield SudokuErrorState(error: event.error, previousState: state);
    }

    if (event is LoadedEvent && !handled) {
      handled = true;
      sudokuState = event.state;
      final newSnap = await genSnapshot();
      yield newSnap;
      await scheduleSave(newSnap);
    }

    if (state is! SudokuBlocStateWithInfo && !handled) {
      throw StateException('The state needs to have info about the squares before the next events').withMessage('Houve um probleminha no sudoku');
    }

    final stateWithInfo = state as SudokuBlocStateWithInfo;

    if (event is PieceLoadedEvent && !handled) {
      handled = true;
      if (event.piece.n != 0) {
        final newSquares = stateWithInfo.squares.toList();
        final prevInfo = newSquares[event.piece.y][event.piece.x];
        newSquares[event.piece.y][event.piece.x] =
            prevInfo.copyWith(number: event.piece.n, isInitial: true);
        yield SudokuLoadingState(newSquares, stateWithInfo.numbers);
      }
    }

    if ((state is! SudokuSnapshot || sudokuState == null) && !handled) {
      throw StateException('The state needs to be an snapshot with an sudokuState before the next events').withMessage('Houve um probleminha no sudoku');
    }

    final snap = state as SudokuSnapshot;

    if (event is ActionReset && !handled) {
      handled = true;
      sudokuState.reset();
      deltas.clear();
      final newSnap = await genSnapshot();
      yield newSnap;
      await scheduleSave(newSnap);
    }
    if (event is ActionUndo && !handled) {
      handled = true;
      undo();
      final newSnap = await genSnapshot();
      yield newSnap;
      await scheduleSave(newSnap);
    }
    if (event is ActionSetMark && !handled) {
      handled = true;
      markType = event.type;
      final newSnap = await genSnapshot();
      yield newSnap;
      await scheduleSave(newSnap);
    }
    if (event is ActionValidate && !handled) {
      handled = true;
      validation = sudokuState.validateWithInfo();
      final newSnap = await genSnapshot();
      yield newSnap;
      await scheduleSave(newSnap);
    }
    if (event is SquareTap && !handled) {
      handled = true;
      squareTap(event.x, event.y);
      final newSnap = await genSnapshot();
      yield newSnap;
      await scheduleSave(newSnap);
    }
    if (event is NumberTap && !handled) {
      handled = true;
      numberTap(event.number);
      final newSnap = await genSnapshot();
      yield newSnap;
      await scheduleSave(newSnap);
    }

    if (event is DeleteSudoku && !handled) {
      handled = true;
      if (!snap.wasDeleted) {
        if (repository.currentStatus().type == StorageStatusType.ready) {
          await repository.deleteSudoku(definition.side, definition.difficulty).withErrorMessage(
              "Houve um erro inesperado ao deletar o Sudoku armazenado");
        }
      }
      yield snap.deleted();
    }
    
    if (!handled) {
      throw StateException('$event was not handled').withMessage('Houve um probleminha no sudoku');
    }
  }
}
