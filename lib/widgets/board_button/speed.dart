import 'package:sudoku_presentation/models.dart';

Duration durationForSpeed(AnimationSpeed speed) {
  switch (speed) {
    case AnimationSpeed.none:
      return Duration.zero;
    case AnimationSpeed.normal:
      return const Duration(milliseconds: 400);
      break;
    case AnimationSpeed.fast:
      return const Duration(milliseconds: 200);
      break;
    case AnimationSpeed.fastest:
      return const Duration(milliseconds: 100);
      break;
  }
}
