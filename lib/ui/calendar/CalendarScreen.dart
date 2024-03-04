import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bin/server.dart';
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
              formatButtonDecoration: BoxDecoration(
                color: Colors.orange,
                // Set the background color for the format button
                shape: BoxShape.rectangle,
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white, // Set the text color for the format button
              ),
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
                                padding: const EdgeInsets.only(left: 8),
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
                                          value: todo
                                              .subtasks[subtaskIndex].completed,
                                          onChanged: (value) {
                                            todo.subtasks[subtaskIndex]
                                                .completed = value ?? false;
                                            viewModel.updateSubtaskStatus(todo,
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
                                              color: todo.subtasks[subtaskIndex]
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
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                          'Tag: ${todo.tag}, Date: ${todo.createDate}-${todo.endDate}'),
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
        ],
      ),
    );
  }
}
