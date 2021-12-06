import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:material_you/material_you.dart';
import 'package:sudoku/widgets/board_button/container.dart';
import 'package:sudoku/widgets/board_button/text.dart';
import 'package:sudoku_presentation/models.dart';

class BoardButton extends StatelessWidget {
  const BoardButton({
    Key key,
    this.onTap,
    this.onFocused,
    this.isSelected,
    this.text,
    this.isBottomText,
    this.animationOptions,
    this.isInitial,
  }) : super(key: key);
  final VoidCallback onTap;
  final VoidCallback onFocused;
  final bool isSelected;
  final bool isInitial;
  final bool isBottomText;
  final String text;
  final AnimationOptions animationOptions;

  void _onFocusChange(bool focused) {
    if (focused) {
      onFocused?.call();
    }
  }

  static const maxButtonSize = 156.0;

  @override
  Widget build(BuildContext context) {
    final sizeClassPaddingMap = {
      MD3WindowSizeClass.compact: 4.0,
      MD3WindowSizeClass.medium: 6.0,
      MD3WindowSizeClass.expanded: 8.0,
    };

    return Padding(
      padding: EdgeInsets.all(sizeClassPaddingMap[context.sizeClass]),
      child: BoardButtonContainer(
        isEnabled: !isInitial,
        isSelected: isSelected,
        onFocusChanged: _onFocusChange,
        animationOptions: animationOptions,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: maxButtonSize,
            maxWidth: maxButtonSize,
          ),
          child: InkResponse(
            onTap: onTap,
            child: BoardButtonTextAnimation(
              text: text,
              isBottom: isBottomText,
              animationOptions: animationOptions,
            ),
          ),
        ),
      ),
    );
  }
}
