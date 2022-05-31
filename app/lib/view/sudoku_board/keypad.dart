import 'package:app/util/monadic.dart' hide colorScheme;
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

import 'actions.dart';
import 'flutter_intents.dart';
import 'locking.dart';
import 'style.dart';

const minKeypadDimension = 64.0;
const minKeypadSquare = Size.square(minKeypadDimension);
final ContextfulAction<ButtonStyle> unselectedkeypadStyle =
    sudokuOutlinedButtonStyle.map(
  (style) => style.copyWith(
    fixedSize: MaterialStateProperty.all(minKeypadSquare),
    padding: MaterialStateProperty.all(EdgeInsets.all(2)),
  ),
);
final ContextfulAction<ButtonStyle> selectedkeypadStyle = colorScheme.bind(
  (scheme) => sudokuFilledButtonStyle.map(
    (style) => style.copyWith(
      fixedSize: MaterialStateProperty.all(minKeypadSquare),
      padding: MaterialStateProperty.all(EdgeInsets.all(2)),
      side: MaterialStateProperty.all(BorderSide.none),
    ),
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
    required this.number,
    required this.child,
  }) : super(key: key);
  final bool isSelected;
  final int number;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    void invokeAction() {
      Actions.invoke<PressFreeNumber>(context, PressFreeNumber(number));
    }

    return SizedBox.fromSize(
      size: minKeypadSquare,
      child: OutlinedButton(
        onPressed: isLocked(context) ? null : invokeAction,
        style:
            (isSelected ? selectedkeypadStyle : unselectedkeypadStyle)(context),
        child: _KeypadButtonChildWrapper(
          child: child,
        ),
      ),
    );
  }
}

class SudokuBoardKeypadWidget extends StatelessWidget {
  const SudokuBoardKeypadWidget({
    Key? key,
    required this.side,
    required this.selectedNumber,
  }) : super(key: key);
  final int side;
  final ValueListenable<int?> selectedNumber;

  Widget _buildNumber(
          BuildContext context, int n, ValueListenable<int?> selectedNumber) =>
      SizedBox.fromSize(
        size: minKeypadSquare,
        child: selectedNumber
            .map((s) => s == n)
            .unique()
            .map((isSelected) => KeypadButton(
                  isSelected: isSelected,
                  number: n,
                  child: Text(n.toString()),
                ))
            .build(),
      );

  Widget _buildClear(
          BuildContext context, ValueListenable<int?> selectedNumber) =>
      SizedBox.fromSize(
        size: minKeypadSquare,
        child: selectedNumber
            .map((s) => s == 0)
            .unique()
            .map((isSelected) => KeypadButton(
                  isSelected: isSelected,
                  number: 0,
                  child: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ))
            .build(),
      );

  @override
  Widget build(BuildContext context) {
    final padding = context.sizeClass.minimumMargins;
    final gutter = padding / 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: ValueListenableOwnerBuilder<int?>(
        valueListenable: selectedNumber,
        builder: (context, selectedNumber) => Wrap(
          spacing: gutter,
          runSpacing: gutter,
          alignment: WrapAlignment.spaceEvenly,
          runAlignment: WrapAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < side; i++)
              _buildNumber(context, i + 1, selectedNumber()),
            _buildClear(context, selectedNumber()),
          ],
        ),
      ),
    );
  }
}

class SudokuBoardKeypad extends ControllerWidget<SudokuViewKeypadController> {
  const SudokuBoardKeypad({
    Key? key,
    required ControllerHandle<SudokuViewKeypadController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  @override
  Widget build(ControllerContext<SudokuViewKeypadController> context) {
    final selectedNumber = context.use(controller.selectedNumber);
    return SudokuBoardKeypadWidget(
      selectedNumber: selectedNumber,
      side: controller.side,
    );
  }
}
