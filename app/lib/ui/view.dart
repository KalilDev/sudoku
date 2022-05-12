import 'package:app/base/sudoku_data.dart';
import 'package:app/monadic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import '../view/controller.dart';
import 'src/actions.dart';
import 'src/board.dart';
import 'src/keypad.dart';
import 'src/layout.dart';

class NumberPressedAction extends Action<PressNumberIntent> {
  final SudokuViewController controller;

  NumberPressedAction(this.controller);

  @override
  Object? invoke(PressNumberIntent intent) {
    if (intent is PressNumberOnBoardIntent) {
      controller.pressNumberOnBoard(intent.index, intent.number, isAlt: false);
    } else if (intent is PressNumberOnBoardAltIntent) {
      controller.pressNumberOnBoard(intent.index, intent.number, isAlt: true);
    } else if (intent is PressFreeNumber) {
      if (intent.number == 0) {
        controller.keypad.pressClear();
      } else {
        controller.keypad.pressNumber(intent.number);
      }
    } else {
      throw TypeError();
    }
  }
}

// data PressNumberIntent = PressNumberOnBoardIntent SudokuBoardIndex int
//                        | PressNumberOnBoardAltIntent SudokuBoardIndex int
//                        | PressFreeNumber int
abstract class PressNumberIntent extends Intent {
  const PressNumberIntent._();
}

class PressNumberOnBoardIntent extends PressNumberIntent {
  final SudokuBoardIndex index;
  final int number;

  const PressNumberOnBoardIntent(this.index, this.number) : super._();
}

class PressNumberOnBoardAltIntent extends PressNumberIntent {
  final SudokuBoardIndex index;
  final int number;

  const PressNumberOnBoardAltIntent(this.index, this.number) : super._();
}

class PressFreeNumber extends PressNumberIntent {
  final int number;

  const PressFreeNumber(this.number) : super._();
}

class BoardValidateAction extends Action<ValidateBoardIntent> {
  final SudokuViewController controller;

  BoardValidateAction(this.controller);

  @override
  Object? invoke(ValidateBoardIntent intent) {
    // TODO: implement invoke
    throw UnimplementedError();
  }
}

class ValidateBoardIntent extends Intent {
  const ValidateBoardIntent();
}

class PlacementModeChangeAction extends Action<ChangePlacementModeIntent> {
  final SudokuViewController controller;

  PlacementModeChangeAction(this.controller);

  @override
  Object? invoke(ChangePlacementModeIntent intent) {
    // TODO: implement invoke
    throw UnimplementedError();
  }
}

class ChangePlacementModeIntent extends Intent {
  const ChangePlacementModeIntent();
}

class UndoAction extends Action<UndoIntent> {
  final SudokuViewController controller;

  UndoAction(this.controller);

  @override
  Object? invoke(UndoIntent intent) {
    // TODO: implement invoke
    throw UnimplementedError();
  }
}

class UndoIntent extends Intent {
  const UndoIntent();
}

final ContextfulAction<bool> isLocked = readC.map(SudokuBoardIsLocked.of);

class SudokuBoardIsLocked extends InheritedWidget {
  final bool isLocked;

  const SudokuBoardIsLocked({
    Key? key,
    required this.isLocked,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(SudokuBoardIsLocked oldWidget) =>
      oldWidget.isLocked != isLocked;

  static bool of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SudokuBoardIsLocked>()!
      .isLocked;
}

class SudokuView extends ControllerWidget<SudokuViewController> {
  const SudokuView({
    Key? key,
    required ControllerHandle<SudokuViewController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  void onMaybeError(BuildContext context, Object? error) {
    if (error == null) {
      return;
    }
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: Text("Erro inesperado: $error")));
  }

  static final emptyActions = <Type, Action<Intent>>{
    //PressNumberIntent: DoNothingAction(),
    PressNumberOnBoardIntent: DoNothingAction(),
    PressNumberOnBoardAltIntent: DoNothingAction(),
    PressFreeNumber: DoNothingAction(),
    ValidateBoardIntent: DoNothingAction(),
    ChangePlacementModeIntent: DoNothingAction(),
    UndoIntent: DoNothingAction(),
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
    final numberPressedAction = NumberPressedAction(controller);
    final enabledActions = <Type, Action<Intent>>{
      // PressNumberIntent: NumberPressedAction(controller),
      PressNumberOnBoardIntent: numberPressedAction,
      PressNumberOnBoardAltIntent: numberPressedAction,
      PressFreeNumber: numberPressedAction,
      ValidateBoardIntent: BoardValidateAction(controller),
      ChangePlacementModeIntent: PlacementModeChangeAction(controller),
      UndoIntent: UndoAction(controller),
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
