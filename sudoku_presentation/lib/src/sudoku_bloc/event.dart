import 'package:sudoku_core/sudoku_core.dart';
import 'package:meta/meta.dart';
import 'state.dart' show MarkType;

@immutable
abstract class SudokuEvent {}

class ActionReset extends SudokuEvent {}
class ActionValidate extends SudokuEvent {}
class ActionSetMark extends SudokuEvent {
  final MarkType type;

  ActionSetMark(this.type);
}
class ActionUndo extends SudokuEvent {}

class LoadedEvent extends SudokuEvent {
  final SudokuState state;
  LoadedEvent(this.state);
}

class DeleteSudoku extends SudokuEvent {}

class SquareTap extends SudokuEvent {
  final int x;
  final int y;

  SquareTap(this.x, this.y);
}

class NumberTap extends SudokuEvent {
  final int number;

  NumberTap(this.number);
}