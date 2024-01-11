import 'package:flutter/cupertino.dart';

class TagType {
  final String tagName;
  IconData icon;

  TagType({
    required this.tagName,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'tagName': tagName,
      'icon': icon.codePoint,
    };
  }

  factory TagType.fromMap(Map<String, dynamic> map) {
    return TagType(
      tagName: map['tagName'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
    );
  }
}

class Subtask {
  final String task;
  bool completed;

  Subtask({
    required this.task,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'completed': completed,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      task: map['task'] as String,
      completed: map['completed'] as bool? ?? false,
    );
  }
}

class Todo {
  final String task;
  final String key;
  final List<Subtask> subtasks;
  final DateTime createDate;
  final DateTime endDate;
  late final String status;
  final TagType tag;
  bool synced; // Added synced property

  Todo({
    required this.task,
    required this.key,
    required this.subtasks,
    required this.createDate,
    required this.endDate,
    required this.status,
    required this.tag,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'key': key,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
      'createDate': createDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'tag': tag,
      'synced': synced, // Include synced property in the map
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      task: map['task'] as String,
      key: map['key'] as String,
      subtasks: (map['subtasks'] as List)
          .map((data) => Subtask.fromMap(data))
          .toList(),
      createDate: DateTime.parse(map['createDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      status: map['status'] as String,
      tag: map['tag'] as TagType,
      synced: map['synced'] as bool, // Extract synced property from the map
    );
  }
}
