import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AddEditTodoBottomSheet.dart';
import 'model/Todo.dart';
import 'viewmodel/TodoViewModel.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<TagType>> tagTypesFuture;
  TextEditingController _tagTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTodos();
    _fetchAllTagTypes();
    tagTypesFuture = _fetchAllTagTypes();
  }

  Future<void> _fetchTodos() async {
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);

    try {
      await todoViewModel.syncWithServer();
    } catch (error) {
      print('Error fetching todos: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              height: 50,
              child: Consumer<TodoViewModel>(
                builder: (context, viewModel, child) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.tags.length,
                    itemBuilder: (context, index) {
                      final tag = viewModel.tags[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(children: [
                            const Icon(Icons.tag),
                            Text(
                              tag.tagName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            )
                          ]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Consumer<TodoViewModel>(
              builder: (context, viewModel, child) {
                return Padding(
                  padding: const EdgeInsets.all(0),
                  child: ListView.builder(
                    itemCount: viewModel.todos.length,
                    itemBuilder: (context, index) {
                      final todo = viewModel.todos[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ExpansionTile(
                          initiallyExpanded: false,
                          title: Row(
                            children: [
                              Checkbox(
                                visualDensity: VisualDensity.compact,
                                checkColor: Colors.green,
                                fillColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  // If the button is pressed, return green, otherwise blue
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.white;
                                  }
                                  return Colors.white;
                                }),
                                value: todo.status == 'completed',
                                onChanged: (value) {
                                  if (value != null && value) {
                                    viewModel.completeTodo(todo);
                                  } else {
                                    viewModel.updateTodoStatus(todo, 'pending');
                                  }
                                },
                              ),
                              Flexible(
                                child: Text(
                                  todo.task,
                                  style: TextStyle(
                                    overflow: TextOverflow.fade,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
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
                              )
                            ],
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var subtaskIndex = 0;
                                    subtaskIndex < todo.subtasks.length;
                                    subtaskIndex++)
                                  Row(
                                    children: [
                                      Checkbox(
                                        visualDensity: VisualDensity.compact,
                                        checkColor: Colors.green,
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                                (states) {
                                          // If the button is pressed, return green, otherwise blue
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return Colors.white;
                                          }
                                          return Colors.white;
                                        }),
                                        value: todo
                                            .subtasks[subtaskIndex].completed,
                                        onChanged: (value) {
                                          todo.subtasks[subtaskIndex]
                                              .completed = value ?? false;
                                          viewModel.updateTodo(todo,
                                              todo.subtasks[subtaskIndex]);
                                        },
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          text:
                                              todo.subtasks[subtaskIndex].task,
                                          style: TextStyle(
                                            color: todo.subtasks[subtaskIndex]
                                                        .completed ==
                                                    true
                                                ? Colors.green
                                                : Colors.grey,
                                            decoration: todo
                                                        .subtasks[subtaskIndex]
                                                        .completed ==
                                                    true
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          'Tag: ${"${todo.tag.tagName}\n"}Date: ${todo.createDate.day}-${todo.endDate.day}'),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _editTodo(context, todo);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteTodo(context, todo);
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  elevation: 5.0,
                  isExtended: true,
                  onPressed: () {
                    _showAddEditTodoBottomSheet(context, null);
                  },
                  child: Icon(
                      color: Theme.of(context).primaryColor, Icons.add_task),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditTodoBottomSheet(BuildContext context, Todo? todo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddEditTodoBottomSheet(
          todo: todo,
          onUpdateTodo: (updatedTodo) {
            final todoViewModel =
                Provider.of<TodoViewModel>(context, listen: false);
            todoViewModel.updateTodoStatus(updatedTodo, updatedTodo.status);
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

  _showAddTagTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Tag'),
          content: TextField(
            controller: _tagTypeController, // Use a TextEditingController
            decoration: InputDecoration(labelText: 'Tag Name'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final newTagType = TagType(
                  tagName: _tagTypeController.text,
                  icon: Icons
                      .tag, // You can set a default icon or let the user choose
                );

                // Call the ViewModel to add the new tag type
                Provider.of<TodoViewModel>(context, listen: false)
                    .addTagType(newTagType);

                Navigator.pop(context);
              },
              child: Text('Create'),
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
      tag: TagType(tagName: tag, icon: Icons.cabin),
    );

    todoViewModel.addTodo(newTodo);
  }

  void _editTodo(BuildContext context, Todo todo) {
    _showAddEditTodoBottomSheet(context, todo);
  }

  void _deleteTodo(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this todo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                final todoViewModel =
                    Provider.of<TodoViewModel>(context, listen: false);
                todoViewModel.deleteTodo(todo);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tagTypeController.dispose();
    super.dispose();
  }
}
