import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../chatmodel.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../chatmodel.dart';

class ChatSocketService {
  static ChatSocketService? _instance;

  factory ChatSocketService(String mobile) {
    _instance ??= ChatSocketService._internal(mobile);
    return _instance!;
  }

  ChatSocketService._internal(this.mobile);

  final String mobile;
  late WebSocketChannel channel;

  bool _isConnected = false;
  bool _isConnecting = false;

  Timer? _pingTimer;
  Timer? _reconnectTimer;

  final StreamController<ChatEvent> _controller = StreamController.broadcast();
  Stream<ChatEvent> get events => _controller.stream;

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;

    channel = WebSocketChannel.connect(
      Uri.parse('wss://simple-chat-server-9vzn.onrender.com/ws/$mobile'),
    );

    channel.stream.listen(
      _handleData,
      onDone: _handleDisconnect,
      onError: (_) => _handleDisconnect(),
    );
  }

  void _handleData(dynamic data) {
    try {
      final json = jsonDecode(data);

      if (!_isConnected) {
        _isConnected = true;
        _isConnecting = false;
        _startPing();
        requestOnlineUsers();
      }

      if (json["type"] == "online_users") {
        final users = List<String>.from(json["users"]);
        users.remove(mobile);
        _controller.add(ChatEvent.onlineUsers(users));
      } else if (json["type"] == "message") {
        if (json["from"] != null && json["text"] != null) {
          _controller.add(
            ChatEvent.message(json["from"].toString(), json["text"].toString()),
          );
        }
      }
    } catch (e) {
      print('Socket parsing error: $e');
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
    _reconnectTimer = Timer(const Duration(seconds: 10), connect);
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_isConnected) channel.sink.add(jsonEncode({"type": "ping"}));
    });
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void requestOnlineUsers() {
    if (!_isConnected) return;
    try {
      channel.sink.add(jsonEncode({"type": "get_online_users"}));
    } catch (e) {
      print("Error requesting online users: $e");
    }
  }

  void sendMessage(String to, String text) {
    if (!_isConnected) return;
    channel.sink.add(jsonEncode({"type": "message", "to": to, "text": text}));
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _stopPing();
    _isConnected = false;
    _isConnecting = false;
    channel.sink.close();
  }
}

