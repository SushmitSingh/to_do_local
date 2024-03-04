import 'package:flutter/material.dart';

import '../PrivacyPolicyScreen.dart';
import '../TermsAndConditionsScreen.dart';
import '../calendar/CalendarScreen.dart';
import '../profile/ProfileScreen.dart';
import '../settings/SettingScreen.dart';
import '../task/TodoScreen.dart';

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

  void _onSettingsClick() {
    Navigator.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingScreen()));
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
                  : _currentIndex == 3
                      ? AppBar(
                          title: const Text("Settings"),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: _onSettingsClick,
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
