import 'package:cbl_dart_plugin/web/logging/log_level.dart';
import 'package:cbl_dart_plugin/web/logging/logger.dart';
import 'package:cbl_dart_plugin/web/utils/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

abstract class WebService {
  WebService(this.logger) {
    logger.logFor(this);
  }

  @protected
  final Logger logger;

  @protected
  @nonVirtual
  Future<Response> send(
    String url, {
    required HttpMethod method,
    AuthHeader? authHeader,
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(minutes: 1),
    String contentType = HttpContentTypes.json,
  }) async {
    assert(url.isNotEmpty);

    headers ??= {};

    if (authHeader != null) {
      headers.putIfAbsent('Authorization', () => authHeader.value);
    }

    headers.putIfAbsent('Content-Type', () => contentType);

    final methodTag = method.toString().split('.').last.toUpperCase();

    Uri uri = Uri.parse(url);

    late Response response;

    logger.log(LogLevel.info, '$methodTag $url');

    try {
      switch (method) {
        case HttpMethod.get:
          response = await get(uri, headers: headers).timeout(timeout);
        case HttpMethod.post:
          response =
              await post(uri, headers: headers, body: body).timeout(timeout);
        case HttpMethod.put:
          response =
              await put(uri, headers: headers, body: body).timeout(timeout);
        case HttpMethod.delete:
          response = await delete(uri, headers: headers).timeout(timeout);
        case HttpMethod.patch:
          response =
              await patch(uri, headers: headers, body: body).timeout(timeout);
      }

      return response;
    } catch (e) {
      logger.log(LogLevel.error, 'Failed $e');
      rethrow;
    }
  }
}

class AuthHeader {
  AuthHeader({required this.authScheme})
      : assert(!StringUtils.isNullOrEmpty(authScheme));

  factory AuthHeader.basic() => AuthHeader(authScheme: 'Basic');

  final String authScheme;

  String get value => toString();

  @override
  String toString() => authScheme;
}

enum HttpMethod { get, post, put, delete, patch }

abstract final class HttpContentTypes {
  static const json = 'application/json';
  static const formUrlEncoded = 'application/x-www-form-urlencoded';
}
