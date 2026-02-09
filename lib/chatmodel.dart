class ChatEvent {
  final String type; // online_users | message
  final String? from;
  final String? text;
  final List<String>? users;

  const ChatEvent.onlineUsers(this.users)
      : type = "online_users",
        from = null,
        text = null;

  const ChatEvent.message(this.from, this.text)
      : type = "message",
        users = null;
}