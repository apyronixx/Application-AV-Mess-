import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupParticipantsScreen extends StatefulWidget {
  final String groupId;

  const GroupParticipantsScreen({super.key, required this.groupId});

  @override
  _GroupParticipantsScreenState createState() => _GroupParticipantsScreenState();
}

class _GroupParticipantsScreenState extends State<GroupParticipantsScreen> {
  late List<Map<String, String>> participants = [];

  @override
  void initState() {
    super.initState();
    fetchGroupData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Participants'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Group Name: ${widget.groupId}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: participants.isEmpty
                ? const Center(child: Text('No participants found'))
                : ListView.builder(
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                return ListTile(
                  title: Text('${participant['firstName']} ${participant['lastName']}'),
                  subtitle: Text(participant['email'] ?? 'No email available'),                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchGroupData() async {
    try {
      final groupsCollection = FirebaseFirestore.instance.collection('groups');
      final querySnapshot = await groupsCollection.where('name', isEqualTo: widget.groupId).get();

      if (querySnapshot.docs.isNotEmpty) {
        final groupId = querySnapshot.docs.first.id;
        final groupSnapshot = await groupsCollection.doc(groupId).get();

        if (kDebugMode) {
          print('Group Snapshot: $groupSnapshot');
        }

        if (groupSnapshot.exists) {
          final members = List<String>.from(groupSnapshot['members'] ?? []);
          await fetchParticipantsDetails(members);
        } else {
          if (kDebugMode) {
            print('Group does not exist');
          }
        }
      } else {
        if (kDebugMode) {
          print('Group not found by name: ${widget.groupId}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching group data: $error');
      }
    }
  }

  Future<void> fetchParticipantsDetails(List<String> emails) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final participantsDetails = <Map<String, String>>[];

    for (final email in emails) {
      final userQuerySnapshot = await usersCollection.where('email', isEqualTo: email).get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        final userData = userQuerySnapshot.docs.first.data();
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';

        participantsDetails.add({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
        });
      }
    }

    setState(() {
      participants = participantsDetails;
    });
  }
}
