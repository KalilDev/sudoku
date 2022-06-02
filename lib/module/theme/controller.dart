import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import 'data.dart';
import 'sudoku_user_themes_db.dart';

class _SudokuUserThemeDbController extends SubcontrollerBase<
    SudokuThemeController, _SudokuUserThemeDbController> {
  final EventNotifier<List<SudokuSeededTheme>> _didChangeUserSudokuThemes =
      EventNotifier();
  late final ValueListenable<SudokuUserThemesDb?> _db;
  _SudokuUserThemeDbController.alreadyOpen(SudokuUserThemesDb db) {
    _db = db.asValueListenable;
  }
  _SudokuUserThemeDbController.open() {
    _db = sudokuUserThemesDbOpen()
        .toValueListenable()
        .map((r) => r.hasData ? r.requireData : null);
  }
  ValueListenable<List<SudokuSeededTheme>?> get didChangeUserSudokuThemes =>
      _didChangeUserSudokuThemes.view();
  late final ValueListenable<Maybe<List<SudokuSeededTheme>>>
      _initialUserSudokuThemes = _db.view().bind((db) => db == null
          ? const Maybe<List<SudokuSeededTheme>>.none().asValueListenable
          : sudokuUserThemesDbRead(db)
              .toValueListenable(eager: true)
              .map((r) => r.hasData ? Just(r.requireData) : const None()));
  ValueListenable<Maybe<List<SudokuSeededTheme>>> get loadingUserSudokuThemes =>
      _initialUserSudokuThemes.view().bind((initial) => initial.visit(
          just: (initial) => didChangeUserSudokuThemes
              .map((change) => change ?? initial)
              .map(Maybe.just),
          none: () => Maybe<List<SudokuSeededTheme>>.none().asValueListenable));
  ValueListenable<List<SudokuSeededTheme>> get userSudokuThemes =>
      loadingUserSudokuThemes.map((loading) => loading.visit(
            just: (loaded) => loaded,
            none: () => [],
          ));

  ValueListenable<bool> get isReady =>
      loadingUserSudokuThemes.map((loading) => loading.visit(
            just: (_) => true,
            none: () => false,
          ));

  Future<int> addTheme(SudokuSeededTheme theme) =>
      sudokuUserThemesDbAdd(_db.value!, theme);
  Future<void> removeTheme(int i) => sudokuUserThemesDbRemove(_db.value!, i);
  Future<void> modifyTheme(int i, SudokuSeededTheme theme) =>
      sudokuUserThemesDbModify(_db.value!, i, theme);
  Future<void> setUserThemes(List<SudokuSeededTheme> themes) =>
      sudokuUserThemesDbStore(_db.value!, themes);

  void init() {
    super.init();
    // ensure it is kicked off
    _initialUserSudokuThemes.listen(() {});
  }

  void dispose() {
    IDisposable.disposeAll([
      _didChangeUserSudokuThemes,
      _initialUserSudokuThemes,
    ]);
    sudokuUserThemesDbClose(_db.value!);
    super.dispose();
  }
}

class SudokuThemeController extends ControllerBase<SudokuThemeController> {
  final _SudokuUserThemeDbController _db;
  final ValueNotifier<int> _activeThemeIndex;

  SudokuThemeController.alreadyOpen(SudokuUserThemesDb db, int activeIndex)
      : _db = ControllerBase.create(
            () => _SudokuUserThemeDbController.alreadyOpen(db)),
        _activeThemeIndex = ValueNotifier(activeIndex);

  SudokuThemeController.open()
      : _db = ControllerBase.create(() => _SudokuUserThemeDbController.open()),
        _activeThemeIndex = ValueNotifier(0);

  ValueListenable<List<SudokuSeededTheme>> get userSudokuThemes =>
      _db.userSudokuThemes;

  ValueListenable<List<SudokuTheme>> get sudokuThemes => userSudokuThemes
      .map((user) => defaultSudokuThemes.followedBy(user).toList());

  ValueListenable<int> get activeThemeIndex => _activeThemeIndex.view();

  // When the user themes are not ready and the theme would be one of the user
  // themes, we would have to fall back. This isnt ideal, so we will expose when
  // we are ready in order to await before displaying the app.
  ValueListenable<SudokuTheme> get activeTheme =>
      isReady.bind((isReady) => sudokuThemes.bind((themes) => activeThemeIndex
          .map((i) => !isReady ? defaultSudokuThemes[0] : themes[i])));

  ValueListenable<bool> get isReady =>
      _db.isReady.bind((userThemesAreReady) => activeThemeIndex
          .map((i) => i < defaultSudokuThemes.length || userThemesAreReady));

  void init() {
    super.init();
    addSubcontroller(_db);
  }

  void dispose() {
    IDisposable.disposeAll([
      _activeThemeIndex,
    ]);
    disposeSubcontroller(_db);
    super.dispose();
  }

  late final addTheme = _db.addTheme;
  late final removeTheme = _db.removeTheme;
  late final modifyTheme = _db.modifyTheme;
  late final setUserThemes = _db.setUserThemes;
  late final changeIndex = _activeThemeIndex.setter;
}
