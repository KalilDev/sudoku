import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
import 'package:hive/hive.dart';
import 'package:utils/utils.dart';

import 'data.dart';

part 'sudoku_animation_db.g.dart';
part 'sudoku_animation_db.adapters.dart';

@data(
  #SudokuAnimationDb,
  [],
  adt.Opaque(T(#Box, args: [T(#dynamic)])),
)
const Type _sudokuAnimationDb = SudokuAnimationDb;

bool _sudokuAnimationDbWasInitialized = false;
void sudokuAnimationDbInitialize() {
  assert(!_sudokuAnimationDbWasInitialized);
  Hive.registerAdapter(_SelectionAnimationOptionsAdapter());
  Hive.registerAdapter(_TextAnimationOptionsAdapter());
  Hive.registerAdapter(_AnimationOptionsAdapter());
}

Future<SudokuAnimationDb> sudokuAnimationDbOpen() =>
    Hive.openBox<dynamic>('sudoku-animation').then(SudokuAnimationDb._);
Future<AnimationOptions?> sudokuAnimationDbRead(SudokuAnimationDb db) async {
  if (db._unwrap.length != 3) {
    return null;
  }
  final sel = await _sudokuAnimationDbReadSelection(db);
  final text = await _sudokuAnimationDbReadText(db);
  final speed = await _sudokuAnimationDbReadSpeed(db);
  return AnimationOptions(sel, text, speed);
}

Future<SelectionAnimationOptions> _sudokuAnimationDbReadSelection(
  SudokuAnimationDb db,
) async =>
    db._unwrap.get('sel');
Future<TextAnimationOptions> _sudokuAnimationDbReadText(
  SudokuAnimationDb db,
) async =>
    db._unwrap.get('text');
Future<AnimationSpeed> _sudokuAnimationDbReadSpeed(
  SudokuAnimationDb db,
) async =>
    db._unwrap.get('speed');
Future<void> sudokuAnimationDbModifySelection(
  SudokuAnimationDb db,
  SelectionAnimationOptions options,
) =>
    db._unwrap.put('sel', options);
Future<void> sudokuAnimationDbModifyText(
  SudokuAnimationDb db,
  TextAnimationOptions options,
) =>
    db._unwrap.put('text', options);
Future<void> sudokuAnimationDbModifySpeed(
  SudokuAnimationDb db,
  AnimationSpeed speed,
) =>
    db._unwrap.put('speed', speed);
Future<void> sudokuAnimationDbClose(SudokuAnimationDb db) => db._unwrap.close();
