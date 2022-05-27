// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

abstract class SudokuTheme implements SumType {
  const SudokuTheme._();
  const factory SudokuTheme.sudokuMaterialYouTheme(ThemeMode themeMode) =
      SudokuMaterialYouTheme;
  const factory SudokuTheme.sudokuSeededTheme(
      String name,
      Brightness brightness,
      Color seed,
      Color? secondarySeed,
      Color? background) = SudokuSeededTheme;

  @override
  SumRuntimeType get runtimeType =>
      SumRuntimeType([SudokuMaterialYouTheme, SudokuSeededTheme]);

  R visit<R extends Object?>(
      {required R Function(SudokuMaterialYouTheme) sudokuMaterialYouTheme,
      required R Function(SudokuSeededTheme) sudokuSeededTheme});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
}

class SudokuMaterialYouTheme extends SudokuTheme {
  final ThemeMode themeMode;

  const SudokuMaterialYouTheme(this.themeMode) : super._();

  @override
  int get hashCode => Object.hash((SudokuMaterialYouTheme), themeMode);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuMaterialYouTheme &&
          true &&
          this.themeMode == other.themeMode);

  @override
  String toString() => "SudokuMaterialYouTheme { $themeMode }";

  @override
  R visit<R extends Object?>(
          {required R Function(SudokuMaterialYouTheme) sudokuMaterialYouTheme,
          required R Function(SudokuSeededTheme) sudokuSeededTheme}) =>
      sudokuMaterialYouTheme(this);
}

class SudokuSeededTheme extends SudokuTheme {
  final String name;
  final Brightness brightness;
  final Color seed;
  final Color? secondarySeed;
  final Color? background;

  const SudokuSeededTheme(this.name, this.brightness, this.seed,
      this.secondarySeed, this.background)
      : super._();

  @override
  int get hashCode => Object.hash(
      (SudokuSeededTheme), name, brightness, seed, secondarySeed, background);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuSeededTheme &&
          true &&
          this.name == other.name &&
          this.brightness == other.brightness &&
          this.seed == other.seed &&
          this.secondarySeed == other.secondarySeed &&
          this.background == other.background);

  @override
  String toString() =>
      "SudokuSeededTheme { $name, $brightness, $seed, $secondarySeed, $background }";

  @override
  R visit<R extends Object?>(
          {required R Function(SudokuMaterialYouTheme) sudokuMaterialYouTheme,
          required R Function(SudokuSeededTheme) sudokuSeededTheme}) =>
      sudokuSeededTheme(this);
}
