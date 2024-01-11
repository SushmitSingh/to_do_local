import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/Todo.dart';
import 'viewmodel/TodoViewModel.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);

    try {
      await todoViewModel.syncWithServer();
    } catch (error) {
      print('Error fetching todos: $error');
    }
  }

  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle tap outside the keyboard to dismiss it
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: Consumer<TodoViewModel>(
                builder: (context, viewModel, child) {
                  return ListView.builder(
                    itemCount: viewModel.tags.length,
                    itemBuilder: (context, index) {
                      final tag = viewModel.tags[index];
                      return Card(
                        elevation: 2,
                        child: Text(tag.tagName),
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<TodoViewModel>(
                builder: (context, viewModel, child) {
                  return ListView.builder(
                    itemCount: viewModel.todos.length,
                    itemBuilder: (context, index) {
                      final todo = viewModel.todos[index];
                      return Card(
                        elevation: 2,
                        child: ExpansionTile(
                          initiallyExpanded: false,
                          title: Row(
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: Checkbox(
                                  value: todo.status == 'completed',
                                  onChanged: (value) {
                                    if (value != null && value) {
                                      viewModel.completeTodo(todo);
                                    } else {
                                      viewModel.updateTodoStatus(
                                          todo, 'pending');
                                    }
                                  },
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    todo.task,
                                    style: TextStyle(
                                      letterSpacing: 0.5,
                                      overflow: TextOverflow.fade,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: todo.status == 'completed'
                                          ? Colors.green
                                          : todo.status == 'expired'
                                              ? Colors.red
                                              : Colors.black,
                                      decoration: todo.status == 'completed'
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var subtaskIndex = 0;
                                    subtaskIndex < todo.subtasks.length;
                                    subtaskIndex++)
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 2, bottom: 2),
                                    child: Row(
                                      children: [
                                        Text(
                                          (subtaskIndex + 1).toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: Checkbox(
                                            value: todo.subtasks[subtaskIndex]
                                                .completed,
                                            onChanged: (value) {
                                              todo.subtasks[subtaskIndex]
                                                  .completed = value ?? false;
                                              viewModel.updateSubtaskStatus(
                                                  todo,
                                                  todo.subtasks[subtaskIndex]);
                                            },
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              right: 8,
                                              left: 8),
                                          child: Text.rich(
                                            TextSpan(
                                              text: todo
                                                  .subtasks[subtaskIndex].task,
                                              style: TextStyle(
                                                color:
                                                    todo.subtasks[subtaskIndex]
                                                                .completed ==
                                                            true
                                                        ? Colors.green
                                                        : Colors.grey,
                                                decoration:
                                                    todo.subtasks[subtaskIndex]
                                                                .completed ==
                                                            true
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                            'Tag: ${todo.tag} ,Date: ${todo.createDate}-${todo.endDate}'),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showAddTodoBottomSheet(context);
              },
              child: Text('Add Todo'),
            ),
            ElevatedButton(
              onPressed: () {
                _syncWithServer(context);
              },
              child: Text('Sync with Server'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTodoBottomSheet(BuildContext context) {
    String task = '';
    DateTime createDate = DateTime.now();
    DateTime endDate = DateTime.now();
    String status = 'pending';
    String selectedTag = 'personal'; // Default tag
    List<Subtask> subtasks = [];

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    FocusNode _focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<List<TagType>>(
              future: _fetchAllTagTypes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading tag types');
                } else {
                  List<String> tagTypeNames = snapshot.data
                          ?.map((tagType) => tagType.tagName)
                          .toList() ??
                      [];

                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Add Todo'),
                            TextFormField(
                              key: ValueKey('unique_key_for_textfield'),
                              focusNode: _focusNode,
                              onChanged: (value) {
                                setState(() {
                                  task = value;
                                });
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Task'),
                            ),
                            const SizedBox(height: 8),
                            Text('Create Date: ${createDate.toLocal()}'),
                            ElevatedButton(
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: createDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );

                                if (selectedDate != null &&
                                    selectedDate != createDate) {
                                  setState(() {
                                    createDate = selectedDate;
                                  });
                                }
                              },
                              child: const Text('Select Create Date'),
                            ),
                            const SizedBox(height: 8),
                            Text('End Date: ${endDate.toLocal()}'),
                            ElevatedButton(
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: endDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );

                                if (selectedDate != null &&
                                    selectedDate != endDate) {
                                  setState(() {
                                    endDate = selectedDate;
                                  });
                                }
                              },
                              child: const Text('Select End Date'),
                            ),
                            SizedBox(height: 8),
                            Text('Status'),
                            DropdownButton<String>(
                              value: status,
                              onChanged: (value) {
                                setState(() {
                                  status = value!;
                                });
                              },
                              items: ['pending', 'completed'].map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 8),
                            Text('Tag'),
                            DropdownButton<String>(
                              value: selectedTag,
                              onChanged: (value) {
                                setState(() {
                                  selectedTag = value!;
                                });

                                // If 'Create New Tag' is selected, clear the text field
                                if (selectedTag == 'createNewTag') {
                                  setState(() {
                                    selectedTag = '';
                                  });
                                }
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
                                DropdownMenuItem<String>(
                                  value: 'createNewTag',
                                  child: const Text('Create New Tag'),
                                ),
                              ],
                            ),
                            // If 'Create New Tag' is selected, show a text field to input a new tag name
                            if (selectedTag == 'createNewTag')
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    selectedTag = value;
                                  });
                                },
                                decoration:
                                    InputDecoration(labelText: 'New Tag'),
                              ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                _showAddSubtaskDialog(
                                    context, subtasks, setState);
                              },
                              child: const Text('Add Subtask'),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _saveTodoLocal(
                                  context,
                                  task,
                                  createDate,
                                  endDate,
                                  status,
                                  selectedTag,
                                  subtasks,
                                );

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
              },
            );
          },
        );
      },
    );
  }

  Future<List<TagType>> _fetchAllTagTypes() async {
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    return await todoViewModel.fetchTags();
  }

  void _showAddSubtaskDialog(
    BuildContext context,
    List<Subtask> subtasks,
    Function setState,
  ) {
    String subtaskName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Subtask'),
          content: TextField(
            onChanged: (value) {
              subtaskName = value;
            },
            decoration: InputDecoration(labelText: 'Subtask'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  subtasks.add(Subtask(task: subtaskName, completed: false));
                });
                Navigator.of(context).pop();
              },
              child: Text('Add Subtask'),
            ),
          ],
        );
      },
    );
  }

  void _saveTodoLocal(
    BuildContext context,
    String task,
    DateTime createDate,
    DateTime endDate,
    String status,
    String tag,
    List<Subtask> subtasks,
  ) {
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);

    final newTodo = Todo(
      task: task,
      key: DateTime.now().millisecondsSinceEpoch.toString(),
      subtasks: subtasks,
      createDate: createDate,
      endDate: endDate,
      status: status,
      tag:
          TagType(tagName: tag, icon: Icons.label), // Example: Creating TagType
    );

    todoViewModel.addTodo(newTodo);
  }

  void _syncWithServer(BuildContext context) async {
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);

    try {
      await todoViewModel.syncWithServer();
      _showSnackbar('Synced with server successfully!', context);
    } catch (error) {
      print('Error syncing with server: $error');
      _showSnackbar('Error syncing with server.', context);
    }
  }

  void _showSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
