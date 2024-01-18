import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:project_bucarest/screens/theme_provider.dart';
import 'package:project_bucarest/screens/create_group_screen.dart';

import 'group_conversation_screen.dart';

class GroupsScreen extends StatefulWidget {
  static String id = "groups_screen";

  const GroupsScreen({super.key});

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Create a local variable to hold the reference to _auth
    final FirebaseAuth auth = _auth;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Groups',
          style: TextStyle(
            fontSize: 20,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('groups').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final groups = snapshot.data?.docs;
              List<GroupTile> groupTiles = [];

              for (var i = 0; i < groups!.length; i++) {
                final groupData = groups[i].data();
                final members = groupData['members'] as List?;

                if (members != null &&
                    members.contains(auth.currentUser?.email)) {
                  groupTiles.add(
                    GroupTile(
                      groupData: groupData,
                      auth: auth,
                      onTap: () {
                        navigateToGroupConversationScreen(
                          context,
                          groupData['name'],
                        );
                      },
                    ),
                  );
                }
              }

              return ListView.separated(
                itemCount: groupTiles.length,
                itemBuilder: (context, index) {
                  return groupTiles[index];
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 1,
                    color: themeProvider.isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[300],
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void navigateToGroupConversationScreen(BuildContext context, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupConversationScreen(
          groupName: groupName,
          groupId: groupName,
        ),
      ),
    );
  }
}

class GroupTile extends StatelessWidget {
  final Map<String, dynamic> groupData;
  final FirebaseAuth auth;
  final VoidCallback? onTap;

  const GroupTile({
    super.key,
    required this.groupData,
    required this.auth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final String groupName = groupData['name'] ?? '';

    return ListTile(
      title: Text(
        groupName,
        style: TextStyle(
          fontSize: 18,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
