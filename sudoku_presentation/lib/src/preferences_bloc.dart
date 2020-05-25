import 'package:bloc/bloc.dart';
import 'package:sudoku_presentation/src/repository/preferences_repository.dart';
import 'package:sudoku_presentation/src/animation_options.dart';
import 'package:sudoku_presentation/src/theme.dart';

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

abstract class PrefsState {}

class LoadingPrefsState extends PrefsState {}

class PrefsSnap extends PrefsState {
  final AvailableTheme theme;
  final AnimationOptions animationOptions;

  PrefsSnap(this.theme, this.animationOptions);

  PrefsSnap copyWith(
          {AvailableTheme theme, AnimationOptions animationOptions}) =>
      PrefsSnap(theme ?? this.theme, animationOptions ?? this.animationOptions);
}

class PreferencesBloc extends Bloc<PrefsEvent<dynamic>, PrefsState> {
  final PreferencesRepository preferencesRepository;

  PreferencesBloc(this.preferencesRepository);

  Future<void> initialize() async {
    final themeName = await preferencesRepository.getCurrentTheme();
    final theme = parseAvailableTheme(themeName ?? '');
    final animOpts = await preferencesRepository.getAnimationOptions() ??
        AnimationOptions.defaultOptions;
    final state = PrefsSnap(theme, animOpts);
    add(PrefsEvent<PrefsSnap>(state, PrefsEventType.loadedState));
  }

  @override
  PrefsState get initialState {
    initialize();
    return LoadingPrefsState();
  }

  void updateTheme(AvailableTheme theme) {
    final themeName = theme.toString().split(".").last;
    preferencesRepository.updateTheme(themeName);
  }

  void updateAnim(AnimationOptions animationOptions) {
    preferencesRepository.updateAnimationOptions(animationOptions);
  }

  @override
  Stream<PrefsState> mapEventToState(PrefsEvent<dynamic> event) async* {
    switch (event.type) {
      case PrefsEventType.animUpdate:
        yield (state as PrefsSnap)
            .copyWith(animationOptions: event.v as AnimationOptions);
        updateAnim(event.v as AnimationOptions);
        break;
      case PrefsEventType.themeUpdate:
        yield (state as PrefsSnap).copyWith(theme: event.v as AvailableTheme);
        updateTheme(event.v as AvailableTheme);
        break;
      case PrefsEventType.loadedState:
        yield event.v as PrefsState;
        break;
    }
  }
}
