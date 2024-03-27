import 'package:floor/floor.dart';

import '../ui/task/model/Todo.dart';

@dao
abstract class TodoDao {
  @Query('SELECT * FROM Todo')
  Future<List<Todo>> getAllTodos();

  @Query('SELECT * FROM Todo WHERE tagId = :tagId')
  Future<List<Todo>> getTodosByTag(int tagId);

  @Query('SELECT * FROM Todo WHERE todoDate = :date')
  Future<List<Todo>> getTodosByDate(int date);

  @insert
  Future<void> insertTodo(Todo todo);

  @update
  Future<void> updateTodo(Todo todo);

  @delete
  Future<void> deleteTodo(Todo todo);
}

@dao
abstract class TagTypeDao {
  @Query('SELECT * FROM TagType')
  Future<List<TagType>> getAllTagTypes();

  @insert
  Future<void> insertTagType(TagType tagType);

  @update
  Future<void> updateTagType(TagType tagType);

  @delete
  Future<void> deleteTagType(TagType tagType);
}

@dao
abstract class SubtaskDao {
  @Query('SELECT * FROM Subtask WHERE todoId = :todoId')
  Future<List<Subtask>> getSubtasksForTodo(int todoId);

  @insert
  Future<void> insertSubtask(Subtask subtask);

  @update
  Future<void> updateSubtask(Subtask subtask);

  @delete
  Future<void> deleteSubtask(Subtask subtask);
}
