import 'package:app/module/animation.dart';
import 'package:app/util/monadic.dart';
import 'package:flutter/material.dart';

class InheritedAnimationOptions extends InheritedWidget {
  const InheritedAnimationOptions({
    Key? key,
    required this.animationOptions,
    required Widget child,
  }) : super(key: key, child: child);
  final AnimationOptions animationOptions;

  @override
  bool updateShouldNotify(InheritedAnimationOptions oldWidget) =>
      oldWidget.animationOptions != animationOptions;

  static AnimationOptions of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedAnimationOptions>()!
      .animationOptions;
}

final ContextfulAction<AnimationOptions> animationOptions =
    readC.map(InheritedAnimationOptions.of);
