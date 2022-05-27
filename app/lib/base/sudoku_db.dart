import 'dart:convert';

import 'package:utils/utils.dart';
import 'hive.dart';
import 'sudoku_data.dart';
import 'package:hive/hive.dart';
import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;

part 'sudoku_db.g.dart';

const Codec<SudokuAppBoardModel, Map<String, dynamic>> _codec =
    DoublyLinkedEventSourcedModelCodec();

@data(
  #SudokuDb,
  [],
  adt.Opaque(T(#Box, args: [T(#dynamic)])),
)
const Type _sudokuDb = SudokuDb;
bool _sudokuDbWasInitialized = false;
void sudokuDbInitialize() {
  assert(!_sudokuDbWasInitialized);
  Hive.registerAdapter(SudokuAppBoardStateAdapter());
  Hive.registerAdapter(ChangeNumberAdapter());
  Hive.registerAdapter(AddPossibilityAdapter());
  Hive.registerAdapter(RemovePossibilityAdapter());
  Hive.registerAdapter(CommitNumberAdapter());
  Hive.registerAdapter(ClearTileAdapter());
  _sudokuDbWasInitialized = true;
}

Future<SudokuDb> sudokuDbOpen(String name) {
  assert(_sudokuDbWasInitialized);
  return Hive.openBox(name).then(SudokuDb._);
}

Future<void> sudokuDbStore(
  SudokuDb db,
  SudokuAppBoardModel sudoku,
) =>
    db._unwrap.putAll(_codec.encode(sudoku));

Future<SudokuAppBoardModel> sudokuDbGet(SudokuDb db) async =>
    _codec.decode(db._unwrap.toMap().cast());

Future<void> sudokuDbFlush(SudokuDb db) => db._unwrap.flush();

Future<void> sudokuDbClose(SudokuDb db) => db._unwrap.close();
