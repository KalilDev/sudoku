import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:sudoku_presentation/errors.dart';
import 'package:sudoku_presentation/repositories.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class MainMenuBloc extends Bloc<MainMenuEvent, MainMenuState> {
  final BoardRepository boardRepository;
  final PreferencesRepository preferencesRepository;
  final ExceptionHandler onException;
  MainMenuBloc({this.boardRepository, this.preferencesRepository, this.onException});
  
  bool closed = false;

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (closed || error is! Error) {
      if (onException == null) {
        debugger();
      } else {
        onException(error);
      }
    } else {
      add(MainMenuErrorEvent((error as Error).withMessage('Erro inesperado no gerenciador do menu principal.')));
    }
    return;
    super.onError(error, stackTrace);
  }

  Future<BidimensionalList<SudokuConfiguration>> loadConfigurations() async {
    final isStorageSupported =
        boardRepository.currentStatus().type == StorageStatusType.ready;

    final sudokuConfigurations = BidimensionalList<SudokuConfiguration>.filled(
        SudokuDifficulty.values.length, null,
        height: SudokuConfiguration.factories.length);

    for (var y = 0; y < sudokuConfigurations.height; y++) {
      final factory = SudokuConfiguration.factories[y];
      final side = SudokuConfiguration.factorySide[y];

      for (var x = 0; x < sudokuConfigurations.width; x++) {
        final difficulty = SudokuDifficulty.values[x];
        bool hasSave;
        if (isStorageSupported) {
          hasSave = await boardRepository.hasConfiguration(side, difficulty).withErrorMessage("Houve um erro inesperado ao checar se há um Sudoku armazenado");
        } else {
          hasSave = false;
        }
        // Error
        if (hasSave == null) {
          return null;
        }
        final configuration =
            factory(x, hasSave ? StateSource.storage : StateSource.random);
        sudokuConfigurations[y][x] = configuration;
      }
    }
    // nnbd from nullable no non-nullable
    return sudokuConfigurations.castInner<SudokuConfiguration>();
  }

  Future<int> getStoredX() => preferencesRepository.getMainMenuX().then((v) => v ?? 0).withErrorMessage("There was an error while getting the stored difficulty");

  Future<int> getStoredY() => preferencesRepository.getMainMenuY().then((v) => v ?? 1).withErrorMessage("There was an error while getting the stored side");

  Future<bool> getAknowledgement() => preferencesRepository
            .getAknowledgement()
            .ignoreError().then((value) => value ?? false);

  Future<void> didAknowledge() => preferencesRepository
        .updateAknowledgement(true)
        .ignoreError();

  Future<void> initialize() async {
    var status = boardRepository.currentStatus();
    if (status.type == StorageStatusType.unawaited) {
      status = await boardRepository.prepareStorage();
    }
    if (status.type == StorageStatusType.error) {
      throw StateError(status.message).withMessage("Houve um erro inesperado ao preparar o armazenamento do Sudoku");
    }
    var storage = StorageAknowledgment.supported;
    if (status.type == StorageStatusType.unsupported) {
      final didAknowledge = await getAknowledgement();
      storage = didAknowledge
          ? StorageAknowledgment.unsupportedAknowledged
          : StorageAknowledgment.unsupported;
    }
    final sudokuConfigurations = await loadConfigurations();
    final savedX = await getStoredX();
    final savedY = await getStoredY();
    final state = MainMenuSnap(
        configurations: sudokuConfigurations,
        difficultyX: savedX,
        sideY: savedY,
        storage: storage);
    add(LoadedEvent(state));
  }

  @override
  Future<void> close() {
    closed = true;
    return super.close();
  }

  @override
  MainMenuState get initialState {
    initialize().withErrorMessage('Houve um erro ao inicializar o menu inicial.', onError: onError);
    return LoadingMainMenu();
  }

  @override
  Stream<MainMenuState> mapEventToState(MainMenuEvent event) async* {
    var handled = false;
    // Ignore events if we are in an error state. This will help me to debug.
    handled = state is MainMenuErrorState;

    if (event is MainMenuErrorEvent) {
      handled = true;
      yield MainMenuErrorState(previousState: state, error: event.error);
    }
    if (event is LoadedEvent && !handled) {
      handled = true;
      yield event.state;
    }

    if (state is! MainMenuSnap && !handled) {
      throw StateException('It is impossible to handle $event while the state is not PrefsSnap').withErrorMessage('Houve um probleminha no menu principal');
    }

    final snap = handled ? null : state as MainMenuSnap;
    
    if (event is ChangeX && !handled) {
      handled = true;
      await preferencesRepository.updateMainMenuX(event.x);
      yield snap.copyWith(difficultyX: event.x);
    }
    if (event is ChangeY && !handled) {
      handled = true;
      await preferencesRepository.updateMainMenuY(event.y);
      yield snap.copyWith(sideY: event.y);
    }
    if (event is ReloadConfigurations && !handled) {
      handled = true;
      yield snap.copyWith(configurations: await loadConfigurations());
    }
    if (event is AknowledgeStorageEvent && !handled) {
      handled = true;
      await didAknowledge();
      yield snap
          .copyWith(storage: StorageAknowledgment.unsupportedAknowledged);
    }
    if (!handled) {
      throw StateException('$event was not handled').withErrorMessage('Houve um probleminha no menu principal');
    }
  }
}
