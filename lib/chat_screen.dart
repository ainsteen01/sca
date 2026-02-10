import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sca/hive/user_list_db/user_list_db.dart';
import 'package:sca/service/chat_socket_service.dart';
import 'package:sca/shared_data.dart';
import 'chats.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatSocketService socket;
  late StreamSubscription sub;
  String mobNum = "";
  final userListBox = Hive.box<UserListDb>("LIST_USERS");
  List<String> onlineUsers = [];
  Set<String> onlineSet = {};
  bool _isLoading = true;

  void _updateOnlineUsers(List<String> incomingUsers) {
    if (!mounted) return;

    // 1️⃣ Remove logged-in user
    final filteredIncoming = incomingUsers
        .where((user) => user != mobNum)
        .toList();

    // 2️⃣ Load stored users
    final storedUsers = userListBox.get("all_users")?.usersList ?? [];

    // 3️⃣ Merge & remove duplicates, keeping stored users order
    final mergedUsers = <String>[];
    final allUniqueUsers = <String>{};

    // Add stored users first to maintain order
    for (var user in storedUsers) {
      if (!allUniqueUsers.contains(user)) {
        allUniqueUsers.add(user);
        mergedUsers.add(user);
      }
    }

    // Add new incoming users that aren't already in the list
    for (var user in filteredIncoming) {
      if (!allUniqueUsers.contains(user)) {
        allUniqueUsers.add(user);
        mergedUsers.add(user);
      }
    }

    // 4️⃣ Save to Hive
    userListBox.put(
      "all_users",
      UserListDb(usersList: mergedUsers),
    );

    // 5️⃣ Update state
    setState(() {
      onlineSet = filteredIncoming.toSet();
      onlineUsers = mergedUsers;
      _isLoading = false;
    });
  }

  void _setupSocketListeners() {
    sub = socket.events.listen((event) {
      if (event.type == "online_users") {
        final incomingUsers = event.users ?? [];
        print("Online users updated: $incomingUsers");
        _updateOnlineUsers(incomingUsers);
      }

      // Add listener for user connection/disconnection events
      else if (event.type == "user_connected" || event.type == "user_disconnected") {
        // Request updated online users list from server
        socket.requestOnlineUsers();
      }
    });

    // Request initial online users
    socket.requestOnlineUsers();

    // Set up periodic refresh (optional)
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        socket.requestOnlineUsers();
      }
    });
  }

  Future<void> _loadShareData() async {
    try {
      final mobile = await SharedData().getSharedNumber();
      mobNum = mobile?.toString() ?? "";

      socket = ChatSocketService(mobNum);
      socket.connect();

      _setupSocketListeners();

      // Load cached users immediately
      final cachedUsers = userListBox.get("all_users")?.usersList ?? [];
      if (mounted) {
        setState(() {
          onlineUsers = cachedUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadShareData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This helps refresh when coming back from Chat screen
  }

  @override
  void dispose() {
    sub.cancel();
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text("Online Users"),
        // Add refresh button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              socket.requestOnlineUsers();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : onlineUsers.isNotEmpty
          ? RefreshIndicator(
        // Pull-to-refresh
        onRefresh: () async {
          socket.requestOnlineUsers();
        },
        child: ListView.builder(
          itemCount: onlineUsers.length,
          itemBuilder: (_, index) {
            final user = onlineUsers[index];
            final isOnline = onlineSet.contains(user);

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 3,
                      blurRadius: 2,
                      offset: Offset(1, 0),
                    )
                  ],
                ),
                child: ListTile(
                  trailing: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  leading: CircleAvatar(
                    child: Text(
                      user.isNotEmpty ? user[0] : "?",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user,
                    style: TextStyle(
                      fontWeight:
                      isOnline ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  onTap: () {
                    isOnline ?
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Chats(
                          mobNum: user,
                          socket: socket,
                        ),
                      ),
                    ).then((_) {
                      // Refresh when returning from chat screen
                      if (mounted) {
                        socket.requestOnlineUsers();
                      }
                    }):
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Oops user is not online")))
                    ;
                  },
                ),
              ),
            );
          },
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_emotions_outlined,
              size: 100,
              color: Colors.grey,
            ),
            const Text(
              textAlign: TextAlign.center,
              "Oops no one is online \nplease try after some time",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                socket.requestOnlineUsers();
              },
              child: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }
}