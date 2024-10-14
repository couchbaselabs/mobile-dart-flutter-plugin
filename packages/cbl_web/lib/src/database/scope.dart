import 'dart:async';

import 'collection.dart';

abstract class Scope {
  static const defaultName = '_default';

  String get name;

  FutureOr<List<Collection>> get collections;

  FutureOr<Collection?> collection(String name);
}
