import 'package:meta/meta.dart';

extension ToUserFriendly on Object {
  UserFriendly<This> withMessage<This extends Object>(String userFriendlyMessage) {
    if (this is UserFriendly<This>) {
      final casted = this as UserFriendly<This>;
      final hasMessage = casted.userFriendlyMessage != null;
      // [userFriendlyMessage] will be ignored
      return hasMessage ? casted : UserFriendly<This>(casted.value, userFriendlyMessage);
    }
    return UserFriendly<This>(this as This, userFriendlyMessage);
  }
}

// Ignore an error. Just for readability
void ignore([dynamic _, dynamic __]) {}

extension ToUserFriendlyFuture<T> on Future<T> {
  Future<T> withErrorMessage(String userFriendlyMessage, {Function onError}) =>
    catchError((Object error) {
      final userFriendlyError = error.withMessage(userFriendlyMessage);
      if (onError == null) {
        // Rethrow the error, now with the proper message.
        throw userFriendlyError;
      }
      // investigate this. onError may be Fuction(Object) or Function(Object, StackTrace)
      return onError(userFriendlyError);
    });
  Future<T> ignoreError() => catchError(ignore);
}

extension ToUserFriendlyError on Error {
  UserFriendlyError withMessage(String userFriendlyMessage) {
    if (this is UserFriendly<Error>) {
      final casted = this as UserFriendly<Error>;
      final hasMessage = casted.userFriendlyMessage != null;
      // [userFriendlyMessage] will be ignored
      return hasMessage ? UserFriendlyError(casted.value, casted.userFriendlyMessage) : UserFriendlyError(casted.value, userFriendlyMessage);
    }
    return UserFriendlyError(this, userFriendlyMessage);
  }
}

extension ToUserFriendlyException on Exception {
  UserFriendlyException withMessage(String userFriendlyMessage) {
    if (this is UserFriendly<Exception>) {
      final casted = this as UserFriendly<Exception>;
      final hasMessage = casted.userFriendlyMessage != null;
      // [userFriendlyMessage] will be ignored
      return hasMessage ? UserFriendlyException(casted.value, casted.userFriendlyMessage) : UserFriendlyException(casted.value, userFriendlyMessage);
    }
    return UserFriendlyException(this, userFriendlyMessage);
  }
}

@immutable
class UserFriendly<T> {
  final T value;
  final String userFriendlyMessage;

  const UserFriendly(this.value, this.userFriendlyMessage);

  @override
  String toString() => value.toString();
}

class UserFriendlyError extends UserFriendly<Error> implements Error {
  const UserFriendlyError(Error value, String userFriendlyMessage) : super(value, userFriendlyMessage);

  @override
  StackTrace get stackTrace => value.stackTrace;
}

class UserFriendlyException extends UserFriendly<Exception> implements Exception {
  const UserFriendlyException(Exception value, String userFriendlyMessage) : super(value, userFriendlyMessage);
}