import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:project_bucarest/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_bucarest/screens/theme_provider.dart';
import 'package:project_bucarest/screens/groups_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ContactsScreen extends StatefulWidget {
  static String id = "contacts_screen";

  const ContactsScreen({super.key});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;

  static const Map<String, Color> statusColors = {
    'Online': Colors.green,
    'Offline': Colors.white,
    'Busy': Colors.brown,
    'Do Not Disturb': Colors.red,
    'On Holiday': Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Create a local variable to hold the reference to _auth
    final FirebaseAuth auth = _auth;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: TextStyle(
            fontSize: 20,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _currentIndex == 0
                  ? StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    final users = snapshot.data?.docs;
                    List<UserTile> userTiles = [];

                    for (var i = 0; i < users!.length; i++) {
                      final userData = users[i].data();
                      final userEmail = userData['email'];

                      if (userEmail?.toLowerCase() == auth.currentUser?.email?.toLowerCase()) {
                        continue;
                      }

                      userTiles.add(
                        UserTile(
                          userData: userData,
                          isEven: i % 2 == 0,
                          auth: auth,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: userTiles.length,
                      itemBuilder: (context, index) {
                        return userTiles[index];
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          thickness: 1,
                          color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        );
                      },
                    );
                  }
                },
              )
                  : const GroupsScreen(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool isEven;
  final FirebaseAuth auth;

  const UserTile({
    super.key,
    required this.userData,
    required this.isEven,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final String userEmail = userData['email'] ?? '';
    final String firstName = userData['firstName'] ?? '';
    final String lastName = userData['lastName'] ?? '';
    final String profilePictureUrl = userData['profilePictureUrl'] ?? '';
    final String status = userData['status'] ?? 'Offline';

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('participants', whereIn: [
        [auth.currentUser?.email, userEmail],
        [userEmail, auth.currentUser?.email],
      ])
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return buildUserTile(
            themeProvider,
            userEmail,
            firstName,
            lastName,
            profilePictureUrl,
            '',
            '',
            '',
            false, // Indicate that there is no last message
            getStatusColor(status),
            context,
          );
        }

        final messages = snapshot.data!.docs;
        final lastMessage = messages.isNotEmpty ? messages[0]['text'] : '';
        final timestamp = messages.isNotEmpty ? messages[0]['timestamp'] : null;
        final timeAgo = timestamp != null ? timeago.format(timestamp.toDate()) : '';
        final date = timestamp != null ? DateFormat.yMd().format(timestamp.toDate()) : '';

        String displayMessage = lastMessage.length > 25 ? '${lastMessage.substring(0, 25)}...' : lastMessage;

        return buildUserTile(
          themeProvider,
          userEmail,
          firstName,
          lastName,
          profilePictureUrl,
          displayMessage,
          timeAgo,
          date,
          true, // Indicate that there is a last message
          getStatusColor(status),
          context,
        );
      },
    );
  }

  Widget buildUserTile(
      ThemeProvider themeProvider,
      String userEmail,
      String firstName,
      String lastName,
      String profilePictureUrl,
      String displayMessage,
      String timeAgo,
      String date,
      bool hasLastMessage,
      Color statusColor,
      BuildContext context,
      ) {
    return ListTile(
      leading: buildUserLeading(profilePictureUrl),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (firstName.isNotEmpty || lastName.isNotEmpty)
                ? '$firstName $lastName'
                : userEmail,
            style: TextStyle(
              fontSize: 18,
              color: isEven
                  ? themeProvider.isDarkMode
                  ? Colors.white
                  : Colors.black
                  : themeProvider.isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasLastMessage ? displayMessage : '',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      trailing: Column(
        children: [
          Text(
            hasLastMessage ? timeAgo : '',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              buildStatusIndicator(statusColor),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              recipientEmail: userEmail,
            ),
          ),
        );
      },
    );
  }


  Color getStatusColor(String status) {
    return _ContactsScreenState.statusColors[status] ?? Colors.grey;
  }

  Widget buildUserLeading(String profilePictureUrl) {
    if (profilePictureUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(profilePictureUrl),
      );
    } else {
      return const CircleAvatar(
        child: Icon(Icons.person),
      );
    }
  }

  Widget buildStatusIndicator(Color statusColor) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: statusColor,
      ),
    );
  }
}
