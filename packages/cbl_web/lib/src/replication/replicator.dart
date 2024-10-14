import 'dart:async';
import 'dart:convert';

import 'configuration.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'replicator_change.dart';

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

class ReplicatorProgress {
  ReplicatorProgress(this.completed, this.progress);

  /// The number of [Document]s processed so far.
  final int completed;

  /// The overall progress as a number between `0.0` and `1.0`.
  ///
  /// The value is very approximate and may bounce around during replication;
  /// making it more accurate would require slowing down the replicator and
  /// incurring more load on the server.
  final double progress;

  @override
  String toString() => 'ReplicatorProgress('
      '${(progress * 100).toStringAsFixed(1)}%; '
      // ignore: missing_whitespace_between_adjacent_strings
      'completed: $completed'
      ')';
}

/// Combined [ReplicatorActivityLevel], [ReplicatorProgress] and possibly error
/// of a [Replicator].
///
/// {@category Replication}
class ReplicatorStatus {
  ReplicatorStatus(this.activity, this.progress, this.webData, this.error);

  /// The current activity level of the [Replicator].
  final ReplicatorActivityLevel activity;

  /// The current progress of the [Replicator].
  final ReplicatorProgress progress;

  /// This is only applicable in web
  final dynamic webData;

  /// The current error of the [Replicator], if one has occurred.
  final Object? error;

  @override
  String toString() => [
        'ReplicatorStatus(',
        [
          activity.name,
          if (progress.completed != 0) 'progress: $progress',
          if (error != null) 'error: $error',
        ].join(', '),
        ')',
      ].join();
}

late WebSocketChannel _channel;
late StreamSubscription<dynamic> _streamSubscription;

abstract class Replicator {
  static Future<Replicator> create(ReplicatorConfiguration config) async {
    RegExp regex = RegExp(r'^(ws|wss)://');
    String modifiedUrl =
        config.target.toString().replaceFirstMapped(regex, (match) {
      return '${match.group(1)}://${config.username}:${config.password}@';
    });

    final wsUrl = Uri.parse(
        '$modifiedUrl.${config.scopeName}.${config.collectionName}/_changes?feed=websocket&include_docs=true&channels=${config.channels?.join(',')}');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel.sink.add(
        '{"include_docs":true,"channels":"${config.channels?.join(',')}"}');

    print(
        '$modifiedUrl.${config.scopeName}.${config.collectionName}/_changes?feed=websocket&include_docs=true&channels=${config.channels?.join(',')}');
    return ReplicatorImpl();
  }

  FutureOr<dynamic> addChangeListener(void Function(ReplicatorChange) listener);

  FutureOr<void> start({bool reset = false});

  FutureOr<void> stop();
}

class ReplicatorImpl extends Replicator {
  ReplicatorImpl();

  // ignore: close_sinks
  final StreamController<dynamic> _streamController =
      StreamController<dynamic>();
  late Stream<dynamic> replicatorDataStream;
  List<dynamic> messages = [];

  @override
  FutureOr<dynamic> addChangeListener(
      void Function(ReplicatorChange) listener) {
    _streamSubscription = _channel.stream.listen((msg) {
      listener.call(
        ReplicatorChangeImpl(
          ReplicatorImpl(),
          ReplicatorStatus(
              ReplicatorActivityLevel.idle, ReplicatorProgress(1, 0), '', msg),
        ),
      );

      return;
    });
  }

  @override
  FutureOr<void> start({bool reset = false}) {
    _streamSubscription = _channel.stream.listen(_streamController.add);

    replicatorDataStream = _streamController.stream;
  }

  @override
  FutureOr<void> stop() {
    _streamSubscription.cancel();
    _channel.sink.close();
  }
}
