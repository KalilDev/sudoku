import 'package:bloc/bloc.dart';
import 'package:sudoku/core/bidimensional_list.dart';
import 'package:sudoku/presentation/main_menu_bloc/bloc.dart';
import 'package:sudoku/presentation/repository/board_repository.dart';
import 'package:sudoku/presentation/repository/preferences_repository.dart';
import '../common.dart';
import 'event.dart';
import 'state.dart';

class MainMenuBloc extends Bloc<MainMenuEvent, MainMenuState> {
  final BoardRepository boardRepository;
  final PreferencesRepository preferencesRepository;
  MainMenuBloc(this.boardRepository, this.preferencesRepository);

  Future<BidimensionalList<SudokuConfiguration>> loadConfigurations() async {
    final sudokuConfigurations = BidimensionalList<SudokuConfiguration>(SudokuDifficulty.values.length, height: SudokuConfiguration.factories.length);
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
    return sudokuConfigurations;
  }

  Future<void> initialize() async {
    final sudokuConfigurations = await loadConfigurations();
    final savedX = await preferencesRepository.getMainMenuX() ?? 0;
    final savedY = await preferencesRepository.getMainMenuY() ?? 1;
    final state = MainMenuState(sudokuConfigurations, savedX, savedY);
    add(LoadedEvent(state));
  }

  @override
  MainMenuState get initialState {
    initialize();
    return MainMenuState.loading();
  }

  @override
  Stream<MainMenuState> mapEventToState(MainMenuEvent event) async* {
    if (event is LoadedEvent) {
      yield event.state;
    }
    if (event is ChangeX) {
      preferencesRepository.updateMainMenuX(event.x);
      yield state.copyWith(difficultyX: event.x);
    }
    if (event is ChangeY) {
      preferencesRepository.updateMainMenuY(event.y);
      yield state.copyWith(sideY: event.y);
    }
    if (event is ReloadConfigurations) {
      yield state.copyWith(configurations: await loadConfigurations());
    }
  }

}