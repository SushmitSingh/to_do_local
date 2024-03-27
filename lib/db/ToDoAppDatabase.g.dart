// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ToDoAppDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorToDoAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ToDoAppDatabaseBuilder databaseBuilder(String name) =>
      _$ToDoAppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ToDoAppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$ToDoAppDatabaseBuilder(null);
}

class _$ToDoAppDatabaseBuilder {
  _$ToDoAppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$ToDoAppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$ToDoAppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<ToDoAppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$ToDoAppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$ToDoAppDatabase extends ToDoAppDatabase {
  _$ToDoAppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TodoDao? _todoDaoInstance;

  TagTypeDao? _tagTypeDaoInstance;

  SubtaskDao? _subtaskDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Todo` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `task` TEXT NOT NULL, `key` TEXT NOT NULL, `todoDate` INTEGER NOT NULL, `status` TEXT NOT NULL, `tagId` INTEGER NOT NULL, `subtasks` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TagType` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `tagName` TEXT NOT NULL, `iconCodePoint` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Subtask` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `task` TEXT NOT NULL, `completed` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TodoDao get todoDao {
    return _todoDaoInstance ??= _$TodoDao(database, changeListener);
  }

  @override
  TagTypeDao get tagTypeDao {
    return _tagTypeDaoInstance ??= _$TagTypeDao(database, changeListener);
  }

  @override
  SubtaskDao get subtaskDao {
    return _subtaskDaoInstance ??= _$SubtaskDao(database, changeListener);
  }
}

class _$TodoDao extends TodoDao {
  _$TodoDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _todoInsertionAdapter = InsertionAdapter(
            database,
            'Todo',
            (Todo item) => <String, Object?>{
                  'id': item.id,
                  'task': item.task,
                  'key': item.key,
                  'todoDate': item.todoDate,
                  'status': item.status,
                  'tagId': item.tagId,
                  'subtasks': _subtaskConverter.encode(item.subtasks)
                }),
        _todoUpdateAdapter = UpdateAdapter(
            database,
            'Todo',
            ['id'],
            (Todo item) => <String, Object?>{
                  'id': item.id,
                  'task': item.task,
                  'key': item.key,
                  'todoDate': item.todoDate,
                  'status': item.status,
                  'tagId': item.tagId,
                  'subtasks': _subtaskConverter.encode(item.subtasks)
                }),
        _todoDeletionAdapter = DeletionAdapter(
            database,
            'Todo',
            ['id'],
            (Todo item) => <String, Object?>{
                  'id': item.id,
                  'task': item.task,
                  'key': item.key,
                  'todoDate': item.todoDate,
                  'status': item.status,
                  'tagId': item.tagId,
                  'subtasks': _subtaskConverter.encode(item.subtasks)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Todo> _todoInsertionAdapter;

  final UpdateAdapter<Todo> _todoUpdateAdapter;

  final DeletionAdapter<Todo> _todoDeletionAdapter;

  @override
  Future<List<Todo>> getAllTodos() async {
    return _queryAdapter.queryList('SELECT * FROM Todo',
        mapper: (Map<String, Object?> row) => Todo(
            id: row['id'] as int?,
            task: row['task'] as String,
            key: row['key'] as String,
            todoDate: row['todoDate'] as int,
            status: row['status'] as String,
            tagId: row['tagId'] as int,
            subtasks: _subtaskConverter.decode(row['subtasks'] as String)));
  }

  @override
  Future<List<Todo>> getTodosByTag(int tagId) async {
    return _queryAdapter.queryList('SELECT * FROM Todo WHERE tagId = ?1',
        mapper: (Map<String, Object?> row) => Todo(
            id: row['id'] as int?,
            task: row['task'] as String,
            key: row['key'] as String,
            todoDate: row['todoDate'] as int,
            status: row['status'] as String,
            tagId: row['tagId'] as int,
            subtasks: _subtaskConverter.decode(row['subtasks'] as String)),
        arguments: [tagId]);
  }

  @override
  Future<List<Todo>> getTodosByDate(int date) async {
    return _queryAdapter.queryList('SELECT * FROM Todo WHERE todoDate = ?1',
        mapper: (Map<String, Object?> row) => Todo(
            id: row['id'] as int?,
            task: row['task'] as String,
            key: row['key'] as String,
            todoDate: row['todoDate'] as int,
            status: row['status'] as String,
            tagId: row['tagId'] as int,
            subtasks: _subtaskConverter.decode(row['subtasks'] as String)),
        arguments: [date]);
  }

  @override
  Future<void> insertTodo(Todo todo) async {
    await _todoInsertionAdapter.insert(todo, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await _todoUpdateAdapter.update(todo, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    await _todoDeletionAdapter.delete(todo);
  }
}

class _$TagTypeDao extends TagTypeDao {
  _$TagTypeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _tagTypeInsertionAdapter = InsertionAdapter(
            database,
            'TagType',
            (TagType item) => <String, Object?>{
                  'id': item.id,
                  'tagName': item.tagName,
                  'iconCodePoint': item.iconCodePoint
                }),
        _tagTypeUpdateAdapter = UpdateAdapter(
            database,
            'TagType',
            ['id'],
            (TagType item) => <String, Object?>{
                  'id': item.id,
                  'tagName': item.tagName,
                  'iconCodePoint': item.iconCodePoint
                }),
        _tagTypeDeletionAdapter = DeletionAdapter(
            database,
            'TagType',
            ['id'],
            (TagType item) => <String, Object?>{
                  'id': item.id,
                  'tagName': item.tagName,
                  'iconCodePoint': item.iconCodePoint
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TagType> _tagTypeInsertionAdapter;

  final UpdateAdapter<TagType> _tagTypeUpdateAdapter;

  final DeletionAdapter<TagType> _tagTypeDeletionAdapter;

  @override
  Future<List<TagType>> getAllTagTypes() async {
    return _queryAdapter.queryList('SELECT * FROM TagType',
        mapper: (Map<String, Object?> row) => TagType(
            id: row['id'] as int?,
            tagName: row['tagName'] as String,
            iconCodePoint: row['iconCodePoint'] as int));
  }

  @override
  Future<void> insertTagType(TagType tagType) async {
    await _tagTypeInsertionAdapter.insert(tagType, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTagType(TagType tagType) async {
    await _tagTypeUpdateAdapter.update(tagType, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTagType(TagType tagType) async {
    await _tagTypeDeletionAdapter.delete(tagType);
  }
}

class _$SubtaskDao extends SubtaskDao {
  _$SubtaskDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _subtaskInsertionAdapter = InsertionAdapter(
            database,
            'Subtask',
            (Subtask item) => <String, Object?>{
                  'id': item.id,
                  'task': item.task,
                  'completed': item.completed ? 1 : 0
                }),
        _subtaskUpdateAdapter = UpdateAdapter(
            database,
            'Subtask',
            ['id'],
            (Subtask item) => <String, Object?>{
                  'id': item.id,
                  'task': item.task,
                  'completed': item.completed ? 1 : 0
                }),
        _subtaskDeletionAdapter = DeletionAdapter(
            database,
            'Subtask',
            ['id'],
            (Subtask item) => <String, Object?>{
                  'id': item.id,
                  'task': item.task,
                  'completed': item.completed ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Subtask> _subtaskInsertionAdapter;

  final UpdateAdapter<Subtask> _subtaskUpdateAdapter;

  final DeletionAdapter<Subtask> _subtaskDeletionAdapter;

  @override
  Future<List<Subtask>> getSubtasksForTodo(int todoId) async {
    return _queryAdapter.queryList('SELECT * FROM Subtask WHERE todoId = ?1',
        mapper: (Map<String, Object?> row) => Subtask(
            id: row['id'] as int?,
            task: row['task'] as String,
            completed: (row['completed'] as int) != 0),
        arguments: [todoId]);
  }

  @override
  Future<void> insertSubtask(Subtask subtask) async {
    await _subtaskInsertionAdapter.insert(subtask, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateSubtask(Subtask subtask) async {
    await _subtaskUpdateAdapter.update(subtask, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteSubtask(Subtask subtask) async {
    await _subtaskDeletionAdapter.delete(subtask);
  }
}

// ignore_for_file: unused_element
final _subtaskConverter = SubtaskConverter();
