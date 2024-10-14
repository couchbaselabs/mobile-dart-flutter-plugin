import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import '../../cbl_web.dart';

abstract class Collection {
  static const defaultName = '_default';

  String get name;
  String get scope;

  void replicatorConfig(ReplicatorConfiguration replicator);
  FutureOr<void> createIndex(String name, dynamic index);
  FutureOr<bool> saveDocument(
    MutableDocument document, [
    ConcurrencyControl concurrencyControl = ConcurrencyControl.lastWriteWins,
  ]);
}

class CollectionImpl extends Collection {
  late String _collection;
  late String _scope;
  late String _username;
  late String _password;
  late String _url;

  CollectionImpl(String collection, String scope) {
    _collection = collection;
    _scope = scope;
  }

  @override
  FutureOr<void> createIndex(String name, dynamic index) {
    // Index creation is not supported on the web
  }

  @override
  void replicatorConfig(ReplicatorConfiguration replicator) {
    _username = replicator.username;
    _password = replicator.password;
    _url = replicator.url;
  }

  @override
  FutureOr<bool> saveDocument(MutableDocument document, [
    ConcurrencyControl concurrencyControl = ConcurrencyControl.lastWriteWins,
  ]) async {
    try {
      final baseUrl = _constructBaseUrl();
      if (baseUrl == null) {
        print('Invalid WebSocket URL');
        return false;
      }

      final requestUrl = '$baseUrl/${_generateRandomString(10)}';
      final headers = _constructHeaders();

      final request = http.Request('PUT', Uri.parse(requestUrl))
        ..body = json.encode(document.map)
        ..headers.addAll(headers);

      final response = await request.send();
      await _handleResponse(response);

      return true;
    } catch (e) {
      print('Error saving document: $e');
      return false;
    }
  }

  @override
  String get name => _collection;
  @override
  String get scope => _scope;

  // Constructs the base URL from the WebSocket URL
  String? _constructBaseUrl() {
    final regex = RegExp(r'^ws://([\w\-.]+)(:\d+)?(/[^\/?]+)?');
    final match = regex.firstMatch(_url);

    if (match == null) return null;

    return 'http://${match.group(1)}:4984${match.group(3) ?? ''}.$_scope.$_collection';
  }

  // Constructs HTTP headers for the request
  Map<String, String> _constructHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$_username:$_password'))}'
    };
  }

  // Handles HTTP response
  Future<void> _handleResponse(http.StreamedResponse response) async {
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print('Failed to save document: ${response.reasonPhrase}');
    }
  }

  // Generates a random string of specified length
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
