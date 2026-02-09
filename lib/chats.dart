import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sca/service/chat_socket_service.dart';

class ChatMessage {
  final String text;
  final bool isMe;

  ChatMessage({required this.text, required this.isMe});
}

class Chats extends StatefulWidget {
  final String mobNum;
  final ChatSocketService socket;


  const Chats({
    super.key,
    required this.mobNum,
    required this.socket,
  });

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> messages = [];
  late StreamSubscription sub;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    sub = widget.socket.events.listen((event) {
      // Then schedule the scroll after the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
      if (event.type == "message" && event.from == widget.mobNum) {
        // Update the state first
        setState(() {
          messages.add(
            ChatMessage(text: event.text!, isMe: false),
          );
        });


      }
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
    controller.dispose();
    _scrollController.dispose();
  }
  void scrollToBottom() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(maxScroll);
  }


  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    widget.socket.sendMessage(widget.mobNum, text);
    setState(() {
      messages.add(
        ChatMessage(text: text, isMe: true),
      );
    });
    controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  void scrollToBottomIfNeeded() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 100) {
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{

        Navigator.pop(context, "recheck");
        return true; },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 1,
            backgroundColor: Colors.white,
            title: Text(widget.mobNum)),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
      controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (_, index) {
      
                  final msg = messages[index];
                  return Align(
                    alignment: msg.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: msg.isMe
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(msg.text),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TextField(
                        showCursor: true,
                        controller: controller,
                        decoration:  InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: "Type message...",
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
