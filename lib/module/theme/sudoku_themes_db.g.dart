// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_themes_db.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

class SudokuThemesDb implements ProductType {
  final Box<dynamic> _themes;
  final Box<SudokuSeededTheme> _userThemes;

  const SudokuThemesDb(this._themes, this._userThemes) : super();

  @override
  ProductRuntimeType get runtimeType =>
      ProductRuntimeType([Box<dynamic>, Box<SudokuSeededTheme>]);

  @override
  int get hashCode => Object.hash((SudokuThemesDb), _themes, _userThemes);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SudokuThemesDb &&
          true &&
          this._themes == other._themes &&
          this._userThemes == other._userThemes);

  @override
  String toString() => "SudokuThemesDb { $_themes, $_userThemes }";
}
