import 'package:sudoku_presentation/src/animation_options.dart';

abstract class PreferencesRepository {
  Future<String> getCurrentTheme();
  Future<void> updateTheme(String theme);
  Future<AnimationOptions> getAnimationOptions();
  Future<void> updateAnimationOptions(AnimationOptions options);
  Future<int> getMainMenuX();
  Future<void> updateMainMenuX(int x);
  Future<int> getMainMenuY();
  Future<void> updateMainMenuY(int y);
  Future<bool> getAknowledgement();
  Future<void> updateAknowledgement(bool a);
}