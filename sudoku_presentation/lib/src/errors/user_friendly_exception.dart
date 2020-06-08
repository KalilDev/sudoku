extension ToUserFriendlyException on Exception {
  UserFriendlyException withMessage(String userFriendlyMessage) {
    if (this is UserFriendlyException) {
      final casted = this as UserFriendlyException;
      final hasMessage = casted.userFriendlyMessage != null;
      // [userFriendlyMessage] will be ignored
      return hasMessage ? casted : UserFriendlyException(casted.exception, userFriendlyMessage);
    }
    return UserFriendlyException(this, userFriendlyMessage);
  }
}

class UserFriendlyException implements Exception {
  final Exception exception;
  final String userFriendlyMessage;
  
  UserFriendlyException(this.exception, this.userFriendlyMessage);

  @override
  String toString() => exception.toString();
}