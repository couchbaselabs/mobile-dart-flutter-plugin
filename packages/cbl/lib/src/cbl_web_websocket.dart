class CblWebSocket {
  void connect(
      {required String url,
      required String username,
      required String password}) {
    throw UnimplementedError();
  }

  void createCollection(String collection, String scope) {}

  void startListening(void Function(dynamic) handleMessage) {
    throw UnimplementedError();
  }

  void stopListening() {
    throw UnimplementedError();
  }

  void disconnect() {
    throw UnimplementedError();
  }

  String _generateRandomString(int length) {
    throw UnimplementedError();
  }

  Future<void> saveDocument(Map<String, Object> map) async {
    throw UnimplementedError();
  }
}
