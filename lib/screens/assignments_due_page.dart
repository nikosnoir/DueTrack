// lib/screens/assignments_due_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';
import 'add_assignment_page.dart';

class AssignmentsDuePage extends StatelessWidget {
  const AssignmentsDuePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);
    
    // Group assignments by course
    final Map<Course, List<Assignment>> courseAssignments = {};
    
    for (final course in provider.courses) {
      final assignments = provider.getAssignmentsForCourse(course.id)
        .where((a) => a.dueDate.isAfter(DateTime.now()))
        .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      
      if (assignments.isNotEmpty) {
        courseAssignments[course] = assignments;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Due Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAssignmentPage()),
            ),
          ),
        ],
      ),
      body: courseAssignments.isEmpty
          ? const Center(child: Text('No upcoming assignments!'))
          : ListView(
              children: courseAssignments.entries.map((entry) {
                final course = entry.key;
                final assignments = entry.value;
                
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: course.color.withOpacity(0.2),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: course.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              course.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...assignments.map((assignment) => ListTile(
                        title: Text(assignment.title),
                        subtitle: Text(
                          'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}\n'
                          '${assignment.description}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      )).toList(),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}