// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_bucarest/screens/registration_screen.dart';
import 'package:project_bucarest/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_bucarest/screens/theme_provider.dart';
import 'package:project_bucarest/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_bucarest/screens/homepage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  static String id = "login_screen";

  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Retrieve email from SharedPreferences and pre-fill the field
    getEmailFromSharedPreferences();
  }

  Future<void> getEmailFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    if (storedEmail != null && storedEmail.isNotEmpty) {
      setState(() {
        emailController.text = prefs.getString('email') ?? '';
      });
    }
  }

  Future<void> setEmailToSharedPreferences(String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text((AppLocalizations.of(context)!.back),),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: emailController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {});
              },
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black,),
              decoration: kTextFieldDecoration.copyWith(
                hintText: (AppLocalizations.of(context)!.enterEmail),
                fillColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: passwordController,
              textAlign: TextAlign.center,
              obscureText: true,
              onChanged: (value) {
                setState(() {});
              },
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
              decoration: kTextFieldDecoration.copyWith(
                hintText: (AppLocalizations.of(context)!.enterPassword),
                fillColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            ElevatedButton(
              onPressed: () async {
                // Store the email to SharedPreferences when the button is pressed
                await setEmailToSharedPreferences(emailController.text);

                if (!emailController.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text((AppLocalizations.of(context)!.emailProblem)),
                    ),
                  );
                  return;
                }

                if (passwordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.of(context)!.authFailed),
                          const SizedBox(height: 8.0),
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
                              foregroundColor: Colors.white, backgroundColor: Colors.red,
                              padding: const EdgeInsets.all(8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text((AppLocalizations.of(context)!.goToRegistration),
                              style: const TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  showSpinner = true;
                });

                try {
                  await _auth.signInWithEmailAndPassword(email: emailController.text,
                      password: passwordController.text);


                  setState(() {
                    showSpinner = false;
                  });

                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                    ),
                  );
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }

                  // Check for internet connectivity exception
                  if (e is FirebaseAuthException && (e.message?.contains('network') ?? false)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.noInternetConnection),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text((AppLocalizations.of(context)!.authFailed)),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: ColorConstants.kPrimaryColor,
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                (AppLocalizations.of(context)!.logIn),
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
