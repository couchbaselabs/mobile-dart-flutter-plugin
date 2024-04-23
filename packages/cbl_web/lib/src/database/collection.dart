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
  CollectionImpl(String collection, String scope) {
    _collection = collection;
    _scope = scope;
  }

  late String _collection;
  late String _scope;
  late String _username;
  late String _password;
  late String _url;

  @override
  FutureOr<void> createIndex(String name, index) {
    // not supported on web
  }

  void replicatorConfig(ReplicatorConfiguration replicator) {
    _username = replicator.username;
    _password = replicator.password;
    _url = replicator.url;
  }

  @override
  FutureOr<bool> saveDocument(MutableDocument document,
      [ConcurrencyControl concurrencyControl =
          ConcurrencyControl.lastWriteWins]) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$_username:$_password'))}'
      };

      String? baseUrl;

      final regex = RegExp(r'^ws://([\w\-.]+)(:\d+)?(/[^\/?]+)?');
      final Match? match = regex.firstMatch(_url);

      if (match != null) {
        baseUrl =
            'http://${match.group(1)}:4984${match.group(3) ?? ''}.$_scope.$_collection';
      } else {
        print('Invalid WebSocket URL');
      }

      print('$baseUrl/${_generateRandomString(10)}');

      final request = http.Request(
          'PUT', Uri.parse('$baseUrl/${_generateRandomString(10)}'));

      request.body = json.encode(document.map);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }

      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  @override
  String get name => _collection;

  @override
  String get scope => _scope;

  String _generateRandomString(int length) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
