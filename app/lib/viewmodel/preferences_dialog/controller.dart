import 'package:app/module/animation.dart';
import 'package:app/module/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import 'data.dart';

class PreferencesDialogThemeController extends SubcontrollerBase<
    PreferencesDialogController, PreferencesDialogThemeController> {
  final ValueNotifier<List<SudokuSeededTheme>> _userThemes;
  final ValueNotifier<int> _currentIndex;

  PreferencesDialogThemeController(
      List<SudokuSeededTheme> initialUserThemes, int initialCurrentIndex)
      : _userThemes = ValueNotifier(initialUserThemes),
        _currentIndex = ValueNotifier(initialCurrentIndex);

  ValueListenable<List<SudokuSeededTheme>> get userThemes => _userThemes.view();
  ValueListenable<int> get currentIndex => _currentIndex.view();
  List<SudokuTheme> get defaultThemes => defaultSudokuThemes;
  ValueListenable<List<SudokuTheme>> get themes => userThemes
      .map((userThemes) => defaultThemes.followedBy(userThemes).toList());
  ValueListenable<SudokuTheme> get currentTheme =>
      ((List<SudokuTheme> themes, int i) => themes[i])
          .curry
          .asValueListenable >>
      themes >>
      currentIndex;

  void addUserTheme(SudokuSeededTheme theme) =>
      _userThemes.value = [..._userThemes.value, theme];
  void modifyUserTheme(int i, SudokuSeededTheme newTheme) =>
      _userThemes.value = [..._userThemes.value]..[i] = newTheme;
  void removeUserTheme(int i) =>
      _userThemes.value = [..._userThemes.value]..removeAt(i);
  late final changeCurrentIndex = _currentIndex.setter;

  void init() {
    super.init();
  }

  void dispose() {
    IDisposable.disposeAll([
      _userThemes,
      _currentIndex,
    ]);
    super.dispose();
  }
}

class PreferencesDialogAnimationController extends SubcontrollerBase<
    PreferencesDialogController, PreferencesDialogAnimationController> {
  final ValueNotifier<AnimationOptions> _animationOptions;

  PreferencesDialogAnimationController(AnimationOptions initial)
      : _animationOptions = ValueNotifier(initial);
  ValueListenable<AnimationOptions> get animationOptions =>
      _animationOptions.view();

  void setSelection(SelectionAnimationOptions options) =>
      _animationOptions.value = AnimationOptions(
        options,
        animationOptions.value.e1,
        animationOptions.value.e2,
      );
  void setText(TextAnimationOptions options) =>
      _animationOptions.value = AnimationOptions(
        animationOptions.value.e0,
        options,
        animationOptions.value.e2,
      );
  void setSpeed(AnimationSpeed speed) =>
      _animationOptions.value = AnimationOptions(
        animationOptions.value.e0,
        animationOptions.value.e1,
        speed,
      );

  void init() {
    super.init();
  }

  void dispose() {
    IDisposable.disposeAll([
      _animationOptions,
    ]);
    super.dispose();
  }
}

class PreferencesDialogController
    extends ControllerBase<PreferencesDialogController> {
  final PreferencesDialogThemeController _theme;
  final PreferencesDialogAnimationController _animation;

  PreferencesDialogController(
    ControllerHandle<SudokuThemeController> themeController,
    ControllerHandle<SudokuAnimationController> animationController,
  )   : _theme = ControllerBase.create(() => PreferencesDialogThemeController(
            themeController.unwrap.userSudokuThemes.value,
            themeController.unwrap.activeThemeIndex.value)),
        _animation = ControllerBase.create(() =>
            PreferencesDialogAnimationController(
                animationController.unwrap.animationOptions.value));

  ControllerHandle<PreferencesDialogThemeController> get theme => _theme.handle;
  ControllerHandle<PreferencesDialogAnimationController> get animation =>
      _animation.handle;

  ValueListenable<SudokuTheme> get currentTheme => _theme.currentTheme;

  PreferencesDialogResult buildResult() => PreferencesDialogResult(
      PreferencesDialogThemeResult(
        _theme.currentIndex.value,
        _theme.userThemes.value,
      ),
      _animation.animationOptions.value);

  void init() {
    super.init();
    addSubcontroller(_theme);
    addSubcontroller(_animation);
  }

  void dispose() {
    disposeSubcontroller(_theme);
    disposeSubcontroller(_animation);
    super.dispose();
  }
}
