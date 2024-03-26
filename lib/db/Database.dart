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

  Future<void> _closeDatabase() async {
    await _database.close();
  }

  Future<void> clearDatabase() async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    await store.delete(_database);

    await _closeDatabase();
  }

  Future<void> addTodo(Todo todo) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('key', todo.key));
    final snapshot = await store.findFirst(_database, finder: finder);

    if (snapshot == null) {
      final newTodoId = await store.add(_database, todo.toMap());
      todo.id = newTodoId;
    } else {
      await store.record(snapshot.key).update(_database, todo.toMap());
    }

    await _closeDatabase();
  }

  Future<void> updateTodo(int id, Todo updatedTodo) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('id', id));
    final snapshot = await store.findFirst(_database, finder: finder);

    if (snapshot != null) {
      await store.record(snapshot.key).update(_database, {
        ...updatedTodo.toMap(),
        'tag': updatedTodo.tag.toJson(),
      });
    }

    await _closeDatabase();
  }

  Future<List<Todo>> getAllTodos() async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(sortOrders: [SortOrder('todoDate')]);
    final todosSnapshots = await store.find(_database, finder: finder);

    final todos = todosSnapshots.map((snapshot) {
      final List<dynamic>? subtasksData =
          snapshot['subtasks'] as List<dynamic>?;
      final Map<String, dynamic> tagData =
          snapshot['tag'] as Map<String, dynamic>;
      final TagType tag = TagType.fromMap(tagData);

      final todoDate = snapshot['todoDate'] as String;
      return Todo(
        id: snapshot['id'] as int?,
        task: snapshot['task'] as String,
        key: snapshot['key'] as String,
        subtasks:
            subtasksData?.map((data) => Subtask.fromMap(data)).toList() ?? [],
        todoDate: DateTime.parse(todoDate),
        status: snapshot['status'] as String,
        tag: tag,
        synced: snapshot['synced'] as bool,
      );
    }).toList();

    await _closeDatabase();

    return todos;
  }

  Future<void> deleteTodoFromDatabase(Todo todo) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('key', todo.key));
    final snapshot = await store.findFirst(_database, finder: finder);

    if (snapshot != null) {
      await store.record(snapshot.key).delete(_database);
    }

    await _closeDatabase();
  }

  Future<List<Todo>> getTodosByTagName(String selectedTag) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('tag.tagName', selectedTag));
    final todosSnapshots = await store.find(_database, finder: finder);

    await _closeDatabase();

    return todosSnapshots.map((snapshot) {
      final List<dynamic> subtasksData = (snapshot['subtasks'] as List) ?? [];
      final List<Subtask> subtasks =
          subtasksData.map((data) => Subtask.fromMap(data)).toList();

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

  Future<List<Todo>> getTodosByDate(DateTime selectedDate) async {
    await _initializeDatabase();

    final DateTime selectedDateTime =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(
      filter: Filter.or([
        Filter.equals('todoDate', selectedDateTime.toIso8601String()),
        Filter.and([
          Filter.greaterThanOrEquals(
              'todoDate', selectedDateTime.toIso8601String()),
          Filter.lessThanOrEquals('endDate',
              selectedDateTime.add(const Duration(days: 1)).toIso8601String()),
        ]),
      ]),
    );
    final todosSnapshots = await store.find(_database, finder: finder);

    await _closeDatabase();

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

  Future<void> addTagType(TagType tagType) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('tagName', tagType.tagName));
    final existingTag = await store.findFirst(_database, finder: finder);

    if (existingTag == null) {
      await store.add(_database, tagType.toMap());
    }

    await _closeDatabase();
  }

  Future<List<TagType>> getAllTagTypes() async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final tagSnapshots = await store.find(_database);

    final tagSet = <String, TagType>{};

    tagSnapshots.forEach((snapshot) {
      final Map<String, dynamic>? tagData =
          snapshot.value['tag'] as Map<String, dynamic>?;

      if (tagData != null) {
        final tag = TagType.fromMap(tagData);
        tagSet[tag.tagName] = tag;
      }
    });

    await _closeDatabase();

    return tagSet.values.toList();
  }
}
