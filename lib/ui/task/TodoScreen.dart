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
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
        children: [
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
                                    viewModel.updateTodoStatus(todo, 'pending');
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var subtask in todo.subtasks)
                                Container(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: Checkbox(
                                          value: subtask.completed,
                                          onChanged: (value) {
                                            subtask.completed = value ?? false;
                                            viewModel.updateSubtaskStatus(
                                                todo, subtask);
                                          },
                                        ),
                                      ),
                                      Text(
                                        '${subtask.task}: ${subtask.completed}',
                                        style: TextStyle(
                                            color: subtask.completed == true
                                                ? Colors.green
                                                : Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                padding: EdgeInsets.only(left: 8, top: 4),
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
    );
  }

  void _showAddTodoBottomSheet(BuildContext context) {
    String task = '';
    DateTime createDate = DateTime.now();
    DateTime endDate = DateTime.now();
    String status = 'pending';
    String tag = 'personal';
    List<Subtask> subtasks = [];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Todo'),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          task = value;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Task'),
                    ),
                    SizedBox(height: 8),
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
                      child: Text('Select Create Date'),
                    ),
                    SizedBox(height: 8),
                    Text('End Date: ${endDate.toLocal()}'),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );

                        if (selectedDate != null && selectedDate != endDate) {
                          setState(() {
                            endDate = selectedDate;
                          });
                        }
                      },
                      child: Text('Select End Date'),
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
                      value: tag,
                      onChanged: (value) {
                        setState(() {
                          tag = value!;
                        });
                      },
                      items: ['personal', 'work', 'others'].map((tag) {
                        return DropdownMenuItem<String>(
                          value: tag,
                          child: Text(tag),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        _showAddSubtaskDialog(context, subtasks, setState);
                      },
                      child: Text('Add Subtask'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Save logic...
                        print('Task: $task');
                        print('Create Date: $createDate');
                        print('End Date: $endDate');
                        print('Status: $status');
                        print('Tag: $tag');
                        print('Subtasks: $subtasks');

                        // Call the save function
                        _saveTodoLocal(
                          context,
                          task,
                          createDate,
                          endDate,
                          status,
                          tag,
                          subtasks,
                        );

                        Navigator.of(context).pop();
                      },
                      child: Text('Save Locally'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
      tag: tag,
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
