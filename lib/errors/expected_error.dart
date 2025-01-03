class ExpectedError extends Error {
  final String message;

  ExpectedError(this.message);

  @override
  String toString() {
    return message;
  }
}
