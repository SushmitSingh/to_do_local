import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_local/ui/task/viewmodel/TodoViewModel.dart';

import 'model/Todo.dart';

class AddEditTodoBottomSheet extends StatefulWidget {
  final Todo? todo;
  final Function(Todo) onUpdateTodo;

  AddEditTodoBottomSheet({Key? key, this.todo, required this.onUpdateTodo})
      : super(key: key);

  @override
  _AddEditTodoBottomSheetState createState() => _AddEditTodoBottomSheetState();
}

class _AddEditTodoBottomSheetState extends State<AddEditTodoBottomSheet> {
  final TextEditingController _tagTypeController = TextEditingController();
  String task = '';
  DateTime todoDate = DateTime.now();
  String status = 'pending';
  late TagType selectedTag;
  List<Subtask> subtasks = [];
  late int id;

  String get _todoTitle {
    if (widget.todo != null) {
      return "Edit Todo";
    } else {
      return "Create New";
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      id = widget.todo!.id!;
      task = widget.todo!.task;
      todoDate = DateTime.fromMillisecondsSinceEpoch(widget.todo!.todoDate);
      status = widget.todo!.status;
      selectedTag = TagType(
          tagName: widget.todo!.tagId.toString(),
          iconCodePoint: widget.todo!.tagId);
      subtasks.addAll(widget.todo!.subtasks);
    } else {
      selectedTag = TagType(
        tagName: "Regular",
        iconCodePoint: Icons.add.codePoint,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _todoTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: task,
                onChanged: (value) {
                  task = value;
                },
                decoration: const InputDecoration(labelText: 'Task'),
              ),
              const SizedBox(height: 20),
              const Text("Subtask"),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ...subtasks.map((subtask) {
                    return Chip(
                      label: Text(subtask.task),
                      onDeleted: () {
                        setState(() {
                          subtasks.remove(subtask);
                        });
                      },
                    );
                  }).toList(),
                  Chip(
                    deleteIcon: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                    label: const Text("Add"),
                    onDeleted: () {
                      setState(() {
                        _showAddSubtaskDialog(context);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Status'),
                        DropdownButton<String>(
                          value: status,
                          onChanged: (value) {
                            setState(() {
                              status = value!;
                            });
                          },
                          items:
                              ['pending', 'completed', 'other'].map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Tag'),
                        FutureBuilder<List<TagType>>(
                          future: _fetchAllTagTypes(context),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<TagType> tagTypeNames = snapshot.data!
                                  .map((tagType) => tagType)
                                  .toList();

                              return DropdownButton<TagType>(
                                value: selectedTag,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTag = value!;
                                  });
                                },
                                items: [
                                  ...tagTypeNames.map((tagType) {
                                    return DropdownMenuItem<TagType>(
                                      value: tagType,
                                      child: Text(tagType.tagName),
                                    );
                                  }),
                                  if (!tagTypeNames.contains(selectedTag))
                                    DropdownMenuItem<TagType>(
                                      value: selectedTag,
                                      child: Text(selectedTag.tagName),
                                    ),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return const Text('Error loading tag types');
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text('Remind Date: ${todoDate.toLocal()}'),
              ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: todoDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (selectedDate != null && selectedDate != todoDate) {
                      setState(() {
                        todoDate = selectedDate;
                      });
                    }
                  },
                  child: Text(
                    'Select Remind Date',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    _saveTodo();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Save Locally',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<TagType>> _fetchAllTagTypes(BuildContext context) async {
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    return await todoViewModel.fetchTags();
  }

  void _saveTodo() {
    final newTodo = Todo(
      task: task,
      key: widget.todo?.key ?? DateTime.now().millisecondsSinceEpoch.toString(),
      subtasks: subtasks,
      todoDate: todoDate.millisecond,
      status: status,
      tagId: selectedTag.id!,
    );

    widget.onUpdateTodo(newTodo);
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);

    if (_todoTitle != "Create New") {
      // Assuming `id` is the index of the subtask you want to update
      todoViewModel.updateTodo(id, newTodo);
    } else {
      todoViewModel.addTodo(newTodo);
    }
  }

  void _showAddSubtaskDialog(BuildContext context) {
    String subtaskName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Subtask'),
          content: TextField(
            onChanged: (value) {
              subtaskName = value;
            },
            decoration: const InputDecoration(labelText: 'Subtask'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  subtasks.add(Subtask(task: subtaskName, completed: false));
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Add Subtask',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
