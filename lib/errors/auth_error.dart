class InvalidCredentials extends Error {
  static const message = 'Invalid email or password';

  InvalidCredentials();

  @override
  String toString() {
    return message;
  }
}
