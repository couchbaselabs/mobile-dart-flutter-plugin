import 'dart:async';
import 'dart:convert';

import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// update this with your device ip
const String cbUrl = 'ws://192.168.0.183:4984/examplechat';
const String databaseName = 'examplechat';
const String scope = 'chat';
const String collection = 'message';
const String username = 'bob';
const String password = '12345';

class ChatMessagesPage extends StatefulWidget {
  const ChatMessagesPage({super.key});
  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  

  @override
  Widget build(BuildContext context) => kIsWeb ? const ChatMessagePageWeb() : const ChatMessagePageMobile();
}

class ChatMessagePageWeb extends StatefulWidget {
  const ChatMessagePageWeb({super.key});

  @override
  State<ChatMessagePageWeb> createState() => _ChatMessagePageWebState();
}

class _ChatMessagePageWebState extends State<ChatMessagePageWeb> {
   final CblWebSocket _cblWebSocket = CblWebSocket();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> messages = [];

  @override
  void initState() {
    super.initState();
    _cblWebSocket.createCollection(collection, scope);

    _cblWebSocket.connect(
        url: cbUrl,
        username: username,
        password: password, channels: []);

    _cblWebSocket.startListening((message) {
      if ((message != null || message != '') && message is String) {
        List<dynamic> decodedMsg = json.decode(message);

        setState(() {
          messages.addAll(decodedMsg);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          } else {
            setState(() => {});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                reverse: false,
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final item = messages[index];
                  return ChatMessageTileWeb(
                    message: item.containsKey('doc')
                        ? item['doc']['chatMessage']
                        : '-',
                    createdAt: item.containsKey('doc')
                        ? item['doc']['createdAt']
                        : DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSS")
                            .format(DateTime.now()),
                  );
                },
              ),
            ),
            const Divider(height: 0),
            _ChatMessageFormWeb(
              onSubmit: (message) {},
              cblWebSocket: _cblWebSocket,
            )
          ]),
        ),
      );
}

class ChatMessageTileWeb extends StatelessWidget {
  const ChatMessageTileWeb({this.message, required this.createdAt, super.key});

  final String? message;
  final String createdAt;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMd().add_jm().format(DateTime.parse(createdAt)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 5),
            Text(message ?? '')
          ],
        ),
      );
}

class _ChatMessageFormWeb extends StatefulWidget {
  const _ChatMessageFormWeb({
    required this.cblWebSocket,
    required this.onSubmit,
  });
  final CblWebSocket cblWebSocket;
  final ValueChanged<String> onSubmit;
  @override
  _ChatMessageFormWebState createState() => _ChatMessageFormWebState();
}

class _ChatMessageFormWebState extends State<_ChatMessageFormWeb> {
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

    Map<String, Object> doc = {
      'type': 'chatMessage',
      'createdAt':
          DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSS").format(DateTime.now()),
      'userId': 'bob',
      'chatMessage': message,
    };

    widget.cblWebSocket.saveDocument(doc);

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

class ChatMessagePageMobile extends StatefulWidget {
  const ChatMessagePageMobile({super.key});

  @override
  State<ChatMessagePageMobile> createState() => _ChatMessagePageMobileState();
}

class _ChatMessagePageMobileState extends State<ChatMessagePageMobile> {
  @override
  void initState() {
    super.initState();
  }

  Future<ChatMessageRepository> setup() async {
    late Database database;
    late Collection chatMessages;
    late Replicator replicator;
    late ChatMessageRepository chatMessageRepository;

    database = await Database.openAsync(databaseName);

    chatMessages = await database.createCollection(collection, scope);

    final targetURL = Uri.parse(cbUrl);

    final targetEndpoint = UrlEndpoint(targetURL);

    final config = ReplicatorConfiguration(target: targetEndpoint);

    config.replicatorType = ReplicatorType.pushAndPull;

    config.enableAutoPurge = false;

    config.continuous = true;

    config.authenticator =
        BasicAuthenticator(username: "bob", password: "12345");

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

  @override
  void initState() {
    super.initState();

    _chatMessagesSub =
        widget.repository!.allChatMessagesStream().listen((chatMessages) {
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

    return query.changes().asyncMap(
          (change) => change.results
              .asStream()
              .map((result) => CblChatMessage(result))
              .toList(),
        );
  }
}
