import 'package:meta/meta.dart';

import 'enum_parser.dart';

enum AnimationSpeed { none, normal, fast, fastest }

class AnimationOptions {
  final bool selectSize;
  final bool selectColor;
  final bool textPosition;
  final bool textOpacity;
  final bool textSize;
  final bool textColor;
  final bool textString;
  final AnimationSpeed speed;

  const AnimationOptions({
    required this.selectSize,
    required this.selectColor,
    required this.textPosition,
    required this.textOpacity,
    required this.textSize,
    required this.textColor,
    required this.textString,
    required this.speed,
  });

  bool get hasAnimations {
    return selectSize ||
        selectColor ||
        textPosition ||
        textOpacity ||
        textSize ||
        textColor ||
        textString;
  }

  bool get hasTextStyleAnimations {
    if (speed == AnimationSpeed.none) {
      return textSize || textColor;
    }
    return true;
  }

  static const AnimationOptions defaultOptions = AnimationOptions(
      selectSize: true,
      selectColor: true,
      textPosition: true,
      textOpacity: true,
      textColor: true,
      textSize: true,
      textString: true,
      speed: AnimationSpeed.fast);

  static AnimationOptions _legacyParseOptions(List<String> opts) {
    if (opts == null || opts.isEmpty) {
      return defaultOptions;
    }
    final bools = opts.take(opts.length - 1).toList();
    final boolDefaults = List.filled(6, "true");
    final masked = (boolDefaults..setRange(0, bools.length, bools))
        .map((e) => e == "true")
        .toList();
    final speed = enumFromString<AnimationSpeed>(
        AnimationSpeed.values, opts.last,
        orElse: AnimationSpeed.normal);
    return AnimationOptions(
        selectSize: masked[0],
        selectColor: masked[1],
        textPosition: masked[2],
        textOpacity: masked[3],
        textColor: masked[4],
        textSize: masked[5],
        textString: true,
        speed: speed);
  }

  factory AnimationOptions.parse(List<String> opts) {
    if (opts == null || opts.isEmpty) {
      return defaultOptions;
    }
    if (opts.length <= 7) {
      return _legacyParseOptions(opts);
    }
    final bools = opts.skip(1).toList();
    final boolDefaults = List.filled(7, "true");
    final masked = (boolDefaults..setRange(0, bools.length, bools))
        .map((e) => e == "true")
        .toList();
    final speed = enumFromString<AnimationSpeed>(
        AnimationSpeed.values, opts.last,
        orElse: AnimationSpeed.normal);
    return AnimationOptions(
      speed: speed,
      selectSize: masked[0],
      selectColor: masked[1],
      textPosition: masked[2],
      textOpacity: masked[3],
      textColor: masked[4],
      textSize: masked[5],
      textString: masked[6],
    );
  }

  List<String> toStringList() {
    return [
      speed.toString().split(".").last,
      selectSize.toString(),
      selectColor.toString(),
      textPosition.toString(),
      textOpacity.toString(),
      textColor.toString(),
      textSize.toString(),
      textString.toString(),
    ];
  }

  AnimationOptions copyWith(
      {bool? selectSize,
      bool? selectColor,
      bool? textPosition,
      bool? textOpacity,
      bool? textColor,
      bool? textSize,
      bool? textString,
      AnimationSpeed? speed}) {
    return AnimationOptions(
      selectSize: selectSize ?? this.selectSize,
      selectColor: selectColor ?? this.selectColor,
      textPosition: textPosition ?? this.textPosition,
      textOpacity: textOpacity ?? this.textOpacity,
      textColor: textColor ?? this.textColor,
      textSize: textSize ?? this.textSize,
      textString: textString ?? this.textString,
      speed: speed ?? this.speed,
    );
  }
}
