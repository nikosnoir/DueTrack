// lib/providers/courses_provider.dart
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/assignment.dart';

class CoursesProvider with ChangeNotifier {
  final List<Course> _courses = [];
  final List<Assignment> _assignments = [];

  List<Course> get courses => [..._courses];
  List<Assignment> get assignments => [..._assignments];

  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }

  void addAssignment(Assignment assignment) {
    _assignments.add(assignment);
    notifyListeners();
  }

  List<Assignment> getAssignmentsForCourse(String courseId) {
    return _assignments.where((a) => a.courseId == courseId).toList();
  }

  void removeCourse(String courseId) {
    _courses.removeWhere((c) => c.id == courseId);
    _assignments.removeWhere((a) => a.courseId == courseId);
    notifyListeners();
  }
}