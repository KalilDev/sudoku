import 'package:app/util/l10n.dart';
import 'package:app/util/monadic.dart' hide colorScheme;
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:value_notifier/value_notifier.dart';

import 'actions.dart';
import 'flutter_intents.dart';
import 'layout.dart';
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
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: child,
            ),
          ),
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

    return MergeSemantics(
      child: SizedBox.fromSize(
        size: minKeypadSquare,
        child: OutlinedButton(
          onPressed: isLocked(context) ? null : invokeAction,
          style: (isSelected
              ? selectedkeypadStyle
              : unselectedkeypadStyle)(context),
          child: _KeypadButtonChildWrapper(
            child: BlockSemantics(
              child: child,
            ),
          ),
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
                  child: Text(
                    n.toString(),
                    semanticsLabel:
                        context.l10n.board_keypad_number.replaceAll('%n', '$n'),
                  ),
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
            .map((isSelected) => Tooltip(
                  message: context.l10n.board_keypad_clear,
                  child: KeypadButton(
                    isSelected: isSelected,
                    number: 0,
                    child: Semantics(
                      label: context.l10n.board_keypad_clear,
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.close,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ))
            .build(),
      );

  @override
  Widget build(BuildContext context) {
    final padding = context.sizeClass.minimumMargins;
    final gutter = padding / 2;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: ValueListenableOwnerBuilder<int?>(
        valueListenable: selectedNumber,
        builder: (context, selectedNumber) => _KeypadLayout(
            spacing: gutter,
            endAlignment: viewLayoutOrientation(context) == Orientation.portrait
                ? mediaQuery(context).size.aspectRatio < 3 / 4
                    ? _Alignment.center
                    : _Alignment.end
                : mediaQuery(context).size.aspectRatio < 5 / 4
                    ? _Alignment.end
                    : _Alignment.center,
            children: [
              for (int i = 0; i < side; i++)
                _buildNumber(context, i + 1, selectedNumber()),
              _buildClear(context, selectedNumber()),
            ]),
      ),
    );
  }
}

enum _Alignment {
  start,
  center,
  end,
}

class _KeypadLayout extends StatelessWidget {
  const _KeypadLayout({
    Key? key,
    required this.spacing,
    required this.endAlignment,
    required this.children,
  }) : super(key: key);
  final double spacing;
  final _Alignment endAlignment;
  final List<Widget> children;

  int _countPerRowFor(double width) {
    for (var c = 1; c <= children.length; c++) {
      final spaceOccupied = c * minKeypadDimension + (c - 1) * spacing;
      if (spaceOccupied > width) {
        return c - 1;
      }
    }
    return children.length;
  }

  CrossAxisAlignment _crossAxisAlignment() {
    switch (endAlignment) {
      case _Alignment.start:
        return CrossAxisAlignment.start;
      case _Alignment.center:
        return CrossAxisAlignment.center;
      case _Alignment.end:
        return CrossAxisAlignment.end;
    }
  }

  Widget _buildLayout(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final maxCountPerRow = _countPerRowFor(width);
    final rows = (children.length / maxCountPerRow).ceil();
    final inRow = (children.length / rows).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: _crossAxisAlignment(),
      children: [
        for (var r = 0; r < rows; r++) ...[
          if (r != 0) SizedBox(height: spacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = r * inRow;
                  i < (r + 1) * inRow && i < children.length;
                  i++) ...[
                if (i != r * inRow) SizedBox(width: spacing),
                children[i]
              ],
            ],
          )
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _buildLayout);
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
