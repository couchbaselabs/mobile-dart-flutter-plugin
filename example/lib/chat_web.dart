import 'dart:convert';

import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessagesPage extends StatefulWidget {
  const ChatMessagesPage({super.key});
  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  final CblWebSocket _cblWebSocket = CblWebSocket();
  final ScrollController _scrollController = ScrollController();
  final CblPerformanceLogger _cblPerformanceLogger = CblPerformanceLogger();

  List<dynamic> messages = [];

  @override
  void initState() {
    super.initState();
    _cblWebSocket.createCollection('data', 'testing');
    _cblWebSocket.connect(
        channels: ['100k:0'],
        url: 'ws://18.220.129.162:4984/water',
        username: 'test',
        password: 'password');

    _cblPerformanceLogger.start('wsPerformancde');

    _cblWebSocket.startListening((message) {
      if ((message != null || message != '') && message is String) {
     
        List<dynamic> decodedMsg = json.decode(message);

        setState(() {
          messages.addAll(decodedMsg);
           _cblPerformanceLogger.end('wsPerformancde');
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
            Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text(
                  'Chat Count: ${messages.length}',
                  
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                reverse: false,
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final item = messages[index];
                  return ChatMessageTile(
                    message: item.containsKey('doc')
                        ? item['doc']['name']
                        : '-',
                    // createdAt: item.containsKey('doc')
                    //     ? item['doc']['createdAt']
                    //     : DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSS")
                    //         .format(DateTime.now()),
                  );
                },
              ),
            ),
            const Divider(height: 0),
            _ChatMessageForm(
              onSubmit: (message) {},
              cblWebSocket: _cblWebSocket,
            )
          ]),
        ),
      );
}

class ChatMessageTile extends StatelessWidget {
  const ChatMessageTile({this.message, 
  //required this.createdAt, 
  super.key});

  final String? message;
  // final String createdAt;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Text(
            // //   DateFormat.yMd().add_jm().format(DateTime.parse(createdAt)),
            // //   style: Theme.of(context).textTheme.bodySmall,
            // // ),
            // const SizedBox(height: 5),
            Text(message ?? '')
          ],
        ),
      );
}

class _ChatMessageForm extends StatefulWidget {
  const _ChatMessageForm({
    required this.cblWebSocket,
    required this.onSubmit,
  });
  final CblWebSocket cblWebSocket;
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

    Map<String, Object> doc = {
      'name': '100k:0',
      'age': 0,
      'index': '0',
      'body': message,
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
