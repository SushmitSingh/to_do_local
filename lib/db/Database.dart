import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import '../ui/task/model/Todo.dart';

class DatabaseProvider {
  final String _todosStoreName = 'todos';
  final String _subtasksStoreName = 'subtasks';
  final String _tagsStoreName = 'tags'; // New store for TagType
  final DatabaseFactory _dbFactory = databaseFactoryIo;
  late Database _database;

  Future<void> _initializeDatabase() async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = '${appDocumentsDirectory.path}/todos_store.db';

    _database = await _dbFactory.openDatabase(dbPath);
  }

  Future<List<Todo>> fetchTodos() async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(sortOrders: [SortOrder('createDate')]);
    final todosSnapshots = await store.find(_database, finder: finder);

    await _database.close();

    return todosSnapshots.map((snapshot) {
      final List<dynamic> subtasksData = (snapshot['subtasks'] as List) ?? [];
      final List<Subtask> subtasks =
          subtasksData.map((data) => Subtask.fromMap(data)).toList();

      return Todo(
        task: snapshot['task'] as String,
        key: snapshot['key'] as String,
        subtasks: subtasks,
        createDate: DateTime.parse(snapshot['createDate'] as String),
        endDate: DateTime.parse(snapshot['endDate'] as String),
        status: snapshot['status'] as String,
        tag: TagType.fromMap(snapshot['tag'] as Map<String, dynamic>),
      );
    }).toList();
  }

  Future<List<TagType>> fetchAllTagTypes() async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_tagsStoreName);
    final tagSnapshots = await store.find(_database);

    await _database.close();

    return tagSnapshots
        .map((snapshot) => TagType.fromMap(snapshot.value))
        .toList();
  }

  Future<List<Todo>> fetchTodosByTag(String selectedTag) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('tag', selectedTag));
    final todosSnapshots = await store.find(_database, finder: finder);

    // Ensure the database is closed after fetching data
    await _database.close();

    return todosSnapshots.map((snapshot) {
      final List<dynamic> subtasksData = (snapshot['subtasks'] as List) ?? [];
      final List<Subtask> subtasks =
          subtasksData.map((data) => Subtask.fromMap(data)).toList();

      return Todo(
        task: snapshot['task'] as String,
        key: snapshot['key'] as String,
        subtasks: subtasks,
        createDate: DateTime.parse(snapshot['createDate'] as String),
        endDate: DateTime.parse(snapshot['endDate'] as String),
        status: snapshot['status'] as String,
        tag: snapshot['tag'] as TagType,
      );
    }).toList();
  }

  Future<List<Todo>> fetchTodosByDate(DateTime selectedDate) async {
    await _initializeDatabase();

    // Assuming selectedDate is a DateTime object
    final DateTime selectedDateTime =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(
      filter: Filter.or([
        Filter.equals('createDate', selectedDateTime.toIso8601String()),
        Filter.equals('endDate', selectedDateTime.toIso8601String()),
        Filter.and([
          Filter.greaterThanOrEquals(
              'createDate', selectedDateTime.toIso8601String()),
          Filter.lessThanOrEquals('endDate',
              selectedDateTime.add(Duration(days: 1)).toIso8601String()),
        ]),
      ]),
    );
    final todosSnapshots = await store.find(_database, finder: finder);

    // Ensure the database is closed after fetching data
    await _database.close();

    return todosSnapshots.map((snapshot) {
      final List<dynamic> subtasksData = (snapshot['subtasks'] as List) ?? [];
      final List<Subtask> subtasks =
          subtasksData.map((data) => Subtask.fromMap(data)).toList();

      return Todo(
        task: snapshot['task'] as String,
        key: snapshot['key'] as String,
        subtasks: subtasks,
        createDate: DateTime.parse(snapshot['createDate'] as String),
        endDate: DateTime.parse(snapshot['endDate'] as String),
        status: snapshot['status'] as String,
        tag: snapshot['tag'] as TagType,
      );
    }).toList();
  }

  Future<List<Todo>> fetchTodosByDateRange(
      DateTime startDate, DateTime endDate) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(
        filter: Filter.and([
      Filter.greaterThanOrEquals('createDate', startDate.toIso8601String()),
      Filter.lessThanOrEquals('createDate', endDate.toIso8601String()),
    ]));
    final todosSnapshots = await store.find(_database, finder: finder);

    // Ensure the database is closed after fetching data
    await _database.close();

    return todosSnapshots.map((snapshot) {
      final List<dynamic> subtasksData = (snapshot['subtasks'] as List) ?? [];
      final List<Subtask> subtasks =
          subtasksData.map((data) => Subtask.fromMap(data)).toList();

      return Todo(
        task: snapshot['task'] as String,
        key: snapshot['key'] as String,
        subtasks: subtasks,
        createDate: DateTime.parse(snapshot['createDate'] as String),
        endDate: DateTime.parse(snapshot['endDate'] as String),
        status: snapshot['status'] as String,
        tag: snapshot['tag'] as TagType,
      );
    }).toList();
  }

  Future<void> addTodo(Todo todo) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('key', todo.key));
    final snapshot = await store.findFirst(_database, finder: finder);

    if (snapshot == null) {
      await store.add(_database, todo.toMap());
    } else {
      await store.record(snapshot.key).update(_database, todo.toMap());
    }

    // Ensure the database is closed after the operation
    await _database.close();
  }

  Future<void> updateTodoInDatabase(Todo updatedTodo) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('key', updatedTodo.key));
    final snapshot = await store.findFirst(_database, finder: finder);

    if (snapshot != null) {
      await store.record(snapshot.key).update(_database, updatedTodo.toMap());
    }

    // Ensure the database is closed after the operation
    await _database.close();
  }
}
