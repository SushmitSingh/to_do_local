import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

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
  const TodoListScreen({Key? key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<String> todos = [];
  late String storePath;

  @override
  void initState() {
    super.initState();
    _initStorePath();
    _fetchLocalTodos();
    _processOfflineTodos();
  }

  Future<void> _initStorePath() async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    storePath = '${appDocumentsDirectory.path}/todos_store.db';
  }

  Future<void> _fetchLocalTodos() async {
    try {
      final DatabaseFactory dbFactory =
          kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
      final Database db = await dbFactory.openDatabase(storePath);

      final store = stringMapStoreFactory.store('todos');
      final record = await store.record('todos').get(db);

      if (record != null) {
        final Map<String, dynamic> data = record;
        if (data.containsKey('todos')) {
          setState(() {
            todos.clear();
            todos.addAll(List<String>.from(data['todos']));
          });
        }
      }
    } catch (error) {
      print('Error fetching local todos: $error');
    }
  }

  Future<void> _saveLocalTodos(List<String> todosToSave) async {
    try {
      final DatabaseFactory dbFactory =
          kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
      final Database db = await dbFactory.openDatabase(storePath);

      final store = stringMapStoreFactory.store('todos');
      await store.record('todos').put(db, {'todos': todosToSave});
    } catch (error) {
      print('Error saving local todos: $error');
    }
  }

  Future<void> _saveTodoOnServer(String task) async {
    try {
      // Save locally first
      await _saveLocalTodos([...todos, task]);

      Map<String, dynamic> newTodo = {'task': task};

      if (await _checkInternetConnection()) {
        String todoJson = jsonEncode(newTodo);

        print('Sending todo to server: $todoJson');

        var response = await http.post(
          Uri.parse(
              'http://192.168.137.1:3000/addTodo'), // Replace with your server endpoint
          headers: {'Content-Type': 'application/json'},
          body: todoJson,
        );

        print('Server response status code: ${response.statusCode}');
        print('Server response body: ${response.body}');

        if (response.statusCode == 200) {
          // If the server returns a 200 OK response, fetch the updated todos
          await _syncWithServer();
        } else {
          print(
              'Failed to add todo on the server. Server returned ${response.statusCode}');
        }
      } else {
        print('No internet connection. Saving todo locally.');
      }
    } catch (error) {
      print('Error sending todo to the server: $error');
    }
  }

  Future<void> _syncWithServer() async {
    try {
      var response = await http.get(
        Uri.parse(
            'http://192.168.137.1:3000/todos'), // Replace with your server endpoint
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          todos = List<String>.from(data['todos']);
        });

        await _saveLocalTodos(todos);
      } else {
        print(
            'Failed to fetch todos from the server. Server returned ${response.statusCode}');
      }
    } catch (error) {
      print('Error syncing with server: $error');
    }
  }

  Future<void> _processOfflineTodos() async {
    try {
      final DatabaseFactory dbFactory =
          kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
      final Database db = await dbFactory.openDatabase(storePath);

      final store = stringMapStoreFactory.store('offlineTodos');
      final todosToProcess = await store.find(db);

      for (var todoRecord in todosToProcess) {
        final String task = todoRecord['task'] as String;
        await _saveTodoOnServer(task);
      }

      // After processing, delete only the processed records
      for (var todoRecord in todosToProcess) {
        await store.record(todoRecord.key).delete(db);
      }
    } catch (error) {
      print('Error processing offline todos: $error');
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _syncWithServer();
              },
              child: Text('Sync with Server'),
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
                _saveTodoOnServer(_textController.text);
              },
              child: Text('Save Locally'),
            ),
          ],
        );
      },
    );
  }
}
