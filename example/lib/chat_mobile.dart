import 'dart:async';

import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessagesPage extends StatefulWidget {
  const ChatMessagesPage({super.key});

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {

  @override
  void initState() {
    super.initState();
  }

  Future<ChatMessageRepository> setup() async {
    late Database database;
    late Collection chatMessages;
    late Replicator replicator;
    late ChatMessageRepository chatMessageRepository;

    database = await Database.openAsync('perfTesting');

    chatMessages = await database.createCollection('data', 'testing');

    // update this with your device ip
    final targetURL = Uri.parse('ws://18.220.129.162:4984/water');

    final targetEndpoint = UrlEndpoint(targetURL);

    final config = ReplicatorConfiguration(target: targetEndpoint);

    config.replicatorType = ReplicatorType.pushAndPull;

    config.enableAutoPurge = false;

    config.continuous = true;

    config.authenticator =
        BasicAuthenticator(username: "test", password: "password");

    config.addCollection(chatMessages, CollectionConfiguration(channels: ['100k:0']));

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

    return chatMessageRepository;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ChatMessageRepository>(
          future: setup(),
          builder: (context, snapshot) => snapshot.data == null
              ? const Center(child: CircularProgressIndicator())
              : ChatMessagesPageMobile(
                  repository: snapshot.data,
                )),
    );
  }
}

class ChatMessagesPageMobile extends StatefulWidget {
  const ChatMessagesPageMobile({this.repository, super.key});
  final ChatMessageRepository? repository;

  @override
  State<ChatMessagesPageMobile> createState() => _ChatMessagesPageMobileState();
}

class _ChatMessagesPageMobileState extends State<ChatMessagesPageMobile> {
  List<ChatMessage> _chatMessages = [];
  late StreamSubscription _chatMessagesSub;
  final CblPerformanceLogger _cblPerformanceLogger = CblPerformanceLogger();
  int count = 0;

  @override
  void initState() {
    super.initState();
       _cblPerformanceLogger.start('wsPerformance');
        
    _chatMessagesSub =
        widget.repository!.allChatMessagesStream().listen((chatMessages) {
        
      setState(() { 
  
        _chatMessages = chatMessages;
        count = count + 1;
          _cblPerformanceLogger.end('wsPerformance');
          print(count);
        });
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
            Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text(
                  'Chat Count: ${_chatMessages.length}',
                  
                ),
              ),
            ),
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
            _ChatMessageForm(onSubmit: widget.repository!.createChatMessage)
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
            // Text(
            //   DateFormat.yMd().add_jm().format(chatMessage.createdAt),
            //   style: Theme.of(context).textTheme.bodySmall,
            // ),
            // const SizedBox(height: 5),
            Text(chatMessage.name.toString())
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
  String get name;
}

class CblChatMessage extends ChatMessage {
  CblChatMessage(this.dict);
  final DictionaryInterface dict;
  @override
  String get id => dict.documentId;
  @override
  String get name => dict.value('name')!;
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
      'name': '100k:0',
      'age': 0,
      'index': '0',
      'body': message,
    });
    await collection.saveDocument(doc);
    return CblChatMessage(doc);
  }

  Stream<List<ChatMessage>> allChatMessagesStream() {
    final query = const QueryBuilder()
        .select(
          SelectResult.expression(Meta.id),
          SelectResult.property('name'),
        )
        .from(DataSource.collection(collection));

    

    return query.changes().asyncMap(
          (change) => change.results
              .asStream()
              .map((result) => CblChatMessage(result))
              .toList(),
        );
  }
}
