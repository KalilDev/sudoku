import 'package:app/module/base.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:flutter/foundation.dart';
import 'package:utils/event_sourcing.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

// We need this so we can differentiate from null (no lastEvent) to an
// _ValidationToken
class _ValidationToken {
  const _ValidationToken();
}

SudokuBoard _sudokuBoardFromSnap(SudokuAppBoardState state) {
  final result = emptySudokuBoard(state.side);
  for (var i = 0; i < state.side; i++) {
    for (var j = 0; j < state.side; j++) {
      final index = SudokuBoardIndex(i, j);
      final permanent = sudokuBoardGetAt(state.fixedNumbers, index);
      sudokuBoardSetAt(
          result,
          index,
          permanent == 0
              ? sudokuBoardGetAt(state.currentNumbers, index)
              : permanent);
    }
  }
  return result;
}

bool _sudokuBoardIsFull(SudokuBoard board) {
  for (var i = 0; i < board.length; i++) {
    for (var j = 0; j < board.length; j++) {
      final index = SudokuBoardIndex(i, j);
      if (sudokuBoardGetAt(board, index) == 0) {
        return false;
      }
    }
  }
  return true;
}

bool _sudokuBoardEqualsAndNotNull(SudokuBoard? a, SudokuBoard? b) {
  if (a == null || b == null) {
    return false;
  }
  return sudokuBoardEquals(a, b);
}

class SudokuViewBoardController
    extends SubcontrollerBase<SudokuViewController, SudokuViewBoardController> {
  final EventNotifier<SudokuBoardIndex> _didPressTile = EventNotifier();
  final EventNotifier<_ValidationToken> _didValidate = EventNotifier();
  final ValueListenable<SudokuBoardIndex?> _selectedIndex;
  final int side;
  final SudokuController _sudokuController;

  SudokuViewBoardController(
    this._selectedIndex,
    this.side,
    ControllerHandle<SudokuController> sudokuController,
  ) : _sudokuController = sudokuController.unwrap;

  ValueListenable<SudokuBoard?> get _solvedBoard => _sudokuController.snapshot
      .map((snap) => snap?.solvedBoard)
      .unique(sudokuBoardEquals);
  ValueListenable<TileStateMatrix?> get _notValidatedBoard =>
      _sudokuController.snapshot.map((snap) => snap?.tileStates);

  ValueListenable<_ValidationToken?> get didValidate => _didValidate.view();

  late final ValueListenable<SudokuBoard> __validationBoard = didValidate
      .bind((token) => token == null ? null.asValueListenable : _solvedBoard)
      .bind((solvedBoard) {
    print("gonna start folding");
    return solvedBoard == null
        ? emptySudokuBoard(side).asValueListenable
        : _didPressTile.view().fold(solvedBoard, (board, event) {
            print("gonna fold");
            if (event == null) {
              return board;
            }
            if (sudokuBoardGetAt(board, event) == 0) {
              return board;
            }
            // The validation was not touched. Therefore, we zero it
            final newBoard = cloneSudokuBoard(board);
            sudokuBoardSetAt(newBoard, event, 0);
            return sudokuBoardCopyLocked(newBoard);
          });
  });

  ValueListenable<SudokuBoard> get _validationBoard => __validationBoard.view();
  ValueListenable<TileMatrix?> get _validatedBoard =>
      validatedFromValidationAndNotValidated.curry.asValueListenable >>
      _validationBoard >>
      _notValidatedBoard;

  ValueListenable<TileMatrix> get board =>
      _validatedBoard.map((board) => board ?? emptyTileMatrix(side));

  ValueListenable<SudokuBoardIndex?> get selectedIndex => _selectedIndex.view();
  ValueListenable<SudokuBoardIndex> get didPressTile =>
      _didPressTile.viewNexts();

  ValueListenable<bool> get isComplete =>
      (_sudokuBoardEqualsAndNotNull.curry.asValueListenable >>
              _solvedBoard >>
              _sudokuController.snapshot
                  .map((s) => s == null ? null : _sudokuBoardFromSnap(s)))
          .where((areEqual) => areEqual)
          .withDefault(false)
          .unique();

  ValueListenable<bool> get isInvalid => _sudokuController.snapshot.map((s) {
        if (s == null) {
          return false;
        }
        final board = _sudokuBoardFromSnap(s);
        if (_sudokuBoardIsFull(board) &&
            !sudokuBoardEquals(board, s.solvedBoard)) {
          return true;
        }
        return false;
      }).unique();

  late final pressTile = _didPressTile.add;
  void validate() => _didValidate.add(const _ValidationToken());

  void dispose() {
    IDisposable.disposeAll([
      _didValidate,
      _didPressTile,
      _selectedIndex,
      __validationBoard,
    ]);
    super.dispose();
  }
}

