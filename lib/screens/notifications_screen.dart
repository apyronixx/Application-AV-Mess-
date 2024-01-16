import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_bucarest/screens/chat_screen.dart';
import 'package:provider/provider.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: const UnreadMessagesList(),
    );
  }
}

class UnreadMessagesList extends StatelessWidget {
  const UnreadMessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = Provider.of<FirebaseAuth>(context, listen: false);
    //final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('unreadMessages')
          .doc(auth.currentUser!.email)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var messages = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            var sender = message['sender'];
            var text = message['text'];
            var timestamp = message['timestamp'].toDate(); // Convert to DateTime
            var formattedTimestamp = DateFormat('EEEE, HH:mm').format(timestamp);

            return ListTile(
              onTap: () async {
                try {
                  // Delete the notification
                  await _deleteNotification(message.id);

                  // Navigate to the chat screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        recipientEmail: sender,
                      ),
                    ),
                  );
                } catch (e) {
                  if (kDebugMode) {
                    print('Error navigating to ChatScreen: $e');
                  }
                }
              },
              title: Text('New Message from $sender'),
              subtitle: Text('$text\n $formattedTimestamp'),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteNotification(String messageId) async {
    await FirebaseFirestore.instance
        .collection('unreadMessages')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

}
