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

  /// ✅ Used by ProfilePage
  List<Assignment> getAllAssignments() {
    return [..._assignments];
  }

  /// ✅ Used by AssignmentDetailPage or swipe to update status/title/etc
  void updateAssignment(Assignment updated) {
    final index = _assignments.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _assignments[index] = updated;
      notifyListeners();
    }
  }

  /// ✅ Alternative: Update by fields (optional helper)
  void updateAssignmentByFields(
    String id, {
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _assignments[index];
      _assignments[index] = Assignment(
        id: old.id,
        courseId: old.courseId,
        title: title ?? old.title,
        description: description ?? old.description,
        dueDate: dueDate ?? old.dueDate,
        priority: priority ?? old.priority,
        status: status ?? old.status,
      );
      notifyListeners();
    }
  }
}
