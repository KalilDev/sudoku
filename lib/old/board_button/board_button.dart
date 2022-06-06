import 'package:app/module/animation.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:material_you/material_you.dart';
import 'decoration.dart';
import 'text.dart';

class BoardButton extends StatelessWidget {
  const BoardButton({
    Key? key,
    this.onTap,
    required this.isLoading,
    required this.isSelected,
    required this.text,
    required this.isBottomText,
    required this.isInvalid,
    required this.animationOptions,
    required this.isInitial,
  }) : super(key: key);
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isSelected;
  final bool isInitial;
  final bool isBottomText;
  final bool isInvalid;
  final String text;
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
          isEnabled: !isInitial,
          isForegroundEnabled: !isLoading,
          isSelected: isSelected,
          isInvalid: isInvalid,
          animationOptions: animationOptions,
          child: Focus(
            canRequestFocus: !isInitial,
            descendantsAreFocusable: !isInitial,
            child: BoardButtonBase(
              onPressed: onTap,
              child: BoardButtonTextAnimation(
                text: text,
                isBottom: isBottomText,
                animationOptions: animationOptions,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BoardButtonBase extends ButtonStyleButton {
  const BoardButtonBase({
    Key? key,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
    required Widget? child,
  }) : super(
            key: key,
            onPressed: onPressed,
            onLongPress: onLongPress,
            onHover: onHover,
            onFocusChange: onFocusChange,
            style: style,
            focusNode: focusNode,
            autofocus: autofocus,
            clipBehavior: clipBehavior,
            child: child);
  static const maxButtonSize = 96.0;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    return ButtonStyle(
      maximumSize: MaterialStateProperty.all(Size.square(maxButtonSize)),
      fixedSize: MaterialStateProperty.all(Size.infinite),
      minimumSize: MaterialStateProperty.all(Size.square(0)),
      enableFeedback: true,
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor: MaterialStateProperty.all(Colors.transparent),
      overlayColor: MD3StateOverlayColor(
        context.colorScheme.onSurface,
        context.stateOverlayOpacity,
      ),
      shadowColor: MaterialStateProperty.all(context.theme.shadowColor),
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      shape: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.pressed)
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              )
            : const CircleBorder(),
      ),
      mouseCursor: MD3DisablableCursor(
        SystemMouseCursors.click,
        SystemMouseCursors.forbidden,
      ),
      visualDensity: context.theme.visualDensity,
      animationDuration: kThemeChangeDuration,
      elevation: MaterialStateProperty.all(0),
      alignment: Alignment.center,
      splashFactory: context.theme.splashFactory,
      tapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) => null;
}
