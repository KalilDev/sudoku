import 'package:bloc/bloc.dart';
import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_presentation/src/repository/board_repository.dart';
import 'package:sudoku_presentation/src/repository/preferences_repository.dart';
import '../sudoku_configuration.dart';
import 'event.dart';
import 'state.dart';

class MainMenuBloc extends Bloc<MainMenuEvent, MainMenuState> {
  final BoardRepository boardRepository;
  final PreferencesRepository preferencesRepository;
  MainMenuBloc(this.boardRepository, this.preferencesRepository);

  Future<BidimensionalList<SudokuConfiguration>> loadConfigurations() async {
    final sudokuConfigurations = BidimensionalList<SudokuConfiguration>.filled(SudokuDifficulty.values.length, null, height: SudokuConfiguration.factories.length);
    for (var y = 0; y < sudokuConfigurations.height; y++) {
      final factory = SudokuConfiguration.factories[y];
      final side = SudokuConfiguration.factorySide[y];
      for (var x = 0; x < sudokuConfigurations.width; x++) {
        final difficulty = SudokuDifficulty.values[x];
        final hasSave = await boardRepository.hasConfiguration(side, difficulty);
        final configuration = factory(x, hasSave ? StateSource.storage : StateSource.random);
        sudokuConfigurations[y][x] = configuration;
      }
    }
    return sudokuConfigurations.castInner<SudokuConfiguration>();
  }

  Future<void> initialize() async {
    final sudokuConfigurations = await loadConfigurations();
    final savedX = await preferencesRepository.getMainMenuX() ?? 0;
    final savedY = await preferencesRepository.getMainMenuY() ?? 1;
    final state = MainMenuSnap(sudokuConfigurations, savedX, savedY);
    add(LoadedEvent(state));
  }

  @override
  MainMenuState get initialState {
    initialize();
    return LoadingMainMenu();
  }

  @override
  Stream<MainMenuState> mapEventToState(MainMenuEvent event) async* {
    if (event is LoadedEvent) {
      yield event.state;
    }
    if (event is ChangeX) {
      preferencesRepository.updateMainMenuX(event.x);
      yield (state as MainMenuSnap).copyWith(difficultyX: event.x);
    }
    if (event is ChangeY) {
      preferencesRepository.updateMainMenuY(event.y);
      yield (state as MainMenuSnap).copyWith(sideY: event.y);
    }
    if (event is ReloadConfigurations) {
      yield (state as MainMenuSnap).copyWith(configurations: await loadConfigurations());
    }
  }

}