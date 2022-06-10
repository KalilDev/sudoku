import 'package:app/module/animation.dart';
import 'package:app/view/sudoku_board/locking.dart';
import 'package:app/viewmodel/sudoku_board.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:material_you/material_you.dart';
import 'decoration.dart';
import 'text.dart';

class BoardButton extends StatelessWidget {
  const BoardButton({
    Key? key,
    this.onTap,
    required this.animationOptions,
    required this.tile,
    required this.isSelected,
  }) : super(key: key);
  final VoidCallback? onTap;
  final SudokuTile tile;
  final bool isSelected;
  final AnimationOptions animationOptions;

  static const maxButtonSize = 156.0;

  @override
  Widget build(BuildContext context) {
    final sizeClassPaddingMap = {
      MD3WindowSizeClass.compact: 4.0,
      MD3WindowSizeClass.medium: 6.0,
      MD3WindowSizeClass.expanded: 8.0,
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(sizeClassPaddingMap[context.sizeClass]!),
        child: AnimatedBoardButtonDecoration(
          isEnabled: onTap != null,
          isForegroundEnabled: !isLocked(context),
          isSelected: isSelected,
          isInvalid: tile.visit(
            permanent: (_) => false,
            number: (_, v) => v == Validation.invalid,
            possibilities: (_) => false,
          ),
          animationOptions: animationOptions,
          child: Focus(
            canRequestFocus: true,
            descendantsAreFocusable: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: maxButtonSize,
                maxWidth: maxButtonSize,
              ),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: BoardButtonTextAnimation(
                  text: tile.visit(
                    permanent: (n) => '$n',
                    number: (n, _) => '$n',
                    possibilities: (ps) => ps.join(' '),
                  ),
                  isBottom: tile.visit(
                    permanent: (_) => false,
                    number: (_, v) => false,
                    possibilities: (_) => true,
                  ),
                  animationOptions: animationOptions,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
