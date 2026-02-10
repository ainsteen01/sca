// // In your chatmodel.dart file
// class ChatEvent {
//   final String type;
//   final List<String>? users;
//   final String? from;
//   final String? text;
//   final String? userId;
//
//   ChatEvent({
//     required this.type,
//     this.users,
//     this.from,
//     this.text,
//     this.userId,
//   });
//
//   // Factory constructors for different event types
//   factory ChatEvent.onlineUsers(List<String> users) {
//     return ChatEvent(type: "online_users", users: users);
//   }
//
//   factory ChatEvent.message(String from, String text) {
//     return ChatEvent(type: "message", from: from, text: text);
//   }
// }
// In your chatmodel.dart file
class ChatEvent {
  final String type;
  final List<String>? users;
  final String? from;
  final String? text;
  final String? userId;

  ChatEvent({
    required this.type,
    this.users,
    this.from,
    this.text,
    this.userId,
  });

  // Factory constructors for different event types
  factory ChatEvent.onlineUsers(List<String> users) {
    return ChatEvent(type: "online_users", users: users);
  }

  factory ChatEvent.message(String from, String text) {
    return ChatEvent(type: "message", from: from, text: text);
  }

  // ADD THIS - Factory constructor from JSON
  factory ChatEvent.fromJson(Map<String, dynamic> json) {
    return ChatEvent(
      type: json['type'] ?? '',
      users: json['users'] != null ? List<String>.from(json['users']) : null,
      from: json['from'],
      text: json['text'],
      userId: json['userId'],
    );
  }

  // Optional: Helper method to convert to Map
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'users': users,
      'from': from,
      'text': text,
      'userId': userId,
    };
  }
}