class SudokuViewKeypadController extends SubcontrollerBase<SudokuViewController,
    SudokuViewKeypadController> {
  final ValueListenable<int?> _selectedNumber;
  final ActionNotifier _didPressClear = ActionNotifier();
  final EventNotifier<int> _didPressNumber = EventNotifier();
  final int side;

  SudokuViewKeypadController(this._selectedNumber, this.side);

  ValueListenable<int?> get selectedNumber => _selectedNumber.view();
  ValueListenable<void> get didPressClear => _didPressClear.viewNexts();
  ValueListenable<int> get didPressNumber => _didPressNumber.viewNexts();

  late final pressNumber = _didPressNumber.add;
  late final pressClear = _didPressClear.notify;

  void dispose() {
    IDisposable.disposeAll([
      _selectedNumber,
      _didPressClear,
      _didPressNumber,
    ]);
    super.dispose();
  }
}

class SudokuViewActionsController extends SubcontrollerBase<
    SudokuViewController, SudokuViewActionsController> {
  final ValueListenable<ModelUndoState?> _undoState;
  final ValueListenable<SudokuPlacementMode> _placementMode;
  final ActionNotifier _didReset = ActionNotifier();
  final ActionNotifier _didValidate = ActionNotifier();
  final ActionNotifier _didToggleMode = ActionNotifier();
  final ActionNotifier _didUndo = ActionNotifier();

  SudokuViewActionsController(this._undoState, this._placementMode);

  ValueListenable<SudokuPlacementMode> get placementMode =>
      _placementMode.view();
  ValueListenable<void> get didReset => _didReset.viewNexts();
  ValueListenable<void> get didValidate => _didValidate.viewNexts();
  ValueListenable<void> get didToggleMode => _didToggleMode.viewNexts();
  ValueListenable<void> get didUndo => _didUndo.viewNexts();

  ValueListenable<bool> get canUndo =>
      _undoState.view().map((s) => s?.undo ?? false);

  late final reset = _didReset.notify;
  late final validate = _didValidate.notify;
  late final toggleMode = _didToggleMode.notify;
  late final undo = _didUndo.notify;

  void dispose() {
    IDisposable.disposeAll([
      _undoState,
      _placementMode,
      _didReset,
      _didValidate,
      _didToggleMode,
      _didUndo,
    ]);
    super.dispose();
  }
}

class SudokuViewController extends ControllerBase<SudokuViewController> {
  final ValueNotifier<NavigationInformation> _navigationInformation =
      ValueNotifier(Unfocused());
  final ValueNotifier<SudokuPlacementMode> _placementMode =
      ValueNotifier(SudokuPlacementMode.number);
  final ActionNotifier _didValidate = ActionNotifier();
  final SudokuController _sudokuController;
  late final SudokuViewBoardController board;
  late final SudokuViewKeypadController keypad;
  late final SudokuViewActionsController actions;

  SudokuViewController(this._sudokuController, int side) {
    board = ControllerBase.create(() => SudokuViewBoardController(
        navigationInformation
            .map((nav) => nav is FocusedOnBoard ? nav.index : null),
        side,
        _sudokuController.handle));
    keypad = ControllerBase.create(() => SudokuViewKeypadController(
        navigationInformation
            .map((nav) => nav is FocusedOnKeypad ? nav.number : null),
        side));
    actions = ControllerBase.create(() => SudokuViewActionsController(
        _sudokuController.undoState, _placementMode));
  }

