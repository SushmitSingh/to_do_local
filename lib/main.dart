import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<String> todos = [];

  @override
  void initState() {
    super.initState();
    // Fetch todos from the server when the screen initializes
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    try {
      // Make a GET request to fetch todos from the server
      var response = await http.get(
        Uri.parse('http://192.168.137.1:8080/todos'),
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, update the local todos list
        setState(() {
          // Parse the JSON response to get the 'todos' list
          final Map<String, dynamic> data = jsonDecode(response.body);
          todos = List<String>.from(data['todos']);
        });
      } else {
        // If the server returns an error response, handle it accordingly
        print('Failed to fetch todos. Server returned ${response.statusCode}');
      }
    } catch (error) {
      // Handle network-related errors
      print('Error fetching todos: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(todos[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _addTodo();
              },
              child: Text('Add Todo'),
            ),
          ),
        ],
      ),
    );
  }

  void _addTodo() {
    TextEditingController _textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: TextField(
            controller: _textController,
            onChanged: (value) {
              // Do nothing for now
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveTodo(_textController.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTodo(String task) async {
    try {
      // Create a Map representing the new todo
      Map<String, dynamic> newTodo = {'task': task};

      // Convert the Map to a JSON string
      String todoJson = jsonEncode(newTodo);

      // Make a POST request to the server
      var response = await http.post(
        Uri.parse('http://192.168.137.1:8080/addTodo'),
        headers: {'Content-Type': 'application/json'},
        body: todoJson,
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, fetch the updated todos
        _fetchTodos();
      } else {
        // If the server returns an error response, handle it accordingly
        print('Failed to add todo. Server returned ${response.statusCode}');
      }
    } catch (error) {
      // Handle network-related errors
      print('Error sending todo: $error');
    }
  }
}
