import 'dart:async';
import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:example/chat.dart';

import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CouchbaseLiteFlutter.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChatMessagesPage(),
      );
}
