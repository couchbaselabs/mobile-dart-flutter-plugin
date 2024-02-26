import 'dart:async';

import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

late ChatMessageRepository chatMessageRepository;

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('test')),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: 0,
                itemBuilder: (context, index) {
                  final chatMessage = CblChatMessage(null);
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
              DateFormat.yMd()
                  .add_jm()
                  .format(chatMessage.createdAt ?? DateTime.now()),
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
  String? get chatMessage;
  DateTime? get createdAt;
}

class CblChatMessage extends ChatMessage {
  CblChatMessage(this.dict);
  final Map<String, Object?>? dict;
  @override
  String get id => '';
  @override
  DateTime? get createdAt => null;
  @override
  String? get chatMessage => null;
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
    return CblChatMessage(doc.toPlainMap());
  }
}
