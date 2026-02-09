import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../chatmodel.dart';

typedef OnlineUsersCallback = void Function(List<String> users);
typedef MessageCallback = void Function(String from, String text);

class ChatSocketService {
  final String mobile;
  late WebSocketChannel channel;

  bool _isConnected = false;
  bool _isConnecting = false;

  Timer? _pingTimer;
  Timer? _reconnectTimer;

  final StreamController<ChatEvent> _controller =
  StreamController.broadcast();
  Stream<ChatEvent> get events => _controller.stream;

  ChatSocketService(this.mobile);

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected || _isConnecting) return;

    _isConnecting = true;

    channel = WebSocketChannel.connect(
      Uri.parse(
        'wss://simple-chat-server-9vzn.onrender.com/ws/$mobile',
      ),
    );
   // print('wss://simple-chat-server-9vzn.onrender.com/ws/${mobile} blal');

    channel.stream.listen(
      _handleData,
      onDone: _handleDisconnect,
      onError: (_) => _handleDisconnect(),
    );

  }

  void _handleData(dynamic data) {
    final json = jsonDecode(data);

    if (!_isConnected) {
      _isConnected = true;
      _isConnecting = false;
      _startPing();
    }

    if (json["type"] == "online_users") {
      final users = List<String>.from(json["users"]);
      users.remove(mobile);
      _controller.add(ChatEvent.onlineUsers(users));
    }

    if (json["type"] == "message") {
      // print(json["from"],);
      // print( json["text"]);
      _controller.add(
        ChatEvent.message(json["from"], json["text"]),
      );
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _isConnecting = false;
    _stopPing();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      const Duration(seconds: 10),
      connect,
    );
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(seconds: 25),
          (_) {
        if (_isConnected) {
          channel.sink.add(jsonEncode({"type": "ping"}));
        }
      },
    );
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void sendMessage(String to, String text) {
    if (!_isConnected) return;

    channel.sink.add(jsonEncode({
      "type": "message",
      "to": to,
      "text": text,
    }));
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _stopPing();
    _isConnected = false;
    _isConnecting = false;
    channel.sink.close();
    //_controller.close();
  }
}
