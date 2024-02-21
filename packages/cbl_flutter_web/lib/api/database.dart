import 'dart:async';

import 'collection.dart';
import 'scope.dart';

class Database {
  Database();

  static Future<void> remove(String name, {String? directory}) async {}
  static Future<Database> openAsync(String name, [dynamic? config]) async =>
      Database();

  FutureOr<Collection> createCollection(
    String name, [
    String scope = Scope.defaultName,
  ]) =>
      Collection();
}
