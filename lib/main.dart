import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_local/ui/auth/OtpScreen.dart';
import 'package:to_do_local/ui/mainScreen/ScreenWithBottomNav.dart';
import 'package:to_do_local/ui/onboarding/OnboardingScreen.dart';
import 'package:to_do_local/ui/task/viewmodel/TodoViewModel.dart';
import 'package:to_do_local/utils/AppPreferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyBZ3NKxX9U55jh8QsL2NGqV5U029TKbXJc',
              appId: '1:881211077216:android:8325bcdf6d11acdca08905',
              messagingSenderId: '881211077216',
              projectId: 'fireaseotp'))
      : await Firebase.initializeApp();

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
            bool userLoggedIn = false;

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
        //'/homeScreen': (BuildContext ctx) => HomeScreen(),
      },
    );
  }

  Future<bool> checkIfUserLoggedIn() async {
    AppPreferences.init().whenComplete(() => null);
    bool isLogin = await AppPreferences.isLoggedIn;
    return isLogin;
  }
}
