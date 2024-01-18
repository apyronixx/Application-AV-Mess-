import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserDetailsScreen extends StatelessWidget {
  final String userEmail;

  const UserDetailsScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.docs[0].data() as Map<String, dynamic>;
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          final bio = userData['bio'] ?? '';
          final profilePictureUrl = userData['profilePictureUrl'] ?? '';
          final status = userData['status'] ?? 'Offline';
          final email = userData['email'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (profilePictureUrl.isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(profilePictureUrl),
                    radius: 60.0,
                  ),
                const SizedBox(height: 16.0),
                Text(
                  '$firstName $lastName',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Status: $status',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Email: $email',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Bio:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                SingleChildScrollView(
                  child: Text(
                    bio,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
