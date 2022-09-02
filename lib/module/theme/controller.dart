import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalil_utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import 'data.dart';
import 'sudoku_themes_db.dart';

class _SudokuThemesDbController extends SubcontrollerBase<SudokuThemeController,
    _SudokuThemesDbController> {
  final EventNotifier<List<SudokuSeededTheme>> _didChangeUserSudokuThemes =
      EventNotifier();
  final EventNotifier<int> _didChangeActiveIndex = EventNotifier();
  late final ValueListenable<SudokuThemesDb?> _db;
  _SudokuThemesDbController.alreadyOpen(SudokuThemesDb db) {
    _db = db.asValueListenable;
  }
  _SudokuThemesDbController.open() {
    _db = sudokuThemesDbOpen()
        .toValueListenable()
        .map((r) => r.hasData ? r.requireData : null);
  }
  ValueListenable<List<SudokuSeededTheme>?> get didChangeUserSudokuThemes =>
      _didChangeUserSudokuThemes.view();
  ValueListenable<int?> get didChangeActiveIndex =>
      _didChangeActiveIndex.view();

  late final ValueListenable<Maybe<int>> _initialActiveIndex = _db.view().bind(
      (db) => db == null
          ? const Maybe<int>.none().asValueListenable
          : sudokuThemesDbReadActiveIndex(db)
              .toValueListenable(eager: true)
              .map((r) =>
                  r.connectionState == ConnectionState.done && !r.hasError
                      ? Just(r.data ?? 0)
                      : const None()));

  late final ValueListenable<Maybe<List<SudokuSeededTheme>>>
      _initialUserSudokuThemes = _db.view().bind((db) => db == null
          ? const Maybe<List<SudokuSeededTheme>>.none().asValueListenable
          : sudokuThemesDbReadUserThemes(db).toValueListenable(eager: true).map(
              (r) => r.connectionState == ConnectionState.done && !r.hasError
                  ? Just(r.requireData)
                  : const None()));

  ValueListenable<Maybe<int>> get loadingActiveIndex =>
      _initialActiveIndex.view().bind((initial) => initial.visit(
          just: (initial) => didChangeActiveIndex
              .map((change) => change ?? initial)
              .map(Maybe.just),
          none: () => Maybe<int>.none().asValueListenable));

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

  ValueListenable<int> get activeIndex =>
      loadingActiveIndex.map((loading) => loading.visit(
            just: (loaded) => loaded,
            none: () => 0,
          ));

  ValueListenable<bool> get isReady => loadingUserSudokuThemes
      .bind((loadingUserThemes) => loadingUserThemes.visit(
            just: (_) => loadingActiveIndex.map(
              (loadingActiveIndex) => loadingActiveIndex.visit(
                just: (_) => true,
                none: () => false,
              ),
            ),
            none: () => false.asValueListenable,
          ));

  Future<int> addTheme(SudokuSeededTheme theme) {
    _didChangeUserSudokuThemes.add([
      ...userSudokuThemes.value,
      theme,
    ]);
    return sudokuThemesDbAddUserTheme(_db.value!, theme);
  }

  Future<void> removeTheme(int i) {
    _didChangeUserSudokuThemes.add([
      ...userSudokuThemes.value,
    ]..removeAt(i));
    return sudokuThemesDbRemoveUserTheme(_db.value!, i);
  }

  Future<void> modifyTheme(int i, SudokuSeededTheme theme) {
    _didChangeUserSudokuThemes.add([
      ...userSudokuThemes.value,
    ]..[i] = theme);
    return sudokuThemesDbModifyUserTheme(_db.value!, i, theme);
  }

  Future<void> setUserThemes(List<SudokuSeededTheme> themes) {
    _didChangeUserSudokuThemes.add(themes);
    return sudokuThemesDbStoreUserThemes(_db.value!, themes);
  }

  Future<void> changeActiveIndex(int i) {
    _didChangeActiveIndex.add(i);
    return sudokuThemesDbStoreActiveIndex(_db.value!, i);
  }

  void init() {
    super.init();
    // ensure it is kicked off
    _initialUserSudokuThemes.listen(() {});
    _initialActiveIndex.listen(() {});
  }

  void dispose() {
    IDisposable.disposeAll([
      _didChangeActiveIndex,
      _didChangeUserSudokuThemes,
      _initialActiveIndex,
      _initialUserSudokuThemes,
    ]);
    sudokuThemesDbClose(_db.value!);
    super.dispose();
  }
}

class SudokuThemeController extends ControllerBase<SudokuThemeController> {
  final _SudokuThemesDbController _db;

  SudokuThemeController.alreadyOpen(SudokuThemesDb db, int activeIndex)
      : _db = ControllerBase.create(
            () => _SudokuThemesDbController.alreadyOpen(db));

  SudokuThemeController.open()
      : _db = ControllerBase.create(() => _SudokuThemesDbController.open());

  ValueListenable<List<SudokuSeededTheme>> get userSudokuThemes =>
      _db.userSudokuThemes;

  ValueListenable<List<SudokuTheme>> get sudokuThemes => userSudokuThemes
      .map((user) => defaultSudokuThemes.followedBy(user).toList());

  ValueListenable<int> get activeThemeIndex => _db.activeIndex;

  // When the user themes are not ready and the theme would be one of the user
  // themes, we would have to fall back. This isnt ideal, so we will expose when
  // we are ready in order to await before displaying the app.
  ValueListenable<SudokuTheme> get activeTheme =>
      isReady.bind((isReady) => sudokuThemes.bind((themes) => activeThemeIndex
          .map((i) => !isReady ? defaultSudokuThemes[0] : themes[i])));

  ValueListenable<bool> get isReady => _db.isReady;

  void init() {
    super.init();
    addSubcontroller(_db);
  }

  void dispose() {
    disposeSubcontroller(_db);
    super.dispose();
  }

  late final addTheme = _db.addTheme;
  void setUserThemes(List<SudokuSeededTheme> userThemes) {
    final isCurrentUserDefined =
        activeThemeIndex.value >= defaultSudokuThemes.length;
    if (isCurrentUserDefined) {
      final previousTheme = activeTheme.value as SudokuSeededTheme;
      if (userThemes.contains(previousTheme)) {
        final nextIndex = userThemes.indexOf(previousTheme);
        _db.setUserThemes(userThemes);
        _db.changeActiveIndex(nextIndex);
        return;
      }
      _db.setUserThemes(userThemes);
      _db.changeActiveIndex(0);
      return;
    }

    _db.setUserThemes(userThemes);
  }

  void removeTheme(int i) {
    if (activeThemeIndex.value == i + defaultSudokuThemes.length) {
      // We were at the deleted theme. update the index to the first theme
      changeIndex(0);
    }
    _db.removeTheme(i);
  }

  void modifyTheme(int i, SudokuSeededTheme theme) {
    if (i >= userSudokuThemes.value.length) {
      throw IndexError(i, userSudokuThemes.value);
    }
    _db.modifyTheme(i, theme);
  }

  void changeIndex(int i) {
    if (i >= sudokuThemes.value.length) {
      throw IndexError(i, sudokuThemes.value);
    }
    _db.changeActiveIndex(i);
  }
}
