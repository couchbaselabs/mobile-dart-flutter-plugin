/// Authenticator objects provide server authentication credentials to the replicator.
abstract class Authenticator {}

class BasicAuthenticator implements Authenticator {
  /// The BasicAuthenticator class is an authenticator that will authenticate using HTTP Basic auth with the given [username] and [password].
  BasicAuthenticator(this.username, this.password);

  final String username;
  final String password;
}