//
// typedef OnlineUsersCallback = void Function(List<String> users);
// typedef MessageCallback = void Function(String from, String text);
//
// class ChatSocketService {
//   final String mobile;
//   late WebSocketChannel channel;
//
//   bool _isConnected = false;
//   bool _isConnecting = false;
//
//   Timer? _pingTimer;
//   Timer? _reconnectTimer;
//
//   final StreamController<ChatEvent> _controller =
//   StreamController.broadcast();
//   Stream<ChatEvent> get events => _controller.stream;
//
//   ChatSocketService(this.mobile);
//
//   bool get isConnected => _isConnected;
//
//   void connect() {
//     if (_isConnected || _isConnecting) return;
//
//     _isConnecting = true;
//
//     channel = WebSocketChannel.connect(
//       Uri.parse(
//         'wss://simple-chat-server-9vzn.onrender.com/ws/$mobile',
//       ),
//     );
//     // print('wss://simple-chat-server-9vzn.onrender.com/ws/${mobile} blal');
//
//     channel.stream.listen(
//       _handleData,
//       onDone: _handleDisconnect,
//       onError: (_) => _handleDisconnect(),
//     );
//   }
//   void _handleData(dynamic data) {
//     print('🔌🔌🔌 RAW SOCKET DATA RECEIVED: $data');
//     print('🔌 Data type: ${data.runtimeType}');
//
//     try {
//       final json = jsonDecode(data);
//       print('📋 PARSED JSON TYPE: ${json["type"]}');
//       print('📋 FULL JSON: $json');
//
//       if (!_isConnected) {
//         _isConnected = true;
//         _isConnecting = false;
//         _startPing();
//         requestOnlineUsers();
//         print('✅ Socket connected successfully');
//       }
//
//       if (json["type"] == "online_users") {
//         final users = List<String>.from(json["users"]);
//         users.remove(mobile);
//         print('👥 Online users list: $users');
//         _controller.add(ChatEvent.onlineUsers(users));
//         print('✅ Added online_users event to controller');
//       }
//       else if (json["type"] == "message") {
//         print('📨📨📨 MESSAGE RECEIVED FROM SERVER!');
//         print('📨 From: ${json["from"]}');
//         print('📨 Text: ${json["text"]}');
//         print('📨 To (if present): ${json["to"]}');
//
//         // CRITICAL: Check if from field exists
//         if (json["from"] == null) {
//           print('❌ ERROR: "from" field is null in message');
//           return;
//         }
//
//         if (json["text"] == null) {
//           print('❌ ERROR: "text" field is null in message');
//           return;
//         }
//
//         // Create and add the ChatEvent
//         final chatEvent = ChatEvent.message(
//             json["from"].toString(),
//             json["text"].toString()
//         );
//
//         print('✅ Creating ChatEvent: type=${chatEvent.type}, from=${chatEvent.from}, text=${chatEvent.text}');
//
//         // Add to controller stream
//         _controller.add(chatEvent);
//         print('✅✅✅ MESSAGE ADDED TO CONTROLLER STREAM!');
//       }
//       else {
//         print('ℹ️ Other event type: ${json["type"]}');
//       }
//     } catch (e) {
//       print('❌❌❌ Error parsing socket data: $e');
//       print('Stack trace: ${e.toString()}');
//     }
//   }
//   // void _handleData(dynamic data) {
//   //   final json = jsonDecode(data);
//   //
//   //   // 🔥 Detect first successful connect OR reconnect
//   //   if (!_isConnected) {
//   //     _isConnected = true;
//   //     _isConnecting = false;
//   //     _startPing();
//   //
//   //     // ✅ REQUEST ONLINE USERS ON CONNECT
//   //     requestOnlineUsers();
//   //   }
//   //
//   //   if (json["type"] == "online_users") {
//   //     final users = List<String>.from(json["users"]);
//   //     users.remove(mobile);
//   //     _controller.add(ChatEvent.onlineUsers(users));
//   //   }
//   //
//   //   if (json["type"] == "message") {
//   //     _controller.add(
//   //       ChatEvent.message(json["from"], json["text"]),
//   //     );
//   //   }
//   // }
//
//   void _handleDisconnect() {
//     _isConnected = false;
//     _isConnecting = false;
//     _stopPing();
//     _scheduleReconnect();
//   }
//
//   void _scheduleReconnect() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(
//       const Duration(seconds: 10),
//       connect,
//     );
//   }
//
//   void _startPing() {
//     _pingTimer?.cancel();
//     _pingTimer = Timer.periodic(
//       const Duration(seconds: 25),
//           (_) {
//         if (_isConnected) {
//           channel.sink.add(jsonEncode({"type": "ping"}));
//         }
//       },
//     );
//   }
//
//   void _stopPing() {
//     _pingTimer?.cancel();
//     _pingTimer = null;
//   }
//
//   // Add this method to request online users
//   void requestOnlineUsers() {
//     if (!_isConnected) {
//       print("Cannot request online users: not connected");
//       return;
//     }
//
//     try {
//       channel.sink.add(jsonEncode({"type": "get_online_users"}));
//       print("Requested online users from server");
//     } catch (e) {
//       print("Error requesting online users: $e");
//     }
//   }
//
//   void sendMessage(String to, String text) {
//     if (!_isConnected) return;
//
//     channel.sink.add(jsonEncode({
//       "type": "message",
//       "to": to,
//       "text": text,
//     }));
//   }
//
//   void disconnect() {
//     _reconnectTimer?.cancel();
//     _stopPing();
//     _isConnected = false;
//     _isConnecting = false;
//     channel.sink.close();
//   }
// }