# Couchbase Lite Flutter Plugin

This plugin provides Flutter support for Couchbase Lite, enabling developers to integrate powerful mobile database capabilities and web into their Flutter applications[2].

## Overview

Couchbase Lite Flutter Plugin allows you to leverage the full potential of Couchbase Lite in your Flutter projects. It offers a seamless integration between Flutter and Couchbase Lite, providing a robust solution for offline-first mobile application and web support.

## Installation

To use this plugin in your Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  couchbase_lite_flutter: ^latest_version
```

Replace `latest_version` with the most recent version of the plugin[2].

## Usage

Here's a basic example of how to use the Couchbase Lite Flutter Plugin in your application:

## Code Example

```dart
import 'package:cbl/cbl.dart';

Future<void> run() async {
  // Open the database (creating it if it doesn’t exist).
  final database = await Database.openAsync('chat_database');

  // Create a collection for chat messages, or return it if it already exists.
  final collection = await database.createCollection('messages');

  // Create a new chat message document.
  final mutableDocument = MutableDocument({
    'sender': 'Alice',
    'recipient': 'Bob',
    'message': 'Hello, Bob!',
    'timestamp': DateTime.now().toIso8601String(),
  });
  await collection.saveDocument(mutableDocument);

  print(
    'Created message with id ${mutableDocument.id} from '
    '${mutableDocument.string('sender')} to ${mutableDocument.string('recipient')}.',
  );

  // Update the message.
  mutableDocument.setString('Hello, Bob! How are you?', key: 'message');
  await collection.saveDocument(mutableDocument);

  print(
    'Updated message with id ${mutableDocument.id}, '
    'new message: ${mutableDocument.string("message")!}.',
  );

  // Read the message document.
  final document = (await collection.document(mutableDocument.id))!;

  print(
    'Read message with id ${document.id}, '
    'from ${document.string('sender')} to ${document.string('recipient')} with '
    'content: ${document.string('message')}.',
  );

  // Create a query to fetch all messages sent by Alice.
  print('Querying messages sent by Alice.');
  final query = await database.createQuery('''
    SELECT * FROM messages
    WHERE sender = 'Alice'
  ''');

  // Run the query.
  final result = await query.execute();
  final results = await result.allResults();
  print('Number of messages sent by Alice: ${results.length}');

  // Close the database.
  await database.close();
}
```

## Features

- **Full Couchbase Lite API**: Access to all Couchbase Lite features including CRUD operations, queries, and replication.
- **Cross-platform**: Works on both iOS, Android and Web platforms.
- **Offline-first**: Build mobile apps that work offline and sync when a connection is available.
- **Performance**: Utilizes native Couchbase Lite libraries for optimal performance.

## Documentation

For detailed documentation and API reference, please visit our [official documentation page](https://github.com/couchbaselabs/mobile-dart-flutter-plugin/wiki/Documentation).

## Contributing

We welcome contributions to the Couchbase Lite Flutter Plugin!.

## License

This project is licensed under the Apache License 2.0.

## Support

For questions, feature requests, or bug reports, please file an issue on our [GitHub issues page](https://github.com/couchbaselabs/mobile-dart-flutter-plugin/issues).
