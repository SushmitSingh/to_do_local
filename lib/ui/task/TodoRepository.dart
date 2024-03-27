import '../../db/Database.dart';
import 'model/Todo.dart';

class Repository {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

  Future<List<Todo>> getTodos() async {
    try {
      return await _databaseProvider.getAllTodos();
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

  Future<void> updateTodo(int id, Todo processedTodo) async {
    try {
      await _databaseProvider.updateTodo(id, processedTodo);
    } catch (error) {
      print('Error updating todo in database: $error');
    }
  }

  Future<List<Todo>> getTodosByTag(String selectedTag) async {
    try {
      return await _databaseProvider.getTodosByTagName(selectedTag);
    } catch (error) {
      print('Error getting todos by tag from database: $error');
      return [];
    }
  }

  Future<List<TagType>> getAllTags() async {
    try {
      return await _databaseProvider.getAllTagTypes();
    } catch (error) {
      print('Error getting tags from database: $error');
      return [];
    }
  }

  Future<void> deleteTodo(Todo todo) async {
    try {
      await _databaseProvider.deleteTodoFromDatabase(todo);
    } catch (error) {
      print('Error deleting todo from database: $error');
    }
  }

  Future<List<TagType>> fetchAllTagTypes() async {
    return await _databaseProvider.getAllTagTypes();
  }

  Future<void> addTagType(TagType tagType) async {
    await _databaseProvider.addTagType(tagType);
  }

  Future<List<Todo>> getTodosByDate(DateTime selectedDate) async {
    try {
      return await _databaseProvider.getTodosByDate(selectedDate.millisecond);
    } catch (error) {
      print('Error getting todos by date from database: $error');
      return [];
    }
  }
}
