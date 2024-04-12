import 'package:flutter/material.dart';

import '../TodoRepository.dart';
import '../model/Todo.dart';

class TodoViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  List<TagType> _tags = [];

  List<TagType> get tags => _tags;

  TagType? _selectedTag;

  TagType? get selectedTag => _selectedTag;

  void setSelectedTag(TagType tag) {
    _selectedTag = tag;
    if (tag.tagName == "all") {
      _fetchTodos();
    } else {
      fetchTodosByTag(tag.tagName);
    }
    notifyListeners();
  }

  Future<void> _fetchTodos() async {
    try {
      if (selectedTag == null) {
        _todos = await _repository.getTodos();
      } else {
        fetchTodosByTag(selectedTag!.tagName);
      }
      notifyListeners();
    } catch (error) {
      print('Error fetching todos: $error');
    }
  }

  Future<List<TagType>> fetchTags() async {
    try {
      _tags = await _repository.getAllTags();
      print(_tags.toString() + "hiii"); // Corrected to _tags
      return _tags;
    } catch (error) {
      print('Error fetching tags $error');
      // You might want to throw an exception here or handle the error appropriately.
      rethrow;
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
        todoDate: todo.todoDate,
        status: todo.status,
        tagId: todo.tagId,
      );

      await _repository.updateTodo(completedTodo);
      await _fetchTodos();
    } catch (error) {
      print('Error completing todo: $error');
    }
  }

  Future<void> syncWithServer() async {
    try {
      /* // Retrieve the todos that need to be synced (e.g., unsynced or modified)
      List<Todo> unsyncedTodos = _todos.where((todo) => !todo.synced).toList();
      // Mark synced todos as synced
     for (var syncedTodo in unsyncedTodos) {
        syncedTodo.synced = true;
        await _repository.updateTodo(syncedTodo.id!, syncedTodo);
      }*/
      await _fetchTodos(); // Refresh the local list after syncing
    } catch (error) {
      print('Error syncing with server: $error');
    }
  }

  Future<void> updateTodoStatus(Todo todo, bool newStatus) async {
    try {
      final updatedTodo = Todo(
        task: todo.task,
        key: todo.key,
        subtasks: todo.subtasks,
        todoDate: todo.todoDate,
        status: newStatus,
        tagId: todo.tagId,
      );

      await _repository.updateTodo(updatedTodo);
      notifyListeners();
    } catch (error) {
      print('Error updating todo status: $error');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _repository.updateTodo(todo);
      await _fetchTodos();

      // Notify listeners to update the UI
      notifyListeners();
    } catch (error) {
      print('Error updating todo: $error');
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

  Future<void> addTagType(TagType tagType) async {
    await _repository.addTagType(tagType);
    await fetchTags();
    notifyListeners();
  }

  void deleteTodo(Todo todo) async {
    await _repository.deleteTodo(todo);
    await fetchTags();
    await _fetchTodos();
    notifyListeners();
  }

  List<IconData> getIconDataList() {
    return [
      Icons.star,
      Icons.favorite,
      Icons.home,
      Icons.work,
      Icons.school,
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.directions_bike,
      Icons.directions_bus,
      Icons.directions_car,
      Icons.directions_boat,
      Icons.directions_railway,
      Icons.directions_walk,
      Icons.local_airport,
      Icons.local_atm,
      Icons.local_bar,
      Icons.local_cafe,
      Icons.local_car_wash,
      Icons.local_convenience_store,
      Icons.local_dining,
      Icons.local_drink,
      Icons.local_florist,
      Icons.local_gas_station,
      Icons.local_grocery_store,
      Icons.local_hospital,
      Icons.local_hotel,
      Icons.local_laundry_service,
      Icons.local_library,
      Icons.local_mall,
      Icons.local_movies,
      Icons.local_offer,
      Icons.local_parking,
      Icons.local_pharmacy,
      Icons.local_phone,
    ];
  }
}
