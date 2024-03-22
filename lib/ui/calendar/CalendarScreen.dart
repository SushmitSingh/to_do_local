import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../task/AddEditTodoBottomSheet.dart';
import '../task/model/Todo.dart';
import '../task/viewmodel/TodoViewModel.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Todo>> _events;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _events = {}; // Initialize the events map
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            pageAnimationEnabled: true,
            firstDay: DateTime.utc(2022, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                // Fetch todos for the selected date
                Provider.of<TodoViewModel>(context, listen: false)
                    .fetchTodosByDate(selectedDay);
                print(selectedDay);
              });
            },
            eventLoader: (day) {
              // Load events for the specified day from your _events map
              return _events[day] ?? [];
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                // Set the background color for today's date
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                // Set the background color for the selected date
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white, // Set the text color for the selected date
              ),
              todayTextStyle: TextStyle(
                color: Colors.white, // Set the text color for today's date
              ),
              outsideTextStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 12 // Text color for days outside the current month
                  ),
            ),
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(
                color: Colors.black,
                // Set the text color for the calendar title
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              leftChevronIcon: Icon(
                Icons.arrow_left_outlined,
                color: Colors.black, // Set the color for the left chevron icon
              ),
              rightChevronIcon: Icon(
                Icons.arrow_right_outlined,
                color: Colors.black, // Set the color for the right chevron icon
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                  color: Colors.black, // Set the text color for weekdays
                  fontSize: 12),
              weekendStyle: TextStyle(
                  color: Colors.red, // Set the text color for weekends
                  fontSize: 12),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Consumer<TodoViewModel>(
              builder: (context, viewModel, child) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: ListView.builder(
                    itemCount: viewModel.todos.length,
                    itemBuilder: (context, index) {
                      final todo = viewModel.todos[index];
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
                                          viewModel.updateTodo(todo.id!, todo);
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
          ),
        ],
      ),
    );
  }

  void _editTodo(BuildContext context, Todo todo) {
    _showAddEditTodoBottomSheet(context, todo);
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
}
