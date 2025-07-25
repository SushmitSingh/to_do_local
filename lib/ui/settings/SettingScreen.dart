import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_local/utils/ThemeSwitcher.dart';

import '../auth/LoginScreen.dart';
import '../task/viewmodel/TodoViewModel.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          ElevatedButton(
              child: const Text('Logout'),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              }),
          ElevatedButton(
            onPressed: () {
              _syncWithServer(context);
            },
            child: const Text('Sync with Server'),
          ),
          ThemeSwitcher(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Primary Color'),
          ),
          PrimaryColorSwitcher(),
        ],
      ),
    );
  }

  void _syncWithServer(BuildContext context) async {
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    try {
      await todoViewModel.syncWithServer();
    } catch (error) {
      print('Error syncing with server: $error');
      _showSnackbar('Error syncing with server.', context);
    }
  }

  void _showSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