  ValueListenable<ModelUndoState?> get undoState => _sudokuController.undoState;
  ValueListenable<NavigationInformation> get navigationInformation =>
      _navigationInformation.view();
  ValueListenable<SudokuPlacementMode> get placementMode =>
      _placementMode.view();
  ValueListenable<void> get didValidate => _didValidate.view();
  ValueListenable<bool> get isLocked =>
      _sudokuController.modelOrNull.map((model) => model == null);
  ValueListenable<Object?> get errorEvents =>
      _sudokuController.model.map((model) => model?.visit(
            left: (err) => err,
            right: (v) => null,
          ));

  void _pressOnBoard(
    SudokuBoardIndex index,
    int number,
    SudokuPlacementMode placementMode,
  ) {
    _onBoardAndNumberCombination(index, number, placementMode);
  }

  void pressNumberOnBoard(
    SudokuBoardIndex index,
    int number, {
    required bool isAlt,
  }) {
    final placementMode = isAlt
        ? _placementMode.value
        : invertPlacementMode(_placementMode.value);
    print("gonna _pressOnBoard with $placementMode");
    _pressOnBoard(index, number, placementMode);
  }

  void _toggleMode(_) =>
      _placementMode.value = invertPlacementMode(_placementMode.value);

  void _undo(_) => _sudokuController.undo();

  void _onBoardAndNumberCombination(
      SudokuBoardIndex index, int number, SudokuPlacementMode placementMode) {
    if (number == 0) {
      _sudokuController.clearTile(index);
      return;
    }

    switch (placementMode) {
      case SudokuPlacementMode.possibility:
        _sudokuController.snapshot.value!.tileStateAt(index).visit(
              constTileState: (_) {},
              possibilitiesTileState: (ps) => ps.contains(number)
                  ? _sudokuController.removePossibility(index, number)
                  : _sudokuController.addPossibility(index, number),
              numberTileState: (_) {
                _sudokuController.changeFromNumberToPossibility(index, number);
              },
            );
        break;
      case SudokuPlacementMode.number:
        _sudokuController.snapshot.value!.tileStateAt(index).visit(
              constTileState: (_) {},
              possibilitiesTileState: (_) =>
                  _sudokuController.commitNumber(index, number),
              numberTileState: (n) => n == number
                  ? _sudokuController.clearTile(index)
                  : _sudokuController.changeNumber(index, number),
            );
        break;
    }
  }

  void _onKeypad(int number) => _navigationInformation.value.visit(
        unfocused: () => _navigationInformation.value = FocusedOnKeypad(number),
        focusedOnKeypad: (n) => _navigationInformation.value =
            number == n ? const Unfocused() : FocusedOnKeypad(number),
        focusedOnBoard: (index) =>
            _onBoardAndNumberCombination(index, number, _placementMode.value),
      );

  void _onBoard(SudokuBoardIndex index) => _navigationInformation.value.visit(
        unfocused: () => _navigationInformation.value = FocusedOnBoard(index),
        focusedOnKeypad: (number) =>
            _onBoardAndNumberCombination(index, number, _placementMode.value),
        focusedOnBoard: (i) => _navigationInformation.value =
            i == index ? const Unfocused() : FocusedOnBoard(index),
      );

  void _resetBoard(_) => _sudokuController.reset();

  // TODO
  void _validate(_) {
    _didValidate.notify();
  }

  void init() {
    super.init();
    addSubcontroller(board);
    addSubcontroller(keypad);
    addSubcontroller(actions);

    {
      board.didPressTile.tap(_onBoard);
    }
    {
      keypad.didPressNumber.tap(_onKeypad);
      keypad.didPressClear.tap((_) => _onKeypad(0));
    }
    {
      actions.didReset.tap(_resetBoard);
      actions.didValidate.tap(_validate);
      actions.didToggleMode.tap(_toggleMode);
      actions.didUndo.tap(_undo);
    }
    {
      actions.didValidate.listen(board.validate);
    }
  }

  void dispose() {
    IDisposable.disposeAll([
      _navigationInformation,
      _placementMode,
      _didValidate,
    ]);
    disposeSubcontroller(board);
    disposeSubcontroller(keypad);
    disposeSubcontroller(actions);
    super.dispose();
  }
}
