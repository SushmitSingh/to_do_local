import 'package:flutter/foundation.dart';

import '../TodoRepository.dart';
import '../model/Todo.dart';

class TodoViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<void> _fetchTodos() async {
    try {
      _todos = await _repository.getTodos();
      notifyListeners();
    } catch (error) {
      print('Error fetching todos: $error');
    }
  }

  Future<void> addTodo(Todo newTodo) async {
    try {
      await _repository.addTodo(newTodo);
      await _fetchTodos();
    } catch (error) {
      print('Error adding todo: $error');
    }
  }

  Future<void> completeTodo(Todo todo) async {
    try {
      final List<Subtask> completedSubtasks = todo.subtasks
          .map((subtask) =>
              Subtask(task: subtask.task, completed: subtask.completed))
          .toList();

      final completedTodo = Todo(
        task: todo.task,
        key: todo.key,
        subtasks: completedSubtasks,
        createDate: todo.createDate,
        endDate: todo.endDate,
        status: 'completed',
        tag: todo.tag,
      );

      await _repository.addTodo(completedTodo);
      await _fetchTodos();
    } catch (error) {
      print('Error completing todo: $error');
    }
  }

  Future<void> syncWithServer() async {
    try {
      // Retrieve the todos that need to be synced (e.g., unsynced or modified)
      List<Todo> unsyncedTodos = _todos.where((todo) => !todo.synced).toList();

      // TODO: Implement logic to send unsyncedTodos to the server and receive updates

      // Mark synced todos as synced
      for (var syncedTodo in unsyncedTodos) {
        syncedTodo.synced = true;
        await _repository.updateTodo(syncedTodo);
      }

      await _fetchTodos(); // Refresh the local list after syncing
    } catch (error) {
      print('Error syncing with server: $error');
      // Handle the error appropriately, e.g., show a snackbar or log it
    }
  }

  Future<void> updateTodoStatus(Todo todo, String newStatus) async {
    try {
      final updatedTodo = Todo(
        task: todo.task,
        key: todo.key,
        subtasks: todo.subtasks,
        createDate: todo.createDate,
        endDate: todo.endDate,
        status: newStatus,
        tag: todo.tag,
      );

      await _repository.addTodo(updatedTodo);
      await _fetchTodos();
    } catch (error) {
      print('Error updating todo status: $error');
    }
  }

  void updateSubtaskStatus(Todo todo, Subtask subtask) {
    try {
      // Find the index of the subtask in the todo's subtasks list
      int subtaskIndex = todo.subtasks.indexOf(subtask);

      if (subtaskIndex != -1) {
        // Update the status of the subtask
        todo.subtasks[subtaskIndex].completed = subtask.completed;

        // Update the todo in the database
        _repository.updateTodo(todo);

        // Notify listeners to update the UI
        notifyListeners();
      }
    } catch (error) {
      print('Error updating subtask status: $error');
    }
  }

  Future<void> fetchTodosByTag(String selectedTag) async {
    try {
      _todos = await _repository.getTodosByTag(selectedTag);
      notifyListeners();
    } catch (error) {
      print('Error fetching todos by tag: $error');
    }
  }

  Future<void> fetchTodosByDate(DateTime selectedDate) async {
    try {
      _todos = await _repository.getTodosByDate(selectedDate);
      notifyListeners();
    } catch (error) {
      print('Error fetching todos by date: $error');
    }
  }

  // Example method to get todos within a date range
  Future<void> fetchTodosByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      _todos = await _repository.getTodosByDateRange(startDate, endDate);
      notifyListeners();
    } catch (error) {
      print('Error fetching todos by date range: $error');
    }
  }
}
