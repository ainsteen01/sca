import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sca/hive/chat_db/user_vice_data.dart';
import 'package:sca/service/chat_socket_service.dart';

import 'chatmodel.dart';
import 'hive/chat_db/chat_entry.dart';

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
  late Box<UserViceData> _userChatBox;

  // FIX: Use consistent box name
  final String _chatBoxName = "USER_VICE_DATA";


  @override
  void initState() {
    super.initState();

    // Initialize Hive box
    _initHiveBox();

    // Load chat history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatHistory();
    });

    // Listen to socket events
    _setupSocketListener();
  }

  void _initHiveBox() {
    _userChatBox = Hive.box<UserViceData>(_chatBoxName);
  }

  void _setupSocketListener() {
    sub = widget.socket.events.listen(_onSocketEvent);
  }

  void _onSocketEvent(ChatEvent event) {
    if (event.type != "message") return;

    final text = event.text ?? "";
    final from = event.from ?? "";
    if (text.isEmpty || from.isEmpty) return;

    // Only show messages not sent by me
    final isMe = false;

    // Prevent duplicates if already sent
    final hasDuplicate = messages.any((msg) => msg.text == text && msg.isMe == true);
    if (hasDuplicate) return;

    setState(() {
      messages.add(ChatMessage(text: text, isMe: isMe));
    });

    saveChat(isMe: isMe, text: text);

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }
  // void _onSocketEvent(ChatEvent event) {
  //   print("🔥 SOCKET EVENT RECEIVED IN CHATS WIDGET");
  //   print("📨 Event type: ${event.type}");
  //   print("📨 From: ${event.from}");
  //   print("📨 Text: ${event.text}");
  //   print("📨 My number: ${widget.mobNum}");
  //
  //   // Only handle message events
  //   if (event.type != "message") {
  //     print("⏭️ Ignoring non-message event: ${event.type}");
  //     return;
  //   }
  //
  //   // Validate required fields
  //   if (event.text == null || event.text!.isEmpty) {
  //     print("❌ Message text is null or empty");
  //     return;
  //   }
  //
  //   if (event.from == null) {
  //     print("❌ Message sender is null");
  //     return;
  //   }
  //
  //   // IMPORTANT: Determine if this is a message FROM me or FROM someone else
  //   final String from = event.from!;
  //   final String me = widget.mobNum;
  //
  //   print("🔍 Checking: From='$from', Me='$me'");
  //   print("🔍 Are they equal? ${from == me}");
  //
  //   // FIX: All messages received via socket are FROM OTHERS (even server echoes)
  //   // When YOU send, you add it locally with isMe: true
  //   // When server echoes back, it should be treated as isMe: false
  //   final bool isMe = false; // ALWAYS false for socket events!
  //
  //   print("📝 This is a RECEIVED message (isMe=false)");
  //
  //   // But wait - check if we already have this message from when we sent it
  //   // This prevents duplicate messages
  //   final messageText = event.text!;
  //   final hasDuplicate = messages.any((msg) => msg.text == messageText && msg.isMe == true);
  //
  //   if (hasDuplicate) {
  //     print("⚠️ Duplicate message detected - ignoring echo");
  //     return;
  //   }
  //
  //   // Add to UI
  //   setState(() {
  //     messages.add(ChatMessage(text: event.text!, isMe: isMe));
  //     print("✅ Added RECEIVER message to UI. isMe=$isMe, Total messages: ${messages.length}");
  //   });
  //
  //   // Save to Hive
  //   saveChat(isMe: isMe, text: event.text!);
  //   print("💾 Saved to Hive");
  //
  //   // Scroll to bottom
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     scrollToBottom();
  //   });
  // }


  void saveChat({required bool isMe, required String text}) {
    final existingData = _userChatBox.get(widget.mobNum);
    final data = existingData ??
        UserViceData(messages: [], uniqueIdentificationNumber: widget.mobNum);

    data.messages.add(ChatEntry(text: text, isMe: isMe, timestamp: DateTime.now()));
    _userChatBox.put(widget.mobNum, data);
  }
  // void saveChat({required bool isMe, required String text}) {
  //   try {
  //     // FIX: Get existing data or create new
  //     final existingData = _userChatBox.get(widget.mobNum);
  //
  //     UserViceData data;
  //     if (existingData != null) {
  //       data = existingData;
  //     } else {
  //       data = UserViceData(
  //         messages: [],
  //         uniqueIdentificationNumber: widget.mobNum,
  //       );
  //     }
  //
  //     // Add new message
  //     data.messages.add(
  //       ChatEntry(
  //         text: text,
  //         isMe: isMe,
  //         timestamp: DateTime.now(),
  //       ),
  //     );
  //
  //     // Save to Hive
  //     _userChatBox.put(widget.mobNum, data);
  //     print('Chat saved: $text (isMe: $isMe)'); // Debug log
  //
  //   } catch (e) {
  //     print('Error saving chat: $e');
  //   }
  // }
  void _loadChatHistory() {
    final chat = _userChatBox.get(widget.mobNum);

    if (chat != null) {
      chat.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final loadedMessages = chat.messages
          .map((e) => ChatMessage(text: e.text, isMe: e.isMe))
          .toList();

      setState(() {
        messages.clear();
        messages.addAll(loadedMessages);
      });

      // Scroll to bottom after UI rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    }
  }

  // void _loadChatHistory() {
  //   final chat = _userChatBox.get(widget.mobNum);
  //   if (chat != null) {
  //     chat.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  //     messages.addAll(chat.messages.map((e) => ChatMessage(text: e.text, isMe: e.isMe)));
  //   }
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  // }
  // void _loadChatHistory() {
  //   try {
  //     final chat = _userChatBox.get(widget.mobNum);
  //     print('Loading chat history for ${widget.mobNum}, found: ${chat != null}'); // Debug log
  //
  //     if (chat == null) {
  //       setState(() {
  //         messages.clear();
  //       });
  //       return;
  //     }
  //
  //     // Sort messages by timestamp
  //     chat.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  //
  //     setState(() {
  //       messages.clear();
  //       messages.addAll(
  //         chat.messages.map(
  //               (e) => ChatMessage(text: e.text, isMe: e.isMe),
  //         ),
  //       );
  //     });
  //
  //     print('Loaded ${messages.length} messages from history'); // Debug log
  //
  //     // Scroll to bottom after loading
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       scrollToBottom();
  //     });
  //
  //   } catch (e) {
  //     print('Error loading chat history: $e');
  //   }
  // }

  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    widget.socket.sendMessage(widget.mobNum, text);

    setState(() => messages.add(ChatMessage(text: text, isMe: true)));
    saveChat(isMe: true, text: text);

    controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }
  // void _send() {
  //   final text = controller.text.trim();
  //   if (text.isEmpty) return;
  //
  //   print('Sending message: $text to ${widget.mobNum}'); // Debug log
  //
  //   // Send via socket
  //   widget.socket.sendMessage(widget.mobNum, text);
  //
  //   // Add to UI
  //   setState(() {
  //     messages.add(ChatMessage(text: text, isMe: true));
  //   });
  //
  //   // Save to local storage
  //   saveChat(isMe: true, text: text);
  //
  //   // Clear input
  //   controller.clear();
  //
  //   // Scroll to bottom
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     scrollToBottom();
  //   });
  // }

  void scrollToBottom() {
    if (!_scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    sub.cancel(); // unsubscribe only from this screen
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "recheck");
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(widget.mobNum),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Align(
                    alignment: msg.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isMe
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.text),
                          const SizedBox(height: 4),
                          Text(
                            msg.isMe ? 'Me' : widget.mobNum,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
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
                        controller: controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: "Type message...",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _send,
                    ),
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