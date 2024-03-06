import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_local/ui/auth/OtpScreen.dart';
import 'package:to_do_local/ui/mainScreen/ScreenWithBottomNav.dart';
import 'package:to_do_local/ui/onboarding/OnboardingScreen.dart';
import 'package:to_do_local/ui/task/viewmodel/TodoViewModel.dart';
import 'package:to_do_local/utils/AppPreferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppPreferences.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoViewModel()),
        // Add other providers if needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkIfUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            bool userLoggedIn = snapshot.data ?? false;

            if (userLoggedIn) {
              return const ScreenWithBottomNav();
            } else {
              return OnboardingScreen();
            }
          }
        },
      ),
      routes: <String, WidgetBuilder>{
        '/otpScreen': (BuildContext ctx) => OtpScreen(),
        '/homeScreen': (BuildContext ctx) => const ScreenWithBottomNav(),
      },
    );
  }

  Future<bool> checkIfUserLoggedIn() async {
    // Check if there is a current user
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null;
  }
}
