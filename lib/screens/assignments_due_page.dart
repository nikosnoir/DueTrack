import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';
import 'add_assignment_page.dart';
import 'assignment_detail_page.dart';

class AssignmentsDuePage extends StatefulWidget {
  const AssignmentsDuePage({Key? key}) : super(key: key);

  @override
  State<AssignmentsDuePage> createState() => _AssignmentsDuePageState();
}

class _AssignmentsDuePageState extends State<AssignmentsDuePage> {
  TaskStatus? _selectedStatus;

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Filter by Status', style: TextStyle(fontWeight: FontWeight.bold))),
            RadioListTile<TaskStatus?>(
              title: const Text('All'),
              value: null,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<TaskStatus>(
              title: const Text('Not Started'),
              value: TaskStatus.notStarted,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<TaskStatus>(
              title: const Text('In Progress'),
              value: TaskStatus.inProgress,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<TaskStatus>(
              title: const Text('Completed'),
              value: TaskStatus.done,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.red;
      case TaskStatus.inProgress:
        return Colors.amber;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  String _statusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);

    final Map<Course, List<Assignment>> activeAssignments = {};
    final List<Assignment> completedAssignments = [];

    for (final course in provider.courses) {
      final assignments = provider.getAssignmentsForCourse(course.id);

      final filtered = assignments
          .where((a) => _selectedStatus == null || a.status == _selectedStatus)
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

      final active = filtered.where((a) => a.status != TaskStatus.done).toList();
      final completed = filtered.where((a) => a.status == TaskStatus.done).toList();

      if (active.isNotEmpty) activeAssignments[course] = active;
      completedAssignments.addAll(completed);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Due Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAssignmentPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (activeAssignments.isEmpty && completedAssignments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(child: Text('No assignments yet!')),
            ),
          ...activeAssignments.entries.map((entry) {
            final course = entry.key;
            final assignments = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: course.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ...assignments.map((assignment) {
                  final bgColor = _getStatusColor(assignment.status).withOpacity(0.1);
                  return Dismissible(
                    key: Key(assignment.id),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      final previousStatus = assignment.status;
                      final updated = assignment.copyWith(status: TaskStatus.done);
                      provider.updateAssignment(updated);

                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${assignment.title} marked as completed'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              provider.updateAssignment(
                                assignment.copyWith(status: previousStatus),
                              );
                            },
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );

                      return false; // don't remove visually
                    },
                    child: Container(
                      color: bgColor,
                      child: ListTile(
                        title: Text(assignment.title),
                        subtitle: Text(
                          'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}\n${assignment.description}',
                        ),
                        trailing: Text(
                          _statusText(assignment.status),
                          style: TextStyle(
                            color: _getStatusColor(assignment.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssignmentDetailPage(assignment: assignment),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }),

          if (completedAssignments.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Text(
                'Completed Assignments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...completedAssignments.map((assignment) {
              final course = provider.courses.firstWhere(
                (c) => c.id == assignment.courseId,
                orElse: () => Course(id: '', name: 'Unknown', color: Colors.grey),
              );
              return Container(
                color: Colors.green.withOpacity(0.1),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: course.color, radius: 6),
                  title: Text(assignment.title),
                  subtitle: Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}\n${assignment.description}',
                  ),
                  trailing: const Icon(Icons.check, color: Colors.green),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignmentDetailPage(assignment: assignment),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterBottomSheet,
        child: const Icon(Icons.filter_alt),
        tooltip: 'Filter Assignments',
      ),
    );
  }
}
