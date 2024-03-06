import '../support/utils.dart';

abstract class Authenticator {}

/// An authenticator for HTTP Basic (username/password) auth.
///
/// {@category Replication}
class BasicAuthenticator extends Authenticator {
  /// Creates an authenticator for HTTP Basic (username/password) auth.
  BasicAuthenticator({required this.username, required this.password});

  /// The username to authenticate with.
  final String username;

  /// The password to authenticate with.
  final String password;

  @override
  String toString() => 'BasicAuthenticator('
      'username: $username, '
      // ignore: missing_whitespace_between_adjacent_strings
      'password: ${redact(password)}'
      ')';
}