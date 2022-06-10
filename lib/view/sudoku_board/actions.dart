library app.view.sudoku_board;

import 'package:app/util/l10n.dart';
import 'package:app/util/monadic.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/utils.dart';
import 'package:value_notifier/value_notifier.dart';

import 'flutter_intents.dart';
import 'layout.dart';
import 'locking.dart';
import 'style.dart';

// ignore: prefer_function_declarations_over_variables
final ContextfulAction<MonetColorScheme> colorScheme =
    (BuildContext context) => context.colorScheme;

const ContextfulAction<ButtonStyle> outlineStyle =
    MD3OutlinedButton.defaultStyleOf;

// ignore: prefer_function_declarations_over_variables
final ContextfulAction<ButtonStyle> filledStyle = (BuildContext context) {
  final scheme = context.colorScheme;

  return FilledButton.styleFrom(
    backgroundColor: scheme.primary,
    foregroundColor: scheme.onPrimary,
    disabledColor: scheme.onSurface,
    stateLayerOpacityTheme: context.stateOverlayOpacity,
  );
};

// ignore: prefer_function_declarations_over_variables
final ContextfulAction<ButtonStyle> filledTonalStyle = (BuildContext context) {
  final scheme = context.colorScheme;

  return FilledButton.styleFrom(
    backgroundColor: scheme.secondary,
    foregroundColor: scheme.onSecondary,
    disabledColor: scheme.onSurface,
    stateLayerOpacityTheme: context.stateOverlayOpacity,
  );
};

class SudokuBoardActionsWidget extends StatelessWidget {
  const SudokuBoardActionsWidget({
    Key? key,
    required this.placementMode,
    required this.canUndo,
  }) : super(key: key);
  final ValueListenable<SudokuPlacementMode> placementMode;
  final ValueListenable<bool> canUndo;

  static ContextfulAction<ButtonStyle> _styleForPlacementMode(
      SudokuPlacementMode mode) {
    switch (mode) {
      case SudokuPlacementMode.possibility:
        return sudokuFilledButtonStyle;
      case SudokuPlacementMode.number:
        return sudokuOutlinedButtonStyle;
    }
  }

  Widget _buildPlacementModeButton(
    BuildContext context,
    SudokuPlacementMode placementMode,
  ) =>
      Semantics(
        onTapHint: placementMode == SudokuPlacementMode.number
            ? context.l10n.board_actions_edit_possibilities
            : context.l10n.board_actions_edit_numbers,
        child: _ActionButton(
          tooltip: placementMode == SudokuPlacementMode.number
              ? context.l10n.board_actions_edit_possibilities
              : context.l10n.board_actions_edit_numbers,
          child: Icon(
            Icons.edit,
            semanticLabel: placementMode == SudokuPlacementMode.number
                ? context.l10n.board_actions_editing_numbers
                : context.l10n.board_actions_editing_possibilities,
          ),
          isSelected: placementMode != SudokuPlacementMode.number,
          onPressed: const ChangePlacementModeIntent(),
        ),
      );

  List<Widget> _buildChildren(
    BuildContext context,
    ValueListenable<SudokuPlacementMode> placementMode,
    ValueListenable<bool> canUndo,
  ) {
    final padding = context.sizeClass.minimumMargins;
    final paddingSquare = SizedBox.square(
      dimension: padding,
    );
    return [
      paddingSquare,
      _ActionButton(
        tooltip: context.l10n.board_actions_reset_sudoku,
        child: Icon(
          Icons.refresh,
          semanticLabel: context.l10n.board_actions_reset_sudoku,
        ),
        onPressed: ResetBoardIntent(),
      ),
      _ActionButton(
        tooltip: context.l10n.board_actions_validate_sudoku,
        child: Icon(
          Icons.check,
          semanticLabel: context.l10n.board_actions_validate_sudoku,
        ),
        onPressed: ValidateBoardIntent(),
      ),
      ValueListenableOwnerBuilder<SudokuPlacementMode>(
        valueListenable: placementMode,
        builder: (context, placementMode) =>
            (_buildPlacementModeButton.curry(context).asValueListenable >>
                    placementMode())
                .build(),
      ),
      canUndo
          .map((canUndo) => _ActionButton(
                tooltip: context.l10n.board_actions_undo,
                child: Icon(
                  Icons.undo,
                  semanticLabel: context.l10n.board_actions_undo,
                ),
                onPressed: canUndo ? const UndoIntent() : null,
              ))
          .build(),
      paddingSquare,
    ];
  }

  Widget _build(
    BuildContext context,
    ValueListenable<SudokuPlacementMode> placementMode,
    ValueListenable<bool> canUndo,
  ) {
    final padding = context.sizeClass.minimumMargins;
    final children = _buildChildren(context, placementMode, canUndo);

    switch (viewLayoutOrientation(context)) {
      case Orientation.portrait:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        );
      case Orientation.landscape:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            verticalDirection: VerticalDirection.up,
            children: children,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableOwnerBuilder<SudokuPlacementMode>(
      valueListenable: placementMode,
      builder: (context, placementMode) => ValueListenableOwnerBuilder<bool>(
        valueListenable: canUndo,
        builder: (context, canUndo) => _build(
          context,
          placementMode(),
          canUndo(),
        ),
      ),
    );
  }
}

class SudokuBoardActions extends ControllerWidget<SudokuViewActionsController> {
  const SudokuBoardActions({
    Key? key,
    required ControllerHandle<SudokuViewActionsController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  @override
  Widget build(ControllerContext<SudokuViewActionsController> context) {
    final placementMode = context.use(controller.placementMode);
    final canUndo = context.use(controller.canUndo);
    void onResetBoard() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.board_actions_reseted)),
      );
    }

    void onRequestValidation() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.board_actions_validated)),
      );
    }

    context.useActionHandler(controller.didReset, onResetBoard);
    context.useActionHandler(controller.didValidate, onRequestValidation);

    return SudokuBoardActionsWidget(
      placementMode: placementMode,
      canUndo: canUndo,
    );
  }
}

class _ActionButton<T extends Intent> extends StatelessWidget {
  const _ActionButton({
    Key? key,
    required this.tooltip,
    required this.child,
    this.isSelected = false,
    required this.onPressed,
  }) : super(key: key);
  final String tooltip;
  final Widget child;
  final bool isSelected;
  final T? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = isSelected
        ? sudokuFilledButtonStyle(context)
        : sudokuOutlinedButtonStyle(context);
    final orientation = viewLayoutOrientation(context);
    final rotated = orientation == Orientation.landscape;

    final isLocked_ = isLocked(context);
    void invokeIntent() => Actions.invoke<T>(context, onPressed!);
    return Tooltip(
      message: (isLocked_ || onPressed == null) ? '' : tooltip,
      child: RotatedBox(
        quarterTurns: rotated ? 1 : 0,
        child: OutlinedButton(
          onPressed: isLocked_ || onPressed == null ? null : invokeIntent,
          style: style,
          child: RotatedBox(
            quarterTurns: rotated ? -1 : 0,
            child: BlockSemantics(child: child),
          ),
        ),
      ),
    );
  }
}
