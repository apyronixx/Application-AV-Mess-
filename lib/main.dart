import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:project_bucarest/screens/firebase_api.dart';
import 'package:project_bucarest/screens/notifications_screen.dart';
import 'package:project_bucarest/screens/welcome_screen.dart';
import 'package:project_bucarest/screens/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await FirebaseApi().initNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Get the user's preferred locale from the phone settings
  Locale preferredLocale =
      WidgetsBinding.instance?.window.locales[0] ?? const Locale('en', 'US');

  // Set the preferred locale for the app
  Intl.defaultLocale = preferredLocale.languageCode;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
      ],
      child: MyApp(preferredLocale: preferredLocale),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  final Locale preferredLocale;

  const MyApp({super.key, required this.preferredLocale});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A.V Messages',
      theme: themeProvider.getTheme().copyWith(primaryColor: ColorConstants.kPrimaryColor),
      locale: preferredLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WelcomeScreen(),
      navigatorKey: navigatorKey,
      routes: {
        '/lib/screens/notification_screen.dart':(context) => const NotificationsScreen(),
      }
    );
  }
}
