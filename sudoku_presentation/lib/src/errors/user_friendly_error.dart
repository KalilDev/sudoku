extension ToUserFriendlyError on Error {
  UserFriendlyError withMessage(String userFriendlyMessage) {
    if (this is UserFriendlyError) {
      final casted = this as UserFriendlyError;
      final hasMessage = casted.userFriendlyMessage != null;
      // [userFriendlyMessage] will be ignored
      return hasMessage ? casted : UserFriendlyError(casted.error, userFriendlyMessage);
    }
    return UserFriendlyError(this, userFriendlyMessage);
  }
}

class UserFriendlyError extends Error {
  final Error error;
  final String userFriendlyMessage;
  
  UserFriendlyError(this.error, this.userFriendlyMessage);

  @override
  String toString() => error.toString();
}