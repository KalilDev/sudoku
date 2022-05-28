// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

class SelectionAnimationOptions implements ProductType {
  final bool size;
  final bool color;

  const SelectionAnimationOptions(this.size, this.color) : super();

  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType([bool, bool]);

  @override
  int get hashCode => Object.hash((SelectionAnimationOptions), size, color);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is SelectionAnimationOptions &&
          true &&
          this.size == other.size &&
          this.color == other.color);

  @override
  String toString() => "SelectionAnimationOptions { $size, $color }";
}

class TextAnimationOptions implements ProductType {
  final bool position;
  final bool opacity;
  final bool color;
  final bool string;

  const TextAnimationOptions(
      this.position, this.opacity, this.color, this.string)
      : super();

  @override
  ProductRuntimeType get runtimeType =>
      ProductRuntimeType([bool, bool, bool, bool]);

  @override
  int get hashCode =>
      Object.hash((TextAnimationOptions), position, opacity, color, string);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is TextAnimationOptions &&
          true &&
          this.position == other.position &&
          this.opacity == other.opacity &&
          this.color == other.color &&
          this.string == other.string);

  @override
  String toString() =>
      "TextAnimationOptions { $position, $opacity, $color, $string }";
}

class AnimationOptions
    implements
        ProductType,
        TupleN3<SelectionAnimationOptions, TextAnimationOptions,
            AnimationSpeed> {
  final SelectionAnimationOptions e0;
  final TextAnimationOptions e1;
  final AnimationSpeed e2;

  const AnimationOptions(this.e0, this.e1, this.e2) : super();

  factory AnimationOptions.fromTupleN(
          TupleN3<SelectionAnimationOptions, TextAnimationOptions,
                  AnimationSpeed>
              tpl) =>
      AnimationOptions(tpl.e0, tpl.e1, tpl.e2);

  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType(
      [SelectionAnimationOptions, TextAnimationOptions, AnimationSpeed]);

  @override
  int get hashCode => Object.hash((AnimationOptions), e0, e1, e2);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is AnimationOptions &&
          true &&
          this.e0 == other.e0 &&
          this.e1 == other.e1 &&
          this.e2 == other.e2);

  @override
  String toString() => "AnimationOptions ($e0, $e1, $e2)";
}
