import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TodoViewModel()),
          // Add other providers if needed
        ],
        child: TodoListScreen(),
      ),
    );
  }
}
