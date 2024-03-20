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
  late String selectedTag;
  List<Subtask> subtasks = [];

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
      task = widget.todo!.task;
      todoDate = widget.todo!.todoDate;
      status = widget.todo!.status;
      selectedTag = widget.todo!.tag.tagName;
      subtasks.addAll(widget.todo!.subtasks);
    } else {
      selectedTag = "Select A Tag";
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
                  fontSize: 16,
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
                    color: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.green;
                      }
                      return Colors.blue;
                    }),
                    deleteIcon: Icon(Icons.add),
                    label: Text("Add"),
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
                              List<String> tagTypeNames = snapshot.data!
                                  .map((tagType) => tagType.tagName)
                                  .toList();

                              return DropdownButton<String>(
                                value: selectedTag,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTag = value!;
                                  });
                                },
                                items: [
                                  ...tagTypeNames.map((tagName) {
                                    return DropdownMenuItem<String>(
                                      value: tagName,
                                      child: Text(tagName),
                                    );
                                  }),
                                  if (!tagTypeNames.contains(selectedTag))
                                    DropdownMenuItem<String>(
                                      value: selectedTag,
                                      child: Text(selectedTag),
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
                child: const Text('Select Remind Date'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveTodo();
                  Navigator.of(context).pop();
                },
                child: const Text('Save Locally'),
              ),
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
      todoDate: todoDate,
      status: status,
      tag: TagType(tagName: selectedTag, icon: Icons.cabin),
    );

    widget.onUpdateTodo(newTodo);
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);

    if (_todoTitle == "Create New") {
      todoViewModel.updateTodo(newTodo, newTodo.subtasks as Subtask);
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  subtasks.add(Subtask(task: subtaskName, completed: false));
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add Subtask'),
            ),
          ],
        );
      },
    );
  }
}
