import 'package:bloc/bloc.dart';
import 'package:sudoku_presentation/models.dart';
import 'package:sudoku_presentation/repositories.dart';
import 'package:sudoku_presentation/errors.dart';
import 'event.dart';
import 'state.dart';

class PreferencesBloc extends Bloc<PrefsEvent, PrefsState> {
  final PreferencesRepository preferencesRepository;

  PreferencesBloc(this.preferencesRepository);

  bool closed = false;

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (closed || error is! Error) {
      // TODO
    } else {
      add(PrefsErrorEvent((error as Error).withMessage('Erro inesperado no gerenciador de preferencias.')));
    }
    super.onError(error, stackTrace);
  }

  Future<void> initialize() async {
    final themeName = await preferencesRepository.getCurrentTheme();
    final theme = parseAvailableTheme(themeName ?? '');
    final animOpts = await preferencesRepository.getAnimationOptions() ??
        AnimationOptions.defaultOptions;
    final state = PrefsSnap(theme, animOpts);
    add(PrefsLoadedEvent(state));
  }

  @override
  PrefsState get initialState {
    initialize().catchError(onError);
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
  Future<void> close() {
    closed = true;
    return super.close();
  }

  @override
  Stream<PrefsState> mapEventToState(PrefsEvent event) async* {
    if (state is! PrefsErrorState) {
      if (event is PrefsLoadedEvent) {
        yield event.state;
      }
      if (state is! PrefsSnap) {
        throw StateException("State should'be been PrefsSnap before it started being mutated!");
      }
      if (event is AnimationOptionsUpdatedEvent) {
          yield (state as PrefsSnap)
              .copyWith(animationOptions: event.animationOptions);
          updateAnim(event.animationOptions);
      }
      if (event is ThemeUpdatedEvent) {
          yield (state as PrefsSnap).copyWith(theme: event.newTheme);
          updateTheme(event.newTheme);
      }
    }
  }
}
