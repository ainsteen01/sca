
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'user_list_db.g.dart';
@HiveType(typeId: 0)
class UserListDb extends HiveObject{


  @HiveField(0)
  final List<String> usersList;

  UserListDb({required this.usersList});
}