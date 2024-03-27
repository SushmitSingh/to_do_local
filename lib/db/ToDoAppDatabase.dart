import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../ui/task/model/Todo.dart';
import 'TagTypeDao.dart';

part 'ToDoAppDatabase.g.dart';

@TypeConverters([SubtaskConverter])
@Database(version: 1, entities: [Todo, TagType, Subtask])
abstract class ToDoAppDatabase extends FloorDatabase {
  TodoDao get todoDao;

  TagTypeDao get tagTypeDao;

  SubtaskDao get subtaskDao;
}
