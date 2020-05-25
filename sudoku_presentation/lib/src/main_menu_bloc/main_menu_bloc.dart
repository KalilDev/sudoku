import 'package:bloc/bloc.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_presentation/src/repository/board_repository.dart';
import 'package:sudoku_presentation/src/repository/preferences_repository.dart';
import '../sudoku_configuration.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class MainMenuBloc extends Bloc<MainMenuEvent, MainMenuState> {
  final BoardRepository boardRepository;
  final PreferencesRepository preferencesRepository;
  MainMenuBloc(this.boardRepository, this.preferencesRepository);

  Future<T> catchFuture<T>(Future<T> future, String userFriendlyMessage) => future.catchError((dynamic e){
    emitError(msg: e.toString(), userFriendlyMsg: userFriendlyMessage);
    return null;
  });

  void emitError({String msg, String userFriendlyMsg}) => add(MainMenuErrorEvent(MainMenuErrorState(
          message: msg,
          userFriendlyMessage: userFriendlyMsg
        )));
  
  @override
  void onError(Object error, StackTrace stackTrace) {
    emitError(msg: error.toString(), userFriendlyMsg: "Houve um erro inesperado, o desenvolvedor é burro");
    super.onError(error, stackTrace);
  }

  Future<BidimensionalList<SudokuConfiguration>> loadConfigurations() async {
    final isStorageSupported = boardRepository.currentStatus().type == StorageStatusType.ready;
    final sudokuConfigurations = BidimensionalList<SudokuConfiguration>.filled(SudokuDifficulty.values.length, null, height: SudokuConfiguration.factories.length);
    for (var y = 0; y < sudokuConfigurations.height; y++) {
      final factory = SudokuConfiguration.factories[y];
      final side = SudokuConfiguration.factorySide[y];
      for (var x = 0; x < sudokuConfigurations.width; x++) {
        final difficulty = SudokuDifficulty.values[x];
        bool hasSave;
        if (isStorageSupported) {
          hasSave = await catchFuture(boardRepository.hasConfiguration(side, difficulty), "Houve um erro inesperado ao checar se há um Sudoku armazenado");
        } else {
          hasSave = false;
        }
        // Error
        if (hasSave == null) {
          return null;
        }
        final configuration = factory(x, hasSave ? StateSource.storage : StateSource.random);
        sudokuConfigurations[y][x] = configuration;
      }
    }
    // nnbd from nullable no non-nullable
    return sudokuConfigurations.castInner<SudokuConfiguration>();
  }

  Future<int> getStoredX() async {
    return catchFuture(preferencesRepository.getMainMenuX().then((v) => v ?? 0), "There was an error while getting the stored difficulty");
  }

  Future<int> getStoredY() async {
    return catchFuture(preferencesRepository.getMainMenuY().then((v) => v ?? 1), "There was an error while getting the stored side");
  }

  Future<bool> getAknowledgement() async {
    return await preferencesRepository.getAknowledgement().catchError((dynamic e) => false) ?? false;
  }

  Future<void> didAknowledge() async {
    return preferencesRepository.updateAknowledgement(true).catchError((dynamic e) => null);
  }

  Future<void> initialize() async {
    var status = boardRepository.currentStatus();
    if (status.type == StorageStatusType.unawaited) {
      status = await boardRepository.prepareStorage();
    }
    if (status.type == StorageStatusType.error) {
      emitError(msg: status.message, userFriendlyMsg: "Houve um erro inesperado ao preparar o armazenamento do Sudoku");
      return;
    }
    var storage = StorageAknowledgment.supported;
    if (status.type == StorageStatusType.unsupported) {
      final didAknowledge = await getAknowledgement();
      storage = didAknowledge ? StorageAknowledgment.unsupportedAknowledged : StorageAknowledgment.unsupported;
    }
    final sudokuConfigurations = await loadConfigurations();
    // Error
    if (sudokuConfigurations == null) {
      return;
    }
    final savedX = await getStoredX();
    // Error
    if (savedX == null) {
      return;
    }
    final savedY = await getStoredY();
    // Error
    if (savedY == null) {
      return;
    }
    final state = MainMenuSnap(configurations: sudokuConfigurations, difficultyX: savedX, sideY: savedY, storage: storage);
    add(LoadedEvent(state));
  }

  @override
  MainMenuState get initialState {
    initialize().catchError(onError);
    return LoadingMainMenu();
  }

  @override
  Stream<MainMenuState> mapEventToState(MainMenuEvent event) async* {
    if (event is LoadedEvent) {
      yield event.state;
    }
    if (event is ChangeX) {
      await preferencesRepository.updateMainMenuX(event.x);
      yield (state as MainMenuSnap).copyWith(difficultyX: event.x);
    }
    if (event is ChangeY) {
      await preferencesRepository.updateMainMenuY(event.y);
      yield (state as MainMenuSnap).copyWith(sideY: event.y);
    }
    if (event is ReloadConfigurations) {
      yield (state as MainMenuSnap).copyWith(configurations: await loadConfigurations());
    }
    if (event is MainMenuErrorEvent) {
      yield event.state;
    }
    if (event is AknowledgeStorageEvent) {
      await didAknowledge();
      yield (state as MainMenuSnap).copyWith(storage: StorageAknowledgment.unsupportedAknowledged);
    }
  }

}