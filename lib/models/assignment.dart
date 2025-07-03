// lib/models/assignment.dart
import 'package:intl/intl.dart';

class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  
  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
  });

  String get formattedDueDate => DateFormat('MMM dd, yyyy').format(dueDate);

  Map<String, dynamic> toMap() => {
    'id': id,
    'courseId': courseId,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
  };

  factory Assignment.fromMap(Map<String, dynamic> map) => Assignment(
    id: map['id'],
    courseId: map['courseId'],
    title: map['title'],
    description: map['description'],
    dueDate: DateTime.parse(map['dueDate']),
  );
}