import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import '../ui/task/model/Todo.dart';

class DatabaseProvider {
  final String _todosStoreName = 'todos';
  final DatabaseFactory _dbFactory = databaseFactoryIo;
  late Database _database;

  Future<void> _initializeDatabase() async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = '${appDocumentsDirectory.path}/todos_store.db';

    _database = await _dbFactory.openDatabase(dbPath);
  }

  Future<List<Todo>> getAllTodos() async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(sortOrders: [SortOrder('todoDate')]);
    final todosSnapshots = await store.find(_database, finder: finder);

    // Ensure the database is closed after fetching data
    await _database.close();

    return todosSnapshots.map((snapshot) {
      final List<dynamic>? subtasksData =
          snapshot['subtasks'] as List<dynamic>?;

      // Ensure subtasksData is not null before using it
      final List<Subtask> subtasks = (subtasksData ?? []).map((data) {
        // Handle null values in subtask data
        return Subtask.fromMap(data as Map<String, dynamic>);
      }).toList();

      return Todo(
          task: snapshot['task'] as String? ?? "",
          key: snapshot['key'] as String? ?? "",
          subtasks: subtasks,
          todoDate: DateTime.parse(snapshot['todoDate'] as String? ?? ""),
          status: snapshot['status'] as String? ?? "",
          tag: TagType.fromMap(snapshot['tag'] as Map<String, dynamic>?));
    }).toList();
  }

  Future<List<TagType>> getAllTagTypes() async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final tagSnapshots = await store.find(_database);

    await _database.close();

    // Use a Set to store unique TagType objects
    final tagSet = <String, TagType>{};

    tagSnapshots.forEach((snapshot) {
      final Map<String, dynamic>? tagData =
          snapshot['tag'] as Map<String, dynamic>?;

      if (tagData != null) {
        final tag = TagType.fromMap(tagData);
        tagSet[tag.tagName] = tag;
      }
    });

    // Convert the Set to a List and return
    return tagSet.values.toList();
  }

  Future<List<Todo>> getTodosByTagName(String selectedTag) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('tag.tagName', selectedTag));
    final todosSnapshots = await store.find(_database, finder: finder);

    // Ensure the database is closed after fetching data
    await _database.close();

    return todosSnapshots.map((snapshot) {
      final List<dynamic> subtasksData = (snapshot['subtasks'] as List) ?? [];
      final List<Subtask> subtasks =
          subtasksData.map((data) => Subtask.fromMap(data)).toList();

      // Deserialize TagType object
      final Map<String, dynamic> tagData =
          snapshot['tag'] as Map<String, dynamic>;
      final TagType tag = TagType.fromJson(tagData);

      return Todo(
        task: snapshot['task'] as String,
        key: snapshot['key'] as String,
        subtasks: subtasks,
        todoDate: DateTime.parse(snapshot['todoDate'] as String),
        status: snapshot['status'] as String,
        tag: tag,
      );
    }).toList();
  }

  Future<List<Todo>> geTTodosByDate(DateTime selectedDate) async {
    await _initializeDatabase();

    // Assuming selectedDate is a DateTime object
    final DateTime selectedDateTime =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(
      filter: Filter.or([
        Filter.equals('todoDate', selectedDateTime.toIso8601String()),
        Filter.equals('endDate', selectedDateTime.toIso8601String()),
        Filter.and([
          Filter.greaterThanOrEquals(
              'todoDate', selectedDateTime.toIso8601String()),
          Filter.lessThanOrEquals('endDate',
              selectedDateTime.add(const Duration(days: 1)).toIso8601String()),
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
        todoDate: DateTime.parse(snapshot['todoDate'] as String),
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
      await store.add(_database, _todoToMap(todo));
    } else {
      await store.record(snapshot.key).update(_database, _todoToMap(todo));
    }

    // Ensure the database is closed after the operation
    await _database.close();
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('key', updatedTodo.key));
    final snapshot = await store.findFirst(_database, finder: finder);

    if (snapshot != null) {
      await store.record(snapshot.key).update(_database, {
        ...updatedTodo.toMap(),
        'tag': updatedTodo.tag.toJson(), // Convert TagType to JSON
      });
    }

    // Ensure the database is closed after the operation
    await _database.close();
  }

  Future<void> addTagType(TagType tagType) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    await store.add(_database, {'tag': tagType.toMap()});

    // Ensure the database is closed after the operation
    await _database.close();
  }

  Future<void> deleteTodoFromDatabase(Todo todo) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('key', todo.key));
    final snapshot = await store.findFirst(_database, finder: finder);

    if (snapshot != null) {
      await store.record(snapshot.key).delete(_database);
    }

    await _database.close();
  }

  Map<String, dynamic> _todoToMap(Todo todo) {
    return {
      'task': todo.task,
      'key': todo.key,
      'subtasks': todo.subtasks.map((subtask) => subtask.toMap()).toList(),
      'todoDate': todo.todoDate.toIso8601String(),
      'status': todo.status,
      'tag':
          todo.tag.toJson(), // Convert TagType to a format suitable for storage
      'synced': todo.synced,
    };
  }
}
