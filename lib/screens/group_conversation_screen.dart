// group_conversation_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_bucarest/screens/GroupMessagesStream.dart';
import 'package:project_bucarest/screens/GroupParticipantsScreen.dart'; // Import the new screen

class GroupConversationScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupConversationScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  _GroupConversationScreenState createState() => _GroupConversationScreenState();
}

class _GroupConversationScreenState extends State<GroupConversationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  late String groupId;  // Declare groupId as a non-nullable variable

  @override
  void initState() {
    super.initState();
    groupId = widget.groupId;

    // Check if there are existing messages with the groupId
    checkExistingMessages();
  }

  void checkExistingMessages() async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('group_message')
        .doc(groupId)
        .collection('messages')
        .get();

    if (messagesSnapshot.docs.isEmpty) {
      // No existing messages, open the conversation
      openConversation();
    }
  }

  void openConversation() async {

    await FirebaseFirestore.instance
        .collection('group_message')
        .doc(groupId)
        .collection('messages')
        .add({
      'sender': 'System',  // You can use a system user or any identifier
      'text': 'Welcome to the group conversation!',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate to the GroupParticipantsScreen when the title is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupParticipantsScreen(groupId: widget.groupId),
              ),
            );
          },
          child: Text(widget.groupName),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: GroupMessagesStream(
              groupId: widget.groupId,
              currentUserEmail: _auth.currentUser?.email ?? '',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    final currentUserEmail = _auth.currentUser?.email;
    final messageText = _messageController.text.trim();

    if (currentUserEmail != null && messageText.isNotEmpty) {
      final groupMessageRef = FirebaseFirestore.instance
          .collection('group_message')
          .doc(widget.groupId)
          .collection('messages')
          .doc();

      await groupMessageRef.set({
        'sender': currentUserEmail,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }
}
