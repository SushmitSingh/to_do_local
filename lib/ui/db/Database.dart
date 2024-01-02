import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import '../task/model/Todo.dart';

class DatabaseProvider {
  final String _todosStoreName = 'todos';
  final String _subtasksStoreName = 'subtasks';
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
        tag: snapshot['tag'] as String,
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
  }

  Future<void> updateTodoInDatabase(Todo updatedTodo) async {
    await _initializeDatabase();

    final store = intMapStoreFactory.store(_todosStoreName);
    final finder = Finder(filter: Filter.equals('key', updatedTodo.key));
    final snapshot = await store.findFirst(_database, finder: finder);

    if (snapshot != null) {
      await store.record(snapshot.key).update(_database, updatedTodo.toMap());
    }
  }
}
