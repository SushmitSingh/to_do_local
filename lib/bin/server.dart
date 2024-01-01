import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

final List<String> todos = [];

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
    // Read the request body
    final requestBody = await request.readAsString();

    // Parse the JSON data
    final Map<String, dynamic> todoData = jsonDecode(requestBody);

    // Get the task from the parsed data
    final String task = todoData['task'];

    // Add the task to the todos list
    todos.add(task);

    // Respond with success
    return shelf.Response.ok('Todo added');
  } catch (error) {
    // Handle errors
    print('Error adding todo: $error');
    return shelf.Response.internalServerError(body: 'Error adding todo');
  }
}

void main() {
  final app = Router();

  app.get('/todos', getAllTodos);
  app.post('/addTodo', addTodo);

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

  shelf_io.serve(handler, '192.168.137.1', 3000).then((server) {
    print('Server started on port 3000');
  });
}
