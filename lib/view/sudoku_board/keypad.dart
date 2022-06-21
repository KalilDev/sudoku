import 'dart:ui';

import 'package:app/util/l10n.dart';
import 'package:app/util/monadic.dart' hide colorScheme;
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                  : unselectedkeypadStyle)(context)
              .copyWith(
                  textStyle: MaterialStateProperty.all(
            context.textTheme.headlineSmall,
          )),
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

  static int _maxCrossAxiesForSide(int side) {
    switch (side) {
      case 1:
        return 1;
      case 4:
        return 1;
      case 9:
        return 2;
      case 16:
        return 4;
      default:
        throw UnimplementedError();
    }
  }

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
            axis: _MainAxis.vertical,
            maxCrossAxies: _maxCrossAxiesForSide(side),
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

enum _MainAxis { vertical, horizontal }

typedef _AxisBuilder = Widget Function({
  MainAxisSize mainAxisSize,
  CrossAxisAlignment crossAxisAlignment,
  required List<Widget> children,
});

class _KeypadLayout extends StatelessWidget {
  const _KeypadLayout({
    Key? key,
    required this.spacing,
    required this.endAlignment,
    required this.children,
    required this.axis,
    required this.maxCrossAxies,
  }) : super(key: key);
  final double spacing;
  final _Alignment endAlignment;
  final _MainAxis axis;
  final int maxCrossAxies;
  final List<Widget> children;

  int _countPerCrossAxisFor(double crossAxis) {
    for (var c = 1; c <= children.length; c++) {
      final spaceOccupied = c * minKeypadDimension + (c - 1) * spacing;
      if (spaceOccupied > crossAxis) {
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

  Widget _mainAxisBuilder(
          {MainAxisSize mainAxisSize = MainAxisSize.max,
          CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
          required List<Widget> children}) =>
      axis == _MainAxis.vertical
          ? Column(
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            )
          : Row(
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            );
  Widget _crossAxisBuilder(
          {MainAxisSize mainAxisSize = MainAxisSize.max,
          CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
          required List<Widget> children}) =>
      axis == _MainAxis.vertical
          ? Row(
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            )
          : Column(
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            );

  Widget _buildLayout(BuildContext context, BoxConstraints constraints) {
    final crossAxis = axis == _MainAxis.vertical
        ? constraints.maxWidth
        : constraints.maxHeight;
    final maxCountPerCrossAxis = _countPerCrossAxisFor(crossAxis);
    final crossAxises =
        (children.length / maxCountPerCrossAxis).ceil().clamp(0, maxCrossAxies);
    final inCrossAxis = (children.length / crossAxises).ceil();
    final spacingW = SizedBox.square(dimension: spacing);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: _mainAxisBuilder(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _crossAxisAlignment(),
        children: [
          for (var c = 0; c < crossAxises; c++) ...[
            if (c != 0) spacingW,
            _crossAxisBuilder(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = c * inCrossAxis;
                    i < (c + 1) * inCrossAxis && i < children.length;
                    i++) ...[if (i != c * inCrossAxis) spacingW, children[i]],
              ],
            )
          ]
        ],
      ),
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
