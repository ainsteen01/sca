

import 'package:hive/hive.dart';

import 'chat_entry.dart';
part 'user_vice_data.g.dart';
@HiveType(typeId: 1)
class UserViceData extends HiveObject {
  @HiveField(0)
  List<ChatEntry> messages;

  @HiveField(1)
  String uniqueIdentificationNumber;

  UserViceData({
    required this.messages,
    required this.uniqueIdentificationNumber,
  });
}
