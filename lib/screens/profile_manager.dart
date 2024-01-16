import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_bucarest/screens/profile_model.dart';

class ProfileManager {
  static Future<void> updateProfile(UserProfile newProfile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstName': newProfile.firstName,
        'lastName': newProfile.lastName,
        'profilePictureUrl': newProfile.profilePictureUrl,
        'bio': newProfile.bio,
        'status': newProfile.status, // Update status
      });
    }
  }


static Future<void> deleteProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Delete user profile data
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    }
  }
}
