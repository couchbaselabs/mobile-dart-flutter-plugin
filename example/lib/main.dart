import 'dart:async';
import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:example/chat_mobile.dart'
    if (dart.library.html) 'package:example/chat_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

late Database database;
late Collection chatMessages;
late Replicator replicator;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CouchbaseLiteFlutter.init();

  await Database.remove('message');

  database = await Database.openAsync('examplechat');

  if (!kIsWeb) {
    chatMessages = await database.createCollection('message', 'chat');
  }

  // update this with your device ip
  final targetURL = Uri.parse('ws://192.168.0.116:4984/examplechat');

  final targetEndpoint = UrlEndpoint(targetURL);

  final config = ReplicatorConfiguration(target: targetEndpoint);

  config.replicatorType = ReplicatorType.pushAndPull;

  config.enableAutoPurge = false;

  config.continuous = true;

  config.authenticator = BasicAuthenticator(username: "bob", password: "12345");

  if (!kIsWeb) {
    config.addCollection(chatMessages, CollectionConfiguration());
  }

  replicator = await Replicator.create(config);

  replicator.addChangeListener((change) {
    if (change.status.activity == ReplicatorActivityLevel.stopped) {
      print('Replication stopped');
    } else {
      print('Replicator is currently: ${change.status.activity.name}');
    }
  });

  await replicator.start();

  if (!kIsWeb) {
    chatMessageRepository = ChatMessageRepository(database, chatMessages);
  }
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
