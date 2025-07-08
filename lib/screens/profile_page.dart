import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/courses_provider.dart';
import '../models/assignment.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);

    final assignments = provider.getAllAssignments();
    final total = assignments.length;
    final done = assignments.where((a) => a.status == TaskStatus.done).length;
    final percent = total == 0 ? 0.0 : done / total;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Progress Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 10.0,
            animation: true,
            percent: percent,
            center: Text("${(percent * 100).toStringAsFixed(1)}%"),
            progressColor: Colors.blue,
            backgroundColor: Colors.grey.shade300,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 20),
          Text('Completed: $done / $total tasks'),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
