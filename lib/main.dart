import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
     _initStorePath().then((path) {
      _fetchLocalTodos();
      _processOfflineTodos();
    });
  }

  Future<String> _initStorePath() async {
    try {
      storePath = '$getDocumentDirectoryPath/todos_store.db';
      return '$getDocumentDirectoryPath/todos_store.db';
    } catch (error) {
      print('Error initializing storePath: $error');
      storePath = '$getDocumentDirectoryPath/todos_store.db';
      throw Exception('Failed to initialize store path: $error');
    }
  }

  Future<String> getDocumentDirectoryPath() async {
    try {
      final appDocumentsDirectory = await getApplicationDocumentsDirectory();
      return appDocumentsDirectory.path;
    } catch (error) {
      print('Error getting document directory path: $error');
      throw Exception('Failed to get document directory path: $error');
    }
  }



  Future<void> _fetchLocalTodos() async {
    try {
      await _initStorePath();

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
      await _initStorePath();

      final DatabaseFactory dbFactory =
          kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
      final Database db = await dbFactory.openDatabase(storePath);

      final store = stringMapStoreFactory.store('todos');

      // Remove duplicates and update local todos list
      final List<String> uniqueTodosToSave = todosToSave.toSet().toList();
      await store.record('todos').put(db, {'todos': uniqueTodosToSave});

      // Refresh the list immediately after saving locally
      _fetchLocalTodos();
    } catch (error) {
      print('Error saving local todos: $error');
    }
  }

  Future<void> _saveTodoOnServer(String task) async {
    try {
      await _initStorePath();

      Map<String, dynamic> newTodo = {'task': task};

      if (await _checkInternetConnection()) {
        String todoJson = jsonEncode(newTodo);

        print('Sending todo to server: $todoJson');

        var response = await http.post(
          Uri.parse('http://192.168.1.7:3000/addTodo'),
          headers: {'Content-Type': 'application/json'},
          body: todoJson,
        );

        print('Server response status code: ${response.statusCode}');
        print('Server response body: ${response.body}');

        if (response.statusCode == 200) {
          await _syncWithServer();
          _showSnackbar('Todo added successfully!');
        } else {
          print(
              'Failed to add todo on the server. Server returned ${response.statusCode}');
          _showSnackbar('Failed to add todo on the server.');

          // Save locally only if the server request fails
          await _saveLocalTodos([...todos, task]);
        }
      } else {
        print('No internet connection. Saving todo locally.');
        await _saveLocalTodos([...todos, task]);
        _showSnackbar('No internet connection. Saving todo locally.');
      }
    } catch (error) {
      print('Error sending todo to the server: $error');
      await _saveLocalTodos([...todos, task]);
      _showSnackbar('Error sending todo to the server. Saving locally.');
    }
  }

  Future<void> _syncWithServer() async {
    try {
      await _initStorePath();

      // Fetch local todos
      final DatabaseFactory dbFactory =
          kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
      final Database db = await dbFactory.openDatabase(storePath);

      final localStore = stringMapStoreFactory.store('todos');
      final localRecord = await localStore.record('todos').get(db);

      List<String> localTodos = [];
      if (localRecord != null) {
        final Map<String, dynamic> localData = localRecord;
        if (localData.containsKey('todos')) {
          localTodos = List<String>.from(localData['todos']);
        }
      }

      // Fetch server todos
      var response = await http.get(
        Uri.parse('http://192.168.1.7:3000/todos'),
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<String> serverTodos = List<String>.from(data['todos']);

        // Combine local and server todos, remove duplicates
        final List<String> combinedTodos = [
          ...Set.from([...localTodos, ...serverTodos])
        ];

        // Update the server with the combined todos
        await _updateServer(combinedTodos);

        setState(() {
          todos = combinedTodos;
        });

        await _saveLocalTodos(combinedTodos);
        _showSnackbar('Synced with server successfully!');
      } else {
        print(
            'Failed to fetch todos from the server. Server returned ${response.statusCode}');
        _showSnackbar('Failed to sync with server.');
      }
    } catch (error) {
      print('Error syncing with server: $error');
      _showSnackbar('Error syncing with server.');
    }
  }

  Future<void> _updateServer(List<String> todosToUpdate) async {
    try {
      await _initStorePath();

      final List<Map<String, dynamic>> todosMapList =
          todosToUpdate.map((todo) => {'task': todo}).toList();

      final String todosJson = jsonEncode({'todos': todosMapList});

      print('Updating server with todos: $todosJson');

      var response = await http.post(
        Uri.parse('http://192.168.1.7:3000/updateTodos'),
        headers: {'Content-Type': 'application/json'},
        body: todosJson,
      );

      print('Server update response status code: ${response.statusCode}');
      print('Server update response body: ${response.body}');

      if (response.statusCode == 200) {
        // Server update successful
      } else {
        print(
            'Failed to update todos on the server. Server returned ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating server with todos: $error');
    }
  }

  Future<void> _processOfflineTodos() async {
    try {
      await _initStorePath();

      final DatabaseFactory dbFactory =
          kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
      final Database db = await dbFactory.openDatabase(storePath);

      final store = stringMapStoreFactory.store('offlineTodos');
      final todosToProcess = await store.find(db);

      for (var todoRecord in todosToProcess) {
        final String task = todoRecord['task'] as String;
        await _saveTodoOnServer(task);
      }

      for (var todoRecord in todosToProcess) {
        await store.record(todoRecord.key).delete(db);
      }
    } catch (error) {
      print('Error processing offline todos: $error');
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) {
        return true;
      }

      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
                _textController.clear();
              },
              child: Text('Save Locally'),
            ),
          ],
        );
      },
    );
  }
}
