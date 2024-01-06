import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_local/ui/auth/LoginScreen.dart';
import 'package:to_do_local/ui/calendar/CalendarScreen.dart';
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
      child: MyApp(),
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
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            bool userLoggedIn = snapshot.data ?? false;

            if (userLoggedIn) {
              return ScreenWithBottomNav();
            } else {
              return LoginScreen();
            }
          }
        },
      ),
    );
  }

  Future<bool> checkIfUserLoggedIn() async {
    // Implement your logic to check if the user is logged in or not
    // Return true if the user is logged in, false otherwise
    return false;
  }
}

class ScreenWithBottomNav extends StatefulWidget {
  @override
  _ScreenWithBottomNavState createState() => _ScreenWithBottomNavState();
}

class _ScreenWithBottomNavState extends State<ScreenWithBottomNav> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    TodoListScreen(),
    CalendarScreen(), // Assuming you have a CalendarScreen widget
    ProfileScreen(), // Assuming you have a ProfileScreen widget
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? 'Todo'
            : _currentIndex == 1
                ? 'Calendar'
                : 'Profile'),
      ),
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
              leading: Icon(Icons.settings_applications),
              title: Text('Settings'),
              onTap: () {
                // Navigate to settings screen or perform some action
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                // Navigate to about screen or perform some action
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
