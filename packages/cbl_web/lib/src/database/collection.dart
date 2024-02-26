import 'dart:async';

import '../document/document.dart';

import 'database.dart';

abstract class Collection {
  FutureOr<void> createIndex(String name, dynamic index);

  FutureOr<bool> saveDocument(
    MutableDocument document, [
    ConcurrencyControl concurrencyControl = ConcurrencyControl.lastWriteWins,
  ]);
}
