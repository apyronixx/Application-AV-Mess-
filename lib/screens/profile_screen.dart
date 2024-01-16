import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_bucarest/screens/profile_model.dart';
import 'package:project_bucarest/screens/profile_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project_bucarest/screens/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _profilePictureUrlController;
  late TextEditingController _bioController;
  late TextEditingController _statusController;
  late ImagePicker _picker;

  late List<StatusOption> statusOptions;
  StatusOption? selectedStatus;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _profilePictureUrlController = TextEditingController();
    _bioController = TextEditingController();
    _statusController = TextEditingController();
    _picker = ImagePicker();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    statusOptions = [
      StatusOption(AppLocalizations.of(context)!.online, Colors.green),
      StatusOption(AppLocalizations.of(context)!.offline, Colors.white),
      StatusOption(AppLocalizations.of(context)!.busy, Colors.brown),
      StatusOption(AppLocalizations.of(context)!.doNotDisturb, Colors.red),
      StatusOption(AppLocalizations.of(context)!.onHoliday, Colors.blue),
    ];

    // Fetch and display user profile data
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userProfile =
      UserProfile.fromMap(userData.data() as Map<String, dynamic>);

      setState(() {
        _firstNameController.text = userProfile.firstName;
        _lastNameController.text = userProfile.lastName;
        _profilePictureUrlController.text = userProfile.profilePictureUrl ?? '';
        _bioController.text = userProfile.bio ?? '';
        _statusController.text = userProfile.status ?? '';
        selectedStatus = statusOptions
            .firstWhere((option) => option.name == userProfile.status,
            orElse: () => statusOptions.first);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Text((AppLocalizations.of(context)!.chooseStatus)),
              DropdownButton<StatusOption>(
                value: selectedStatus,
                items: statusOptions.map((StatusOption option) {
                  return DropdownMenuItem<StatusOption>(
                    value: option,
                    child: Row(
                      children: <Widget>[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: option.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(option.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (StatusOption? value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
              Text((AppLocalizations.of(context)!.firstName)),
              TextField(
                controller: _firstNameController,
              ),
              const SizedBox(height: 20.0),
              Text((AppLocalizations.of(context)!.lastname)),
              TextField(
                controller: _lastNameController,
              ),
              const SizedBox(height: 20.0),
              Text((AppLocalizations.of(context)!.profilePicture)),
              ProfilePictureWidget(
                imageUrl: _profilePictureUrlController.text,
                onPickImage: _pickImage,
              ),
              const SizedBox(height: 20.0),
              const Text('Bio:'),
              TextField(
                controller: _bioController,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _updateProfile();
                },
                child: Text((AppLocalizations.of(context)!.updateProfile)),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text((AppLocalizations.of(context)!.deleteAccount)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProfile() async {
    final newProfile = UserProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      profilePictureUrl: _profilePictureUrlController.text,
      bio: _bioController.text,
      status: selectedStatus?.name,
    );

    await ProfileManager.updateProfile(newProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Updated Successfully'),
      ),
    );
  }

  Future<void> _pickImage() async {
    TextEditingController urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Image URL"),
          content: TextField(
            controller: urlController,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(urlController.text);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((url) {
      if (url != null && url.isNotEmpty) {
        setState(() {
          _profilePictureUrlController.text = url;
        });
      }
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() async {
    try {
      await ProfileManager.deleteProfile();
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
      );
    } catch (e) {
      print('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting account. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _profilePictureUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

class StatusOption {
  final String name;
  final Color color;

  StatusOption(this.name, this.color);
}

class ProfilePictureWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onPickImage;

  const ProfilePictureWidget({
    super.key,
    required this.imageUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl.isNotEmpty)
          CircleAvatar(
            backgroundImage: imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : FileImage(File(imageUrl)) as ImageProvider<Object>,
            radius: 40.0,
          ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: onPickImage,
          child: const Text('Pick Image'),
        ),
      ],
    );
  }
}
