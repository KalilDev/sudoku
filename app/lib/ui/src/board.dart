import 'package:app/old/board_button/board_button.dart';
import 'package:app/old/models/animation_options.dart';
import 'package:app/view/controller.dart';
import 'package:app/view/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:value_notifier/value_notifier.dart';

import '../../base/sudoku_data.dart';
import '../view.dart';
import 'layout.dart';

const AnimationOptions defaultAnimationOptions = AnimationOptions(
  selectSize: true,
  selectColor: true,
  textPosition: true,
  textOpacity: true,
  textSize: true,
  textColor: true,
  textString: true,
  speed: AnimationSpeed.normal,
);

class _TileWidget extends StatelessWidget {
  const _TileWidget({
    Key? key,
    required this.tile,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final SudokuTile tile;
  final bool? isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => BoardButton(
        onTap: tile is Permanent ? null : onPressed,
        isLoading: isLocked(context),
        isSelected: isSelected ?? false,
        text: tile.visit(
          permanent: (n) => n.toString(),
          number: (n, _) => n.toString(),
          possibilities: (ps) => (ps.toList()..sort()).join(' '),
        ),
        isBottomText: tile is Possibilities,
        isInvalid:
            tile is Number && (tile as Number).validation == Validation.invalid,
        animationOptions: defaultAnimationOptions,
        isInitial: tile is Permanent,
      );
}

class SudokuViewBoard extends ControllerWidget<SudokuViewBoardController> {
  const SudokuViewBoard({
    Key? key,
    required ControllerHandle<SudokuViewBoardController> controller,
  }) : super(
          key: key,
          controller: controller,
        );

  static final _indexedShortcutCache =
      <SudokuBoardIndex, Map<ShortcutActivator, Intent>>{};
  static Map<ShortcutActivator, Intent> shortcutsForIndex(
          SudokuBoardIndex index) =>
      _indexedShortcutCache.putIfAbsent(
          index,
          () => {
                const SingleActivator(LogicalKeyboardKey.digit0):
                    PressNumberOnBoardIntent(index, 0),
                const SingleActivator(LogicalKeyboardKey.digit1):
                    PressNumberOnBoardIntent(index, 1),
                const SingleActivator(LogicalKeyboardKey.digit2):
                    PressNumberOnBoardIntent(index, 2),
                const SingleActivator(LogicalKeyboardKey.digit3):
                    PressNumberOnBoardIntent(index, 3),
                const SingleActivator(LogicalKeyboardKey.digit4):
                    PressNumberOnBoardIntent(index, 4),
                const SingleActivator(LogicalKeyboardKey.digit5):
                    PressNumberOnBoardIntent(index, 5),
                const SingleActivator(LogicalKeyboardKey.digit6):
                    PressNumberOnBoardIntent(index, 6),
                const SingleActivator(LogicalKeyboardKey.digit7):
                    PressNumberOnBoardIntent(index, 7),
                const SingleActivator(LogicalKeyboardKey.digit8):
                    PressNumberOnBoardIntent(index, 8),
                const SingleActivator(LogicalKeyboardKey.digit9):
                    PressNumberOnBoardIntent(index, 9),
                const SingleActivator(LogicalKeyboardKey.digit0, control: true):
                    PressNumberOnBoardAltIntent(index, 0),
                const SingleActivator(LogicalKeyboardKey.digit1, control: true):
                    PressNumberOnBoardAltIntent(index, 1),
                const SingleActivator(LogicalKeyboardKey.digit2, control: true):
                    PressNumberOnBoardAltIntent(index, 2),
                const SingleActivator(LogicalKeyboardKey.digit3, control: true):
                    PressNumberOnBoardAltIntent(index, 3),
                const SingleActivator(LogicalKeyboardKey.digit4, control: true):
                    PressNumberOnBoardAltIntent(index, 4),
                const SingleActivator(LogicalKeyboardKey.digit5, control: true):
                    PressNumberOnBoardAltIntent(index, 5),
                const SingleActivator(LogicalKeyboardKey.digit6, control: true):
                    PressNumberOnBoardAltIntent(index, 6),
                const SingleActivator(LogicalKeyboardKey.digit7, control: true):
                    PressNumberOnBoardAltIntent(index, 7),
                const SingleActivator(LogicalKeyboardKey.digit8, control: true):
                    PressNumberOnBoardAltIntent(index, 8),
                const SingleActivator(LogicalKeyboardKey.digit9, control: true):
                    PressNumberOnBoardAltIntent(index, 9),
              });

  @override
  Widget build(ControllerContext<SudokuViewBoardController> context) {
    final board = context.useLazy((c) => c.board);
    final selected = context.use(controller.selectedIndex);
    return _GridLayout(
      child: board.map((board) {
        Widget buildChild(BuildContext context, SudokuBoardIndex index) {
          final tile = matrixGetAt(board, index);
          return Shortcuts(
            shortcuts: shortcutsForIndex(index),
            child: selected
                .view()
                // Ensure we are not doing useless rebuilds by only querying the
                // current index
                .map((selected) => selected == null ? null : selected == index)
                .unique()
                .map(
                  (isSelected) => _TileWidget(
                    tile: tile,
                    isSelected: isSelected,
                    onPressed: () => controller.pressTile(index),
                  ),
                )
                .build(),
          );
        }

        return _BoardGrid(
          side: controller.side,
          buildChild: buildChild,
        );
      }).build(),
    );
  }
}

class _GridLayout extends StatelessWidget {
  const _GridLayout({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: child,
          ),
        ),
      );
}

class _BoardGrid extends StatelessWidget {
  const _BoardGrid({
    Key? key,
    this.padding = 0,
    required this.side,
    required this.buildChild,
  }) : super(key: key);
  final double padding;
  final int side;
  final Widget Function(BuildContext, SudokuBoardIndex) buildChild;

  @override
  Widget build(BuildContext context) {
    final paddingSquare = SizedBox(
      height: padding,
      width: padding,
    );
    return Column(
      children: List.generate(
        side * 2 - 1,
        (twoJ) => twoJ % 2 != 0
            ? paddingSquare
            : Expanded(
                child: Row(
                  children: List.generate(
                    side * 2 - 1,
                    (twoI) => twoI % 2 != 0
                        ? paddingSquare
                        : Expanded(
                            child: buildChild(
                              context,
                              SudokuBoardIndex(twoI ~/ 2, twoJ ~/ 2),
                            ),
                          ),
                    growable: false,
                  ),
                ),
              ),
        growable: false,
      ),
    );
  }
}
