import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../providers/courses_provider.dart';

class AssignmentDetailPage extends StatefulWidget {
  final Assignment assignment;
  const AssignmentDetailPage({super.key, required this.assignment});

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _dueDate;
  late TaskStatus _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment.title);
    _descController = TextEditingController(text: widget.assignment.description);
    _dueDate = widget.assignment.dueDate;
    _status = widget.assignment.status;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text('${_dueDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() => _dueDate = picked);
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              onChanged: (value) => setState(() => _status = value!),
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_statusText(status)),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () {
                final updated = widget.assignment.copyWith(
                  title: _titleController.text,
                  description: _descController.text,
                  dueDate: _dueDate,
                  status: _status,
                );
                provider.updateAssignment(updated);
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
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
}
