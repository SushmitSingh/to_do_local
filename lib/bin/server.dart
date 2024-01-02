import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

final List<Map<String, dynamic>> todos = [];

class Todo {
  final String task;

  Todo(this.task);

  Map<String, dynamic> toMap() {
    return {'task': task};
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      map['task'] as String,
    );
  }
}

final _todosRouter = Router()
  ..get('/', getAllTodos)
  ..post('/add', addTodo)
  ..post('/update', updateTodos);

shelf.Response getAllTodos(shelf.Request request) {
  try {
    final jsonResponse = jsonEncode({'todos': todos});
    return shelf.Response.ok(jsonResponse,
        headers: {'Content-Type': 'application/json'});
  } catch (error) {
    print('Error getting todos: $error');
    return shelf.Response.internalServerError(body: 'Error getting todos');
  }
}

Future<shelf.Response> addTodo(shelf.Request request) async {
  try {
    final requestBody = await request.readAsString();
    final Map<String, dynamic> todoData = jsonDecode(requestBody);
    final Todo todo = Todo.fromMap(todoData);
    todos.add(todo.toMap());
    return shelf.Response.ok('Todo added');
  } catch (error) {
    print('Error adding todo: $error');
    return shelf.Response.internalServerError(body: 'Error adding todo');
  }
}

Future<shelf.Response> updateTodos(shelf.Request request) async {
  try {
    final requestBody = await request.readAsString();
    final Map<String, dynamic> todosData = jsonDecode(requestBody);
    final List<Map<String, dynamic>> updatedTodos =
        (todosData['todos'] as List<dynamic>)
            .map<Map<String, dynamic>>((todo) => Todo.fromMap(todo).toMap())
            .toList();
    todos.clear();
    todos.addAll(updatedTodos);
    return shelf.Response.ok('Todos updated');
  } catch (error) {
    print('Error updating todos: $error');
    return shelf.Response.internalServerError(body: 'Error updating todos');
  }
}

void main() {
  final app = Router()..mount('/todos/', _todosRouter);

  var handler = const shelf.Pipeline()
      .addMiddleware(corsHeaders(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        },
      ))
      .addMiddleware(shelf.logRequests())
      .addHandler(app);

  shelf_io.serve(handler, '192.168.137.1', 8080).then((server) {
    print('Server started on port 8080');
  });
}
