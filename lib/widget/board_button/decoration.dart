import 'package:app/module/animation.dart';
import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';

import 'speed.dart';

class AnimatedBoardButtonDecoration extends StatefulWidget {
  const AnimatedBoardButtonDecoration({
    Key? key,
    required this.isEnabled,
    required this.isForegroundEnabled,
    required this.isSelected,
    required this.isInvalid,
    required this.animationOptions,
    required this.child,
  }) : super(key: key);
  final bool isEnabled;
  final bool isForegroundEnabled;
  final bool isSelected;
  final bool isInvalid;
  final AnimationOptions animationOptions;
  final Widget child;

  @override
  _AnimatedBoardButtonDecorationState createState() =>
      _AnimatedBoardButtonDecorationState();
}

class _AnimatedBoardButtonDecorationState
    extends State<AnimatedBoardButtonDecoration> {
  late MaterialStateProperty<Color> backgroundColor;
  late MaterialStateProperty<Color> foregroundColor;

  void didChangeDependencies() {
    super.didChangeDependencies();
    final scheme = context.colorScheme;
    backgroundColor = MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return scheme.surfaceVariant.withOpacity(0.6);
      }
      if (states.contains(MaterialState.selected)) {
        return scheme.tertiaryContainer;
      }
      return widget.isInvalid ? scheme.error : Colors.transparent;
    });
    foregroundColor = MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return scheme.onSurface.withOpacity(0.38 / 0.8);
      }
      if (states.contains(MaterialState.selected)) {
        return scheme.onTertiaryContainer;
      }
      return widget.isInvalid ? scheme.onError : scheme.onSurface;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundStates = {
      if (!widget.isEnabled) MaterialState.disabled,
      if (widget.isSelected) MaterialState.selected,
    };
    final foregroundStates = {
      if (!widget.isForegroundEnabled) MaterialState.disabled,
      if (widget.isSelected) MaterialState.selected,
    };
    return _AnimatedBoardButtonContainer(
      backgroundColor: backgroundColor.resolve(backgroundStates),
      animateBackground: widget.animationOptions.e0.color,
      foregroundColor: foregroundColor.resolve(foregroundStates),
      animateForeground: widget.animationOptions.e1.color,
      duration: durationForSpeed(widget.animationOptions.e2),
      backgroundPosition:
          (widget.isSelected || !widget.isEnabled || widget.isInvalid)
              ? 1.0
              : 0.0,
      animateBackgroundPosition: widget.animationOptions.e0.size,
      child: widget.child,
    );
  }
}

class _AnimatedBoardButtonContainer extends ImplicitlyAnimatedWidget {
  const _AnimatedBoardButtonContainer({
    Key? key,
    required this.backgroundColor,
    required this.animateBackground,
    required this.foregroundColor,
    required this.animateForeground,
    required this.backgroundPosition,
    required this.animateBackgroundPosition,
    Curve curve = Curves.linear,
    Duration duration = kThemeChangeDuration,
    required this.child,
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
  ColorTween? _backgroundColor;
  ColorTween? _foregroundColor;
  Tween<double>? _backgroundPosition;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    if (widget.animateBackground) {
      _backgroundColor = visitor(
        _backgroundColor,
        widget.backgroundColor,
        (c) => ColorTween(begin: c as Color),
      ) as ColorTween?;
    } else {
      _backgroundColor = ColorTween(
        begin: widget.backgroundColor,
        end: widget.backgroundColor,
      );
    }
    if (widget.animateForeground) {
      _foregroundColor = visitor(
        _foregroundColor,
        widget.foregroundColor,
        (c) => ColorTween(begin: c as Color),
      ) as ColorTween?;
    } else {
      _foregroundColor = ColorTween(
        begin: widget.foregroundColor,
        end: widget.foregroundColor,
      );
    }
    if (widget.animateBackgroundPosition) {
      _backgroundPosition = visitor(
        _backgroundPosition,
        widget.backgroundPosition,
        (p) => Tween<double>(begin: p as double),
      ) as Tween<double>;
    } else {
      _backgroundPosition = Tween(
        begin: widget.backgroundPosition,
        end: widget.backgroundPosition,
      );
    }
  }

  Widget _foreground(
    Color foregroundColor, {
    required Widget child,
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
        final bg = _backgroundColor!.evaluate(animation)!;
        final bgPos = _backgroundPosition!.evaluate(bgPosAnimation);
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
            _foregroundColor!.evaluate(animation)!,
            child: widget.child,
          ),
        );
      },
    );
  }
}
