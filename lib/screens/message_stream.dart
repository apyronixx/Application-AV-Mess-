import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';

class MessagesStream extends StatelessWidget {
  final String recipientEmail;
  final String currentUserEmail;

  const MessagesStream({
    super.key,
    required this.recipientEmail,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];

        for (var message in messages) {
          final participants = List<String>.from(message['participants']);

          if (participants.contains(currentUserEmail) &&
              participants.contains(recipientEmail)) {
            final messageText = message['text'];
            final messageSender = message['sender'];

            final currentUser = currentUserEmail;

            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              isMe: currentUser == messageSender,
              themeProvider: themeProvider,
            );

            messageBubbles.add(messageBubble);
          }
        }

        return ListView(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: messageBubbles,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final ThemeProvider themeProvider;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users')
                .where('email', isEqualTo: sender).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else {
                final userData = snapshot.data?.docs[0].data() as Map<String, dynamic>;
                final firstName = userData['firstName'] ?? '';

                return Text(
                  firstName,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: isMe ? Colors.white : (themeProvider.isDarkMode ? Colors.white : Colors.black),
                  ),
                );
              }
            },
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : const BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMe ? Colors.blueAccent :  Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
