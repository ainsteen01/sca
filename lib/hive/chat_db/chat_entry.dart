import 'package:hive/hive.dart';
part 'chat_entry.g.dart';
@HiveType(typeId: 2)
class ChatEntry extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isMe;

  @HiveField(2)
  DateTime timestamp;

  ChatEntry({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}
