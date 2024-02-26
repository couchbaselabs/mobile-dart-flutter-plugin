import 'dart:async';

import 'collection.dart';
import 'database_configuration.dart';
import 'scope.dart';

enum ConcurrencyControl {
  /// The current save/delete will overwrite a conflicting revision if there is
  /// a conflict.
  lastWriteWins,

  /// The current save/delete will fail if there is a conflict.
  failOnConflict,
}

abstract class Database {
  Database();

  static Future<Database> openAsync(String name,
          [DatabaseConfiguration? config]) async =>
      AsyncDatabase.open(name, config);

  static Future<void> remove(String name, {String? directory}) async {}

  FutureOr<Collection> createCollection(
    String name, [
    String scope = Scope.defaultName,
  ]);
}

class AsyncDatabase implements Database {
  AsyncDatabase();

  static Future<AsyncDatabase> open(
    String name, [
    DatabaseConfiguration? config,
  ]) async =>
      AsyncDatabase();

  @override
  FutureOr<Collection> createCollection(String name,
      [String scope = Scope.defaultName]) {
    throw UnimplementedError();
  }
}
