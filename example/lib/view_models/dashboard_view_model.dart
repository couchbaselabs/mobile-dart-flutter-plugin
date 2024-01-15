import 'dart:async';
import 'package:example/services/couchbase_service.dart';
import 'package:flutter/foundation.dart';

class DashboardViewModel with ChangeNotifier, DiagnosticableTreeMixin {
  DashboardViewModel({required CouchbaseService couchbaseService})
      : _couchbaseService = couchbaseService;

  final CouchbaseService _couchbaseService;

  Future<void> viewDocument(String name) async {
    _couchbaseService.getListDocument(name);
  }

  Future<void> addDocument(String name, String scope) async {
    _couchbaseService.createCollection(name, scope);
  }

  Future<void> deleteDocument(String name, String scope) async {
    _couchbaseService.dropCollection(name, scope);
  }
}
