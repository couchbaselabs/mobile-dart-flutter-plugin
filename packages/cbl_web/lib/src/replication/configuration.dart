import 'dart:async';

import '../database/collection.dart';
import 'authenticator.dart';
import 'conflict_resolver.dart';
import 'endpoint.dart';

enum ReplicatorType {
  /// Bidirectional; both push and pull
  pushAndPull,

  /// Pushing changes to the target
  push,

  /// Pulling changes from the target
  pull,
}

enum DocumentFlag {
  /// The document has been deleted.
  deleted,

  /// The document was removed from all the Sync Gateway channels the user has
  /// access to.
  accessRemoved,
}

typedef ReplicationFilter = FutureOr<bool> Function(
  dynamic document,
  Set<DocumentFlag> flags,
);

class CollectionConfiguration {
  /// Creates a replication configuration for a [Collection].
  CollectionConfiguration({
    this.channels,
    this.documentIds,
    this.pushFilter,
    this.pullFilter,
    this.conflictResolver,
  });

  /// Creates a replication configuration for a [Collection] from another
  /// [config] by coping it.
  CollectionConfiguration.from(CollectionConfiguration config)
      : channels = config.channels,
        documentIds = config.documentIds,
        pushFilter = config.pushFilter,
        pullFilter = config.pullFilter,
        conflictResolver = config.conflictResolver;

  /// A set of Sync Gateway channel names to pull from.
  ///
  /// Ignored for push replication. If unset, all accessible channels will be
  /// pulled.
  ///
  /// Note: Channels that are not accessible to the user will be ignored by Sync
  /// Gateway.
  List<String>? channels;

  /// A set of document IDs to filter by.
  ///
  /// If given, only documents with these ids will be pushed and/or pulled.
  List<String>? documentIds;

  /// Filter for validating whether the [Document]s can be pushed to the remote
  /// endpoint.
  ///
  /// Only documents for which the function returns `true` are replicated.
  ReplicationFilter? pushFilter;

  /// Filter for validating whether the [Document]s can be pulled from the
  /// remote endpoint.
  ///
  /// Only documents for which the function returns `true` are replicated.
  ReplicationFilter? pullFilter;

  /// A custom conflict resolver.
  ///
  /// If this value is not set, or set to `null`, the default conflict resolver
  /// will be applied.
  ConflictResolver? conflictResolver;

  @override
  String toString() => [
        'CollectionConfiguration(',
        [
          if (channels != null) 'channels: $channels',
          if (documentIds != null) 'documentIds: $documentIds',
          if (pushFilter != null) 'PUSH-FILTER',
          if (pullFilter != null) 'PULL-FILTER',
          if (conflictResolver != null) 'CUSTOM-CONFLICT-RESOLVER',
        ].join(', '),
        ')'
      ].join();
}

class ReplicatorConfiguration {
  ReplicatorConfiguration({
    required this.target,
    this.replicatorType = ReplicatorType.pushAndPull,
    this.authenticator,
    this.enableAutoPurge = true,
    this.continuous = false,
    Duration? heartbeat,
    int? maxAttempts,
    Duration? maxAttemptWaitTime,
  }) {
    this
      ..heartbeat = heartbeat
      ..maxAttempts = maxAttempts
      ..maxAttemptWaitTime = maxAttemptWaitTime;
  }

  final Endpoint target;

  ReplicatorType replicatorType;

  Authenticator? authenticator;

  bool enableAutoPurge;

  bool continuous;

  Duration? get heartbeat => _heartbeat;
  Duration? _heartbeat;

  set heartbeat(Duration? heartbeat) {
    if (heartbeat != null && heartbeat.inSeconds <= 0) {
      throw RangeError.range(
        heartbeat.inSeconds,
        1,
        null,
        'heartbeat.inSeconds',
      );
    }
    _heartbeat = heartbeat;
  }

  int? get maxAttempts => _maxAttempts;
  int? _maxAttempts;

  set maxAttempts(int? maxAttempts) {
    if (maxAttempts != null && maxAttempts <= 0) {
      throw RangeError.range(maxAttempts, 1, null, 'maxAttempts');
    }
    _maxAttempts = maxAttempts;
  }

  Duration? get maxAttemptWaitTime => _maxAttemptWaitTime;
  Duration? _maxAttemptWaitTime;

  set maxAttemptWaitTime(Duration? maxAttemptWaitTime) {
    if (maxAttemptWaitTime != null && maxAttemptWaitTime.inSeconds <= 0) {
      throw RangeError.range(
        maxAttemptWaitTime.inSeconds,
        1,
        null,
        'maxAttemptWaitTime.inSeconds',
      );
    }
    _maxAttemptWaitTime = maxAttemptWaitTime;
  }

  void addCollection(
    Collection collection, [
    CollectionConfiguration? config,
  ]) {}
}
