// lib/models/course.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final Color color; // For course color coding

  Course({
    String? id,
    required this.name,
    this.description = '',
    this.color = Colors.blue,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color.value,
  };

  factory Course.fromMap(Map<String, dynamic> map) => Course(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    color: Color(map['color']),
  );
}