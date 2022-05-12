import 'package:app/monadic.dart';
import 'package:app/view/controller.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

import '../../view/data.dart';
import '../view.dart';
import 'layout.dart';

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
    final placementModeStyle = context.use(controller.placementMode.map((mode) {
      switch (mode) {
        case SudokuPlacementMode.possibility:
          return filledTonalStyle;
        case SudokuPlacementMode.number:
          return outlineStyle;
      }
    }));
    final canUndo = context.use(controller.canUndo);
    final padding = context.sizeClass.minimumMargins;
    final paddingSquare = SizedBox.square(
      dimension: padding,
    );
    final children = [
      paddingSquare,
      _ActionButton(
        child: const Icon(Icons.refresh),
        onPressed: controller.reset,
      ),
      _ActionButton(
        child: const Icon(Icons.check),
        onPressed: controller.validate,
      ),
      placementModeStyle
          .map((style) => _ActionButton(
                child: const Icon(Icons.edit),
                style: style(context),
                onPressed: controller.toggleMode,
              ))
          .build(),
      canUndo
          .map((canUndo) => _ActionButton(
                child: const Icon(Icons.undo),
                onPressed: canUndo ? controller.undo : null,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    Key? key,
    required this.child,
    this.style,
    required this.onPressed,
  }) : super(key: key);
  final Widget child;
  final ButtonStyle? style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? outlineStyle(context);
    return OutlinedButton(
      onPressed: isLocked(context) ? null : onPressed,
      style: style,
      child: child,
    );
  }
}