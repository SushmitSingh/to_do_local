import 'package:flutter/cupertino.dart';

class TagType {
  int? id; // Add id field

  final String tagName;
  IconData icon;

  TagType({
    this.id, // Add id parameter
    required this.tagName,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagName': tagName,
      'icon': icon.codePoint,
    };
  }

  factory TagType.fromMap(Map<String, dynamic>? map) {
    return TagType(
      id: map?['id'] as int?,
      tagName: map?['tagName'] as String? ?? '',
      icon: IconData(map?['icon'] as int? ?? 0, fontFamily: 'MaterialIcons'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagName': tagName,
      'icon': icon.codePoint,
    };
  }

  factory TagType.fromJson(Map<String, dynamic> json) {
    return TagType(
      tagName: json['tagName'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
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
  int? id; // Add id field

  final String task;
  final String key;
  late final List<Subtask> subtasks;
  final DateTime todoDate;
  late final String status;
  final TagType tag;
  bool synced; // Added synced property

  Todo({
    this.id, // Add id parameter
    required this.task,
    required this.key,
    required this.subtasks,
    required this.todoDate,
    required this.status,
    required this.tag,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'key': key,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
      'todoDate': todoDate.toIso8601String(),
      'status': status,
      'tag': tag.toMap(),
      'synced': synced, // Include synced property in the map
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      task: map['task'] as String,
      key: map['key'] as String,
      subtasks: (map['subtasks'] as List)
          .map((data) => Subtask.fromMap(data))
          .toList(),
      todoDate: DateTime.parse(map['todoDate'] as String),
      status: map['status'] as String,
      tag: TagType.fromMap(map['tag'] as Map<String, dynamic>?),
      synced: map['synced'] as bool, // Extract synced property from the map
    );
  }
}
