import 'dart:convert';

import 'package:floor/floor.dart';

import '../ui/task/model/Todo.dart';

class SubtaskListConverter extends TypeConverter<List<Subtask>, String> {
  @override
  List<Subtask> decode(String databaseValue) {
    List<dynamic> list = json.decode(databaseValue);
    return list.map((e) => Subtask.fromJson(e)).toList();
  }

  @override
  String encode(List<Subtask> value) {
    return json.encode(value.map((e) => e.toJson()).toList());
  }
}
