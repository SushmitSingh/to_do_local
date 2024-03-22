import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
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
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 50,
              child: Consumer<TodoViewModel>(
                builder: (context, viewModel, child) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.tags.length +
                        2, // Add 2 for the "Add Tag" chips
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        var isSelected =
                            viewModel.selectedTag?.tagName == "all";
                        return GestureDetector(
                          onTap: () {
                            viewModel.setSelectedTag(TagType(
                              tagName: "all",
                              icon: Icons.all_inbox,
                            ));
                          },
                          child: Card(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 1,
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Icon(Icons.all_inbox),
                                  Text(
                                    "All",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      } else if (index <= viewModel.tags.length) {
                        final tag = viewModel.tags[index - 1];
                        final isSelected = viewModel.selectedTag == tag;
                        return GestureDetector(
                          onTap: () {
                            viewModel.setSelectedTag(tag);
                          },
                          child: Card(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Icon(tag.icon),
                                  Text(
                                    tag.tagName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () {
                            _showAddTagTypeDialog(context);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 1,
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    "Add Tag",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.green),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
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
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: ListView.builder(
                    itemCount: viewModel.todos.length,
                    itemBuilder: (context, index) {
                      final todo = viewModel.todos[index];
                      final id = todo.id;
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ExpansionTile(
                          iconColor: Theme.of(context).primaryColor,
                          initiallyExpanded: false,
                          backgroundColor:
                              Theme.of(context).primaryColor.withAlpha(5),
                          shape: const Border(),
                          title: Row(
                            children: [
                              Checkbox(
                                visualDensity: const VisualDensity(
                                    horizontal: -4.0, vertical: -4.0),
                                checkColor: Colors.green,
                                fillColor:
                                    MaterialStateProperty.resolveWith((states) {
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
                                    fontSize: 16,
                                    color: todo.status == 'completed'
                                        ? Colors.green.shade600
                                        : todo.status == 'expired'
                                            ? Colors.red
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
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
                                        focusColor: Colors.grey,
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
                                          viewModel.updateTodo(id!, todo);
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
                                                ? Colors.grey
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5,
                                                            right: 5,
                                                            top: 2,
                                                            bottom: 2),
                                                    child: Icon(
                                                        Icons.signpost_rounded,
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withAlpha(100)),
                                                  ),
                                                  Text(
                                                    todo.tag.tagName,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5,
                                                            right: 5,
                                                            top: 2,
                                                            bottom: 2),
                                                    child: Icon(
                                                        Icons.access_time,
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withAlpha(100)),
                                                  ),
                                                  Text(
                                                    intl.DateFormat.yMMMEd()
                                                        .format(todo.todoDate),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.green.withAlpha(200)),
                                        onPressed: () {
                                          _editTodo(context, todo);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red.withAlpha(200)),
                                        onPressed: () {
                                          _deleteTodo(context, todo);
                                        },
                                      )
                                    ],
                                  ),
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
          )
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

  void _showAddTagTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Tag'),
          content: TextField(
            controller: _tagTypeController,
            decoration: const InputDecoration(labelText: 'Tag Name'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final newTagType = TagType(
                  tagName: _tagTypeController.text,
                  icon: Icons.tag,
                );

                Provider.of<TodoViewModel>(context, listen: false)
                    .addTagType(newTagType);

                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
