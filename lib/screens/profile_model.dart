import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String firstName;
  String lastName;
  String? profilePictureUrl;
  String? bio;
  String? status;

  UserProfile({
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
    this.bio,
    this.status,
  });

  // Define a factory method to create a UserProfile from a map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      bio: map['bio'],
      status: map['status'],
    );
  }

  // Convert UserProfile to a map
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
      'status': status,
    };
  }
}
