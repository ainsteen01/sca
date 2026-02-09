import 'dart:async';
import 'package:flutter/material.dart';
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

  List<String> onlineUsers = [];


  Future<void> loadShareData() async {
    final mobile = await SharedData().getSharedNumber();
   // print(mobile);
    setState(() {
      mobNum = mobile.toString();
    });
    socket = ChatSocketService(mobNum);
    socket.connect();

    sub = socket.events.listen((event) {
      if (event.type == "online_users") {
        setState(() {
          onlineUsers = event.users ?? [];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
          title: const Text("Online Users")),
      body:
      onlineUsers.isNotEmpty?
      ListView.builder(
        itemCount: onlineUsers.length,
        itemBuilder: (_, index) {
          final user = onlineUsers[index];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadiusGeometry.circular(10),
              color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, spreadRadius:3, blurRadius: 2, offset: Offset(1, 0))
                ]
              ),
              child: ListTile(
                trailing: Icon(Icons.do_not_disturb_on_total_silence_rounded, color: Colors.green,),
                leading: CircleAvatar(child: Text(user[0])),
                title: Text(user),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Chats(
                        mobNum: user,
                        socket: socket,
                      ),
                    ),
                  ).then((onValue){
                    onValue == "recheck"?
                        loadShareData():"";
                  });
                },
              ),
            ),
          );
        },
      ):
      Center(child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.emoji_emotions_outlined, size: 100,color: Colors.grey,),
             const  Text(textAlign: TextAlign.center,"Oops no one is online \nplease try after some time")

            ],
          )
        ,)
      ,
    );
  }
}
