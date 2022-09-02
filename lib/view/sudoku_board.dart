library app.view.sudoku_board;

import 'package:app/viewmodel/sudoku_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalil_utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import 'sudoku_board/actions.dart';
import 'sudoku_board/board.dart';
import 'sudoku_board/flutter_intents.dart';
import 'sudoku_board/keypad.dart';
import 'sudoku_board/layout.dart';
import 'sudoku_board/locking.dart';

class TilePressedAction extends Action<PressTileIntent> {
  final SudokuViewController controller;

  TilePressedAction(this.controller);

  @override
  Object? invoke(PressTileIntent intent) {
    print('invoking tile pressed');
    controller.board.pressTile(intent.index);
  }
}

abstract class NumberPressedAction<T extends PressNumberIntent>
    extends Action<T> {
  final SudokuViewController controller;

  NumberPressedAction(this.controller);

  @override
  Object? invoke(PressNumberIntent intent) {
    print('invoking number pressed');
    intent.visit(
      pressNumberOnBoardIntent: (index, number) =>
          controller.pressNumberOnBoard(index, number, isAlt: false),
      pressNumberOnBoardAltIntent: (index, number) =>
          controller.pressNumberOnBoard(index, number, isAlt: true),
      pressFreeNumber: (number) => number == 0
          ? controller.keypad.pressClear()
          : controller.keypad.pressNumber(number),
    );
  }
}

class NumberOnBoardPressedAction
    extends NumberPressedAction<PressNumberOnBoardIntent> {
  NumberOnBoardPressedAction(SudokuViewController controller)
      : super(controller);
}

class NumberOnBoardAltPressedAction
    extends NumberPressedAction<PressNumberOnBoardAltIntent> {
  NumberOnBoardAltPressedAction(SudokuViewController controller)
      : super(controller);
}

class FreeNumberPressedAction extends NumberPressedAction<PressFreeNumber> {
  FreeNumberPressedAction(SudokuViewController controller) : super(controller);
}

class BoardValidateAction extends Action<ValidateBoardIntent> {
  final SudokuViewController controller;

  BoardValidateAction(this.controller);

  @override
  Object? invoke(ValidateBoardIntent intent) {
    controller.actions.validate();
  }
}

class PlacementModeChangeAction extends Action<ChangePlacementModeIntent> {
  final SudokuViewController controller;

  PlacementModeChangeAction(this.controller);

  @override
  Object? invoke(ChangePlacementModeIntent intent) {
    controller.actions.toggleMode();
  }
}

class UndoAction extends Action<UndoIntent> {
  final SudokuViewController controller;

  UndoAction(this.controller);

  @override
  Object? invoke(UndoIntent intent) {
    controller.actions.undo();
  }
}

class BoardResetAction extends Action<ResetBoardIntent> {
  final SudokuViewController controller;

  BoardResetAction(this.controller);

  @override
  Object? invoke(ResetBoardIntent intent) {
    controller.actions.reset();
  }
}

class SudokuView extends ControllerWidget<SudokuViewController> {
  const SudokuView({
    Key? key,
    required ControllerHandle<SudokuViewController> controller,
    this.sudokuBoardKey,
  }) : super(
          key: key,
          controller: controller,
        );
  final Key? sudokuBoardKey;

  void onMaybeError(BuildContext context, Object? error) {
    if (error == null) {
      return;
    }
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: Text("Erro inesperado: $error")));
  }

  static final emptyActions = <Type, Action<Intent>>{
    PressTileIntent: DoNothingAction(),
    //PressNumberIntent: DoNothingAction(),
    PressNumberOnBoardIntent: DoNothingAction(),
    PressNumberOnBoardAltIntent: DoNothingAction(),
    PressFreeNumber: DoNothingAction(),
    ValidateBoardIntent: DoNothingAction(),
    ChangePlacementModeIntent: DoNothingAction(),
    UndoIntent: DoNothingAction(),
    ResetBoardIntent: DoNothingAction(),
  };

  static const shortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.digit0): PressFreeNumber(0),
    SingleActivator(LogicalKeyboardKey.digit1): PressFreeNumber(1),
    SingleActivator(LogicalKeyboardKey.digit2): PressFreeNumber(2),
    SingleActivator(LogicalKeyboardKey.digit3): PressFreeNumber(3),
    SingleActivator(LogicalKeyboardKey.digit4): PressFreeNumber(4),
    SingleActivator(LogicalKeyboardKey.digit5): PressFreeNumber(5),
    SingleActivator(LogicalKeyboardKey.digit6): PressFreeNumber(6),
    SingleActivator(LogicalKeyboardKey.digit7): PressFreeNumber(7),
    SingleActivator(LogicalKeyboardKey.digit8): PressFreeNumber(8),
    SingleActivator(LogicalKeyboardKey.digit9): PressFreeNumber(9),
    SingleActivator(LogicalKeyboardKey.keyV): ValidateBoardIntent(),
    SingleActivator(LogicalKeyboardKey.keyM): ChangePlacementModeIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(),
  };

  @override
  Widget build(ControllerContext<SudokuViewController> context) {
    context.useEventHandler<Object?>(
      controller.errorEvents,
      onMaybeError.apL(context),
    );
    final isLocked = context.use(controller.isLocked);
    final enabledActions = <Type, Action<Intent>>{
      PressTileIntent: TilePressedAction(controller),
      PressNumberOnBoardIntent: NumberOnBoardPressedAction(controller),
      PressNumberOnBoardAltIntent: NumberOnBoardAltPressedAction(controller),
      PressFreeNumber: FreeNumberPressedAction(controller),
      ValidateBoardIntent: BoardValidateAction(controller),
      ChangePlacementModeIntent: PlacementModeChangeAction(controller),
      UndoIntent: UndoAction(controller),
      ResetBoardIntent: BoardResetAction(controller),
    };
    return isLocked
        .map(
          (isLocked) => Actions(
            actions: isLocked ? emptyActions : enabledActions,
            child: Shortcuts(
              shortcuts: shortcuts,
              child: SudokuBoardIsLocked(
                isLocked: isLocked,
                child: SudokuViewLayout(
                  board: SudokuViewBoard(
                    controller: controller.board.handle,
                    sudokuBoardKey: sudokuBoardKey,
                  ),
                  keypad: SudokuBoardKeypad(
                    controller: controller.keypad.handle,
                  ),
                  actions: SudokuBoardActions(
                    controller: controller.actions.handle,
                  ),
                ),
              ),
            ),
          ),
        )
        .build();
  }
}
