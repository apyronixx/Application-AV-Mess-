import 'package:flutter/material.dart';
import 'package:magnifying_glass/magnifying_glass.dart';
import 'package:project_bucarest/screens/welcome_screen.dart';
import 'contacts_screen.dart';
import 'meeting_screen.dart';
import 'calendar_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MagnifyingGlassController magnifyingGlassController = MagnifyingGlassController();
  bool isMagnifyingGlassActive = false;

  void toggleMagnifyingGlass() {
    setState(() {
      isMagnifyingGlassActive = !isMagnifyingGlassActive;
    });

    if (isMagnifyingGlassActive) {
      magnifyingGlassController.openGlass();
    } else {
      magnifyingGlassController.closeGlass();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('unreadMessages')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection('messages')
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = snapshot.hasData
                  ? (snapshot.data!).docs.length
                  : 0;

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 10,
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: MagnifyingGlass(
        controller: magnifyingGlassController,
        glassPosition: GlassPosition.touchPosition,
        borderThickness: 8.0,
        borderColor: Colors.grey,
        glassParams: GlassParams(
          startingPosition: const Offset(150, 150),
          diameter: 200,
          distortion: 1.2,
          magnification: 1.7,
          padding: const EdgeInsets.all(10),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/logo.jpg',
                  height: 200,
                  width: 200,
                  semanticLabel: (AppLocalizations.of(context)!.appLogo),
                ),
                const SizedBox(height: 20),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    var userData = snapshot.data!.data() as Map<String, dynamic>;
                    String imageUrl = userData['profile_picture'] ?? '';
                    String firstName = userData['first_name'] ?? '';
                    String lastName = userData['last_name'] ?? '';

                    return ProfileHeader(
                      imageUrl: imageUrl,
                      firstName: firstName,
                      lastName: lastName,
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: ColorConstants.kPrimaryColor, backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                        minimumSize: const Size(100, 100),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.contacts,
                              size: 40, color: ColorConstants.kPrimaryColor),
                          SizedBox(height: 8.0),
                          Text(
                            'Contact',
                            style: TextStyle(
                                fontSize: 14, color: ColorConstants.kPrimaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MeetingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: ColorConstants.kPrimaryColor, backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                        minimumSize: const Size(100, 100),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.meeting_room,
                              size: 40, color: ColorConstants.kPrimaryColor),
                          const SizedBox(height: 8.0),
                          Text(
                            (AppLocalizations.of(context)!.meeting),
                            style: const TextStyle(
                                fontSize: 14, color: ColorConstants.kPrimaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalendarScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: ColorConstants.kPrimaryColor, backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                    minimumSize: const Size(220, 100),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 40, color: ColorConstants.kPrimaryColor),
                      const SizedBox(height: 8.0),
                      Text(
                        (AppLocalizations.of(context)!.calendar),
                        style: const TextStyle(
                            fontSize: 14, color: ColorConstants.kPrimaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100.0),
                const Text(
                  'Copyright Alexandre Villance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: AppDrawer(
        isMagnifyingGlassActive: isMagnifyingGlassActive,
        magnifyingGlassController: magnifyingGlassController,
        toggleMagnifyingGlass: toggleMagnifyingGlass,
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String firstName;
  final String lastName;

  const ProfileHeader({
    super.key,
    required this.imageUrl,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      },
      child: Column(
        children: [
          if (imageUrl.isNotEmpty)
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 40.0,
              backgroundImage: imageUrl.startsWith('http')
                  ? NetworkImage(imageUrl)
                  : const AssetImage('path/to/placeholder_image.png')
              as ImageProvider<Object>,
            ),
          const SizedBox(height: 8),
          Text(
            '$firstName $lastName',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
