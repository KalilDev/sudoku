import 'dart:ui';

import 'package:app/widget/decoration.dart';
import 'package:flutter/material.dart';
import 'package:material_widgets/material_widgets.dart';
import 'package:utils/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
    this.initialColors,
    required this.home,
  }) : super(key: key);
  final Tuple2<Color, Color>? initialColors;
  final Widget home;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> animation;
  ColorTween? backgroundBaseTween;
  ColorTween? foregroundBaseTween;
  final Animatable<double> _backgroundTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(0), weight: 1),
    TweenSequenceItem(tween: CurveTween(curve: Curves.easeInOut), weight: 2),
    TweenSequenceItem(tween: ConstantTween(1), weight: 2),
  ]);
  final Animatable<double> _backgroundOpacityTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(1), weight: 4),
    TweenSequenceItem(
        tween: CurveTween(curve: Curves.easeInOut).chain(Tween(
          begin: 1,
          end: 0,
        )),
        weight: 1),
  ]);
  final Animatable<double> _foregroundTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(0), weight: 1),
    TweenSequenceItem(tween: CurveTween(curve: Curves.easeInOut), weight: 2),
    TweenSequenceItem(tween: ConstantTween(1), weight: 2),
  ]);
  final Animatable<double> _foregroundOpacityTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(1), weight: 3.5),
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(
          curve: Curves.easeInOut,
        )),
        weight: 3.5),
    TweenSequenceItem(tween: ConstantTween(0), weight: 0.5),
  ]);
  final Animatable<double> _textOpacityTween = TweenSequence([
    TweenSequenceItem(tween: CurveTween(curve: Curves.easeInOut), weight: 1),
    TweenSequenceItem(tween: ConstantTween(1), weight: 2),
    TweenSequenceItem(
        tween:
            CurveTween(curve: Curves.easeInOut).chain(Tween(begin: 1, end: 0)),
        weight: 1),
    TweenSequenceItem(tween: ConstantTween(0), weight: 1),
  ]);
  final Animatable<double> _textPositionTween = TweenSequence([
    TweenSequenceItem(tween: CurveTween(curve: Curves.easeInOut), weight: 1),
    TweenSequenceItem(tween: ConstantTween(1), weight: 4),
  ]);
  final Animatable<double> _sudokuStrokeWidthTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(1), weight: 1),
    TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 4.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1),
    TweenSequenceItem(
        tween: Tween(
          begin: 4.0,
          end: 2.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1),
    TweenSequenceItem(tween: ConstantTween(2), weight: 2),
  ]);
  final Animatable<double> _sudokuSizeTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(0), weight: 2),
    TweenSequenceItem(tween: CurveTween(curve: Curves.easeInOut), weight: 2),
    TweenSequenceItem(tween: ConstantTween(1), weight: 1),
  ]);
  final Animatable<double> _sudokuPositionTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(0), weight: 3),
    TweenSequenceItem(tween: CurveTween(curve: Curves.easeInOut), weight: 1),
    TweenSequenceItem(tween: ConstantTween(1), weight: 1),
  ]);

  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );
    animation = _controller.view;
    _controller.addStatusListener(_onController);
    _controller.forward();
  }

  void _onController(AnimationStatus status) => setState(() {});

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    backgroundBaseTween ??= ColorTween(
      begin: widget.initialColors?.e0 ?? context.colorScheme.background,
      end: context.colorScheme.background,
    );
    foregroundBaseTween ??= ColorTween(
      begin: widget.initialColors?.e1 ?? context.colorScheme.primary,
      end: context.colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !animation.isCompleted,
              child: widget.home,
            ),
          ),
          if (!animation.isCompleted)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: animation,
                builder: (_, __) => Container(
                  color: backgroundBaseTween!
                      .transform(_backgroundTween.evaluate(animation))!
                      .withOpacity(_backgroundOpacityTween.evaluate(animation)),
                  child: _SplashScreenAnimationLayout(
                      text: Material(
                        type: MaterialType.transparency,
                        textStyle: TextStyle(
                          color: (ThemeData.estimateBrightnessForColor(
                                        backgroundBaseTween!.transform(
                                          _backgroundTween.evaluate(animation),
                                        )!,
                                      ) ==
                                      context.theme.brightness
                                  ? context.colorScheme.onBackground
                                  : context.colorScheme.onInverseSurface)
                              .withOpacity(
                            _textOpacityTween.evaluate(animation),
                          ),
                        ),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: 'by ',
                                style: context.textTheme.labelLarge),
                            TextSpan(
                                text: 'Pedro Kalil',
                                style: context.textTheme.titleLarge),
                          ]),
                        ),
                      ),
                      textPosition: _textPositionTween.evaluate(animation),
                      sudokuSize: _sudokuSizeTween.evaluate(animation),
                      sudokuPosition: _sudokuPositionTween.evaluate(animation),
                      decoration: SudokuBoardDecoration(
                        sideSqrt: 3,
                        secondaryOpacity: AlwaysStoppedAnimation(0),
                        color: foregroundBaseTween!
                            .transform(
                              _foregroundTween.evaluate(animation),
                            )!
                            .withOpacity(
                              _foregroundOpacityTween.evaluate(animation),
                            ),
                        largeStrokeWidth:
                            _sudokuStrokeWidthTween.animate(animation),
                      )),
                ),
              ),
            ),
        ],
      );
}

