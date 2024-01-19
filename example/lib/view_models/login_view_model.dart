import 'dart:async';
import 'package:example/services/couchbase_service.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel with ChangeNotifier, DiagnosticableTreeMixin {
  LoginViewModel({required CouchbaseService couchbaseService})
      : _couchbaseService = couchbaseService;

  final CouchbaseService _couchbaseService;

  Future<void> login(String username, String password) async {
    _couchbaseService.startReplicator(<String, String>{
      'url': 'ws://localhost/sync_gateway',
      'username': username,
      'password': password,
    });
  }

  Future<void> logout() async {
    _couchbaseService.logout();
  }
}
