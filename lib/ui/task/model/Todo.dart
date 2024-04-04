import 'package:floor/floor.dart';

import '../../../db/SubtaskListConverter.dart';

@entity
class Todo {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String task;
  final String key;
  final int todoDate;
  final String status;
  final int tagId; // Reference to TagType
  @TypeConverters([SubtaskListConverter])
  final List<Subtask> subtasks;

  Todo({
    this.id,
    required this.task,
    required this.key,
    required this.todoDate,
    required this.status,
    required this.tagId,
    this.subtasks = const [],
  });
}

@entity
class TagType {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String tagName;
  final int iconCodePoint;

  TagType({
    this.id,
    required this.tagName,
    required this.iconCodePoint,
  });
}

@entity
class Subtask {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String task;
  bool completed;

  Subtask({
    this.id,
    required this.task,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'completed': completed,
    };
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      task: json['task'],
      completed: json['completed'],
    );
  }
}
