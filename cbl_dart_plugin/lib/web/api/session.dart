import 'package:cbl_dart_plugin/web/logging/logger.dart';
import 'package:cbl_dart_plugin/web/service/web_service.dart';

abstract class Session {
  // If the credentials provided in the request body are valid, the session
  // is created with an idle session timeout of 24 hours. An idle session timeout
  // in the context of Sync Gateway is defined as the following: if 10% or more
  // of the current expiration time has elapsed when a subsequent request with
  // that session id is processed, the session’s expiry time is automatically
  // updated to 24 hours from that time.
  Future<String> create(
      {required String url,
      required String username,
      required String password});

  // This request deletes the session that currently authenticates the requests.
  Future<String> delete({required String url, required String cookie});
}

class SessionImpl extends WebService implements Session {
  SessionImpl(Logger logger) : super(logger);

  @override
  Future<String> create(
      {required String url,
      required String username,
      required String password}) async {
    final response = await send(url,
        method: HttpMethod.post,
        body: '{"name": "$username", "password": "$password"}');

    return response.body;
  }

  @override
  Future<String> delete({required String url, required String cookie}) async {
    final response = await send(url,
        method: HttpMethod.delete, headers: <String, String>{"cookie": cookie});

    return response.body;
  }
}
