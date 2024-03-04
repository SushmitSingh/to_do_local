import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_local/ui/mainScreen/ScreenWithBottomNav.dart';
import 'package:to_do_local/ui/onboarding/OnboardingScreen.dart';
import 'package:to_do_local/ui/task/viewmodel/TodoViewModel.dart';
import 'package:to_do_local/utils/AppPreferences.dart';

void main() async {
  //await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoViewModel()),
        // Add other providers if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
    );
  }

  Future<bool> checkIfUserLoggedIn() async {
    bool? isLogin = await AppPreferences.isLoggedIn;
    return isLogin;
  }
}
