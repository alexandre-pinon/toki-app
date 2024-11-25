class AuthError extends Error {
  final String message;

  AuthError(this.message);

  @override
  String toString() {
    return message;
  }
}

class InvalidCredentials extends AuthError {
  InvalidCredentials() : super('Invalid email or password');
}

class EmailAlreadyExist extends AuthError {
  EmailAlreadyExist()
      : super(
          'An account with this email already exist, please choose another',
        );
}
