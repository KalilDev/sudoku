import 'package:app/monadic.dart';
import '../view.dart';
import 'actions.dart';
import 'package:app/view/controller.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

import 'layout.dart';

const minKeypadDimension = 64.0;
const minKeypadSquare = Size.square(minKeypadDimension);
final ContextfulAction<ButtonStyle> unselectedkeypadStyle = outlineStyle.map(
  (style) => style.copyWith(
    fixedSize: MaterialStateProperty.all(minKeypadSquare),
    padding: MaterialStateProperty.all(EdgeInsets.all(2)),
  ),
);
final ContextfulAction<ButtonStyle> selectedkeypadStyle = filledStyle.map(
  (style) => style.copyWith(
    fixedSize: MaterialStateProperty.all(minKeypadSquare),
    padding: MaterialStateProperty.all(EdgeInsets.all(2)),
  ),
);

class _KeypadButtonChildWrapper extends StatelessWidget {
  const _KeypadButtonChildWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  static const maxChildSize = 48.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: maxChildSize,
          maxHeight: maxChildSize,
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: child,
        ),
      );
}

class KeypadButton extends StatelessWidget {
  const KeypadButton({
    Key? key,
    required this.isSelected,
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  final bool isSelected;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
        size: minKeypadSquare,
        child: OutlinedButton(
          onPressed: isLocked(context) ? null : onPressed,
          style: (isSelected
              ? selectedkeypadStyle
              : unselectedkeypadStyle)(context),
          child: _KeypadButtonChildWrapper(
            child: child,
          ),
        ),
      );
}

class SudokuBoardKeypad extends ControllerWidget<SudokuViewKeypadController> {
  const SudokuBoardKeypad({
    Key? key,
    required ControllerHandle<SudokuViewKeypadController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  Widget _buildNumber(BuildContext context, int n) => SizedBox.fromSize(
        size: minKeypadSquare,
        child: controller.selectedNumber
            .map((s) => s == n)
            .unique()
            .map((isSelected) => KeypadButton(
                  isSelected: isSelected,
                  onPressed: () => controller.pressNumber(n),
                  child: Text(n.toString()),
                ))
            .build(),
      );

  Widget _buildClear(BuildContext context) => SizedBox.fromSize(
        size: minKeypadSquare,
        child: controller.selectedNumber
            .map((s) => s == 0)
            .unique()
            .map((isSelected) => KeypadButton(
                  isSelected: isSelected,
                  onPressed: () => controller.pressClear(),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ))
            .build(),
      );

  @override
  Widget build(ControllerContext<SudokuViewKeypadController> context) {
    final padding = context.sizeClass.minimumMargins;
    final gutter = padding / 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Wrap(
        spacing: gutter,
        runSpacing: gutter,
        alignment: WrapAlignment.spaceEvenly,
        runAlignment: WrapAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < controller.side; i++)
            _buildNumber(context, i + 1),
          _buildClear(context),
        ],
      ),
    );
  }
}
