import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_bucarest/screens/theme_provider.dart';
import 'package:provider/provider.dart';

class GroupMessagesStream extends StatelessWidget {
  final String groupId;
  final String currentUserEmail;

  const GroupMessagesStream({
    super.key,
    required this.groupId,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('group_message')
          .doc(groupId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;
        List<GroupMessageBubble> messageBubbles = [];

        for (var message in messages) {
          final sender = message['sender'];
          final text = message['text'];

          final groupMessageBubble = GroupMessageBubble(
            sender: sender,
            text: text,
            currentUserEmail: currentUserEmail,
          );

          messageBubbles.add(groupMessageBubble);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: messageBubbles,
        );
      },
    );
  }
}

class GroupMessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String currentUserEmail;

  const GroupMessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = sender == currentUserEmail; // Check if the sender is the current user
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) // Display sender information only if it's not the current user
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').where('email', isEqualTo: sender).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container();
                } else {
                  final userData = snapshot.data!.docs[0].data();
                  final firstName = userData['firstName'] ?? '';

                  return Text(
                    firstName,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black54,
                    ),
                  );
                }
              },
            ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isCurrentUser ? 30.0 : 0.0),
              topRight: Radius.circular(isCurrentUser ? 0.0 : 30.0),
              bottomLeft: const Radius.circular(30.0),
              bottomRight: const Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isCurrentUser ? Colors.blueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
