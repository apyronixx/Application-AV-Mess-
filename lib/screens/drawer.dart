// drawer.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magnifying_glass/magnifying_glass.dart';
import 'package:project_bucarest/screens/welcome_screen.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'profile_screen.dart'; // Import the profile screen
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  final MagnifyingGlassController magnifyingGlassController;
  final bool isMagnifyingGlassActive;
  final Function toggleMagnifyingGlass;

  AppDrawer({super.key,
    required this.magnifyingGlassController,
    required this.isMagnifyingGlassActive,
    required this.toggleMagnifyingGlass,
  });

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String imageUrl = userData['profilePictureUrl'] ?? '';
          String firstName = userData['firstName'] ?? '';
          String lastName = userData['lastName'] ?? '';

          return Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Text(
                    '$firstName $lastName',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                accountEmail: null,
                currentAccountPicture: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 80.0,
                      child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                          ? ClipOval(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 160.0,
                          height: 160.0,
                        ),
                      )
                          : Icon(
                        Icons.person,
                        size: 80.0,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.black
                      : ColorConstants.kPrimaryColor,
                ),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.zoom_in),
                    SizedBox(width: 8),
                    Text('Magnifying glass'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.toggleMagnifyingGlass();
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16), // Added space for separation
              Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.yellow), // Moon icon
                  const SizedBox(width: 8),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleDarkMode();
                    },
                    activeColor: ColorConstants.kPrimaryColor,
                    activeTrackColor: ColorConstants.kPrimaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.dark_mode, color: themeProvider.isDarkMode ? Colors.white : Colors.black), // Sun icon
                ],
              ),
              const Spacer(),
              const LogoutButton(),
            ],
          );
        },
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Row(
        children: [
          Icon(Icons.logout),
          SizedBox(width: 8),
          Text('Logout'),
        ],
      ),
      onTap: () {
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
    );
  }
}
