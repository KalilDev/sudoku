import 'package:meta/meta.dart';

typedef Maybe<T> = T?;

Maybe<T> maybe<T>(Function f, {List positionalArguments = const [], Map<Symbol, dynamic> namedArguments = const {}}) {
  try {
    return Function.apply(f, positionalArguments, namedArguments) as Maybe<T>;
  } catch (e) {
    return null;
  }
}


T maybeOrElse<T>(Function f, {List positionalArguments = const [], Map<Symbol, dynamic> namedArguments = const {}, @required Maybe<T> orElse}) {
  if (orElse == null) {
    throw TypeError();
  }
  try {
    final returnValue = Function.apply(f, positionalArguments, namedArguments);
    if (returnValue == null) {
      return orElse as T;
    }
    return returnValue as T;
  } catch (e) {
    return orElse as T;
  }
}