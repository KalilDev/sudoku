import 'dart:async';

import 'package:meta/meta.dart';
extension ToUserFriendly on Object {
  UserFriendly<dynamic> withErrorMessage(String _userFriendlyMessage) {
    if (this is UserFriendly) {
      final casted = this as UserFriendly;
      final hasMessage = casted.userFriendlyMessage != null;
      // [_userFriendlyMessage] will be ignored. This is needed in case this is
      // an UserFriendly<Object> but the value is an Error or Exception.
      final userFriendlyMessage = hasMessage ? casted.userFriendlyMessage : _userFriendlyMessage;
      if (casted.value is Error) {
        return UserFriendlyError(casted.value as Error, userFriendlyMessage);
      }
      if (casted.value is Exception) {
        return UserFriendlyException(casted.value as Exception, userFriendlyMessage);
      }
      return UserFriendly<Object>(casted.value, userFriendlyMessage);
    }

    if (this is Error) {
      return UserFriendlyError(this as Error, _userFriendlyMessage);
    }
    if (this is Exception) {
      return UserFriendlyException(this as Exception, _userFriendlyMessage);
    }

    return UserFriendly<Object>(this, _userFriendlyMessage);
  }
}

extension ErrorWithMessage on Error {
  UserFriendlyError withMessage(String _userFriendlyMessage) => this.withErrorMessage(_userFriendlyMessage) as UserFriendlyError;
}

extension ExceptionWithMessage on Exception {
  UserFriendlyException withMessage(String _userFriendlyMessage) => this.withErrorMessage(_userFriendlyMessage) as UserFriendlyException;
}

// Ignore an error. Just for readability
T ignore<T>([dynamic _, dynamic __]) => null;

extension ToUserFriendlyFuture<T> on Future<T> {
  Future<T> withErrorMessage(String userFriendlyMessage, {Function onError, bool Function(Object) test}) {
    final newFuture = catchError((Object error) {
      final userFriendlyError = error.withErrorMessage(userFriendlyMessage);
      // Rethrow the error, now with the proper message. It is an
      // UserFriendlyError if [error] is an [Error], an UserFriendlyException if
      // [error] is an Exception and an UserFriendly<Object> if [error] is
      // anything else.
      // ignore: only_throw_errors
      throw userFriendlyError;
    });
    // We can't just run the onError function because we don't know it's
    // signature. It could be Function(Object) or Function(Object, StackTrace)
    return onError == null ? newFuture : newFuture.catchError(onError, test: test);
  }
  Future<T> ignoreError() => catchError((Object _, StackTrace __) => ignore<T>(_, __));
  Future<T> withDefault(T value) => then((T result) => result ?? value);
  Future<T> orElse(T value) => ignoreError().withDefault(value) as Future<T>;
}

extension RetryFutureCallback<T> on Future<T> Function() {
  Future<T> retry([int times = 3]) {
    if (times == 0) {
      return this.call();
    }
    // ignore the error and retry
    return this.call().catchError((Object error) => retry(times - 1));
  }
}

@immutable
class UserFriendly<T> {
  final T value;
  final String userFriendlyMessage;

  const UserFriendly(this.value, this.userFriendlyMessage);

  String getText(bool isDebug) => isDebug ? value.toString() : userFriendlyMessage;
  String getExtraText(bool isDebug) => isDebug ? userFriendlyMessage : value.toString();

  @override
  String toString() => value.toString();
}

class UserFriendlyError extends UserFriendly<Error> implements Error {
  const UserFriendlyError(Error value, String userFriendlyMessage) : super(value, userFriendlyMessage);

  @override
  String getExtraText(bool isDebug) => isDebug ? stackTrace.toString() : super.getExtraText(isDebug);

  @override
  StackTrace get stackTrace => value.stackTrace;
}

class UserFriendlyException extends UserFriendly<Exception> implements Exception {
  const UserFriendlyException(Exception value, String userFriendlyMessage) : super(value, userFriendlyMessage);
}