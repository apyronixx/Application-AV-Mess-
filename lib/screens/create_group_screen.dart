import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_bucarest/screens/chat_screen.dart';
import 'package:project_bucarest/screens/groups_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _auth = FirebaseAuth.instance;
  final _selectedUsers = <String>{};
  final _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Group'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                hintText: 'Enter group name',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  final users = snapshot.data?.docs;
                  return ListView.builder(
                    itemCount: users!.length,
                    itemBuilder: (context, index) {
                      final userData = users[index].data();
                      final userEmail = userData['email'];
                      final isSelected = _selectedUsers.contains(userEmail);

                      return ListTile(
                        title: Text(userEmail),
                        trailing: isSelected
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_box_outline_blank),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedUsers.remove(userEmail);
                            } else {
                              _selectedUsers.add(userEmail);
                            }
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createGroupAndNavigate();
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }

  void createGroupAndNavigate() async {
    if (_selectedUsers.isNotEmpty) {
      final groupName = _groupNameController.text.trim();
      final currentUserEmail = _auth.currentUser?.email;

      if (groupName.isNotEmpty && currentUserEmail != null) {
        // Check if the group name already exists
        final existingGroups = await FirebaseFirestore.instance
            .collection('groups')
            .where('name', isEqualTo: groupName)
            .get();

        if (existingGroups.docs.isNotEmpty) {
          // Show a message indicating that the group already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This group already exists.'),
            ),
          );
          return; // Stop execution if the group already exists
        }

        // Include the current user in the group members
        _selectedUsers.add(currentUserEmail);

        // Create a document in 'groups' collection
        final groupDoc = await FirebaseFirestore.instance.collection('groups').add({
          'name': groupName,
          'members': _selectedUsers.toList(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Link the group to the 'group_message' collection
        final groupId = groupDoc.id;
        await FirebaseFirestore.instance.collection('group_message').doc(groupId).set({
          'name': groupName,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GroupsScreen(),
          ),
        );
      }
    }
  }
}
