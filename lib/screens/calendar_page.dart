import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/assignment.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);
    final assignments = provider.getAllAssignments();
    final courses = provider.courses;

    // Group assignments by due date
    Map<DateTime, List<Assignment>> assignmentMap = {};
    for (var a in assignments) {
      final date = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      assignmentMap.putIfAbsent(date, () => []).add(a);
    }

    List<Assignment> _getAssignmentsForDay(DateTime day) {
      final key = DateTime(day.year, day.month, day.day);
      return assignmentMap[key] ?? [];
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 32, left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Calendar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getAssignmentsForDay,
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              outsideDaysVisible: true,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                final dots = events.take(3).map((e) {
                  final assignment = e as Assignment;
                  final course = courses.firstWhere(
                    (c) => c.id == assignment.courseId,
                    orElse: () => Course(id: '', name: 'Unknown', description: '', color: Colors.grey),
                  );

                  final isCompleted = assignment.status == TaskStatus.done;

                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.grey : course.color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList();

                return Row(mainAxisAlignment: MainAxisAlignment.center, children: dots);
              },
            ),
          ),
        ),
        if (_selectedDay != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(builder: (_) {
                final selectedAssignments = _getAssignmentsForDay(_selectedDay!);
                if (selectedAssignments.isEmpty) {
                  return const Center(child: Text("No assignments due."));
                }

                return ListView.builder(
                  itemCount: selectedAssignments.length,
                  itemBuilder: (context, index) {
                    final a = selectedAssignments[index];
                    final course = courses.firstWhere(
                      (c) => c.id == a.courseId,
                      orElse: () => Course(id: '', name: 'Unknown', description: '', color: Colors.grey),
                    );

                    final isCompleted = a.status == TaskStatus.done;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: course.color,
                        radius: 6,
                        child: isCompleted
                            ? const Icon(Icons.check, size: 10, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        a.title,
                        style: TextStyle(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text(
                        'Due: ${DateFormat('MMM dd, yyyy').format(a.dueDate)}',
                        style: TextStyle(
                          color: isCompleted ? Colors.grey : null,
                        ),
                      ),
                      trailing: isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    );
                  },
                );
              }),
            ),
          ),
      ],
    );
  }
}
