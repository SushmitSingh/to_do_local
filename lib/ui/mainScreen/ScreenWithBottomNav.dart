import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../PrivacyPolicyScreen.dart';
import '../TermsAndConditionsScreen.dart';
import '../calendar/CalendarScreen.dart';
import '../profile/ProfileScreen.dart';
import '../settings/SettingScreen.dart';
import '../task/AddEditTodoBottomSheet.dart';
import '../task/TodoScreen.dart';
import '../task/model/Todo.dart';
import '../task/viewmodel/TodoViewModel.dart';

class ScreenWithBottomNav extends StatefulWidget {
  const ScreenWithBottomNav({Key? key}) : super(key: key);

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingScreen()),
    );
  }

  void _onTermsAndConditionsTapped() {
    Navigator.pop(context); // Close the drawer before navigating
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsAndConditionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 5.0,
        isExtended: true,
        onPressed: () {
          _showAddEditTodoBottomSheet(context, null);
        },
        child: Icon(color: Theme.of(context).primaryColor, Icons.add_task),
      ),
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
            icon: Icon(Icons.task),
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
        selectedFontSize: 14,
        selectedItemColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Todo Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
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

  void _showAddEditTodoBottomSheet(BuildContext context, Todo? todo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddEditTodoBottomSheet(
          todo: todo,
          onUpdateTodo: (updatedTodo) {
            final todoViewModel =
                Provider.of<TodoViewModel>(context, listen: false);
            todoViewModel.updateTodoStatus(updatedTodo, updatedTodo.status);
          },
        );
      },
    );
  }
}
