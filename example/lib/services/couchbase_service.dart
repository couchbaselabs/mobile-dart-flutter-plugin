import 'package:cbl/cbl.dart';

class CouchbaseService {
  static const String databaseName = 'db';

  late Database _database;
  late Replicator _pull;
  late Replicator _push;
  late ListenerToken _pullReplicatorListener;
  late ListenerToken _pushReplicatorListener;

  Future<void> initializeCouchbase() async {
    _database = await Database.openAsync(databaseName);
  }

  Future<void> startReplicator(Map<String, dynamic> credentials) async {
    createAndStartPullReplication(credentials);
    createAndStartPushReplication(credentials);
  }

  Future<void> createAndStartPullReplication(
      Map<String, dynamic> credentials) async {
    await _pull.removeChangeListener(_pullReplicatorListener);
    _pull.stop();

    startReplication(
      replicator: _pull,
      credentials: credentials,
      isPull: true,
    );
  }

  Future<void> restartPullReplication(Map<String, dynamic> credentials) async {
    createAndStartPullReplication(credentials);
    createAndStartPushReplication(credentials);
  }

  Future<void> createAndStartPushReplication(
      Map<String, dynamic> credentials) async {
    await _push.removeChangeListener(_pushReplicatorListener);
    _push.stop();

    startReplication(
      replicator: _push,
      credentials: credentials,
      isPull: false,
    );
  }

  Future<void> startReplication(
      {required Replicator replicator,
      required Map<String, dynamic> credentials,
      required bool isPull}) async {
    replicator = await Replicator.create(
      ReplicatorConfiguration(
        target: UrlEndpoint(
          Uri.parse(credentials['url']),
        ),
        continuous: true,
        replicatorType: isPull ? ReplicatorType.pull : ReplicatorType.push,
        maxAttemptWaitTime: const Duration(minutes: 5),
        authenticator: BasicAuthenticator(
            username: credentials['username'],
            password: credentials['password']),
      ),
    );

    await initReplicatorChangeListeners(replicator, isPull);

    await replicator.start();
  }

  Future<void> initReplicatorChangeListeners(
      Replicator replicator, bool isPull) async {
    if (isPull) {
      _pullReplicatorListener =
          await replicator.addChangeListener((change) async {
        ReplicatorStatus status = change.status;

        if (change.status.error != null) {
          if (change.status.error is WebSocketException) {
            print('PULL: Websocket error ${change.status.error}');
          } else if (change.status.error is HttpException) {
            print('PULL: HttpException error ${change.status.error}');
          } else {
            print(change.status.error.toString());
          }
        } else if (status.activity == ReplicatorActivityLevel.offline) {
          print('PULL: activity is offline');
        } else if (status.activity != ReplicatorActivityLevel.busy) {
          print('PULL: activity is busy');
        }
      });
    } else {
      _pushReplicatorListener =
          await replicator.addChangeListener((change) async {
        print(change);
        if (change.status.error != null) {
          print('PUSH: ${change.status.error}');
        }
      });
    }
  }

  Future<List<Collection>> getListDocument(String name) async {
    final document = await _database.collections(name);

    return document;
  }

  Future<void> createCollection(String name, String scope) async {
    await _database.createCollection(name, scope);
  }

  Future<void> dropCollection(String name, String scope) async {
    await _database.deleteCollection(name, scope);
  }

  Future<void> logout() async {
    await _pull.removeChangeListener(_pullReplicatorListener);
    await _push.removeChangeListener(_pushReplicatorListener);
    await _pull.stop();
    await _push.stop();
    await _database.delete();
  }
}
