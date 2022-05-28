import 'package:adt_annotation/adt_annotation.dart' show data, T, Tp, NoMixin;
import 'package:adt_annotation/adt_annotation.dart' as adt;
import 'package:utils/utils.dart';

part 'data.g.dart';

@data(
    #SelectionAnimationOptions,
    [],
    adt.Record({
      #size: T(#bool),
      #color: T(#bool),
    }))
const Type _selectionAnimationOptions = SelectionAnimationOptions;

@data(
    #TextAnimationOptions,
    [],
    adt.Record({
      #position: T(#bool),
      #opacity: T(#bool),
      #color: T(#bool),
      #string: T(#bool),
    }))
const Type _textAnimationOptions = TextAnimationOptions;

enum AnimationSpeed { none, normal, fast, fastest }

@data(
    #AnimationOptions,
    [],
    adt.Tuple([
      T(#SelectionAnimationOptions),
      T(#TextAnimationOptions),
      T(#AnimationSpeed)
    ]))
const Type _animationOptions = AnimationOptions;

const defaultAnimationOptions = AnimationOptions(
  SelectionAnimationOptions(true, true),
  TextAnimationOptions(true, true, true, true),
  AnimationSpeed.fast,
);
