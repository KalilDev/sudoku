/// An bad, but recoverable exception. It should be shown to the user, but in an
/// non blocking manner
class StateException implements Exception {
  final String message;

  StateException(this.message);
  
  @override
  String toString() {
    if (message == null) return "Exception";
    return "StateException: $message";
  }
}