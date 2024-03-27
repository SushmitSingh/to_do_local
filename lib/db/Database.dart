import 'dart:async';

import '../ui/task/model/Todo.dart';
import 'ToDoAppDatabase.dart';

class DatabaseProvider {
  Future<ToDoAppDatabase> _initializeDatabase() async {
    return $FloorToDoAppDatabase.databaseBuilder('app_database.db').build();
  }

  Future<void> addTodo(Todo todo) async {
    final database = await _initializeDatabase();
    await database.todoDao.insertTodo(todo);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final database = await _initializeDatabase();
    await database.todoDao.updateTodo(updatedTodo);
  }

  Future<List<Todo>> getAllTodos() async {
    final database = await _initializeDatabase();
    return database.todoDao.getAllTodos();
  }

  Future<void> deleteTodoFromDatabase(Todo todo) async {
    final database = await _initializeDatabase();
    await database.todoDao.deleteTodo(todo);
  }

  Future<List<Todo>> getTodosByTagName(String selectedTag) async {
    final database = await _initializeDatabase();
    final tagType = await database.tagTypeDao
        .getAllTagTypes()
        .then((tags) => tags.firstWhere((tag) => tag.tagName == selectedTag));
    return database.todoDao.getTodosByTag(tagType.id!);
  }

  Future<List<Todo>> getTodosByDate(int selectedDate) async {
    final database = await _initializeDatabase();
    return database.todoDao.getTodosByDate(selectedDate);
  }

  Future<void> addTagType(TagType tagType) async {
    final database = await _initializeDatabase();
    await database.tagTypeDao.insertTagType(tagType);
  }

  Future<List<TagType>> getAllTagTypes() async {
    final database = await _initializeDatabase();
    return database.tagTypeDao.getAllTagTypes();
  }
}
