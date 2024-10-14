import 'package:web_socket_channel/io.dart';

abstract class WebSocket {
  void start(List<String> urls);
}

class WebSocketImpl implements WebSocket {
  void start(List<String> urls) {
    // Create and manage WebSocket channels using forEach
    urls.forEach((socketUrl) {
      final channel = IOWebSocketChannel.connect(socketUrl);

      // Subscribe to events for each channel
      channel.stream.listen((data) {
        print('Received on $socketUrl: $data');
        // Handle the received data from the current channel
      });

      // Send a message on each channel
      channel.sink.add('Message to $socketUrl');

      // Close the channel when done
      channel.sink.close();
    });
  }
}
