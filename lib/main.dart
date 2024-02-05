import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_local/ui/PrivacyPolicyScreen.dart';
import 'package:to_do_local/ui/TermsAndConditionsScreen.dart';
import 'package:to_do_local/ui/calendar/CalendarScreen.dart';
import 'package:to_do_local/ui/onboarding/OnboardingScreen.dart';
import 'package:to_do_local/ui/profile/ProfileScreen.dart';
import 'package:to_do_local/ui/task/TodoScreen.dart';
import 'package:to_do_local/ui/task/viewmodel/TodoViewModel.dart';

void main() {
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
    // Implement your logic to check if the user is logged in or not
    // Return true if the user is logged in, false otherwise
    return true;
  }
}

class ScreenWithBottomNav extends StatefulWidget {
  const ScreenWithBottomNav({super.key});

  @override
  _ScreenWithBottomNavState createState() => _ScreenWithBottomNavState();
}

class _ScreenWithBottomNavState extends State<ScreenWithBottomNav> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const TodoListScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context); // Close the drawer when a screen is selected
  }

  void _onPrivacyPolicyTapped() {
    Navigator.pop(context); // Close the drawer before navigating
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  void _onTermsAndConditionsTapped() {
    Navigator.pop(context); // Close the drawer before navigating
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('Todo'),
            )
          : _currentIndex == 1
              ? AppBar(
                  title: const Text('Calendar'),
                )
              : _currentIndex == 2
                  ? AppBar(
                      title: const Text('Profile'),
                    )
                  : null,
      // AppBar is null for Privacy Policy and Terms and Conditions screens
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Todo'),
              onTap: () => _onItemTapped(0),
              selected: _currentIndex == 0,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendar'),
              onTap: () => _onItemTapped(1),
              selected: _currentIndex == 1,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => _onItemTapped(2),
              selected: _currentIndex == 2,
            ),
            const Divider(), // Add a divider for visual separation
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Privacy Policy'),
              onTap: _onPrivacyPolicyTapped,
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Terms and Conditions'),
              onTap: _onTermsAndConditionsTapped,
            ),
          ],
        ),
      ),
    );
  }
}
