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
    var handled = false;
    handled = state is PrefsErrorState;
    if (event is PrefsLoadedEvent && !handled) {
      handled = true;
      yield event.state;
    }
    if (state is! PrefsSnap && !handled) {
      throw StateException('It is impossible to handle $event while the state is not PrefsSnap').withMessage('Houve um probleminha nas preferencias');
    }
    final snap = state as PrefsSnap;
    if (event is AnimationOptionsUpdatedEvent && !handled) {
      handled = true;
      yield snap.copyWith(animationOptions: event.animationOptions);
      updateAnim(event.animationOptions);
    }
    if (event is ThemeUpdatedEvent && !handled) {
      handled = true;
      yield snap.copyWith(theme: event.newTheme);
      updateTheme(event.newTheme);
    }
    if (event is PrefsErrorEvent && !handled) {
      handled = true;
      yield PrefsErrorState.fromError(event.error, state);
    }
    if (!handled) {
      throw StateException('$event was not handled').withMessage('Houve um probleminha nas preferencias');
    }
  }
}
