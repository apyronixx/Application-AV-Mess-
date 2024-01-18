import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_bucarest/screens/login_screen.dart';
import 'package:project_bucarest/screens/registration_screen.dart';
import 'package:project_bucarest/screens/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = "welcome_screen";

  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Timer _timer;
  bool _shouldNavigate = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _shouldNavigate = true;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                themeProvider.toggleDarkMode();
              },
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.brightness_4,
                    size: 36.0,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/logo.jpg',
                    height: 330.0,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  const Text(
                    'AV Mess',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: ColorConstants.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: ColorConstants.kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login, size: 24.0),
                  const SizedBox(width: 8.0),
                  Text(
                    (AppLocalizations.of(context)!.logIn),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 24.0),
                  const SizedBox(width: 8.0),
                  Text(
                    (AppLocalizations.of(context)!.register),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    appVersion,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 12.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ColorConstants {
  static const kPrimaryColor = Color(0xFF2c75FF);
  static const kSecondaryColor = Color(0xA6889EF3);
  static const kThirdSecondaryColor = Color(0xFF5E6BD8);
  static const kGravishBlueColor = Color(0xFF9BA1D2);
}

// Version information
const String appVersion = "version 1.1.0";
