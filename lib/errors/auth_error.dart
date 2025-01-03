import 'package:toki_app/errors/expected_error.dart';

class InvalidCredentials extends ExpectedError {
  InvalidCredentials() : super('Invalid email or password');
}

class EmailAlreadyExist extends ExpectedError {
  EmailAlreadyExist()
      : super(
          'An account with this email already exist, please choose another',
        );
}

class Unauthenticated extends ExpectedError {
  Unauthenticated() : super('Your session has expired');
}
