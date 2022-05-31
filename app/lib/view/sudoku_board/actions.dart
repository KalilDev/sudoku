library app.view.sudoku_board;

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
        return filledStyle;
      case SudokuPlacementMode.number:
        return outlinedActionAndKeypadButtonStyle;
    }
  }

  Widget _buildPlacementModeButton(
    BuildContext context,
    ContextfulAction<ButtonStyle> style,
    SudokuPlacementMode placementMode,
  ) =>
      _ActionButton(
        tooltip: placementMode == SudokuPlacementMode.number
            ? 'Editar possibilidades'
            : 'Editar numeros',
        child: const Icon(Icons.edit),
        style: style(context),
        onPressed: const ChangePlacementModeIntent(),
      );

  @override
  Widget build(BuildContext context) {
    final padding = context.sizeClass.minimumMargins;
    final paddingSquare = SizedBox.square(
      dimension: padding,
    );
    final children = [
      paddingSquare,
      const _ActionButton(
        tooltip: 'Resetar sudoku',
        child: Icon(Icons.refresh),
        onPressed: ResetBoardIntent(),
      ),
      const _ActionButton(
        tooltip: 'Validar Sudoku',
        child: Icon(Icons.check),
        onPressed: ValidateBoardIntent(),
      ),
      ValueListenableOwnerBuilder<SudokuPlacementMode>(
        valueListenable: placementMode,
        builder: (context, placementMode) =>
            (_buildPlacementModeButton.curry(context).asValueListenable >>
                    placementMode().map(_styleForPlacementMode) >>
                    placementMode())
                .build(),
      ),
      canUndo
          .map((canUndo) => _ActionButton(
                tooltip: 'Desfazer',
                child: const Icon(Icons.undo),
                onPressed: canUndo ? const UndoIntent() : null,
              ))
          .build(),
      paddingSquare,
    ];

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
            children: children,
          ),
        );
    }
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
    this.style,
    required this.onPressed,
  }) : super(key: key);
  final String tooltip;
  final Widget child;
  final ButtonStyle? style;
  final T? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? outlinedActionAndKeypadButtonStyle(context);
    final isLocked_ = isLocked(context);
    void invokeIntent() => Actions.invoke<T>(context, onPressed!);
    return Tooltip(
      message: (isLocked_ || onPressed == null) ? '' : tooltip,
      child: OutlinedButton(
        onPressed: isLocked_ || onPressed == null ? null : invokeIntent,
        style: style,
        child: child,
      ),
    );
  }
}
