import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
              height: 40,
              child: Consumer<TodoViewModel>(
                builder: (context, viewModel, child) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.tags.length +
                        1, // Add 2 for the "Add Tag" chips
                    itemBuilder: (context, index) {
                      if (index <= viewModel.tags.length - 1) {
                        final tag = viewModel.tags[index];
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
                                  Icon(
                                    IconData(tag.iconCodePoint,
                                        fontFamily: 'MaterialIcons'),
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    tag.tagName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
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
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.yellow,
                                ),
                                Text(
                                  "Add Tag",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.yellow),
                                )
                              ],
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
                                value: todo.status,
                                onChanged: (value) {
                                  viewModel.updateTodo(
                                    Todo(
                                      id: id,
                                      task: todo.task,
                                      key: todo.key,
                                      todoDate: todo.todoDate,
                                      status: value ?? false,
                                      tagId: todo.tagId,
                                      subtasks: todo.subtasks,
                                    ),
                                  );
                                  //update the status of the todo
                                  setState(() {
                                    todo.status = value ?? false;
                                  });
                                },
                              ),
                              Flexible(
                                child: Text(
                                  todo.task,
                                  style: TextStyle(
                                    overflow: TextOverflow.fade,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: todo.status
                                        ? Colors.grey
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                    decoration: todo.status == true
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
                                          viewModel.updateTodo(todo);
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
                                                    todo.tagId.toString(),
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
                                                    todo.todoDate.toString(),
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
    IconData selectedIcon = Icons.tag;
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    List<IconData> iconDataList = todoViewModel.getIconDataList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Tag'),
          content: Row(
            children: [
              Container(
                width: 280, // Set the width as needed
                height: 400, // Set the height as needed
                child: Scrollable(
                  scrollBehavior: const MaterialScrollBehavior(),
                  viewportBuilder:
                      (BuildContext context, ViewportOffset position) {
                    return Column(
                      children: [
                        TextField(
                          controller: _tagTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Tag Name',
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                          ),
                          itemCount: iconDataList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Set the selected item with  color to the primary color
                                setState(() {
                                  selectedIcon = iconDataList[index];
                                });
                              },
                              child: Icon(
                                iconDataList[index],
                                color: selectedIcon == iconDataList[index]
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final newTagType = TagType(
                  tagName: _tagTypeController.text,
                  iconCodePoint: selectedIcon.codePoint,
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
