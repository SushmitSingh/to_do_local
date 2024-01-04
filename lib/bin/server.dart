import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

final todos = <String>[];

Response getAllTodos(Request request) {
  final jsonResponse = jsonEncode({'todos': todos});
  return Response.ok(jsonResponse,
      headers: {'Content-Type': 'application/json'});
}

Future<Response> addTodo(Request request) async {
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
    return Response.ok('Todo added');
  } catch (error) {
    // Handle errors
    print('Error adding todo: $error');
    return Response.internalServerError(body: 'Error adding todo');
  }
}

Future<shelf.Response> updateTodos(shelf.Request request) async {
  try {
    // Read the request body
    final requestBody = await request.readAsString();

    // Parse the JSON data
    final Map<String, dynamic> todosData = jsonDecode(requestBody);

    // Get the list of tasks from the parsed data
    final List<String> updatedTodos = (todosData['todos'] as List<dynamic>)
        .map<String>((todo) => todo['task'].toString())
        .toList();

    // Update the todos list
    todos.clear();
    todos.addAll(updatedTodos);

    // Respond with success
    return shelf.Response.ok('Todos updated');
  } catch (error) {
    // Handle errors
    print('Error updating todos: $error');
    return shelf.Response.internalServerError(body: 'Error updating todos');
  }
}

void main() {
  final app = Router();

  app.get('/todos', getAllTodos);
  app.post('/addTodo', addTodo);
  app.post('/updateTodos', updateTodos); // New route for updating todos

  var handler = const Pipeline()
      .addMiddleware(corsHeaders(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        },
      ))
      .addMiddleware(logRequests())
      .addHandler(app);

  shelf_io.serve(handler, '192.168.1.7', 3000).then((server) {
    print('Server started on port 3000');
  });
}
