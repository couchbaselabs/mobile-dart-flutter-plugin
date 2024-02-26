import 'dart:async';

import 'configuration.dart';

enum ReplicatorActivityLevel {
  /// The replicator is unstarted, finished, or hit a fatal error.
  stopped,

  /// The replicator is offline, as the remote host is unreachable.
  offline,

  /// The replicator is connecting to the remote host.
  connecting,

  /// The replicator is inactive, waiting for changes to sync.
  idle,

  /// The replicator is actively transferring data.
  busy,
}

abstract class Replicator {
  static Future<dynamic> create(ReplicatorConfiguration config) async => '';

  FutureOr<dynamic> addChangeListener(dynamic listener);

  FutureOr<void> start({bool reset = false});

  FutureOr<void> stop();
}
