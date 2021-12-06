import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';
import 'package:sudoku_presentation/models.dart';

import 'speed.dart';

class BoardButtonContainer extends StatefulWidget {
  const BoardButtonContainer({
    Key key,
    this.isEnabled,
    this.isSelected,
    this.onFocusChanged,
    this.animationOptions,
    this.child,
  }) : super(key: key);
  final bool isEnabled;
  final bool isSelected;
  final ValueChanged<bool> onFocusChanged;
  final AnimationOptions animationOptions;
  final Widget child;

  @override
  _BoardButtonContainerState createState() => _BoardButtonContainerState();
}

class _BoardButtonContainerState extends State<BoardButtonContainer> {
  MaterialStateProperty<Color> backgroundColor;
  MaterialStateProperty<Color> foregroundColor;

  void didChangeDependencies() {
    super.didChangeDependencies();
    final scheme = context.colorScheme;
    backgroundColor = MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return scheme.surfaceVariant.withOpacity(0.38);
      }
      if (states.contains(MaterialState.selected)) {
        return scheme.tertiaryContainer;
      }
      return Colors.transparent;
    });
    foregroundColor = MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return scheme.onSurface;
      }
      if (states.contains(MaterialState.selected)) {
        return scheme.onTertiaryContainer;
      }
      return scheme.onSurface;
    });
  }

  @override
  Widget build(BuildContext context) {
    final states = {
      if (!widget.isEnabled) MaterialState.disabled,
      if (widget.isSelected) MaterialState.selected,
    };
    return Focus(
      onFocusChange: widget.onFocusChanged,
      canRequestFocus: widget.isEnabled,
      descendantsAreFocusable: widget.isEnabled,
      skipTraversal: !widget.isEnabled,
      child: _AnimatedBoardButtonContainer(
        backgroundColor: backgroundColor.resolve(states),
        animateBackground: widget.animationOptions.selectColor,
        foregroundColor: foregroundColor.resolve(states),
        animateForeground: widget.animationOptions.textColor,
        duration: durationForSpeed(widget.animationOptions.speed),
        backgroundPosition:
            (widget.isSelected || !widget.isEnabled) ? 1.0 : 0.0,
        animateBackgroundPosition: widget.animationOptions.selectSize,
        child: widget.child,
      ),
    );
  }
}

class _AnimatedBoardButtonContainer extends ImplicitlyAnimatedWidget {
  const _AnimatedBoardButtonContainer({
    Key key,
    this.backgroundColor,
    this.animateBackground,
    this.foregroundColor,
    this.animateForeground,
    this.backgroundPosition,
    this.animateBackgroundPosition,
    Curve curve = Curves.linear,
    Duration duration = kThemeChangeDuration,
    this.child,
  }) : super(
          key: key,
          curve: curve,
          duration: duration,
        );

  final Color backgroundColor;
  final bool animateBackground;
  final Color foregroundColor;
  final bool animateForeground;
  final double backgroundPosition;
  final bool animateBackgroundPosition;
  final Widget child;

  @override
  _AnimatedBoardButtonContainerState createState() =>
      _AnimatedBoardButtonContainerState();
}

class _AnimatedBoardButtonContainerState
    extends ImplicitlyAnimatedWidgetState<_AnimatedBoardButtonContainer> {
  ColorTween backgroundColor;
  ColorTween foregroundColor;
  Tween<double> backgroundPosition;

  @override
  void forEachTween(TweenVisitor visitor) {
    if (widget.animateBackground) {
      backgroundColor = visitor(
        backgroundColor,
        widget.backgroundColor,
        (c) => ColorTween(begin: c as Color),
      ) as ColorTween;
    } else {
      backgroundColor = ColorTween(
          begin: widget.backgroundColor, end: widget.backgroundColor);
    }
    if (widget.animateForeground) {
      foregroundColor = visitor(
        foregroundColor,
        widget.foregroundColor,
        (c) => ColorTween(begin: c as Color),
      ) as ColorTween;
    } else {
      foregroundColor = ColorTween(
          begin: widget.foregroundColor, end: widget.foregroundColor);
    }
    if (widget.animateBackgroundPosition) {
      backgroundPosition = visitor(
        backgroundPosition,
        widget.backgroundPosition,
        (p) => Tween<double>(begin: p as double),
      ) as Tween<double>;
    } else {
      backgroundPosition = Tween(
          begin: widget.backgroundPosition, end: widget.backgroundPosition);
    }
  }

  Widget _foreground(
    Color foregroundColor, {
    Widget child,
  }) =>
      DefaultTextStyle.merge(
        style: TextStyle(color: foregroundColor),
        child: IconTheme.merge(
          data: IconThemeData(color: foregroundColor),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bgPosAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.bounceInOut,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final bg = backgroundColor.evaluate(animation);
        final bgPos = backgroundPosition.evaluate(bgPosAnimation);
        return Ink(
          decoration: BoxDecoration(
            color: bg,
            gradient: RadialGradient(
              center: Alignment.center,
              colors: [bg, bg, bg.withOpacity(0.0), bg.withOpacity(0.0)],
              stops: [0.0, bgPos, bgPos, 1.0],
            ),
            shape: BoxShape.circle,
          ),
          child: _foreground(
            foregroundColor.evaluate(animation),
            child: widget.child,
          ),
        );
      },
    );
  }
}
