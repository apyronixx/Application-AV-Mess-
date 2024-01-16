import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_bucarest/screens/theme_provider.dart';
import 'package:project_bucarest/screens/user_details_screen.dart';
import 'package:provider/provider.dart';
import 'message_stream.dart';
import '../constants.dart';

class ChatScreen extends StatefulWidget {
  final String recipientEmail;

  const ChatScreen({super.key, required this.recipientEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserTile(
          userEmail: widget.recipientEmail,
          onTap: () {
            // Add the code to navigate to the user details screen
            final otherUserEmail = widget.recipientEmail;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailsScreen(userEmail: otherUserEmail),
              ),
            );
          },
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Provider(
                create: (_) => FirebaseFirestore.instance
                    .collection('messages')
                    .where('participants', arrayContains: _auth.currentUser!.email),
                child: MessagesStream(
                  recipientEmail: widget.recipientEmail,
                  currentUserEmail: _auth.currentUser!.email!,
                ),
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (value) {
                        // Do nothing for now
                      },
                      decoration: kMessageTextFieldDecoration,
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
      ),
    );
  }

  void sendMessage() async {
    final text = _textController.text.trim();

    if (text.isNotEmpty) {
      // Create a new document in the 'messages' collection
      final messageDoc = await FirebaseFirestore.instance.collection('messages').add({
        'text': text,
        'sender': _auth.currentUser!.email,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [
          _auth.currentUser!.email,
          widget.recipientEmail,
        ],
      });

      // Add the message to the recipient's unreadMessages
      final recipientUnreadMessages = FirebaseFirestore.instance.collection('unreadMessages').doc(widget.recipientEmail);
      recipientUnreadMessages.collection('messages').doc(messageDoc.id).set({
        'text': text,
        'sender': _auth.currentUser!.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _textController.clear();
    }
  }
}

class UserTile extends StatelessWidget {
  final String userEmail;
  final VoidCallback onTap;

  const UserTile({
    super.key,
    required this.userEmail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            userEmail,
            style: TextStyle(
              fontSize: 18,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          );
        } else {
          final userData = snapshot.data?.docs[0].data() as Map<String, dynamic>;
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          final profilePictureUrl = userData['profilePictureUrl'] ?? '';

          return GestureDetector(
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (profilePictureUrl.isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(profilePictureUrl),
                    radius: 20.0,
                  ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$firstName $lastName',
                      style: TextStyle(
                        fontSize: 18,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
