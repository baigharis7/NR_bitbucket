class ErrorTypStrings {
  static const NOT_AUTORIZED_USER = 'Incorrect username or password.';
  static const USER_ALREADY_EXISTS = 'User already exists';
  static const INVALID_CODE = 'Invalid verification code provided, please try again.';
  static const DAILY_LIMIT_EXCEEDED = 'Exceeded daily email limit for the operation or the account. If a higher limit is required, please configure your user pool to use your own Amazon SES configuration for sending email.';
  static const OPERATION_NOT_COMPLETED_ES = 'se ha podido completar la operación.' ;

  /// Fragment (lowercase) of Cognito's InvalidParameterException message when
  /// resendSignUpCode targets an already-confirmed account. Matched with
  /// contains() over the lowercased message — pinned exactly in tests and
  /// verified live in B3's manual pass.
  static const USER_ALREADY_CONFIRMED_FRAGMENT = 'already confirmed';
}