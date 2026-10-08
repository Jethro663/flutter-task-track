import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class WidgetTask extends StatelessWidget {
  final TaskItem task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const WidgetTask({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Checkbox(
          value: task.isFinished,
          onChanged: onToggle,
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.isFinished ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.content.isNotEmpty) ...[
              Text(task.content),
              SizedBox(height: 4),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.category,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade800),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red.shade300),
          onPressed: onDelete,
        ),
      ),
    );
  }
}