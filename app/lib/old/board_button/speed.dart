import 'package:app/module/animation.dart';

Duration durationForSpeed(AnimationSpeed speed) {
  switch (speed) {
    case AnimationSpeed.none:
      return Duration.zero;
    case AnimationSpeed.normal:
      return const Duration(milliseconds: 400);
    case AnimationSpeed.fast:
      return const Duration(milliseconds: 200);
    case AnimationSpeed.fastest:
      return const Duration(milliseconds: 100);
  }
}
