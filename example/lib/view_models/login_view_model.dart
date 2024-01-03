import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel with ChangeNotifier, DiagnosticableTreeMixin {
  Future<void> initialize() async {
    await CouchbaseLiteFlutter.init();
  }

  void login() {
    print('test');
  }
}
