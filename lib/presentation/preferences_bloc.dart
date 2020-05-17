import 'package:bloc/bloc.dart';
import 'package:sudoku/presentation/repository/preferences_repository.dart';
import 'package:sudoku/presentation/sudoku_bloc/state.dart' show AnimationOptions;
import 'package:sudoku/theme.dart';

class PrefsEvent<T> {
  final T v;
  final PrefsEventType type;
  
  PrefsEvent(this.v, this.type);
}

enum PrefsEventType {
  themeUpdate,
  animUpdate,
  loadedState,
}

class PrefsState {
  final SudokuTheme theme;
  final AnimationOptions animationOptions;
  final bool isLoading;

  PrefsState.loading() : theme = null, animationOptions = null, isLoading = true;
  PrefsState(this.theme, this.animationOptions) : isLoading = false;

  PrefsState copyWith({SudokuTheme theme, AnimationOptions animationOptions}) => PrefsState(theme ?? this.theme, animationOptions ?? this.animationOptions);
}

class PreferencesBloc extends Bloc<PrefsEvent, PrefsState> {
  final PreferencesRepository preferencesRepository;

  PreferencesBloc(this.preferencesRepository);

  Future<void> initialize() async {
    final themeName = await preferencesRepository.getCurrentTheme();
    final theme = themeName != null ? SudokuTheme.parse(themeName): SudokuTheme.defaultTheme;
    final animOpts = await preferencesRepository.getAnimationOptions() ?? AnimationOptions.defaultOptions;
    final state = PrefsState(theme, animOpts);
    add(PrefsEvent<PrefsState>(state, PrefsEventType.loadedState));
  }

  @override
  PrefsState get initialState {
    initialize();
    return PrefsState.loading();
  }

  void updateTheme(AvailableTheme theme) {
    final themeName = theme.toString().split(".").last;
    preferencesRepository.updateTheme(themeName);
  }

  void updateAnim(AnimationOptions animationOptions) {
    preferencesRepository.updateAnimationOptions(animationOptions);
  }

  @override
  Stream<PrefsState> mapEventToState(PrefsEvent event) async* {
    switch (event.type) {
      case PrefsEventType.animUpdate:
        yield state.copyWith(animationOptions: event.v as AnimationOptions);
        updateAnim(event.v as AnimationOptions);
        break;
      case PrefsEventType.themeUpdate:
        yield state.copyWith(theme: SudokuTheme.availableThemeMap[event.v as AvailableTheme]);
        updateTheme(event.v as AvailableTheme);
        break;
      case PrefsEventType.loadedState: yield event.v as PrefsState; break;
    }
  }

}