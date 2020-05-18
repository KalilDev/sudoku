import 'package:meta/meta.dart';
import 'package:sudoku/core/bidimensional_list.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/core/sudoku_state.dart';
import 'package:sudoku/presentation/sudoku_bloc/bloc.dart';
import '../common.dart';

final _listEquality = ListEquality();

E enumFromString<E>(List<E> values, String s) => values
    .singleWhere((v) => v.toString().split('.').last == s, orElse: () => null);

const Map<SudokuDifficulty, double> difficultyMaskMap = {
  SudokuDifficulty.begginer: 1 - 0.7,
  SudokuDifficulty.easy: 1 - 0.55,
  SudokuDifficulty.medium: 1 - 0.45,
  SudokuDifficulty.hard: 1 - 0.32,
  SudokuDifficulty.extreme: 1 - 0.38,
  SudokuDifficulty.impossible: 1 - 0.24
};

enum AnimationSpeed { none, normal, fast, fastest }

class AnimationOptions {
  final bool selectSize;
  final bool selectColor;
  final bool textPosition;
  final bool textOpacity;
  final bool textSize;
  final bool textColor;
  final AnimationSpeed speed;

  bool get hasAnimations {
    if (speed == AnimationSpeed.none) {
      return selectSize || selectColor || textPosition || textOpacity || textSize || textColor;
    }
    return true;
  }
  bool get hasTextStyleAnimations {
    if (speed == AnimationSpeed.none) {
      return textSize || textColor;
    }
    return true;
  }

  static final defaultOptions = AnimationOptions(
      selectSize: true,
      selectColor: true,
      textPosition: true,
      textOpacity: true,
      textColor: true,
      textSize: true,
      speed: AnimationSpeed.fast);

  factory AnimationOptions.parse(List<String> opts) {
    if (opts == null || opts.isEmpty) {
      return defaultOptions;
    }
    final bools = opts.take(opts.length - 1).toList();
    final boolDefaults = List.filled(6, "true");
    final masked = (boolDefaults..setRange(0, bools.length, bools)).map((e) => e == "true").toList();
    final speed = enumFromString<AnimationSpeed>(AnimationSpeed.values, opts.last);
    return AnimationOptions(
      selectSize: masked[0],
      selectColor: masked[1],
      textPosition: masked[2],
      textOpacity: masked[3],
      textColor: masked[4],
      textSize: masked[5],
      speed: speed);
  }

  List<String> toStringList() {
    return [
      selectSize.toString(),
      selectColor.toString(),
      textPosition.toString(),
      textOpacity.toString(),
      textColor.toString(),
      textSize.toString(),
      speed.toString().split(".").last
    ];

  }

  AnimationOptions copyWith({bool selectSize, bool selectColor, bool textPosition, bool textOpacity, bool textColor, bool textSize, AnimationSpeed speed}) {
    return AnimationOptions(
      selectSize: selectSize ?? this.selectSize,
      selectColor: selectColor ?? this.selectColor,
      textPosition: textPosition ?? this.textPosition,
      textOpacity: textOpacity ?? this.textOpacity,
      textColor: textColor ?? this.textColor,
      textSize: textSize ?? this.textSize,
      speed: speed ?? this.speed,
    );

  }
  
  AnimationOptions(
      {this.selectSize,
      this.selectColor,
      this.textPosition,
      this.textOpacity,
      this.speed,
      this.textColor,
      this.textSize});
}

@immutable
class SquareInfo {
  final int number; // may be null
  final List<int> possibleNumbers; // may be null
  final bool isInitial; // non nullable
  final bool isSelected; // non nullable
  final bool isValid; // nullable

  SquareInfo(
      {this.number,
      this.possibleNumbers,
      this.isInitial,
      this.isSelected,
      this.isValid});
  static final SquareInfo empty =
      SquareInfo(isInitial: false, isSelected: false);

  bool hasSameContentAs(SquareInfo other) =>
      number == other.number &&
      _listEquality.equals(possibleNumbers, other.possibleNumbers) &&
      isInitial == other.isInitial &&
      isSelected == other.isSelected &&
      (isValid ?? true) == (other.isValid ?? true);
}

@immutable
class NumberInfo {
  final int number; // non nullable
  final bool isSelected;

  NumberInfo({this.number, this.isSelected}); // non nullable
}

@immutable
class SudokuSnapshot {
  final BidimensionalList<SquareInfo> squares;
  final List<NumberInfo> numbers;
  int get side => squares.length;

  final MarkType markType;
  final bool canRewind;

  final bool isLoading;
  final Validation validationState;

  SudokuSnapshot(
      {this.squares,
      this.numbers,
      this.canRewind,
      this.markType,
      this.validationState})
      : isLoading = false;
  SudokuSnapshot.loading()
      : squares = null,
        numbers = null,
        markType = null,
        canRewind = false,
        validationState = null,
        isLoading = true;
}

enum MarkType { possible, concrete }
