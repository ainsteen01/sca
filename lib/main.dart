import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sca/hive/chat_db/chat_entry.dart';
import 'package:sca/hive/chat_db/user_vice_data.dart';
import 'package:sca/hive/user_list_db/user_list_db.dart';
import 'package:sca/shared_data.dart';
import 'chat_screen.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserListDbAdapter());
  Hive.registerAdapter(UserViceDataAdapter());
  Hive.registerAdapter(ChatEntryAdapter());
  await Hive.openBox<UserListDb>("LIST_USERS");
  await Hive.openBox<UserViceData>("USER_VICE_DATA");
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _loadShareData() async {
    final mobile = await SharedData().getSharedNumber();
    var mobNum = mobile?.toString() ?? "";
    return mobNum.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder<bool>(
        future: _loadShareData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return ChatScreen();
          }

          return LoginPage();
        },
      ),
    );
  }
}


