import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({Key? key}) : super(key: key);

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  String? _selectedCourseId;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _dueDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = Provider.of<CoursesProvider>(context).courses;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: (courses.any((c) => c.id == _selectedCourseId))
                    ? _selectedCourseId
                    : null,
                hint: const Text('Select Course'),
                items: courses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course.id,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: course.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(course.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCourseId = value);
                },
                validator: (value) =>
                    value == null ? 'Please select a course' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _dueDate == null
                        ? 'No due date selected'
                        : 'Due: ${DateFormat('MMM dd, yyyy').format(_dueDate!)}',
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _selectDueDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _dueDate != null &&
                      _selectedCourseId != null) {
                    final assignment = Assignment(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      courseId: _selectedCourseId!,
                      title: _titleController.text,
                      description: _descController.text,
                      dueDate: _dueDate!,
                    );

                    Provider.of<CoursesProvider>(context, listen: false)
                        .addAssignment(assignment);

                    Navigator.pop(context);
                  } else if (_dueDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a due date'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
