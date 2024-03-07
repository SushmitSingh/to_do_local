import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_local/ui/auth/OtpScreen.dart';
import 'package:to_do_local/ui/mainScreen/ScreenWithBottomNav.dart';
import 'package:to_do_local/ui/onboarding/OnboardingScreen.dart';
import 'package:to_do_local/ui/task/viewmodel/TodoViewModel.dart';
import 'package:to_do_local/utils/AppColors.dart';
import 'package:to_do_local/utils/AppPreferences.dart';
import 'package:to_do_local/utils/ThemeProvider.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Add other providers if needed
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Rebuilt App!');
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.selectedThemeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: AppColors.getMaterialColorFromColor(
                themeProvider.selectedPrimaryColor,
              ),
              primaryColor: themeProvider.selectedPrimaryColor,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: AppColors.getMaterialColorFromColor(
                themeProvider.selectedPrimaryColor,
              ),
              primaryColor: themeProvider.selectedPrimaryColor,
            ),
            home: child ?? MyApp(),
            routes: <String, WidgetBuilder>{
              '/otpScreen': (BuildContext ctx) => OtpScreen(),
              '/homeScreen': (BuildContext ctx) => const ScreenWithBottomNav(),
            });
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkIfUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          bool userLoggedIn = snapshot.data ?? false;

          if (userLoggedIn) {
            return ScreenWithBottomNav();
          } else {
            return OnboardingScreen();
          }
        }
      },
    );
  }

  Future<bool> checkIfUserLoggedIn() async {
    // Check if there is a current user
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null;
  }
}
