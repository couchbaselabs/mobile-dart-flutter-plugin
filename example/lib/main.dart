import 'dart:async';
import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

late Database database;
late Collection chatMessages;
late Replicator replicator;
late ChatMessageRepository chatMessageRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CouchbaseLiteFlutter.init();

  await Database.remove('message');

  database = await Database.openAsync('examplechat');

  chatMessages = await database.createCollection('message', 'chat');
  await chatMessages.createIndex(
    'type+createdAt',
    ValueIndex([
      ValueIndexItem.property('type'),
      ValueIndexItem.property('createdAt'),
    ]),
  );

  // update this with your device ip
  final targetURL = Uri.parse('ws://192.168.0.116:4984/examplechat');

  final targetEndpoint = UrlEndpoint(targetURL);

  final config = ReplicatorConfiguration(target: targetEndpoint);

  config.replicatorType = ReplicatorType.pushAndPull;

  config.enableAutoPurge = false;

  config.continuous = true;

  config.authenticator = BasicAuthenticator(username: "bob", password: "12345");

  config.addCollection(chatMessages, CollectionConfiguration());

  replicator = await Replicator.create(config);

  replicator.addChangeListener((change) {
    if (change.status.activity == ReplicatorActivityLevel.stopped) {
      print('Replication stopped');
    } else {
      print('Replicator is currently: ${change.status.activity.name}');
    }
  });

  await replicator.start();

  chatMessageRepository = ChatMessageRepository(database, chatMessages);

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

class ChatMessagesPage extends StatefulWidget {
  const ChatMessagesPage({super.key});
  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  List<ChatMessage> _chatMessages = [];
  late StreamSubscription _chatMessagesSub;
  @override
  void initState() {
    super.initState();
    _chatMessagesSub =
        chatMessageRepository.allChatMessagesStream().listen((chatMessages) {
      setState(() => _chatMessages = chatMessages);
    });
  }

  @override
  void dispose() {
    _chatMessagesSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final chatMessage =
                      _chatMessages[_chatMessages.length - 1 - index];
                  return ChatMessageTile(chatMessage: chatMessage);
                },
              ),
            ),
            const Divider(height: 0),
            _ChatMessageForm(onSubmit: chatMessageRepository.createChatMessage)
          ]),
        ),
      );
}

class ChatMessageTile extends StatelessWidget {
  const ChatMessageTile({super.key, required this.chatMessage});
  final ChatMessage chatMessage;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMd().add_jm().format(chatMessage.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 5),
            Text(chatMessage.chatMessage.toString())
          ],
        ),
      );
}

class _ChatMessageForm extends StatefulWidget {
  const _ChatMessageForm({required this.onSubmit});
  final ValueChanged<String> onSubmit;
  @override
  _ChatMessageFormState createState() => _ChatMessageFormState();
}

class _ChatMessageFormState extends State<_ChatMessageForm> {
  late final TextEditingController _messageController;
  late final FocusNode _messageFocusNode;
  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    widget.onSubmit(message);
    _messageController.clear();
    _messageFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration:
                    const InputDecoration.collapsed(hintText: 'Message'),
                autofocus: true,
                focusNode: _messageFocusNode,
                controller: _messageController,
                minLines: 1,
                maxLines: 10,
                style: Theme.of(context).textTheme.bodyMedium,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 5),
            TextButton(
              onPressed: _onSubmit,
              child: const Text('Send'),
            )
          ],
        ),
      );
}

abstract class ChatMessage {
  String get id;
  String get chatMessage;
  DateTime get createdAt;
}

class CblChatMessage extends ChatMessage {
  CblChatMessage(this.dict);
  final DictionaryInterface dict;
  @override
  String get id => dict.documentId;
  @override
  DateTime get createdAt => dict.value('createdAt')!;
  @override
  String get chatMessage => dict.value('chatMessage') ?? '-';
}

extension DictionaryDocumentIdExt on DictionaryInterface {
  String get documentId {
    final self = this;
    return self is Document ? self.id : self.value('id')!;
  }
}

class ChatMessageRepository {
  ChatMessageRepository(this.database, this.collection);
  final Database database;
  final Collection collection;

  Future<ChatMessage> createChatMessage(String message) async {
    final doc = MutableDocument({
      'type': 'chatMessage',
      'createdAt': DateTime.now(),
      'userId': 'bob',
      'chatMessage': message,
    });
    await collection.saveDocument(doc);
    return CblChatMessage(doc);
  }

  Stream<List<ChatMessage>> allChatMessagesStream() {
    final query = const QueryBuilder()
        .select(
          SelectResult.expression(Meta.id),
          SelectResult.property('createdAt'),
          SelectResult.property('chatMessage'),
        )
        .from(DataSource.collection(collection))
        .where(
          Expression.property('type').equalTo(Expression.value('chatMessage')),
        )
        .orderBy(Ordering.property('createdAt'));

    Future(query.explain).then(print);

    return query.changes().asyncMap(
          (change) =>
              change.results.asStream().map(CblChatMessage.new).toList(),
        );
  }
}
