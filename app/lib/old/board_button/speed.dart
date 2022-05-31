import 'package:app/module/animation.dart';

Duration durationForSpeed(AnimationSpeed speed) {
  switch (speed) {
    case AnimationSpeed.disabled:
      return Duration.zero;
    case AnimationSpeed.fastest:
      return const Duration(milliseconds: 100);
    case AnimationSpeed.fast:
      return const Duration(milliseconds: 200);
    case AnimationSpeed.normal:
      return const Duration(milliseconds: 400);
    case AnimationSpeed.slow:
      return const Duration(milliseconds: 600);
  }
}
