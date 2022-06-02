import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
import 'package:app/util/hive_adapter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:utils/utils.dart';

import 'data.dart';

part 'sudoku_user_themes_db.g.dart';
part 'sudoku_user_themes_db.adapters.dart';

@data(
  #SudokuUserThemesDb,
  [],
  adt.Opaque(T(#Box, args: [T(#SudokuSeededTheme)])),
)
const Type _sudokuUserThemesDb = SudokuUserThemesDb;

bool _sudokuUserThemesDbWasInitialized = false;
void sudokuUserThemesDbInitialize() {
  assert(!_sudokuUserThemesDbWasInitialized);
  Hive.registerAdapter(_SudokuSeededThemeAdapter());
}

Future<SudokuUserThemesDb> sudokuUserThemesDbOpen() =>
    Hive.openBox<SudokuSeededTheme>('sudoku-user-themes')
        .then(SudokuUserThemesDb._);
Future<List<SudokuSeededTheme>> sudokuUserThemesDbRead(
        SudokuUserThemesDb db) async =>
    db._unwrap.values.toList();
Future<void> sudokuUserThemesDbStore(
  SudokuUserThemesDb db,
  List<SudokuSeededTheme> themes,
) =>
    db._unwrap.clear().then((_) => db._unwrap.putAll(themes.asMap()));
Future<void> sudokuUserThemesDbModify(
  SudokuUserThemesDb db,
  int i,
  SudokuSeededTheme theme,
) =>
    db._unwrap.put(i, theme);
Future<int> sudokuUserThemesDbAdd(
  SudokuUserThemesDb db,
  SudokuSeededTheme theme,
) =>
    db._unwrap.add(theme);
Future<void> sudokuUserThemesDbRemove(
  SudokuUserThemesDb db,
  int i,
) =>
    db._unwrap.delete(i);
Future<void> sudokuUserThemesDbClose(SudokuUserThemesDb db) =>
    db._unwrap.close();
