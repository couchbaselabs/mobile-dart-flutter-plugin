import 'package:cbl/cbl.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel with ChangeNotifier, DiagnosticableTreeMixin {
  late Replicator _replicator;

  Future<void> login(String username, String password) async {
    _replicator = await Replicator.create(
      ReplicatorConfiguration(
        database: await Database.openAsync('test'),
        target: UrlEndpoint(
          Uri.parse('ws://localhost:4984/cake31'),
        ),
        authenticator:
            BasicAuthenticator(username: username, password: password),
      ),
    );
    _replicator.start();

    _replicator.addChangeListener((change) {
      print(change.status.activity.name);
    });
  }
}
