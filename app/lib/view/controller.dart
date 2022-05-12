import 'package:app/base/controller.dart';
import 'package:app/base/sudoku_data.dart';
import 'package:app/view/data.dart';
import 'package:flutter/foundation.dart';
import 'package:utils/event_sourcing.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import 'navigation_data.dart';

class SudokuViewBoardController
    extends SubcontrollerBase<SudokuViewController, SudokuViewBoardController> {
  final EventNotifier<SudokuBoardIndex> _didPressTile = EventNotifier();
  final ValueListenable<SudokuBoardIndex?> _selectedIndex;
  final int side;
  final SudokuController _sudokuController;

  SudokuViewBoardController(
    this._selectedIndex,
    this.side,
    ControllerHandle<SudokuController> sudokuController,
  ) : _sudokuController = sudokuController.unwrap;

  // TODO: how tf do i represent validation? maybe another matrix that i can
  // modify, and binding it together with this board? Yeah, defo. Using an proxy
  // value listenable will allow me to swap between an oneshot valdation and an
  // always correct validator.
  ValueListenable<TileMatrix> get _notValidatedBoard =>
      _sudokuController.snapshot
          .map((snap) => snap == null ? null : tileMatrixFromState(snap))
          .map((tiles) => tiles ?? emptyTileMatrix(side));

  ValueListenable<TileMatrix> get board => _notValidatedBoard;

  ValueListenable<SudokuBoardIndex?> get selectedIndex => _selectedIndex.view();
  ValueListenable<SudokuBoardIndex> get didPressTile =>
      _didPressTile.viewNexts();

  late final pressTile = _didPressTile.add;
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
            a: (err) => err,
            b: (v) => null,
          ));

  void _pressOnBoard(
    SudokuBoardIndex index,
    int number,
    SudokuPlacementMode placementMode,
  ) {}

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

  // TODO: Other placement modes. This is SudokuPlacementMode.number
  void _onKeypad(int n) {
    print('KEUPAD $n');
    _navigationInformation.value.visit(
      unfocused: () => _navigationInformation.value = FocusedOnKeypad(n),
      focusedOnKeypad: (number) => _navigationInformation.value =
          number == n ? Unfocused() : FocusedOnKeypad(n),
      focusedOnBoard: (index) => n == 0
          ? _sudokuController.clearTile(index)
          : _sudokuController.commitNumber(index, n),
    );
  }

  // TODO: Other placement modes. This is SudokuPlacementMode.number
  void _onBoard(SudokuBoardIndex index) => _navigationInformation.value.visit(
        unfocused: () => _navigationInformation.value = FocusedOnBoard(index),
        focusedOnKeypad: (number) => number == 0
            ? _sudokuController.clearTile(index)
            : _sudokuController.commitNumber(index, number),
        focusedOnBoard: (i) => _navigationInformation.value =
            i == index ? Unfocused() : FocusedOnBoard(index),
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
  }
}