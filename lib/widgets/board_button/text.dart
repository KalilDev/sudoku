import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';
import 'package:sudoku_presentation/models.dart';

import 'speed.dart';

class BoardButtonTextAnimation extends StatelessWidget {
  const BoardButtonTextAnimation({
    Key key,
    this.text,
    this.isBottom,
    this.animationOptions,
  }) : super(key: key);
  final String text;
  final bool isBottom;
  final AnimationOptions animationOptions;

  @override
  Widget build(BuildContext context) {
    final bottom = isBottom || text.isEmpty;
    final color = DefaultTextStyle.of(context).style.color;
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
        if (textStyleHeight * textStyle.fontSize >= maxTextHeight) {
          textStyle =
              textStyle.copyWith(fontSize: maxTextHeight / textStyleHeight);
        }

        return _AnimatedBoardButtonText(
          alignment: bottom ? Alignment.bottomCenter : Alignment.center,
          animateAlignment: animationOptions.textPosition,
          textStyle: textStyle,
          animateTextStyle: animationOptions.textSize,
          bottomText: bottom ? text : '',
          topText: bottom ? '' : text,
          animateTextString: animationOptions.textString,
          bottomTextOpacity: bottom ? 1.0 : 0.0,
          topTextOpacity: bottom ? 0.0 : 1.0,
          animateTextOpacity: animationOptions.textOpacity,
          duration: durationForSpeed(animationOptions.speed),
        );
      },
    );
  }
}

class _AnimatedBoardButtonText extends ImplicitlyAnimatedWidget {
  const _AnimatedBoardButtonText({
    Key key,
    this.bottomText,
    this.topText,
    this.animateTextString,
    this.bottomTextOpacity,
    this.topTextOpacity,
    this.animateTextOpacity,
    this.textStyle,
    this.animateTextStyle,
    this.alignment,
    this.animateAlignment,
    Curve curve = Curves.linear,
    Duration duration = kThemeChangeDuration,
    this.child,
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
  final Widget child;

  @override
  _AnimatedBoardButtonTextState createState() =>
      _AnimatedBoardButtonTextState();
}

class _AnimatedBoardButtonTextState
    extends ImplicitlyAnimatedWidgetState<_AnimatedBoardButtonText> {
  StringTween bottomText;
  StringTween topText;
  Tween<double> topTextOpacity;
  Tween<double> bottomTextOpacity;
  TextStyleTween textStyle;
  AlignmentTween alignment;

  @override
  void forEachTween(TweenVisitor visitor) {
    if (widget.animateTextString) {
      bottomText = visitor(
        bottomText,
        widget.bottomText,
        (t) => StringTween(begin: t as String),
      ) as StringTween;
      topText = visitor(
        topText,
        widget.topText,
        (t) => StringTween(begin: t as String),
      ) as StringTween;
    } else {
      bottomText =
          StringTween(begin: widget.bottomText, end: widget.bottomText);
      topText = StringTween(begin: widget.topText, end: widget.topText);
    }
    if (widget.animateTextOpacity) {
      bottomTextOpacity = visitor(
        bottomTextOpacity,
        widget.bottomTextOpacity,
        (t) => Tween<double>(begin: t as double),
      ) as Tween<double>;
      topTextOpacity = visitor(
        topTextOpacity,
        widget.topTextOpacity,
        (t) => Tween<double>(begin: t as double),
      ) as Tween<double>;
    } else {
      bottomTextOpacity =
          Tween(begin: widget.bottomTextOpacity, end: widget.bottomTextOpacity);
      topTextOpacity =
          Tween(begin: widget.topTextOpacity, end: widget.topTextOpacity);
    }
    if (widget.animateTextStyle) {
      textStyle = visitor(
        textStyle,
        widget.textStyle,
        (s) => TextStyleTween(begin: s as TextStyle),
      ) as TextStyleTween;
    } else {
      textStyle =
          TextStyleTween(begin: widget.textStyle, end: widget.textStyle);
    }
    if (widget.animateAlignment) {
      alignment = visitor(
        alignment,
        widget.alignment,
        (a) => AlignmentTween(begin: a as Alignment),
      ) as AlignmentTween;
    } else {
      alignment =
          AlignmentTween(begin: widget.alignment, end: widget.alignment);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (context, _) => Align(
          alignment: alignment.evaluate(animation),
          child: AnimatedSize(
            duration: kThemeChangeDuration,
            alignment: Alignment.centerLeft,
            child: Stack(
              fit: StackFit.loose,
              children: [
                Opacity(
                  opacity: topTextOpacity.evaluate(animation),
                  child: Text(
                    topText.evaluate(animation),
                    style: textStyle.evaluate(animation),
                  ),
                ),
                Opacity(
                  opacity: bottomTextOpacity.evaluate(animation),
                  child: Text(
                    bottomText.evaluate(animation),
                    style: textStyle.evaluate(animation),
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
  StringTween({String begin, String end}) : super(begin: begin, end: end);
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
