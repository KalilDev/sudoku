import 'dart:convert';
import 'dart:typed_data';

import 'package:kalil_adt_annotation/kalil_adt_annotation.dart'
    show data, T, Tp, NoMixin;
import 'package:kalil_adt_annotation/kalil_adt_annotation.dart' as adt;
import 'package:app/util/hive_adapter.dart';
import 'package:hive/hive.dart';
import 'package:kalil_utils/utils.dart';

import 'sudoku_data.dart';

part 'sudoku_db.adapters.dart';
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
  Hive.registerAdapter(_SudokuAppBoardStateAdapter());
  Hive.registerAdapter(_ChangeNumberAdapter());
  Hive.registerAdapter(_AddPossibilityAdapter());
  Hive.registerAdapter(_RemovePossibilityAdapter());
  Hive.registerAdapter(_CommitNumberAdapter());
  Hive.registerAdapter(_ClearTileAdapter());
  Hive.registerAdapter(_ChangeFromNumberToPossibility());
  Hive.registerAdapter(_ClearBoardAdapter());
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
