import '../db/Database.dart';
import 'model/Todo.dart';

class Repository {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  Future<List<Todo>> getTodos() async {
    try {
      return await _databaseProvider.fetchTodos();
    } catch (error) {
      print('Error getting todos from database: $error');
      return [];
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      await _databaseProvider.addTodo(todo);
    } catch (error) {
      print('Error adding todo to database: $error');
    }
  }

  Future<void> updateTodo(Todo processedTodo) async {
    try {
      await _databaseProvider.updateTodoInDatabase(processedTodo);
    } catch (error) {
      print('Error updating todo in database: $error');
    }
  }
}
