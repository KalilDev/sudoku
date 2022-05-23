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
import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
import 'package:flutter/foundation.dart';
part 'view.g.dart';

class NumberPressedAction extends Action<PressNumberIntent> {
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

// data PressNumberIntent = PressNumberOnBoardIntent SudokuBoardIndex int
//                        | PressNumberOnBoardAltIntent SudokuBoardIndex int
//                        | PressFreeNumber int
@data(
  #PressNumberIntent,
  [],
  adt.Union({
    #PressNumberOnBoardIntent: {
      #index: T(#SudokuBoardIndex),
      #number: T(#int),
    },
    #PressNumberOnBoardAltIntent: {
      #index: T(#SudokuBoardIndex),
      #number: T(#int),
    },
    #PressFreeNumber: {
      #number: T(#int),
    },
  }),
  mixin: [
    T(#IntentMixin),
    T(#Diagnosticable),
  ],
  // Cant be used because Diagnosticable has an different signature for
  // toString(). Kinda sucks tbh.
  deriveToString: false,
)
const Type _pressNumberIntent = PressNumberIntent;
mixin IntentMixin implements Intent {}

class BoardValidateAction extends Action<ValidateBoardIntent> {
  final SudokuViewController controller;

  BoardValidateAction(this.controller);

  @override
  Object? invoke(ValidateBoardIntent intent) {
    print('invoking board validate');
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
    print('invoking placement mode change');
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
    print('invoking undo');
    // TODO: implement invoke
    throw UnimplementedError();
  }
}

class ResetBoardIntent extends Intent {
  const ResetBoardIntent();
}

class BoardResetAction extends Action<ResetBoardIntent> {
  final SudokuViewController controller;

  BoardResetAction(this.controller);

  @override
  Object? invoke(ResetBoardIntent intent) {
    print('invoking board reset');
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
    final numberPressedAction = NumberPressedAction(controller);
    final enabledActions = <Type, Action<Intent>>{
      // PressNumberIntent: NumberPressedAction(controller),
      PressNumberOnBoardIntent: numberPressedAction,
      PressNumberOnBoardAltIntent: numberPressedAction,
      PressFreeNumber: numberPressedAction,
      ValidateBoardIntent: BoardValidateAction(controller),
      ChangePlacementModeIntent: PlacementModeChangeAction(controller),
      UndoIntent: UndoAction(controller),
      ResetBoardIntent: BoardResetAction(controller),
    };
    return isLocked
        .map(
          (isLocked) => Actions(
            actions: isLocked ? emptyActions : enabledActions,
            dispatcher: DebugDispatcher(),
            child: Shortcuts(
              shortcuts: shortcuts,
              manager: DebugShortcutManager(),
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

class DebugShortcutManager extends ShortcutManager {
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final r = super.handleKeypress(context, event);
    print('shortcut keypress $event result $r');
    print(super.shortcuts);
    return r;
  }
}

class DebugDispatcher extends ActionDispatcher {
  Object? invokeAction(Action<Intent> action, Intent intent,
      [BuildContext? context]) {
    print('invoke action $action intent $intent');
    return super.invokeAction(action, intent, context);
  }
}
