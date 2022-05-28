import 'dart:math';

import 'package:app/module/animation.dart';
import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';

import 'speed.dart';

class BoardButtonTextAnimation extends StatelessWidget {
  const BoardButtonTextAnimation({
    Key? key,
    required this.text,
    required this.isBottom,
    required this.animationOptions,
  }) : super(key: key);
  final String text;
  final bool isBottom;
  final AnimationOptions animationOptions;

  @override
  Widget build(BuildContext context) {
    final bottom = isBottom || text.isEmpty;
    final color = DefaultTextStyle.of(context).style.color!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTextHeight = constraints.maxHeight;
        var textStyle = bottom
            ? context.textTheme.labelMedium.copyWith(
                color: color.withOpacity(0.6 * color.opacity),
              )
            : context.textTheme.headlineMedium.copyWith(
                color: color.withOpacity(0.8 * color.opacity),
              );
        final textStyleHeight = textStyle.height ?? 1.0;
        if (textStyleHeight * textStyle.fontSize! >= maxTextHeight) {
          textStyle =
              textStyle.copyWith(fontSize: maxTextHeight / textStyleHeight);
        }

        return _AnimatedBoardButtonText(
          alignment: bottom ? Alignment.bottomCenter : Alignment.center,
          animateAlignment: animationOptions.e1.position,
          textStyle: textStyle,
          animateTextStyle: animationOptions.e1.size,
          bottomText: bottom ? text : '',
          topText: bottom ? '' : text,
          animateTextString: animationOptions.e1.string,
          bottomTextOpacity: bottom ? 1.0 : 0.0,
          topTextOpacity: bottom ? 0.0 : 1.0,
          animateTextOpacity: animationOptions.e1.opacity,
          duration: durationForSpeed(animationOptions.e2),
        );
      },
    );
  }
}

class _AnimatedBoardButtonText extends ImplicitlyAnimatedWidget {
  const _AnimatedBoardButtonText({
    Key? key,
    required this.bottomText,
    required this.topText,
    required this.animateTextString,
    required this.bottomTextOpacity,
    required this.topTextOpacity,
    required this.animateTextOpacity,
    required this.textStyle,
    required this.animateTextStyle,
    required this.alignment,
    required this.animateAlignment,
    Curve curve = Curves.linear,
    Duration duration = kThemeChangeDuration,
  }) : super(
          key: key,
          curve: curve,
          duration: duration,
        );

  final String topText;
  final String bottomText;
  final bool animateTextString;
  final double bottomTextOpacity;
  final double topTextOpacity;
  final bool animateTextOpacity;
  final TextStyle textStyle;
  final bool animateTextStyle;
  final Alignment alignment;
  final bool animateAlignment;

  @override
  _AnimatedBoardButtonTextState createState() =>
      _AnimatedBoardButtonTextState();
}

class _AnimatedBoardButtonTextState
    extends ImplicitlyAnimatedWidgetState<_AnimatedBoardButtonText> {
  StringTween? _bottomText;
  StringTween? _topText;
  Tween<double>? _topTextOpacity;
  Tween<double>? _bottomTextOpacity;
  TextStyleTween? _textStyle;
  AlignmentTween? _alignment;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    if (widget.animateTextString) {
      _bottomText = visitor(
        _bottomText,
        widget.bottomText,
        (t) => StringTween(begin: t as String),
      ) as StringTween;
      _topText = visitor(
        _topText,
        widget.topText,
        (t) => StringTween(begin: t as String),
      ) as StringTween;
    } else {
      _bottomText =
          StringTween(begin: widget.bottomText, end: widget.bottomText);
      _topText = StringTween(begin: widget.topText, end: widget.topText);
    }
    if (widget.animateTextOpacity) {
      _bottomTextOpacity = visitor(
        _bottomTextOpacity,
        widget.bottomTextOpacity,
        (t) => Tween<double>(begin: t as double),
      ) as Tween<double>;
      _topTextOpacity = visitor(
        _topTextOpacity,
        widget.topTextOpacity,
        (t) => Tween<double>(begin: t as double),
      ) as Tween<double>;
    } else {
      _bottomTextOpacity =
          Tween(begin: widget.bottomTextOpacity, end: widget.bottomTextOpacity);
      _topTextOpacity =
          Tween(begin: widget.topTextOpacity, end: widget.topTextOpacity);
    }
    if (widget.animateTextStyle) {
      _textStyle = visitor(
        _textStyle,
        widget.textStyle,
        (s) => TextStyleTween(begin: s as TextStyle),
      ) as TextStyleTween;
    } else {
      _textStyle =
          TextStyleTween(begin: widget.textStyle, end: widget.textStyle);
    }
    if (widget.animateAlignment) {
      _alignment = visitor(
        _alignment,
        widget.alignment,
        (a) => AlignmentTween(begin: a as Alignment),
      ) as AlignmentTween;
    } else {
      _alignment =
          AlignmentTween(begin: widget.alignment, end: widget.alignment);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (context, _) => Align(
          alignment: _alignment!.evaluate(animation),
          child: AnimatedSize(
            duration: kThemeChangeDuration,
            alignment: Alignment.centerLeft,
            child: Stack(
              fit: StackFit.loose,
              children: [
                Opacity(
                  opacity: _topTextOpacity!.evaluate(animation),
                  child: Text(
                    _topText!.evaluate(animation),
                    style: _textStyle!.evaluate(animation),
                  ),
                ),
                Opacity(
                  opacity: _bottomTextOpacity!.evaluate(animation),
                  child: Text(
                    _bottomText!.evaluate(animation),
                    style: _textStyle!.evaluate(animation),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

int intLerp(int a, int b, double t) => a + ((b - a) * t).round();

class StringTween extends Tween<String> {
  StringTween({String? begin, String? end}) : super(begin: begin, end: end);
  static String commonStartFor(String a, String b) {
    int i;
    for (i = 0; i < min(a.length, b.length); i++) {
      if (a[i] != b[i]) {
        break;
      }
    }
    return a.substring(0, i);
  }

  @override
  String lerp(double t) {
    final a = begin ?? '';
    final b = end ?? '';
    /*if (a == b) {
      return a;
    }*/
    if (a.isEmpty) {
      return b.substring(0, intLerp(0, b.length, t));
    }
    if (b.isEmpty) {
      return a.substring(0, intLerp(a.length, 0, t));
    }
    //debugger();
    final commonStart = commonStartFor(a, b);
    if (t < 0.5) {
      return commonStart +
          a.substring(
            commonStart.length,
            commonStart.length +
                intLerp(
                  a.length - commonStart.length,
                  commonStart.isEmpty ? 1 : 0,
                  t * 2,
                ),
          );
    }
    return commonStart +
        b.substring(
          commonStart.length,
          commonStart.length +
              intLerp(
                commonStart.isEmpty ? 1 : 0,
                b.length - commonStart.length,
                t * 2 - 1,
              ),
        );
  }
}
