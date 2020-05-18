import 'package:meta/meta.dart';
import 'dart:math';
import 'helpers.dart' show Maybe;
import 'helpers.dart' as helpers;

extension MaybeFunction<T> on T Function () {
  Maybe<T> maybe({List positionalArguments = const [], Map<Symbol, dynamic> namedArguments = const {}}) {
    return helpers.maybe<T>(this, positionalArguments: positionalArguments, namedArguments: namedArguments);
  }
  T orElse({List positionalArguments = const [], Map<Symbol, dynamic> namedArguments = const {}, @required Maybe<T> orElse}) {
    return helpers.maybeOrElse<T>(this, positionalArguments: positionalArguments, namedArguments: namedArguments, orElse: orElse);
  }
}


int functionThatThrowsSometimes() {
  if (Random().nextBool()) {
    throw StateError("welp");
  }
  return 999;
}

void main() {
  final int normallyIWouldDoThis = functionThatThrowsSometimes();
  final Maybe<int> thisWayImForcedToHandleTheError = functionThatThrowsSometimes.maybe();
  final int thisWayThereIsAlwaysAnValue = functionThatThrowsSometimes.orElse(orElse: 10);
  print(normallyIWouldDoThis);
  print(thisWayImForcedToHandleTheError);
  print(thisWayThereIsAlwaysAnValue);
  print(normallyIWouldDoThis.runtimeType);
  print(thisWayImForcedToHandleTheError.runtimeType);
  print(thisWayThereIsAlwaysAnValue.runtimeType);
}