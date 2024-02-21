export 'api/collection.dart';
export 'api/database.dart';
export 'api/scope.dart';

class CouchbaseLiteFlutter {
  /// Private constructor to allow control over instance creation.
  CouchbaseLiteFlutter._();

  /// Initializes the `cbl` package, for the main isolate.
  static Future<void> init() async {}
}