class _SplashScreenAnimationLayout extends StatelessWidget {
  const _SplashScreenAnimationLayout(
      {Key? key,
      required this.text,
      required this.textPosition,
      required this.sudokuSize,
      required this.sudokuPosition,
      required this.decoration})
      : super(key: key);
  final Widget text;
  final double textPosition;
  final double sudokuSize;
  final double sudokuPosition;
  final Widget decoration;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: CustomMultiChildLayout(
          delegate: _SplashScreenLayoutDelegate(
            textPosition,
            sudokuSize,
            sudokuPosition,
          ),
          children: [
            LayoutId(id: _Layout.text, child: text),
            LayoutId(id: _Layout.decoration, child: decoration),
          ],
        ),
      );
}

enum _Layout {
  text,
  decoration,
}

class _SplashScreenLayoutDelegate extends MultiChildLayoutDelegate {
  final double textPosition;
  final double sudokuSize;
  final double sudokuPosition;

  _SplashScreenLayoutDelegate(
      this.textPosition, this.sudokuSize, this.sudokuPosition);

  @override
  void performLayout(Size size) {
    const minDistanceFromTextToSudoku = 12.0;
    const maxDistanceFromTextToSudoku = 24.0;
    final distanceFromTextToSudoku = lerpDouble(minDistanceFromTextToSudoku,
        maxDistanceFromTextToSudoku, 1 - textPosition)!;
    const minSudokuWidth = 72.0;
    final maxSudokuWidth = size.width - 4;
    final sudokuWidth = lerpDouble(minSudokuWidth, maxSudokuWidth, sudokuSize)!;
    // TODO: final finalSudokuPosition = 64.0;
    final textWSize = layoutChild(_Layout.text, BoxConstraints.loose(size));
    final sudokuWSize = layoutChild(
      _Layout.decoration,
      BoxConstraints(
        minWidth: sudokuWidth,
        maxWidth: sudokuWidth,
      ),
    );
    final sudokuStartHeight = (size.height - sudokuWSize.height) / 2;
    final sudokuStartDx = (size.width - sudokuWSize.width) / 2;
    final sudokuEndHeight = sudokuStartHeight + sudokuWSize.height;
    final textStartHeight = sudokuEndHeight + distanceFromTextToSudoku;
    final textStartDx = (size.width - textWSize.width) / 2;
    positionChild(_Layout.decoration, Offset(sudokuStartDx, sudokuStartHeight));
    positionChild(_Layout.text, Offset(textStartDx, textStartHeight));
  }

  @override
  bool shouldRelayout(_SplashScreenLayoutDelegate oldDelegate) =>
      oldDelegate.textPosition != textPosition ||
      oldDelegate.sudokuSize != sudokuSize ||
      oldDelegate.sudokuPosition != sudokuPosition;
}
