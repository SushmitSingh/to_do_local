import '../../db/Database.dart';
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

  Future<List<Todo>> getTodosByTag(String selectedTag) async {
    try {
      return await _databaseProvider.fetchTodosByTag(selectedTag);
    } catch (error) {
      print('Error getting todos by tag from database: $error');
      return [];
    }
  }

  Future<List<TagType>> getAllTags() async {
    try {
      return await _databaseProvider.fetchAllTagTypes();
    } catch (error) {
      print('Error getting tags from database: $error');
      return [];
    }
  }

  Future<List<Todo>> getTodosByDate(DateTime selectedDate) async {
    try {
      return await _databaseProvider.fetchTodosByDate(selectedDate);
    } catch (error) {
      print('Error getting todos by date from database: $error');
      return [];
    }
  }

  Future<List<Todo>> getTodosByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      return await _databaseProvider.fetchTodosByDateRange(startDate, endDate);
    } catch (error) {
      print('Error getting todos by date range from database: $error');
      return [];
    }
  }
}
