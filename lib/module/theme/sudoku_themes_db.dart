import 'package:kalil_adt_annotation/kalil_adt_annotation.dart'
    show data, T, Tp, NoMixin;
import 'package:kalil_adt_annotation/kalil_adt_annotation.dart' as adt;
import 'package:app/util/hive_adapter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kalil_utils/utils.dart';

import 'data.dart';

part 'sudoku_themes_db.g.dart';
part 'sudoku_themes_db.adapters.dart';

@data(
  #SudokuThemesDb,
  [],
  adt.Record(
    {
      #_themes: T(
        #Box,
        args: [T(#dynamic)],
      ),
      #_userThemes: T(
        #Box,
        args: [T(#SudokuSeededTheme)],
      ),
    },
  ),
)
const Type _sudokuThemesDb = SudokuThemesDb;

bool _sudokuUserThemesDbWasInitialized = false;
void sudokuUserThemesDbInitialize() {
  assert(!_sudokuUserThemesDbWasInitialized);
  Hive.registerAdapter(_SudokuSeededThemeAdapter());
}

Future<SudokuThemesDb> sudokuThemesDbOpen() async {
  return SudokuThemesDb(
    await Hive.openBox<dynamic>('sudoku-themes'),
    await Hive.openBox<SudokuSeededTheme>('sudoku-user-themes'),
  );
}

Future<int?> sudokuThemesDbReadActiveIndex(SudokuThemesDb db) async =>
    Future.value(db._themes.get("active-index"))
        .then((d) => d as int?)
        .then((activeIndex) {
      print('read active index $activeIndex');
      return activeIndex;
    });

Future<void> sudokuThemesDbStoreActiveIndex(SudokuThemesDb db, int i) async =>
    db._themes.put("active-index", i);

Future<List<SudokuSeededTheme>> sudokuThemesDbReadUserThemes(
        SudokuThemesDb db) async =>
    db._userThemes.values.toList();

Future<void> sudokuThemesDbStoreUserThemes(
  SudokuThemesDb db,
  List<SudokuSeededTheme> themes,
) =>
    db._userThemes.clear().then((_) => db._userThemes.putAll(themes.asMap()));
Future<void> sudokuThemesDbModifyUserTheme(
  SudokuThemesDb db,
  int i,
  SudokuSeededTheme theme,
) =>
    db._userThemes.put(i, theme);
Future<int> sudokuThemesDbAddUserTheme(
  SudokuThemesDb db,
  SudokuSeededTheme theme,
) =>
    db._userThemes.add(theme);
Future<void> sudokuThemesDbRemoveUserTheme(
  SudokuThemesDb db,
  int i,
) =>
    db._userThemes.delete(i);

Future<void> sudokuThemesDbClose(SudokuThemesDb db) => Future.wait([
      db._themes.close(),
      db._userThemes.close(),
    ]);
