// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:math';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../../../base/sudoku_data.dart';

class S_Board extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> board;
  // uint
  @ffi.Uint32()
  external int sideSqrt;
}

typedef ExternSudokuBoard = ffi.Pointer<S_Board>;

final libsudoku = ffi.DynamicLibrary.open('libsudoku.so');
typedef s_board_initialize_to_zero_signature_native = ffi.Void Function(
    ffi.Pointer<S_Board> board);
typedef s_board_initialize_to_zero_signature_dart = void Function(
    ffi.Pointer<S_Board> board);
final s_board_initialize_to_zero = libsudoku.lookupFunction<
    s_board_initialize_to_zero_signature_native,
    s_board_initialize_to_zero_signature_dart>('s_board_initialize_to_zero');

typedef s_board_get_at_signature_native = ffi.Uint8 Function(
    S_Board board, ffi.Uint32 r, ffi.Uint32 c);
typedef s_board_get_at_signature_dart = int Function(
    S_Board board, int r, int c);
final s_board_get_at = libsudoku.lookupFunction<s_board_get_at_signature_native,
    s_board_get_at_signature_dart>('s_board_get_at');

typedef s_board_set_at_signature_native = ffi.Void Function(
    S_Board board, ffi.Uint32 r, ffi.Uint32 c, ffi.Uint8 value);
typedef s_board_set_at_signature_dart = void Function(
    S_Board board, int r, int c, int value);
final s_board_set_at = libsudoku.lookupFunction<s_board_set_at_signature_native,
    s_board_set_at_signature_dart>('s_board_set_at');

typedef s_board_copy_into_signature_native = ffi.Void Function(
    S_Board dest, S_Board src);
typedef s_board_copy_into_signature_dart = void Function(
    S_Board dest, S_Board src);
final s_board_copy_into = libsudoku.lookupFunction<
    s_board_copy_into_signature_native,
    s_board_copy_into_signature_dart>('s_board_copy_into');

typedef s_sudoku_generate_signature_native = ffi.Void Function(S_Board board);
typedef s_sudoku_generate_signature_dart = void Function(S_Board board);
final s_sudoku_generate = libsudoku.lookupFunction<
    s_sudoku_generate_signature_native,
    s_sudoku_generate_signature_dart>('s_sudoku_generate');

typedef s_sudoku_solve_signature_native = ffi.Bool Function(S_Board board);
typedef s_sudoku_solve_signature_dart = bool Function(S_Board board);
final s_sudoku_solve = libsudoku.lookupFunction<s_sudoku_solve_signature_native,
    s_sudoku_solve_signature_dart>('s_sudoku_solve');
typedef s_sudoku_has_many_sols_signature_native = ffi.Bool Function(
    S_Board board);
typedef s_sudoku_has_many_sols_signature_dart = bool Function(S_Board board);
final s_sudoku_has_many_sols = libsudoku.lookupFunction<
    s_sudoku_has_many_sols_signature_native,
    s_sudoku_has_many_sols_signature_dart>('s_sudoku_has_many_sols');

ffi.Pointer<S_Board> _createExternBoardWithSideSqrt(int sideSqrt) {
  final side = sideSqrt * sideSqrt;
  final __board =
      malloc.allocate(ffi.sizeOf<ffi.Uint8>() * side * side).cast<ffi.Uint8>();
  final board = malloc.allocate(ffi.sizeOf<S_Board>()).cast<S_Board>();
  board.ref.board = __board;
  board.ref.sideSqrt = sideSqrt;
  return board;
}

void _zeroOutExternBoard(ExternSudokuBoard board) {
  s_board_initialize_to_zero(board);
}

ExternSudokuBoard externSudokuBoardFrom(SudokuBoard board) {
  final side = board.length;
  final sideSqrt = sqrt(side).toInt();
  assert(sideSqrt * sideSqrt == side);

  final nativeBoard = _createExternBoardWithSideSqrt(side);
  for (int y = 0; y < side; y++) {
    for (int x = 0; x < side; x++) {
      s_board_set_at(
        nativeBoard.ref,
        y,
        x,
        sudokuBoardGetAt(board, SudokuBoardIndex(x, y)),
      );
    }
  }
  return nativeBoard;
}

ExternSudokuBoard emptyExternSudokuBoard(int side) {
  final sideSqrt = sqrt(side).toInt();
  assert(sideSqrt * sideSqrt == side);
  final nativeBoard = _createExternBoardWithSideSqrt(sideSqrt);
  _zeroOutExternBoard(nativeBoard);
  return nativeBoard;
}

ExternSudokuBoard cloneExternSudokuBoard(ExternSudokuBoard other) {
  final result = _createExternBoardWithSideSqrt(other.ref.sideSqrt);
  s_board_copy_into(result.ref, other.ref);
  return result;
}

int externSudokuBoardGetAt(ExternSudokuBoard board, SudokuBoardIndex index) =>
    s_board_get_at(board.ref, index.right, index.left);

void externSudokuBoardSetAt(
  ExternSudokuBoard board,
  SudokuBoardIndex index,
  int value,
) =>
    s_board_set_at(board.ref, index.right, index.left, value);

int externSudokuSide(ExternSudokuBoard board) =>
    board.ref.sideSqrt * board.ref.sideSqrt;

SudokuBoard sudokuBoardFromExtern(ExternSudokuBoard extern) {
  final side = externSudokuSide(extern);
  final result = emptySudokuBoard(side);
  for (var y = 0; y < side; y++) {
    for (var x = 0; x < side; x++) {
      final index = SudokuBoardIndex(x, y);
      sudokuBoardSetAt(
        result,
        index,
        externSudokuBoardGetAt(extern, index),
      );
    }
  }
  return result;
}

ExternSudokuBoard generateExternSudokuBlocking(int side) {
  final state = emptyExternSudokuBoard(side);
  s_sudoku_generate(state.ref);
  return state;
}

ExternSudokuBoard solveExternSudokuBlocking(ExternSudokuBoard board) {
  final result = emptyExternSudokuBoard(externSudokuSide(board));
  s_board_copy_into(result.ref, board.ref);
  final didSolve = s_sudoku_solve(result.ref);
  assert(didSolve);
  return result;
}

bool externSudokuHasOneSolBlocking(ExternSudokuBoard board) {
  return !s_sudoku_has_many_sols(board.ref);
}

void externSudokuFree(ExternSudokuBoard board) {
  malloc.free(board.ref.board);
  malloc.free(board);
}
